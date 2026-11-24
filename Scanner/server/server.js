// Lille webserver uden afhængigheder (kun Node.js):
//  - serverer app-mappen
//  - /bc/*  videresendes til https://api.businesscentral.dynamics.com/* (bruges hvis BC afviser
//    browserkald pga. CORS). Brugerens eget login-token sendes bare videre; serveren gemmer intet.
//
// Start:  node server/server.js            (http://localhost:8080)
// HTTPS:  sæt TLS_CERT og TLS_KEY (stier til PEM-filer) – kræves for at installere appen på scanneren.
const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const PORT = Number(process.env.PORT || 8080);
const ROOT = path.resolve(__dirname, '..', 'app');
const BC_HOST = 'api.businesscentral.dynamics.com';

const TYPES = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8',
  '.json': 'application/json', '.webmanifest': 'application/manifest+json', '.png': 'image/png', '.svg': 'image/svg+xml',
};

function proxy(req, res) {
  const target = req.url.replace(/^\/bc/, '');
  const headers = { ...req.headers, host: BC_HOST };
  delete headers.origin; delete headers.referer; delete headers.cookie;
  const up = https.request({ host: BC_HOST, path: target, method: req.method, headers }, (r) => {
    res.writeHead(r.statusCode, r.headers);
    r.pipe(res);
  });
  up.on('error', (e) => { res.writeHead(502, { 'content-type': 'application/json' }); res.end(JSON.stringify({ error: { message: 'Proxy-fejl: ' + e.message } })); });
  req.pipe(up);
}

function serveStatic(req, res) {
  let p = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  if (p.endsWith('/')) p += 'index.html';
  const file = path.resolve(ROOT, '.' + p);
  if (!file.startsWith(ROOT)) { res.writeHead(403); return res.end(); }
  fs.readFile(file, (err, data) => {
    if (err) { res.writeHead(404); return res.end('Not found'); }
    res.writeHead(200, { 'content-type': TYPES[path.extname(file)] || 'application/octet-stream', 'cache-control': 'no-cache' });
    res.end(data);
  });
}

function handler(req, res) {
  if (req.url.startsWith('/bc/')) return proxy(req, res);
  return serveStatic(req, res);
}

if (process.env.TLS_CERT && process.env.TLS_KEY) {
  https.createServer({ cert: fs.readFileSync(process.env.TLS_CERT), key: fs.readFileSync(process.env.TLS_KEY) }, handler)
    .listen(PORT, () => console.log(`JKF Lager kører på https://localhost:${PORT}`));
} else {
  http.createServer(handler).listen(PORT, () => console.log(`JKF Lager kører på http://localhost:${PORT}`));
}
