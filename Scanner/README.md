# JKF Lager – egen scanner-app til Business Central

En erstatning for Tasklet Mobile WMS, bygget til Honeywell-scannerne (CT40/CT45).
Version 1 indeholder de funktioner fra billederne, som lagerfolkene bruger:

| Menupunkt | Hvad sker der i BC |
|---|---|
| **Find vare** | Viser placeringsindhold (tilgængeligt/beholdning) for varen på lokationen |
| **Uplanlagt flyt** | Bogfører en omposteringskladde-linje (vare → fra-placering → til-placering) |
| **Pluk** | Liste over lagerpluk med filter (Mine & uallokerede / Alle / Kun mine). Scan placering → vare → antal, og registrér med standard-codeunit "Whse.-Activity-Register" |
| **Indstillinger** | Forbindelse, regnskab og standardlokation |

De øvrige fliser i menuen vises nedtonet ("kommer senere").

## Sådan hænger det sammen

```
Honeywell (Chrome, installeret som app)
   │  scanner = "keyboard wedge" (stregkoden tastes ind + Enter)
   ▼
Scanner/app/  (HTML/JS – ingen build, bare statiske filer)
   │  login med Microsoft (MSAL) – samme bruger som i BC
   ▼
Business Central API:  /api/jkf/scanner/v1.0/...
   ▲
Scanner/AL/  (del af udvidelsen "JKF Custom APIs": API-sider + bogføring)
```

Tasklet gør grundlæggende det samme: en BC-udvidelse + en Android-app. De bruger en SOAP-webservice med XML-beskeder.
Vi bruger i stedet almindelige BC API-sider (JSON). Det er nemmere at vedligeholde.

### Mapper

Alt ligger i mappen `Scanner/` i udvidelsen **JKF Custom APIs** (`C:\Udvikling\BC-Custom-API`).

- `Scanner/AL/` – AL-objekterne (ID 50340–50347). De bygges sammen med resten af JKF Custom APIs
  - API'er: `locations`, `items`, `itemReferences`, `binContents`, `picks`, `pickLines`, `transactions` (skriv)
  - Siden **Scanner-transaktioner** i BC viser alt, hvad scannerne har bogført, og hvem der gjorde det
  - Tilladelsessæt **JKF SCANNER**
- `Scanner/app/` – selve scanner-appen (PWA)
- `Scanner/server/server.js` – lille Node-webserver (uden afhængigheder) til test og evt. drift. `/bc/*` videresender til BC, hvis CORS driller

## Afprøv appen nu (demo-data, uden BC)

Kør fra `C:\Udvikling\BC-Custom-API`:

```bash
node Scanner/server/server.js
```

Åbn http://localhost:8080. Appen starter i **Demo**-tilstand med testdata, bl.a. vare 1170132 på 10-07-138-B2 og 10-07-139-A5 og plukordrer PL054001 …
Stregkoden `5701234567890` er en varereference til 1170132.

---

## Opsætning – trin for trin

### 1. Byg og udgiv JKF Custom APIs
1. Åbn `C:\Udvikling\BC-Custom-API` i VS Code, som I plejer. Scanner-objekterne bygges automatisk med.
2. Hæv `version` i `app.json`, og publicér til en **sandbox** først (F5).
3. Tildel brugerne tilladelsessættet **JKF SCANNER** og deres normale lagerrettigheder. Brugerne skal også være **lagermedarbejder** på lokationen for at kunne registrere pluk.
4. Når det er testet: byg `.app`-filen og upload den i produktion via *Udvidelsesstyring → Upload*.

### 2. Opret en app-registrering i Microsoft Entra (én gang)
1. Gå til portal.azure.com → **Microsoft Entra ID → App-registreringer → Ny registrering**.
2. Navn: `JKF Lager scanner`. Kontotyper: *Kun denne organisation*.
3. Omdirigerings-URI: platform **Single-page application (SPA)**, URL = adressen hvor appen hostes, fx `https://lager.jkfuniverse.com/index.html` (husk `index.html`). Tilføj også `http://localhost:8080/index.html` til test.
4. **API-tilladelser → Tilføj → Dynamics 365 Business Central → Delegerede → `user_impersonation`** (og `Financials.ReadWrite.All`). Klik **Giv administratorsamtykke**.
5. Notér **Program-id (klient-id)** og **Mappe-id (tenant-id)**.

Appen logger ind som den enkelte medarbejder. Alt i BC bliver derfor registreret på deres eget bruger-id, og der ligger ingen adgangskoder i appen.

### 3. Host appen på jeres nginx-server (skal være HTTPS)
Appen er kun statiske filer, og scannerne kalder selv Business Central. Serveren skal derfor ikke køre nogen kode.
Det er testet, at BC tillader kaldene direkte fra browseren (CORS), så der skal ikke bruges proxy.

Første gang:
1. Opret DNS-navnet `lager.jkfuniverse.com`, så det peger på serveren.
2. Kopiér `Scanner/hosting/jkf-lager.nginx.conf` til `/etc/nginx/sites-available/jkf-lager` på serveren, og aktivér den:
   `sudo ln -s /etc/nginx/sites-available/jkf-lager /etc/nginx/sites-enabled/ && sudo nginx -t && sudo systemctl reload nginx`
3. Udgiv filerne fra din pc: `.\Scanner\hosting\publish.ps1 -Server bruger@server`
4. Sæt https op: `sudo certbot --nginx -d lager.jkfuniverse.com`
5. Tilføj `https://lager.jkfuniverse.com/index.html` som **Single-page application**-redirect i Entra (se trin 2).

Nye versioner: hæv `CACHE` i `Scanner/app/sw.js`, og kør `publish.ps1` igen.

(`Scanner/server/server.js` er kun til lokal test på http://localhost:8080.)

### 4. Konfigurer scannerens wedge (Honeywell CT40/CT45)
På scanneren: **Indstillinger → Honeywell Settings → Scanning → Internal Scanner → Default profile → Data Processing Settings**:
- **Wedge**: slået til, metode *Standard/Keyboard* (ikke "Data Intent")
- **Suffix**: `\n` (Enter). Appen kan også klare sig uden, men Enter-suffix er mest sikkert.
- Slå de stregkodetyper til, I bruger, under *Symbology Settings*, fx QR til placeringsetiketterne.

(Menunavnene kan variere lidt mellem Android-versioner.)

### 5. Installér appen på scanneren
1. Åbn **Chrome** på scanneren og gå til app-adressen. Lav evt. en QR-kode med adressen og scan den.
2. Chrome-menu **⋮ → Installer app** (eller *Føj til startskærm*).
3. Åbn **JKF Lager** fra startskærmen. Den kører i fuld skærm uden adresselinje.
4. *Indstillinger*: vælg **Business Central**, udfyld tenant, miljø (`Production`) og klient-id → **Log ind** → **Hent** → vælg regnskab og standardlokation → **Gem**.

Mange scannere: indstillingerne gemmes pr. enhed. Det kan senere automatiseres med Honeywell Enterprise Provisioner eller jeres MDM.

**Opdateringer:** læg nye filer op på serveren. Scannerne henter dem automatisk næste gang appen åbnes. Hæv `CACHE`-navnet i `Scanner/app/sw.js` ved hver udgivelse.

---

## Kendte begrænsninger i version 1
- **Lokationer med "Styret læg-på-lager og pluk"** understøttes ikke for uplanlagt flyt. Det kræver lager-ompostering. Udvidelsen giver en klar fejl.
- **Lot-/serienumre** spørges der ikke om endnu. Varer med varesporing fejler ved bogføring.
- **Lagerpluk** (inventory pick) og salgsordrer uden lagerdokument vises ikke. Kun lagerpluk af typen *Pluk*.
- Plukket antal gemmes lokalt på scanneren (overlever genstart af appen) og sendes først til BC ved **Registrer pluk**.
- Pluk "låses" ikke, mens nogen arbejder på dem (Tasklet gør). Pluk tildelt en anden vises med hængelås, og appen spørger, før de åbnes.

## Mulige næste skridt
- Flere menupunkter: Placeringsindhold, Varereference, Skift standardplacering, Uplanlagt optælling, Bulk flyt.
- Lot/serie-trin i flyt og pluk.
- Pakke appen som rigtig Android-APK (Trusted Web Activity via Bubblewrap). Så kan den rulles ud via MDM og bruge Honeywells "Data Intent" i stedet for wedge.
