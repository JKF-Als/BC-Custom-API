# AL-udvidelse til ordreoptagelsesagent

Pakken implementerer API-adgang til POC'en i det vedlagte oplæg. Den er beregnet til en BC-partner, som skal installere og afprøve den i **DK_Test**. Koden er kompileret mod Microsoft Business Central 28.3-symboler. Den er ikke installeret eller funktionstestet i jeres miljø. Den er ikke selve AI-agenten, PDF-læseren eller mailintegrationen.

## Til dig der skal bestille arbejdet

Send ZIP-filen til jeres BC-partner med denne besked:

> Her er AL-kildekode og en kompileret POC-udvidelse til ordreagenten. Byg den mod symbolerne fra vores DK_Test, gennemgå rettigheder og installer kun i DK_Test. Start med JKF AGENT READ. Gennemfør accepttestene i TESTPLAN.md før fase 2 aktiveres. Konfigurer Entra-serviceadgang og HTTP-logning. Kontroller også hvilket felt hos os der svarer til salgsleveringstid. Skriveadgang må først aktiveres efter vores godkendelse af fase 1.

Udvidelsen kræver ingen hemmeligheder i kildekoden. Tenant-id, client-id og certifikat/hemmelighed oprettes og deles sikkert af IT. Der er ikke foretaget nogen ændringer i Business Central som led i leveringen af denne pakke.

## Implementeret

- 20 egne API-sider til de efterspurgte læseområder, inklusive kontakter og debitorrelationer, vareattributter, udvidede tekster, salgsprislister, arkiver og bogført historik.
- Fase 1: `JKF AGENT READ`, kun læsning gennem disse sider.
- Fase 2: `JKF AGENT WRITE`, inkluderer fase 1 og en afgrænset anmodnings-API.
- Oprettelse af åbent salgstilbud eller åben salgsordre med varelinjer.
- Redigering af antal på eksisterende varelinjer og tilføjelse af nye varelinjer på agentens egne åbne dokumenter.
- Vedhæftning via base64, højst 10 MiB dekodet fil pr. anmodning.
- BC-validering af kunde, vare, variant, enhed, lokation og antal. Pris og linjerabat er ikke tilladte inputfelter; BC beregner dem via standardvalidering.
- Intet endpoint til frigivelse, bogføring, afsendelse eller sletning. Ingen direkte skrivning på salgstabeller til servicekontoen; kun indirekte rettigheder gennem skrivekodeenheden.
- Kontrol af sandbox og miljønavnet `DK_Test` ved alle egne indgange.
- Entydigt anmodnings-id og låsning for sikre genforsøg. Samme id og præcis samme payload genbruger resultatet; ændret payload afvises efter gennemførelse.
- Ændringskontrol på hoved og på hver eksisterende linje ved opdatering.

## Bevidste POC-grænser

Redigering er afgrænset til antal og nye linjer. Ændring af kunde, hovedbetingelser, varenummer eller dimensioner på en eksisterende linje er ikke implementeret. Originale dokumenter skal vedhæftes med en separat `attach`-anmodning. Oprettelse og vedhæftning er derfor to transaktioner. Sletning, linjefjernelse og nul- eller negative antal understøttes ikke.

Dubletkontrol ved oprettelse søger på kombinationen debitor + eksternt bilagsnummer i eksisterende tilbud og ordrer, både åbne og frigivne. Agenten skal desuden undersøge arkiv og bogførte dokumenter via læse-API'erne; de er ikke en automatisk afvisningsregel. Systemets normale nummerserier kan bruge numre, selv om en transaktion fejler.

`leadTimeCalculation` er standardfeltet `Item."Lead Time Calculation"`, som ikke i sig selv er en lovet salgsleveringstid. BC-partneren skal mappe jeres faktiske salgsleveringstidsfelt, hvis det er en tilpasning. Lagerbeholdning er bogført totalbeholdning uden lokationsfilter og er ikke disponibel beholdning efter reservationer.

Pris-API'et forudsætter det nyere prislisteformat (`Price List Line`). Ældre Sales Price/Sales Line Discount-tabeller og partnerens egne prisaftaletabeller er ikke implementeret. Prislisteopslag alene afgør ikke den endelige pris: valuta, datoer, variant, enhed, antal og jeres prisudvidelser kan påvirke beregningen. Fakturarabat, automatisk indsættelse af udvidet tekst og jeres workflows skal afprøves særskilt.

Der er enkel AL-telemetri for åbning af læse-API'er og gennemførte skriveoperationer. Det er **ikke** en komplet revisionslog over alle HTTP-kald eller læste poster. Konfigurer gateway/agentlog med tidspunkt, serviceidentitet, company-id, metode, endpoint, correlation-id, resultatkode og request-id. Brug BC-telemetri som supplement. Log ikke tokens eller kundebilagenes indhold. Konfigurer også opsamling af fejl og adgangsafvisninger. Godkend dette før kravet om logning af alle kald anses opfyldt.

## Installation hos BC-partneren

1. Kontroller version, objekt-id'erne 50300–50399, navnekollisioner og kundens øvrige udvidelser. Manifestet har BC 28 som minimum; leveret binær er bygget mod 28.3. Genbyg altid mod **DK_Test**-symboler før installation, især ved en anden version.
2. Åbn projektmappen i VS Code med Microsoft AL-udvidelsen. Opret egen `launch.json` til SaaS-sandboxen DK_Test og hent symboler. Byg med AL: Package. Ingen tenantoplysninger eller login er medleveret.
3. Installer udvidelsen som en per-tenant extension i DK_Test. Koden kræver, at både sandboxtype og miljønavn passer. Den må ikke installeres i produktion; miljøværnet er ekstra beskyttelse.
4. Opret en dedikeret Microsoft Entra-app til client credentials med Business Central application permission `API.ReadWrite.All` og administratorens consent. Registrer den kun i DK_Test under Microsoft Entra-programmer. Giv rettigheder for det relevante selskab, ikke alle selskaber.
5. Tildel først kun `JKF AGENT READ`. Brug ikke SUPER, D365 FULL ACCESS eller brede salgs-/bogføringsrettigheder. BC-rettigheder lægges sammen; denne udvidelse kan ikke fjerne rettigheder givet af andre sæt.
6. Efter godkendt fase 1 kan `JKF AGENT WRITE` tildeles. Standardvalidering kan kræve yderligere læse- eller indirekte rettigheder til opsætning, nummerserier, prisberegning, medier eller installerede partnerudvidelser. Spor konkrete rettighedsfejl med permission recorder/debugger, og tildel kun det nødvendige. Ingen brede direkte skrive-/slette- eller bogføringsrettigheder må tilføjes for at få en test til at virke.
7. Gennemfør TESTPLAN.md med den faktiske serviceidentitet. Manglende execute-rettigheder til standard-API-sider og bogføringskodeenheder er en del af afgrænsningen. Egne API'er har miljøværn; andre udvidelsers endpoints skal kontrolleres separat.
8. Aftal opdatering/anonymisering af testdata og godkendt AI-behandling. Disse administrative beslutninger er ikke automatiseret af udvidelsen. Continia-licens og egnethed er heller ikke afgjort her.

## Endpoints

Grundadresse for SaaS:

```text
https://api.businesscentral.dynamics.com/v2.0/{tenantId}/DK_Test/api/jkf/orderAgent/v1.0/companies({companyId})/
```

`companyId` er selskabets GUID, ikke navnet. IT/partneren kan udlevere det. Alle kald bruger OAuth bearer-token og HTTPS. Tilføj `Accept: application/json` og ved JSON-input `Content-Type: application/json`. Følg `@odata.nextLink` ved paginering. Ved HTTP 429/503: følg Retry-After og brug begrænsede genforsøg med stigende ventetid.

| Entity set | Indhold |
|---|---|
| customers | Debitorer og betingelser |
| contacts | Kontakter |
| contactRelations | Kontaktfirmaets relation til debitor; filtrer linkToTable til Customer |
| items | Varer, ekstra beskrivelse, grupper, spærret og beholdning |
| itemUnits | Vareenheder og omregning |
| attributes | Attributdefinitioner |
| attributeValues | Attributværdier |
| attributeMappings | Kobling mellem varenummer, attribut-id og værdi-id |
| itemReferences | Kundereferencer og andre varereferencer |
| extendedTextHeaders | Vareteksters sprog, gyldighed og dokumentflag |
| extendedTextLines | Tekstlinjer; join på vare, sprog og tekstnummer |
| salesPriceLines | Salgsprislister, enheder, gyldighed og status |
| salesHeaders / salesLines | Aktuelle tilbud og ordrer |
| archiveHeaders / archiveLines | Arkiver med version og forekomst |
| shipmentHeaders / shipmentLines | Bogførte salgsleverancer |
| invoiceHeaders / invoiceLines | Bogførte salgsfakturaer |
| requests | Fase 2-anmodninger og resultat |

Alle læsesider returnerer `id` (SystemId) og `lastModifiedAt`. Disse bruges også ved ændringskontrol. Feltet `number` er det læsbare BC-nummer. Siderne har selvstændige endpoints; der er ikke implementeret `$expand` mellem dem. Brug hovedets dokumenttype og nummer til at hente linjer. Arkiver kræver også versionsnummer og forekomst. For kontaktpersoner følges `companyNumber` til firmaets Contact Business Relation.

Eksempel på søgning, URL-enkodet ved afsendelse:

```text
GET customers?$filter=number eq '10000'
GET salesHeaders?$filter=customerNumber eq '10000' and externalDocumentNumber eq 'PO-123'
GET salesLines?$filter=documentNumber eq 'SO-123' and documentType eq 'Order'
```

## Sådan skrives et udkast

1. Generer et request-id (GUID), gem det i agentens jobtilstand, og opret anmodningen:

```http
POST {base}/requests

{"requestId":"b0304f5e-d050-4fbb-88bf-c6de02538d60"}
```

2. Svaret indeholder `id`, som er anmodningspostens SystemId. Udfør med dette `id`:

```http
POST {base}/requests({id})/Microsoft.NAV.execute

{"payload":"{\"operation\":\"create\",\"documentType\":\"Order\",\"customerNumber\":\"10000\",\"externalDocumentNumber\":\"PO-123\",\"orderDate\":\"2026-11-16\",\"lines\":[{\"lineNumber\":10000,\"itemNumber\":\"1000\",\"quantity\":2}]}"}
```

`payload` er en JSON-**streng** med et JSON-objekt indeni. Byg objektet og serialiser med en normal JSON-serializer; undgå manuel escaping. Kundenumre og varenumre ovenfor er illustrative og skal erstattes med rigtige testdata. Handlingsnavnet kontrolleres i API'ets `$metadata` på den installerede version.

3. Læs `GET requests({id})` efter handlingen. `completed=true`, `documentId` og `documentNumber` er resultatet. Hent dokumentet og linjerne igen og kontroller BC's pris og rabat før kundecenterets godkendelse. `completed` betyder alene, at API-operationen er gennemført, ikke at en medarbejder har godkendt ordren.

Ved netværksfejl: slå requestId op med `requests?$filter=requestId eq {GUID}`. Hvis posten ikke findes, genbrug samme request-id ved POST. Hvis den findes, genbrug dens `id` og samme payload til Execute. Ved gennemført anmodning returneres det eksisterende resultat. Opret ikke et nyt request-id blindt. Ved en rettet anmodning efter en allerede gennemført handling skal der bruges nyt request-id.

`examples/` indeholder læsbare indre payloads til create, update og attach. De skal indpakkes som `{ "payload": JSON.stringify(objekt) }` i HTTP-kaldet. `expectedModifiedAt` skal kopieres præcist fra hovedets `lastModifiedAt`; for en eksisterende linje også fra linjens `lastModifiedAt`. Eksempeltidspunkter og GUID'er er pladsholdere.

En `update` ændrer kun de nævnte linjer. Udeladte linjer bevares. En eksisterende linje kræver et `expectedModifiedAt`; en ny linje har et ubrugt positivt linjenummer og kræver ikke dette felt. Eksisterende vare, variant, enhed og lokation må ikke ændres. Pris- og rabatfelter og alle ukendte inputfelter afvises.

Der er ingen `Commit()` i skriveforløbet. `[CommitBehavior(Error)]` afviser eksplicitte commits i underliggende kode. Fejl ruller normale databaseændringer i handlingen tilbage. Test partnerudvidelser for implicitte commits, integrationer og andre sideeffekter. Oprettede request-poster ligger i en separat transaktion og kan blive stående som ikke gennemført efter en fejl.

Request-tabellen indeholder original payload, også bilagets base64, for at sammenligne genforsøg. Aftal en kort opbevaringsperiode og administrativ oprydning med partneren; agenten har ingen sletterettighed. Payload eksponeres ikke i request-API'et. Hold ZIP, kildekode og tests fri for kundedata og hemmeligheder.

## Kontrolleret ved levering

AL-kompilering af alle 27 AL-filer mod lokalt tilgængelige Microsoft BC 28.3-symboler. Der er ikke udført API-kald, rettighedstests, prisberegningstests eller installation i DK_Test. Den kompilerede `.app` er en POC-build og skal valideres af partneren før brug.

## Microsofts dokumentation

- [Egne API-sider](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-api)
- [API-adresser](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/webservices/api-endpoint-structure)
- [Service-til-service-godkendelse](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/automation-apis-using-s2s-authentication)
- [Environment Information](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/codeunit/system.environment.environment-information)
- [Vedhæftning fra stream](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/table/microsoft.foundation.attachment.document-attachment)
- [API-tips og transaktioner](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-connect-apps-tips)
