// Indstillinger gemmes lokalt på den enkelte scanner.
const KEY = 'jkf-scanner-config';

const defaults = {
  // Standardopsætning: en ny scanner skal kun trykke "Log ind".
  // Skift environment til produktionsmiljøet, når Scanner-objekterne er udgivet dér.
  mode: 'bc',              // 'demo' | 'bc'
  tenantId: '67c998ad-883d-4441-8709-30a73ec72cb6', // Entra tenant-id
  environment: 'Robex_test', // BC-miljø med JKF Custom APIs
  clientId: '7335c1ac-be96-42c5-b4ca-cf77b88fef6f', // Entra app "BC MCP - Claude" (SPA-platform påkrævet)
  companyId: '45342618-9928-ed11-97e8-000d3a652983',
  companyName: 'JKF Industri A/S',
  useProxy: false,         // true = kald BC via /bc på samme server (undgår CORS)
  defaultLocation: 'JKF',
  deviceId: '',
};

function safeGet() {
  try { return JSON.parse(localStorage.getItem(KEY) || '{}'); } catch { return {}; }
}

export const config = Object.assign({}, defaults, safeGet());
if (!config.deviceId) {
  config.deviceId = 'DEV-' + Math.random().toString(36).slice(2, 8).toUpperCase();
  saveConfig();
}

export function saveConfig(patch = {}) {
  Object.assign(config, patch);
  try { localStorage.setItem(KEY, JSON.stringify(config)); } catch { /* ignore */ }
}

export function isConfigured() {
  return config.mode === 'demo' || (config.tenantId && config.clientId && config.environment);
}
