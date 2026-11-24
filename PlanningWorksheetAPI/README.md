# JKF Planning Worksheet API

Gør planlægningskladden (side 99000852) tilgængelig via API og dermed via Business Centrals MCP-server. Bruges af indkøbsassistenten "Lone", så MRP kan køres og læses uden browserstyring.

Er en del af appen **JKF Custom APIs** (fra version 1.0.0.45) og ikke længere en selvstændig extension.

**Skal først installeres i Robex_test. Installation i DK_Production kræver separat godkendelse fra Indkøb.**

## Indhold

Alle objekter ligger i én fil: `PlanningWorksheetAPI.al`.

| Objekt | ID | Formål |
|---|---|---|
| Page `JKF Planning Lines API` | 50213 | Læs planlægningslinjer. Kun `acceptActionMessage` kan ændres. Ingen opret/slet. |
| Page `JKF Planning Batches API` | 50214 | Kladdenavne + bundne handlinger `calculatePlan` og `carryOutAcceptedPurchaseLines`. |
| Codeunit `JKF Planning API Mgt.` | 50215 | Logik og sikkerhedsregler. |
| Permission set `JKF PLAN API` | 50216 | Tildeles assistentens app-bruger. |

## Endpoints

Base: `/api/jkf/purchasing/v1.0/companies({companyId})/`

- `GET planningLines?$filter=journalBatchName eq 'AI' and vendorNo eq '5707'`
- `PATCH planningLines({id})` med `{ "acceptActionMessage": true }` (kræver `If-Match`)
- `GET planningBatches?$filter=name eq 'AI'`
- `POST planningBatches({id})/Microsoft.NAV.calculatePlan` med `{ "vendorFilter": "5707", "locationFilter": "JKF", "startDate": "2026-11-20", "endDate": "2026-12-04" }`
- `POST planningBatches({id})/Microsoft.NAV.carryOutAcceptedPurchaseLines`

## Indbyggede sikkerhedsregler

- Kun kladden **AI** kan ændres eller bruges i handlingerne.
- `calculatePlan` kræver et kreditorfilter og en periode på højst 62 dage. Den udfører ikke aktionsmeddelelser.
- `calculatePlan` sletter kladdens planlægningsfejllog før kørsel, så rapporten ikke viser en bekræftelsesdialog (det svarer til at starte forfra).
- `carryOutAcceptedPurchaseLines` udfører kun linjer med *Accepter aktionsmeddelelse* og afviser, hvis en accepteret linje ikke er et køb. Den laver købsordrer, men frigiver og sender dem ikke.

## Test i Robex_test

Begge rapporter kører med `UseRequestPage(false)`. `Message` ignoreres i API-kald, men en `Confirm` fra en event subscriber (fx fra EV-apps) vil få kaldet til at fejle. Test begge handlinger.

## Opsætning af MCP

1. Udgiv appen i Robex_test.
2. Tildel `JKF PLAN API` og de nødvendige planlægnings-/indkøbsrettigheder til assistentens bruger.
3. Tilføj de to API-sider til MCP-konfigurationen **test** (Model Context Protocol Server Configurations), og tillad *Modify* på `planningLines` og bundne handlinger på `planningBatches`.
