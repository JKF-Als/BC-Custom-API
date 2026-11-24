// Login mod Microsoft Entra ID (samme konto som i Business Central) via MSAL.js.
import { config } from './config.js';

// .default = de BC-tilladelser app-registreringen allerede har fået admin-samtykke til
const SCOPES = ['https://api.businesscentral.dynamics.com/.default'];
let pca = null;
let account = null;

// Altid .../index.html: en adresse med sti kan ikke forveksles med app-registreringens
// "Mobile and desktop"-indgang "http://localhost" (Entra ignorerer porten for localhost).
function redirectUri() {
  return location.origin + location.pathname.replace(/index\.html$/, '').replace(/\/?$/, '/') + 'index.html';
}

export async function initAuth() {
  if (config.mode !== 'bc' || !config.clientId || !config.tenantId) return null;
  pca = new window.msal.PublicClientApplication({
    auth: {
      clientId: config.clientId,
      authority: `https://login.microsoftonline.com/${config.tenantId}`,
      redirectUri: redirectUri(),
    },
    cache: { cacheLocation: 'localStorage' },
  });
  await pca.initialize();
  const result = await pca.handleRedirectPromise();
  if (result && result.account) pca.setActiveAccount(result.account);
  account = pca.getActiveAccount() || pca.getAllAccounts()[0] || null;
  if (account) pca.setActiveAccount(account);
  return account;
}

export function currentAccount() { return account; }

export function userLabel() {
  if (config.mode === 'demo') return 'demo';
  return account ? account.username.split('@')[0] : '';
}

export async function login() {
  if (!pca) await initAuth();
  if (!pca) throw new Error('Login er ikke sat op. Udfyld tenant og klient-id under Indstillinger.');
  await pca.loginRedirect({ scopes: SCOPES, prompt: 'select_account' });
}

export async function logout() {
  if (!pca || !account) return;
  await pca.logoutRedirect({ account, postLogoutRedirectUri: redirectUri() });
}

export async function getToken() {
  if (!pca) await initAuth();
  if (!account) throw new Error('Ikke logget ind.');
  try {
    const r = await pca.acquireTokenSilent({ scopes: SCOPES, account });
    return r.accessToken;
  } catch (e) {
    if (e instanceof window.msal.InteractionRequiredAuthError) {
      await pca.acquireTokenRedirect({ scopes: SCOPES, account });
    }
    throw e;
  }
}
