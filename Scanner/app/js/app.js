import { config, saveConfig, isConfigured } from './config.js';
import { initAuth, currentAccount, login, logout, userLabel } from './auth.js';
import { api } from './api.js';
import { onScan, clearScanHandler, getScanHandler, beep } from './scanner.js';
import { icons } from './icons.js';

// ---------------------------------------------------------------- helpers
const $ = (sel, root = document) => root.querySelector(sel);
const view = $('#view');
const overlay = $('#overlay');

const esc = (v) => String(v ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const fmtQty = (n) => Number(n || 0).toLocaleString('da-DK', { maximumFractionDigits: 5 });
const parseQty = (s) => Number(String(s).trim().replace(/\./g, '').replace(',', '.'));

let locations = [];
let filterHandler = null;

function setHeader({ title, counter = '', back = true, filter = null }) {
  $('#title').textContent = title;
  $('#subtitle').textContent = `${userLabel()}@${config.companyName || (config.mode === 'demo' ? 'Demo' : '')}`;
  $('#counter').textContent = counter;
  $('#btn-back').hidden = !back;
  filterHandler = filter;
  $('#btn-filter').hidden = !filter;
  document.title = title;
}
$('#btn-back').onclick = () => history.back();
$('#btn-filter').onclick = () => filterHandler && filterHandler();

let toastTimer;
function toast(msg, type = '') {
  const t = $('#toast');
  t.textContent = msg;
  t.className = type;
  t.hidden = false;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { t.hidden = true; }, type === 'err' ? 5000 : 2500);
  if (type) beep(type !== 'err');
}

async function busy(fn) {
  $('#busy').hidden = false;
  try { return await fn(); } finally { $('#busy').hidden = true; }
}

function locationOptions(selected) {
  return locations.map((l) => `<option value="${esc(l.code)}" ${l.code === selected ? 'selected' : ''}>${esc(l.code)}</option>`).join('');
}

async function ensureLocations() {
  if (!locations.length) locations = await api.getLocations();
  if (!config.defaultLocation && locations.length) saveConfig({ defaultLocation: (locations.find((l) => l.binMandatory) || locations[0]).code });
}

/** Indtastningsfelt til scanning. inputmode=none skjuler skærmtastaturet; tastatur-knappen viser det. */
function scanInput(id, value = '', placeholder = 'Skan eller indtast') {
  return `<div class="row"><input id="${id}" value="${esc(value)}" inputmode="none" autocomplete="off" autocapitalize="characters" spellcheck="false" placeholder="${placeholder}">
    <button type="button" class="icon-btn kbd" data-for="${id}" aria-label="Tastatur">${icons.keyboard}</button></div>`;
}
document.addEventListener('click', (e) => {
  const k = e.target.closest('.kbd');
  if (!k) return;
  const inp = document.getElementById(k.dataset.for);
  inp.setAttribute('inputmode', inp.getAttribute('inputmode') === 'none' ? 'text' : 'none');
  inp.blur(); setTimeout(() => inp.focus(), 30);
});

function onEnter(input, fn) {
  input.addEventListener('keydown', (e) => { if (e.key === 'Enter') { e.preventDefault(); fn(input.value.trim()); } });
}

// ---------------------------------------------------------------- router
const screens = {};
let current = null;

function go(name, params = {}, replace = false) {
  const st = { name, params };
  if (replace) history.replaceState(st, ''); else history.pushState(st, '');
  render(st);
}

function render(st) {
  closeOverlay(true);
  clearScanHandler();
  current = st;
  view.innerHTML = '';
  view.scrollTop = 0;
  Promise.resolve(screens[st.name](st.params || {})).catch(showError);
}

let skipPop = 0;
window.addEventListener('popstate', (e) => {
  if (skipPop > 0) { skipPop--; return; }
  if (!overlay.hidden) { closeOverlay(false); return; }
  if (!e.state || e.state.name === 'boot') { go('menu', {}, true); return; }
  render(e.state);
});

function showError(e) {
  console.error(e);
  toast(e.message || String(e), 'err');
}

// ---------------------------------------------------------------- wizard (trin-for-trin dialog)
let wizardClose = null;
let prevScanHandler = null;
function closeOverlay(silent) {
  if (overlay.hidden) return;
  overlay.hidden = true;
  overlay.innerHTML = '';
  onScan(prevScanHandler);
  if (wizardClose) { const f = wizardClose; wizardClose = null; if (!silent) f(); }
}

/**
 * steps: [{ key, title, kind: 'scan'|'qty', hint(ctx), defaultValue(ctx), validate: async (value, ctx) => errorText|null }]
 */
function wizard({ summary, steps, ctx = {}, onDone, onCancel }) {
  let idx = 0;
  let error = '';
  history.pushState(current, '');
  prevScanHandler = getScanHandler();
  overlay.hidden = false;
  wizardClose = () => { onCancel && onCancel(); };

  const draw = () => {
    const st = steps[idx];
    const last = idx === steps.length - 1;
    const has = ctx[st.key] !== undefined && ctx[st.key] !== '';
    const val = has ? ctx[st.key] : (st.defaultValue ? st.defaultValue(ctx) : '');
    const input = st.kind === 'qty'
      ? `<div class="field"><label>Antal:</label><input id="wz-in" value="${esc(val === '' ? '' : fmtQty(val))}" inputmode="decimal" autocomplete="off"></div>`
      : `<div class="scanprompt">${icons.scan}<span>Skan for at sætte værdien</span></div><div class="field">${scanInput('wz-in', val)}</div>`;
    overlay.innerHTML = `
      ${summary ? `<div class="summary">${summary}</div>` : ''}
      <div class="sheet">
        <div class="step-head ${error ? 'err' : ''}"><span>${esc(st.title(ctx))}</span><button id="wz-x" aria-label="Luk">✕</button></div>
        <div class="step-body">
          ${input}
          ${st.hint ? `<div class="hint">${st.hint(ctx)}</div>` : ''}
          ${error ? `<div class="error-text">${esc(error)}</div>` : ''}
        </div>
        <div class="step-nav">
          <button class="btn" id="wz-prev" ${idx === 0 ? 'disabled' : ''}>‹</button>
          <div class="dots">${steps.map((_, i) => `<span class="${i === idx ? 'on' : ''}"></span>`).join('')}</div>
          <button class="btn ${last ? 'ok' : ''}" id="wz-next">${last ? '✓' : '›'}</button>
        </div>
      </div>`;
    const inp = $('#wz-in', overlay);
    setTimeout(() => { inp.focus(); inp.select(); }, 30);
    onEnter(inp, () => next());
    $('#wz-x', overlay).onclick = () => { closeOverlay(); skipPop++; history.back(); };
    $('#wz-prev', overlay).onclick = () => { ctx[st.key] = readValue(); error = ''; idx--; draw(); };
    $('#wz-next', overlay).onclick = () => next();
    // Scanning når feltet ikke har fokus
    onScan((code) => { inp.value = code; next(); });
  };

  const readValue = () => {
    const st = steps[idx];
    const raw = $('#wz-in', overlay).value.trim();
    if (raw === '' && st.fallback) return st.fallback(ctx) || '';
    return st.kind === 'qty' ? (raw === '' ? '' : parseQty(raw)) : raw.toUpperCase();
  };

  const next = async () => {
    const st = steps[idx];
    const value = readValue();
    let err = null;
    if (value === '' || value === null) err = 'Værdien må ikke være tom.';
    else if (st.kind === 'qty' && (!(value > 0) || Number.isNaN(value))) err = 'Antal skal være større end 0.';
    else if (st.validate) {
      try { err = await busy(() => st.validate(value, ctx)); } catch (e) { err = e.message; }
    }
    if (err) { error = err; beep(false); ctx[st.key] = value; draw(); return; }
    ctx[st.key] = value;
    error = '';
    if (idx < steps.length - 1) { idx++; beep(true); draw(); return; }
    try {
      await busy(() => onDone(ctx));
      wizardClose = null;
      closeOverlay(true);
      skipPop++;
      history.back();
    } catch (e) {
      error = e.message; beep(false); draw();
    }
  };
  draw();
}

// ---------------------------------------------------------------- MENU
const menuItems = [
  { key: 'receive', label: 'Modtag' },
  { key: 'putaway', label: 'Læg På Lager' },
  { key: 'pick', label: 'Pluk', route: 'picks' },
  { key: 'count', label: 'Optælling' },
  { key: 'move', label: 'Flyt' },
  { key: 'unplannedCount', label: 'Uplanlagt Optælling' },
  { key: 'unplannedMove', label: 'Uplanlagt Flyt', route: 'move' },
  { key: 'binContent', label: 'Placeringsindhold' },
  { key: 'itemRef', label: 'Varereference' },
  { key: 'substitute', label: 'Erstatningsvare' },
  { key: 'findItem', label: 'Find Vare', route: 'find' },
  { key: 'bulkMove', label: 'Bulk Flyt' },
  { key: 'changeDefault', label: 'Skift standardplacering' },
  { key: 'settings', label: 'Indstillinger', route: 'settings' },
];

screens.menu = async () => {
  setHeader({ title: 'Mobile WMS', back: false });
  view.innerHTML = `<div class="menu-grid">${menuItems.map((m) => `
    <button class="tile ${m.route ? '' : 'disabled'}" data-key="${m.key}">${icons[m.key]}<span>${esc(m.label)}</span></button>`).join('')}</div>`;
  view.querySelectorAll('.tile').forEach((b) => {
    b.onclick = () => {
      const m = menuItems.find((x) => x.key === b.dataset.key);
      if (m.route) go(m.route); else toast(`"${m.label}" kommer i en senere version.`);
    };
  });
};

// ---------------------------------------------------------------- FIND VARE
screens.find = async (params) => {
  setHeader({ title: 'Find vare', counter: '0/0' });
  await ensureLocations();
  const loc = params.location || config.defaultLocation;
  view.innerHTML = `
    <div class="form">
      <div class="field"><label>Lokation:</label><select id="f-loc"><option value="">Alle</option>${locationOptions(loc)}</select></div>
      <div class="field"><label>Vare:</label><div class="row" style="gap:0">${scanInput('f-item', params.item || '')}<button class="icon-btn" id="f-go" aria-label="Søg">${icons.search}</button></div></div>
      <div class="actions"><button class="btn" id="f-reset">Nulstil</button><button class="btn" id="f-ok">Accepter</button></div>
    </div>
    <div class="list" id="f-list"></div>`;
  const inp = $('#f-item');
  const list = $('#f-list');
  const search = async (code) => {
    code = (code ?? inp.value).trim();
    if (!code) { inp.focus(); return; }
    inp.value = code;
    const location = $('#f-loc').value;
    history.replaceState({ name: 'find', params: { item: code, location } }, '');
    const item = await busy(() => api.resolveItem(code));
    if (!item) { list.innerHTML = ''; setHeader({ title: 'Find vare', counter: '0/0' }); toast(`Vare "${code}" blev ikke fundet.`, 'err'); return; }
    const bins = (await busy(() => api.getBinContents(location, item.no))).filter((b) => b.quantity !== 0 || b.isDefault);
    bins.sort((a, b) => (b.isDefault - a.isDefault) || a.binCode.localeCompare(b.binCode));
    const withQty = bins.filter((b) => b.quantity > 0).length;
    setHeader({ title: 'Find vare', counter: `${withQty}/${bins.length}` });
    beep(true);
    list.innerHTML = bins.length ? bins.map((b) => `
      <div class="card">
        <div class="head"><span>${esc(b.binCode)}${b.isDefault ? ' ★' : ''}</span><span>${fmtQty(b.available)}/${fmtQty(b.quantity)}</span></div>
        <div class="sub">${esc(item.no)}${b.variantCode ? ' · ' + esc(b.variantCode) : ''}</div>
        <div class="sub">${esc(item.description)}</div>
        <div class="sub">${esc(item.description2)}</div>
        <div class="sub">${esc(item.vendorName)}</div>
        <div class="sub">Enhed: ${esc(b.uom)}${location ? '' : ' · Lokation: ' + esc(b.locationCode)}</div>
      </div>`).join('') : `<div class="empty">Ingen beholdning på placeringer for ${esc(item.no)}.</div>`;
    inp.select();
  };
  onEnter(inp, (v) => search(v).catch(showError));
  $('#f-go').onclick = () => search().catch(showError);
  $('#f-ok').onclick = () => search().catch(showError);
  $('#f-reset').onclick = () => { inp.value = ''; list.innerHTML = ''; setHeader({ title: 'Find vare', counter: '0/0' }); inp.focus(); };
  onScan((code) => search(code).catch(showError));
  if (params.item) await search(params.item); else inp.focus();
};

// ---------------------------------------------------------------- UPLANLAGT FLYT
let movedCount = 0;
screens.move = async (params) => {
  setHeader({ title: 'Uplanlagt flyt', counter: String(movedCount) });
  await ensureLocations();
  const from = params.from || config.defaultLocation;
  const to = params.to || from;
  view.innerHTML = `
    <div class="form">
      <div class="field"><label>Lokation:</label><select id="m-from">${locationOptions(from)}</select></div>
      <div class="field"><label>Ny lokation:</label><select id="m-to">${locationOptions(to)}</select></div>
      <div class="field"><label>Vare:</label>${scanInput('m-item')}</div>
      <div class="actions"><button class="btn" id="m-reset">Nulstil</button><button class="btn" id="m-ok">Accepter</button></div>
    </div>
    <div id="m-msg"></div>`;
  const inp = $('#m-item');
  const msg = $('#m-msg');
  const showMsg = (text, ok = true) => { msg.innerHTML = `<div class="msg ${ok ? 'ok' : 'err'}"><span class="dot">${ok ? '✓' : '!'}</span><span>${esc(text)}</span></div>`; };
  const keepLocs = () => history.replaceState({ name: 'move', params: { from: $('#m-from').value, to: $('#m-to').value } }, '');
  $('#m-from').onchange = () => { $('#m-to').value = $('#m-from').value; keepLocs(); };
  $('#m-to').onchange = keepLocs;

  const start = async (code) => {
    code = (code ?? inp.value).trim();
    if (!code) { inp.focus(); return; }
    const fromLoc = $('#m-from').value;
    const toLoc = $('#m-to').value;
    const item = await busy(() => api.resolveItem(code));
    if (!item) { showMsg(`Vare "${code}" blev ikke fundet.`, false); beep(false); inp.select(); return; }
    beep(true);
    const bins = await busy(() => api.getBinContents(fromLoc, item.no));
    const def = bins.find((b) => b.isDefault) || bins.find((b) => b.quantity > 0);
    const findBin = (code) => bins.find((b) => b.binCode === code);
    const ctx = { fromBin: '', quantity: '', toBin: '' };
    msg.innerHTML = '';
    wizard({
      ctx,
      summary: `<div><b>Lokation:</b>${esc(fromLoc)}</div><div><b>Ny lokation:</b>${esc(toLoc)}</div><div><b>Vare:</b>${esc(item.no)} ${esc(item.description2 || item.description)}</div>`,
      steps: [
        {
          key: 'fromBin', kind: 'scan',
          title: () => `Vare ${item.no} - Vælg placering`,
          fallback: () => (def ? def.binCode : ''),
          hint: () => (def ? `Standard: ${esc(def.binCode)}` : 'Varen har ingen beholdning på lokationen.'),
          validate: async (v) => {
            const b = findBin(v);
            if (!b || b.quantity <= 0) return `Vare ${item.no} findes ikke på placering ${v}.`;
            return null;
          },
        },
        {
          key: 'quantity', kind: 'qty',
          title: () => `Vare ${item.no} - Angiv antal`,
          defaultValue: () => 1,
          hint: (c) => { const b = findBin(c.fromBin); return `Enhed: ${esc(b ? b.uom : item.baseUom)}${b ? `<br>Tilgængelig på ${esc(b.binCode)}: ${fmtQty(b.available)}` : ''}`; },
          validate: async (v, c) => {
            const b = findBin(c.fromBin);
            if (b && v > b.available) return `Der er kun ${fmtQty(b.available)} ${b.uom} tilgængelig på ${b.binCode}.`;
            return null;
          },
        },
        {
          key: 'toBin', kind: 'scan',
          title: () => `Vare ${item.no} - Skan til-placering`,
          validate: async (v, c) => (fromLoc === toLoc && v === c.fromBin ? 'Til-placering må ikke være den samme som fra-placering.' : null),
        },
      ],
      onDone: async (c) => {
        const b = findBin(c.fromBin);
        await api.postUnplannedMove({ itemNo: item.no, variantCode: b?.variantCode, uom: b?.uom, quantity: c.quantity, fromLocation: fromLoc, fromBin: c.fromBin, toLocation: toLoc, toBin: c.toBin });
        movedCount++;
        setHeader({ title: 'Uplanlagt flyt', counter: String(movedCount) });
        showMsg(`Uplanlagt flyt for vare ${item.no} er registreret.`);
        beep(true);
        inp.value = '';
        setTimeout(() => inp.focus(), 50);
      },
      onCancel: () => setTimeout(() => inp.focus(), 50),
    });
  };
  onEnter(inp, (v) => start(v).catch(showError));
  $('#m-ok').onclick = () => start().catch(showError);
  $('#m-reset').onclick = () => { inp.value = ''; msg.innerHTML = ''; $('#m-from').value = config.defaultLocation; $('#m-to').value = config.defaultLocation; keepLocs(); inp.focus(); };
  onScan((code) => { inp.value = code; start(code).catch(showError); });
  inp.focus();
};

// ---------------------------------------------------------------- PLUK (liste)
const ASSIGN = { mineUnassigned: 'Mine & uallokerede', all: 'Alle', mine: 'Kun mine ordrer' };
const pickFilter = { location: null, assigned: 'mineUnassigned', open: false };

screens.picks = async () => {
  await ensureLocations();
  if (pickFilter.location === null) pickFilter.location = config.defaultLocation;
  let all = [];
  const draw = () => {
    const rows = all.filter((p) => pickFilter.assigned === 'all'
      || (pickFilter.assigned === 'mine' && p.assignedToMe)
      || (pickFilter.assigned === 'mineUnassigned' && (p.assignedToMe || !p.assignedUserId)));
    setHeader({ title: 'Plukordrer', counter: `${rows.length ? 1 : 0}/${rows.length}`, filter: () => { pickFilter.open = !pickFilter.open; draw(); } });
    view.innerHTML = `
      ${pickFilter.open ? `<div class="form">
        <div class="field"><label>Lokation:</label><select id="p-loc"><option value="">Alle</option>${locationOptions(pickFilter.location)}</select></div>
        <div class="field"><label>Tildelt bruger-id:</label><select id="p-ass">${Object.entries(ASSIGN).map(([k, v]) => `<option value="${k}" ${k === pickFilter.assigned ? 'selected' : ''}>${v}</option>`).join('')}</select></div>
        <div class="actions"><button class="btn" id="p-reset">Nulstil</button><button class="btn" id="p-apply">Anvend</button></div>
      </div>` : ''}
      <div class="list">${rows.length ? rows.map((p) => `
        <div class="card" data-no="${esc(p.no)}">
          <div class="head"><span>${esc(p.no)}</span></div>
          <div class="sub">Antal linier: ${p.lines}</div>
          <div class="sub">Type: ${esc(p.documentType)}</div>
          <div class="sub">Dokument: ${esc(p.documentNo)}</div>
          <div class="sub">${esc(p.destination)}</div>
          ${p.assignedUserId && !p.assignedToMe ? icons.lock : ''}
        </div>`).join('') : '<div class="empty">Ingen plukordrer.</div>'}</div>
      <button class="fab" id="p-refresh"><span class="circle"><svg viewBox="0 0 24 24"><path d="M5 7h14M5 12h14M5 17h14"/></svg></span>Opdater</button>`;
    view.querySelectorAll('.card').forEach((c) => {
      c.onclick = () => {
        const p = all.find((x) => x.no === c.dataset.no);
        if (p.assignedUserId && !p.assignedToMe && !confirm(`${p.no} er tildelt ${p.assignedUserId}. Vil du åbne den alligevel?`)) return;
        go('pick', { no: p.no });
      };
    });
    $('#p-refresh').onclick = () => load().catch(showError);
    if (pickFilter.open) {
      $('#p-reset').onclick = () => { pickFilter.location = config.defaultLocation; pickFilter.assigned = 'mineUnassigned'; pickFilter.open = false; load().catch(showError); };
      $('#p-apply').onclick = () => { pickFilter.location = $('#p-loc').value; pickFilter.assigned = $('#p-ass').value; pickFilter.open = false; load().catch(showError); };
    }
  };
  const load = async () => { all = await busy(() => api.getPicks(pickFilter.location)); draw(); };
  // Skan et pluknr. eller leverancenr. for at åbne det direkte
  onScan((code) => {
    const p = all.find((x) => x.no === code.toUpperCase() || x.documentNo === code.toUpperCase());
    if (p) go('pick', { no: p.no }); else toast(`Plukordre "${code}" blev ikke fundet i listen.`, 'err');
  });
  await load();
};

// ---------------------------------------------------------------- PLUK (linjer)
const pickKey = (no) => `jkf-pick-${config.mode}-${config.companyId}-${no}`;
function loadPicked(no) { try { return JSON.parse(localStorage.getItem(pickKey(no)) || '{}'); } catch { return {}; } }
function savePicked(no, data) { try { localStorage.setItem(pickKey(no), JSON.stringify(data)); } catch { /* ignore */ } }

screens.pick = async ({ no }) => {
  const lines = await busy(() => api.getPickLines(no));
  lines.sort((a, b) => a.binCode.localeCompare(b.binCode) || a.lineNo - b.lineNo);
  let picked = loadPicked(no);
  // Fjern gemte linjer der ikke længere findes
  for (const k of Object.keys(picked)) if (!lines.some((l) => String(l.lineNo) === k)) delete picked[k];

  const draw = () => {
    const done = lines.filter((l) => (picked[l.lineNo]?.qty || 0) >= l.outstanding).length;
    setHeader({ title: no, counter: `${done}/${lines.length}` });
    const any = Object.values(picked).some((p) => p.qty > 0);
    view.innerHTML = `
      <div class="list">${lines.length ? lines.map((l) => {
        const q = picked[l.lineNo]?.qty || 0;
        const cls = q >= l.outstanding ? 'done' : q > 0 ? 'partial' : '';
        return `<div class="card ${cls}" data-line="${l.lineNo}">
          <div class="head"><span>${esc(l.binCode || '(ingen placering)')}</span><span>${fmtQty(q)}/${fmtQty(l.outstanding)}</span></div>
          <div class="sub"><b>${esc(l.itemNo)}</b>${l.variantCode ? ' · ' + esc(l.variantCode) : ''}</div>
          <div class="sub">${esc(l.description)}</div>
          <div class="sub">${esc(l.description2 || '')}</div>
          <div class="sub">Enhed: ${esc(l.uom)}${l.lotNo ? ' · Lot: ' + esc(l.lotNo) : ''}${l.serialNo ? ' · Serie: ' + esc(l.serialNo) : ''}</div>
        </div>`;
      }).join('') : '<div class="empty">Ingen åbne linjer på plukket.</div>'}</div>
      <div class="bottombar"><button class="btn wide ok" id="pk-reg" ${any ? '' : 'disabled'}>Registrer pluk</button></div>`;
    view.querySelectorAll('.card').forEach((c) => { c.onclick = () => pickLine(lines.find((l) => String(l.lineNo) === c.dataset.line)); });
    $('#pk-reg').onclick = () => register().catch(showError);
  };

  const pickLine = (l, prefill = {}) => {
    const ctx = { bin: prefill.bin || '', item: prefill.item || '', quantity: '' };
    const already = picked[l.lineNo]?.qty || 0;
    const steps = [];
    if (l.binCode) steps.push({
      key: 'bin', kind: 'scan', title: () => `Linje ${l.lineNo / 10000 | 0} - Skan placering`,
      hint: () => `Placering: <b>${esc(l.binCode)}</b>`,
      validate: async (v) => (v === l.binCode ? null : `Forkert placering. Forventet ${l.binCode}.`),
    });
    steps.push({
      key: 'item', kind: 'scan', title: () => `Placering ${l.binCode} - Skan vare`,
      hint: () => `Vare: <b>${esc(l.itemNo)}</b><br>${esc(l.description)}`,
      validate: async (v) => {
        if (v === l.itemNo) return null;
        const it = await api.resolveItem(v);
        return it && it.no === l.itemNo ? null : `Forkert vare. Forventet ${l.itemNo}.`;
      },
    });
    steps.push({
      key: 'quantity', kind: 'qty', title: () => `Vare ${l.itemNo} - Angiv antal`,
      defaultValue: () => Math.max(l.outstanding - already, 0) || '',
      hint: () => `Enhed: ${esc(l.uom)}<br>Mangler: ${fmtQty(l.outstanding - already)} af ${fmtQty(l.outstanding)}`,
      validate: async (v) => (already + v > l.outstanding ? `Du kan højst plukke ${fmtQty(l.outstanding - already)} mere.` : null),
    });
    // Spring trin over, der allerede er udfyldt via scanning i listen
    if (ctx.bin === l.binCode && steps[0].key === 'bin') steps.shift();
    if (ctx.item && steps[0].key === 'item') steps.shift();
    wizard({
      ctx,
      summary: `<div><b>Pluk:</b>${esc(no)}</div><div><b>Placering:</b>${esc(l.binCode)}</div><div><b>Vare:</b>${esc(l.itemNo)}</div>`,
      steps,
      onDone: async (c) => {
        picked[l.lineNo] = { qty: already + c.quantity, bin: l.binCode };
        savePicked(no, picked);
        setTimeout(draw, 0);
        toast(`Linje plukket: ${fmtQty(c.quantity)} × ${l.itemNo}`, 'ok');
      },
    });
  };

  const attachScan = () => onScan(async (code) => {
    code = code.toUpperCase();
    const open = lines.filter((l) => (picked[l.lineNo]?.qty || 0) < l.outstanding);
    let l = open.find((x) => x.binCode === code);
    if (l) return pickLine(l, { bin: code });
    l = open.find((x) => x.itemNo === code);
    if (!l) {
      const it = await busy(() => api.resolveItem(code)).catch(() => null);
      if (it) l = open.find((x) => x.itemNo === it.no);
    }
    if (l) return pickLine(l, { bin: l.binCode, item: code });
    toast(`"${code}" passer ikke til nogen åben linje.`, 'err');
  });

  const register = async () => {
    const list = Object.entries(picked).filter(([, p]) => p.qty > 0).map(([lineNo, p]) => ({ lineNo: Number(lineNo), quantity: p.qty, binCode: p.bin }));
    if (!list.length) return;
    const total = list.length;
    if (!confirm(`Registrer ${total} linje(r) på ${no}?`)) return;
    await busy(() => api.registerPick(no, list));
    localStorage.removeItem(pickKey(no));
    toast(`Pluk ${no} er registreret.`, 'ok');
    history.back();
  };

  attachScan();
  draw();
};

// ---------------------------------------------------------------- INDSTILLINGER
screens.settings = async () => {
  setHeader({ title: 'Indstillinger' });
  const acc = currentAccount();
  view.innerHTML = `
    <div class="settings">
      <h3>Forbindelse</h3>
      <div class="form">
        <div class="field"><label>Tilstand:</label><select id="s-mode">
          <option value="demo" ${config.mode === 'demo' ? 'selected' : ''}>Demo (testdata, ingen BC)</option>
          <option value="bc" ${config.mode === 'bc' ? 'selected' : ''}>Business Central</option></select></div>
        <div id="s-bc" ${config.mode === 'bc' ? '' : 'hidden'}>
          <div class="field"><label>Tenant (id eller domæne):</label><input id="s-tenant" value="${esc(config.tenantId)}" autocomplete="off"></div>
          <div class="field"><label>Miljø:</label><input id="s-env" value="${esc(config.environment)}" autocomplete="off"></div>
          <div class="field"><label>Klient-id (Entra app):</label><input id="s-client" value="${esc(config.clientId)}" autocomplete="off"></div>
          <label class="check"><input type="checkbox" id="s-proxy" ${config.useProxy ? 'checked' : ''}> Brug proxy (/bc på samme server)</label>
          <div class="small">Logget ind som: ${acc ? esc(acc.username) : '<i>ikke logget ind</i>'}</div>
          <div class="actions">${acc ? '<button class="btn" id="s-logout">Log ud</button>' : ''}<button class="btn" id="s-login">${acc ? 'Skift bruger' : 'Log ind'}</button></div>
        </div>
      </div>
      <h3>Regnskab og lokation</h3>
      <div class="form">
        <div class="field"><label>Regnskab:</label><div class="row"><select id="s-company"><option value="${esc(config.companyId)}">${esc(config.companyName || '(vælg)')}</option></select>
          <button class="btn" id="s-load">Hent</button></div></div>
        <div class="field"><label>Standardlokation:</label><select id="s-loc"><option value="">(ingen)</option>${locationOptions(config.defaultLocation)}</select></div>
        <div class="actions"><button class="btn" id="s-save">Gem</button></div>
      </div>
      <div class="small">Enhed: ${esc(config.deviceId)} · Version 1.0.1</div>
    </div>`;

  const persistConn = () => {
    const mode = $('#s-mode').value;
    const changed = mode !== config.mode || ($('#s-tenant').value.trim() !== config.tenantId) || ($('#s-client').value.trim() !== config.clientId);
    saveConfig({ mode, tenantId: $('#s-tenant').value.trim(), environment: $('#s-env').value.trim() || 'Production', clientId: $('#s-client').value.trim(), useProxy: $('#s-proxy').checked });
    if (changed) { locations = []; saveConfig({ companyId: '', companyName: '', defaultLocation: '' }); }
    return changed;
  };
  $('#s-mode').onchange = () => { $('#s-bc').hidden = $('#s-mode').value !== 'bc'; };
  if ($('#s-login')) $('#s-login').onclick = async () => { persistConn(); try { await initAuth(); await login(); } catch (e) { showError(e); } };
  if ($('#s-logout')) $('#s-logout').onclick = () => logout().catch(showError);
  $('#s-load').onclick = async () => {
    const changed = persistConn();
    if (changed && config.mode === 'bc') { location.reload(); return; }
    try {
      const companies = await busy(() => api.getCompanies());
      $('#s-company').innerHTML = companies.map((c) => `<option value="${esc(c.id)}" ${c.id === config.companyId ? 'selected' : ''}>${esc(c.name)}</option>`).join('');
      toast(`${companies.length} regnskab(er) hentet.`, 'ok');
    } catch (e) { showError(e); }
  };
  $('#s-company').onchange = async () => {
    const opt = $('#s-company').selectedOptions[0];
    saveConfig({ companyId: opt.value, companyName: opt.textContent });
    locations = [];
    try { await busy(ensureLocations); $('#s-loc').innerHTML = `<option value="">(ingen)</option>${locationOptions(config.defaultLocation)}`; } catch (e) { showError(e); }
  };
  $('#s-save').onclick = () => {
    const changed = persistConn();
    const opt = $('#s-company').selectedOptions[0];
    if (opt && opt.value) saveConfig({ companyId: opt.value, companyName: opt.textContent });
    saveConfig({ defaultLocation: $('#s-loc').value });
    if (changed) { location.reload(); return; }
    toast('Indstillinger gemt.', 'ok');
    history.back();
  };
};

// ---------------------------------------------------------------- LOGIN-skærm
screens.login = async () => {
  setHeader({ title: 'Log ind', back: false });
  view.innerHTML = `
    <div class="form" style="padding:20px 14px">
      <p>Log ind med din JKF Microsoft-konto (samme som i Business Central).</p>
      <button class="btn wide" id="l-in">Log ind</button>
      <p></p>
      <button class="btn wide" id="l-set" style="background:#4b587a">Indstillinger</button>
    </div>`;
  $('#l-in').onclick = () => login().catch(showError);
  $('#l-set').onclick = () => go('settings');
};

// ---------------------------------------------------------------- opstart
async function boot() {
  history.replaceState({ name: 'boot' }, '');
  if (config.mode === 'demo' && !config.companyName) saveConfig({ companyId: 'demo', companyName: 'JKF DK Prod (demo)' });
  try { await initAuth(); } catch (e) { showError(e); }
  if (!isConfigured()) return go('settings');
  if (config.mode === 'bc' && !currentAccount()) return go('login');
  if (config.mode === 'bc' && !config.companyId) return go('settings');
  go('menu');
}

if ('serviceWorker' in navigator && (location.protocol === 'https:' || location.hostname === 'localhost')) {
  navigator.serviceWorker.register('sw.js').catch(() => {});
}
boot();
