// Demo-data, så appen kan afprøves uden Business Central.
// Data nulstilles når siden genindlæses.

const wait = (ms = 250) => new Promise((r) => setTimeout(r, ms));

const items = {
  '1170132': { no: '1170132', description: 'Bøjning galvaniseret presset', description2: 'ø 80 x 1,00 30° f.lyn', vendorName: 'NEU-JKF Nordic A/S', baseUom: 'PCS' },
  '1170140': { no: '1170140', description: 'Bøjning galvaniseret presset', description2: 'ø 100 x 1,00 45° f.lyn', vendorName: 'NEU-JKF Nordic A/S', baseUom: 'PCS' },
  '2200100': { no: '2200100', description: 'Spiralrør galvaniseret', description2: 'ø 100 x 3000 mm', vendorName: 'NEU-JKF Nordic A/S', baseUom: 'PCS' },
  '3300050': { no: '3300050', description: 'Spjæld manuel', description2: 'ø 125', vendorName: 'NEU-JKF Nordic A/S', baseUom: 'PCS' },
};
const references = { '5701234567890': '1170132', '5701234567906': '2200100' };

const binContents = [
  { locationCode: 'JKF', binCode: '10-07-138-B2', itemNo: '1170132', uom: 'PCS', quantity: 90, isDefault: true },
  { locationCode: 'JKF', binCode: '10-07-139-A5', itemNo: '1170132', uom: 'PCS', quantity: 249, isDefault: false },
  { locationCode: 'JKF', binCode: '10-07-140-A1', itemNo: '1170140', uom: 'PCS', quantity: 40, isDefault: true },
  { locationCode: 'JKF', binCode: '12-01-010-A1', itemNo: '2200100', uom: 'PCS', quantity: 120, isDefault: true },
  { locationCode: 'JKF', binCode: '14-02-003-C1', itemNo: '3300050', uom: 'PCS', quantity: 18, isDefault: true },
];

const picks = [
  { no: 'PL054001', locationCode: 'JKF', assignedUserId: '', documentType: 'Leverance', documentNo: 'LL046524', destination: 'LAJAC AB',
    lines: [{ lineNo: 10000, itemNo: '1170132', binCode: '10-07-138-B2', outstanding: 12 }] },
  { no: 'PL054002', locationCode: 'JKF', assignedUserId: 'DEMO', documentType: 'Leverance', documentNo: 'LL046523', destination: 'LAJAC AB',
    lines: [{ lineNo: 10000, itemNo: '2200100', binCode: '12-01-010-A1', outstanding: 6 }, { lineNo: 30000, itemNo: '3300050', binCode: '14-02-003-C1', outstanding: 2 }] },
  { no: 'PL054004', locationCode: 'JKF', assignedUserId: 'PETER', documentType: 'Leverance', documentNo: 'LL046517', destination: 'LAJAC AB',
    lines: [{ lineNo: 10000, itemNo: '1170140', binCode: '10-07-140-A1', outstanding: 10 }] },
  { no: 'PL054023', locationCode: 'JKF', assignedUserId: '', documentType: 'Leverance', documentNo: 'LL045741', destination: 'Bühler AG',
    lines: [
      { lineNo: 10000, itemNo: '1170132', binCode: '10-07-139-A5', outstanding: 25 },
      { lineNo: 30000, itemNo: '1170140', binCode: '10-07-140-A1', outstanding: 4 },
      { lineNo: 50000, itemNo: '2200100', binCode: '12-01-010-A1', outstanding: 8 },
    ] },
  { no: 'PL054043', locationCode: 'JKF', assignedUserId: '', documentType: 'Leverance', documentNo: 'LL046530', destination: 'Bühler AG',
    lines: [{ lineNo: 10000, itemNo: '3300050', binCode: '14-02-003-C1', outstanding: 6 }] },
];

function enrich(bc) {
  const i = items[bc.itemNo] || {};
  return { ...bc, available: bc.quantity, description: i.description, description2: i.description2, vendorName: i.vendorName };
}

export const demo = {
  async getCompanies() { await wait(); return [{ id: 'demo', name: 'JKF DK Prod (demo)' }]; },

  async getLocations() {
    await wait(100);
    return [{ code: 'JKF', name: 'JKF Hovedlager', binMandatory: true, directed: false }, { code: 'JKF-SE', name: 'JKF Sverige', binMandatory: true, directed: false }];
  },

  async resolveItem(code) {
    await wait();
    code = code.trim();
    const no = items[code.toUpperCase()] ? code.toUpperCase() : references[code];
    return no ? { ...items[no] } : null;
  },

  async getBinContents(locationCode, itemNo) {
    await wait();
    return binContents.filter((b) => b.itemNo === itemNo && (!locationCode || b.locationCode === locationCode)).map(enrich);
  },

  async postUnplannedMove(m) {
    await wait(400);
    const from = binContents.find((b) => b.locationCode === m.fromLocation && b.binCode === m.fromBin && b.itemNo === m.itemNo);
    if (!from) throw new Error(`Vare ${m.itemNo} findes ikke på placering ${m.fromBin}.`);
    if (from.quantity < m.quantity) throw new Error(`Der er kun ${from.quantity} ${from.uom} på placering ${m.fromBin}.`);
    if (m.fromLocation === m.toLocation && m.fromBin === m.toBin) throw new Error(`Fra- og til-placering er den samme (${m.fromBin}).`);
    from.quantity -= m.quantity;
    let to = binContents.find((b) => b.locationCode === m.toLocation && b.binCode === m.toBin && b.itemNo === m.itemNo);
    if (!to) { to = { locationCode: m.toLocation, binCode: m.toBin, itemNo: m.itemNo, uom: from.uom, quantity: 0, isDefault: false }; binContents.push(to); }
    to.quantity += m.quantity;
    return { status: 'Processed', documentNumber: 'SCN' + Date.now().toString().slice(-6) };
  },

  async getPicks(locationCode) {
    await wait();
    return picks
      .filter((p) => p.lines.some((l) => l.outstanding > 0) && (!locationCode || p.locationCode === locationCode))
      .map((p) => ({ no: p.no, locationCode: p.locationCode, assignedUserId: p.assignedUserId, assignedToMe: p.assignedUserId === 'DEMO',
        lines: p.lines.filter((l) => l.outstanding > 0).length, documentType: p.documentType, documentNo: p.documentNo, destination: p.destination }));
  },

  async getPickLines(pickNo) {
    await wait();
    const p = picks.find((x) => x.no === pickNo);
    if (!p) throw new Error(`Pluk ${pickNo} findes ikke.`);
    return p.lines.filter((l) => l.outstanding > 0).map((l) => {
      const i = items[l.itemNo];
      return { ...l, description: i.description, description2: i.description2, quantity: l.outstanding, uom: i.baseUom, sourceNo: 'SO' + p.documentNo.slice(2) };
    });
  },

  async registerPick(pickNo, picked) {
    await wait(600);
    const p = picks.find((x) => x.no === pickNo);
    if (!picked.length) throw new Error(`Der er intet at registrere på pluk ${pickNo}.`);
    for (const x of picked) {
      const l = p.lines.find((y) => y.lineNo === x.lineNo);
      if (x.quantity > l.outstanding) throw new Error(`Du kan højst plukke ${l.outstanding} af vare ${l.itemNo}.`);
    }
    for (const x of picked) {
      const l = p.lines.find((y) => y.lineNo === x.lineNo);
      l.outstanding -= x.quantity;
      const b = binContents.find((y) => y.binCode === l.binCode && y.itemNo === l.itemNo);
      if (b) b.quantity -= x.quantity;
    }
    return { status: 'Processed' };
  },
};
