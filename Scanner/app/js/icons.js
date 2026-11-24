// Enkle, egne ikoner til menuen (SVG).
const s = (body) => `<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">${body}</svg>`;
const box = (x, y, c = '#8a8f99') => `<g transform="translate(${x} ${y})"><path d="M0 6l10-6 10 6v12l-10 6-10-6z" fill="${c}"/><path d="M0 6l10 6 10-6M10 12v12" stroke="#5c616b" stroke-width="1.2" fill="none"/></g>`;
const arrow = (d, c = '#3aa54a') => `<path d="${d}" fill="none" stroke="${c}" stroke-width="4" stroke-linecap="round"/>`;
const doc = (x, y, letter, c = '#fff') => `<g transform="translate(${x} ${y})"><rect width="20" height="24" rx="2" fill="${c}" stroke="#7a8090"/><text x="10" y="17" font-size="13" text-anchor="middle" font-family="Arial" font-weight="700" fill="#1f3c88">${letter}</text></g>`;

export const icons = {
  receive: s(`<circle cx="32" cy="30" r="20" fill="#3d8be0"/><path d="M18 26c6-4 10 2 16-2s8 6 12 2" stroke="#4caf50" stroke-width="5" fill="none"/>${arrow('M52 50L22 50', '#e23b32')}<path d="M22 44l-8 6 8 6z" fill="#e23b32"/>`),
  putaway: s(`${box(12, 14)}${box(30, 14, '#a7adb8')}${box(21, 28)}${arrow('M14 52c8 6 28 6 36-4', '#3aa54a')}`),
  pick: s(`<rect x="14" y="10" width="36" height="46" rx="3" fill="#fff" stroke="#7a8090" stroke-width="2"/><rect x="24" y="6" width="16" height="8" rx="2" fill="#7a8090"/><path d="M20 24h24M20 32h24M20 40h16" stroke="#1f3c88" stroke-width="3"/>`),
  count: s(`<rect x="10" y="14" width="44" height="34" rx="2" fill="none" stroke="#3d8be0" stroke-width="3"/><path d="M10 24h44M10 34h44" stroke="#7a8090" stroke-width="2"/><circle cx="22" cy="24" r="4" fill="#e23b32"/><circle cx="34" cy="34" r="4" fill="#3aa54a"/><circle cx="28" cy="24" r="4" fill="#3d8be0"/>`),
  move: s(`${doc(6, 10, 'A')}${doc(36, 30, 'B')}${arrow('M18 40c0 10 10 12 18 6', '#3aa54a')}<path d="M36 40l2 8-8 0z" fill="#3aa54a"/>`),
  unplannedCount: s(`<rect x="8" y="12" width="40" height="30" rx="2" fill="none" stroke="#3d8be0" stroke-width="3"/><circle cx="20" cy="22" r="4" fill="#e23b32"/><circle cx="32" cy="32" r="4" fill="#3aa54a"/><circle cx="48" cy="48" r="9" fill="#f39c12"/><path d="M45 44l7 4-7 4z" fill="#fff"/>`),
  unplannedMove: s(`${doc(6, 10, 'A')}${doc(32, 26, 'B')}${arrow('M18 40c0 8 8 10 14 6', '#3aa54a')}<circle cx="50" cy="50" r="9" fill="#f39c12"/><path d="M47 46l7 4-7 4z" fill="#fff"/>`),
  binContent: s(`${box(10, 24)}${box(32, 24)}${box(21, 8)}`),
  itemRef: s(`<rect x="8" y="14" width="48" height="36" fill="#fff" stroke="#7a8090"/><path d="M14 18v28M18 18v28M21 18v28M26 18v28M29 18v28M34 18v28M38 18v28M41 18v28M46 18v28M50 18v28" stroke="#222" stroke-width="2"/><path d="M6 32h52" stroke="#e23b32" stroke-width="2"/>`),
  substitute: s(`${box(8, 22)}${box(36, 22)}${arrow('M14 18c6-10 30-10 36 0', '#3aa54a')}${arrow('M50 50c-6 10-30 10-36 0', '#3aa54a')}`),
  findItem: s(`${box(28, 14)}${box(36, 30)}<circle cx="22" cy="34" r="12" fill="#cfe0f5" stroke="#5c616b" stroke-width="3"/><path d="M30 42l12 12" stroke="#3aa54a" stroke-width="5" stroke-linecap="round"/>`),
  bulkMove: s(`${doc(6, 10, 'A')}${doc(36, 30, 'B')}${arrow('M18 40c0 10 10 12 18 6', '#3aa54a')}`),
  changeDefault: s(`${box(8, 22)}${box(36, 22)}${arrow('M14 18c6-10 30-10 36 0', '#3aa54a')}`),
  settings: s(`<circle cx="26" cy="28" r="12" fill="none" stroke="#c9a227" stroke-width="8" stroke-dasharray="5 4"/><circle cx="26" cy="28" r="6" fill="#c9a227"/><circle cx="44" cy="44" r="8" fill="none" stroke="#c9a227" stroke-width="6" stroke-dasharray="4 3"/>`),
  scan: `<svg viewBox="0 0 48 48"><circle cx="24" cy="24" r="22" fill="#fff" stroke="#9aa"/><path d="M12 14v20M15 14v20M18 14v20M22 14v20M25 14v20M29 14v20M32 14v20M36 14v20" stroke="#333" stroke-width="1.6"/><path d="M6 24h36" stroke="#e23b32" stroke-width="2"/></svg>`,
  lock: `<svg class="lock" viewBox="0 0 24 24"><rect x="4" y="10" width="16" height="12" rx="2" fill="#1f3c88"/><path d="M8 10V7a4 4 0 018 0v3" stroke="#1f3c88" stroke-width="2.4" fill="none"/><rect x="11" y="14" width="2" height="4" fill="#fff"/></svg>`,
  search: `<svg viewBox="0 0 24 24" width="26" height="26"><circle cx="10" cy="10" r="6.5" fill="none" stroke="#1f3c88" stroke-width="2.4"/><path d="M15 15l6 6" stroke="#1f3c88" stroke-width="2.6" stroke-linecap="round"/></svg>`,
  keyboard: `<svg viewBox="0 0 24 24" width="24" height="24"><rect x="2" y="6" width="20" height="12" rx="2" fill="none" stroke="#1f3c88" stroke-width="1.8"/><path d="M6 10h1M10 10h1M14 10h1M18 10h1M7 14h10" stroke="#1f3c88" stroke-width="1.8" stroke-linecap="round"/></svg>`,
};
