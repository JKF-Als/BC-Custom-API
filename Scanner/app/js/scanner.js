// Honeywell-scanneren kører som "keyboard wedge": stregkoden tastes ind som tastetryk,
// efterfulgt af Enter (suffix). Står markøren i et inputfelt, havner koden dér, og feltets
// Enter-håndtering tager over. Står markøren ikke i et felt, opsamler vi tastetrykkene her
// og sender hele koden til den aktive skærm.
//
// Uden Enter-suffix: vi afslutter også en scanning, hvis tegnene kom meget hurtigt efter
// hinanden og der så er en pause.

let handler = null;
let buffer = '';
let lastKey = 0;
let fastCount = 0;
let timer = null;

const FAST_MS = 45;     // tegn tættere end dette = scanner, ikke menneske
const IDLE_MS = 120;    // pause der afslutter en scanning uden Enter

export function onScan(fn) { handler = fn; }
export function clearScanHandler() { handler = null; }
export function getScanHandler() { return handler; }

function isTypingTarget(el) {
  return el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.tagName === 'SELECT' || el.isContentEditable);
}

function flush() {
  clearTimeout(timer);
  const code = buffer.trim();
  buffer = '';
  fastCount = 0;
  if (code && handler) handler(code);
}

document.addEventListener('keydown', (e) => {
  if (isTypingTarget(document.activeElement)) return;
  const now = performance.now();
  if (e.key === 'Enter') {
    if (buffer) { e.preventDefault(); flush(); }
    return;
  }
  if (e.key.length !== 1) return;
  if (now - lastKey > 400) { buffer = ''; fastCount = 0; }
  if (now - lastKey < FAST_MS) fastCount++;
  lastKey = now;
  buffer += e.key;
  clearTimeout(timer);
  timer = setTimeout(() => { if (fastCount >= 3) flush(); else { buffer = ''; fastCount = 0; } }, IDLE_MS);
}, true);

/** Lyd/vibration som feedback. */
let audioCtx = null;
export function beep(ok = true) {
  try {
    audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)();
    const o = audioCtx.createOscillator();
    const g = audioCtx.createGain();
    o.frequency.value = ok ? 1400 : 300;
    o.type = ok ? 'sine' : 'square';
    g.gain.value = 0.15;
    o.connect(g); g.connect(audioCtx.destination);
    o.start(); o.stop(audioCtx.currentTime + (ok ? 0.08 : 0.35));
  } catch { /* ingen lyd */ }
  if (!ok && navigator.vibrate) navigator.vibrate([120, 60, 120]);
}
