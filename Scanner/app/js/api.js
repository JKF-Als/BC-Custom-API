// Al kommunikation med Business Central går gennem dette modul.
// I demo-tilstand bruges in-memory data (js/demo.js), så appen kan afprøves uden BC.
import { config } from './config.js';
import { getToken } from './auth.js';
import { demo } from './demo.js';

const API_PATH = 'api/jkf/scanner/v1.0';

function q(s) { return String(s).replace(/'/g, "''"); }

function root() {
  const host = config.useProxy ? `${location.origin}/bc` : 'https://api.businesscentral.dynamics.com';
  return `${host}/v2.0/${encodeURIComponent(config.tenantId)}/${encodeURIComponent(config.environment)}/${API_PATH}`;
}

function companyRoot() {
  if (!config.companyId) throw new Error('Vælg et regnskab under Indstillinger.');
  return `${root()}/companies(${config.companyId})`;
}

async function request(url, options = {}) {
  const token = await getToken();
  let res;
  try {
    res = await fetch(url, {
      ...options,
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'Accept-Language': 'da-DK',
        ...(options.headers || {}),
      },
    });
  } catch (e) {
    throw new Error('Ingen forbindelse til Business Central. Tjek netværket' +
      (config.useProxy ? '.' : ' (eller slå "Brug proxy" til under Indstillinger, hvis det er CORS).'));
  }
  if (!res.ok) {
    let msg = `${res.status} ${res.statusText}`;
    try {
      const body = await res.json();
      if (body && body.error && body.error.message) msg = body.error.message.replace(/\s*CorrelationId:.*$/s, '');
    } catch { /* ignore */ }
    throw new Error(msg);
  }
  if (res.status === 204) return null;
  return res.json();
}

async function getAll(path, filter, extra = '') {
  const params = [];
  if (filter) params.push('$filter=' + encodeURIComponent(filter));
  if (extra) params.push(extra);
  let url = `${companyRoot()}/${path}${params.length ? '?' + params.join('&') : ''}`;
  const out = [];
  while (url) {
    const data = await request(url);
    out.push(...data.value);
    url = data['@odata.nextLink'] || null;
  }
  return out;
}

const bc = {
  async getCompanies() {
    const data = await request(`${root()}/companies`);
    return data.value.map((c) => ({ id: c.id, name: c.name }));
  },

  async getLocations() {
    const rows = await getAll('locations', 'useAsInTransit eq false');
    return rows.map((r) => ({ code: r.code, name: r.name, binMandatory: r.binMandatory, directed: r.directedPutAwayAndPick }));
  },

  /** Find vare ud fra varenr., stregkode eller varereference. Returnerer null hvis ukendt. */
  async resolveItem(code) {
    code = code.trim();
    if (!code) return null;
    let items = await getAll('items', `number eq '${q(code.toUpperCase())}'`);
    if (!items.length) {
      const refs = await getAll('itemReferences', `referenceNumber eq '${q(code)}'`);
      if (refs.length) items = await getAll('items', `number eq '${q(refs[0].itemNumber)}'`);
    }
    if (!items.length) return null;
    const i = items[0];
    return { no: i.number, description: i.description, description2: i.description2, vendorName: i.vendorName, baseUom: i.baseUnitOfMeasure, blocked: i.blocked };
  },

  async getBinContents(locationCode, itemNo) {
    let f = `itemNumber eq '${q(itemNo)}'`;
    if (locationCode) f += ` and locationCode eq '${q(locationCode)}'`;
    const rows = await getAll('binContents', f);
    return rows.map((r) => ({
      locationCode: r.locationCode, binCode: r.binCode, itemNo: r.itemNumber, variantCode: r.variantCode,
      uom: r.unitOfMeasureCode, quantity: r.quantity, available: r.availableQuantity, isDefault: r.default,
      description: r.itemDescription, description2: r.itemDescription2, vendorName: r.vendorName,
    }));
  },

  async postUnplannedMove(m) {
    return request(`${companyRoot()}/transactions`, {
      method: 'POST',
      body: JSON.stringify({
        type: 'UnplannedMove',
        itemNumber: m.itemNo,
        variantCode: m.variantCode || '',
        unitOfMeasureCode: m.uom || '',
        quantity: m.quantity,
        locationCode: m.fromLocation,
        binCode: m.fromBin,
        newLocationCode: m.toLocation,
        newBinCode: m.toBin,
        deviceId: config.deviceId,
      }),
    });
  },

  async getPicks(locationCode) {
    const rows = await getAll('picks', locationCode ? `locationCode eq '${q(locationCode)}'` : '');
    return rows.map((r) => ({
      no: r.number, locationCode: r.locationCode, assignedUserId: r.assignedUserId, assignedToMe: r.assignedToMe,
      lines: r.numberOfLines, documentType: r.documentType, documentNo: r.documentNumber, destination: r.destinationName,
    }));
  },

  async getPickLines(pickNo) {
    const rows = await getAll('pickLines', `pickNumber eq '${q(pickNo)}'`);
    return rows
      .filter((r) => r.actionType === 'Take' && r.quantityOutstanding > 0)
      .map((r) => ({
        lineNo: r.lineNumber, itemNo: r.itemNumber, variantCode: r.variantCode, description: r.description,
        description2: r.description2, binCode: r.binCode, quantity: r.quantity, outstanding: r.quantityOutstanding,
        uom: r.unitOfMeasureCode, sourceNo: r.sourceNumber, lotNo: r.lotNumber, serialNo: r.serialNumber,
      }));
  },

  /** picked: [{lineNo, quantity, binCode}] */
  async registerPick(pickNo, picked) {
    const url = `${companyRoot()}/transactions`;
    for (const p of picked) {
      await request(url, {
        method: 'POST',
        body: JSON.stringify({
          type: 'PickLine', activityNumber: pickNo, activityLineNumber: p.lineNo,
          quantity: p.quantity, binCode: p.binCode || '', deviceId: config.deviceId,
        }),
      });
    }
    return request(url, {
      method: 'POST',
      body: JSON.stringify({ type: 'PickRegister', activityNumber: pickNo, deviceId: config.deviceId }),
    });
  },
};

export const api = new Proxy({}, {
  get(_, name) { return (config.mode === 'demo' ? demo : bc)[name]; },
});
