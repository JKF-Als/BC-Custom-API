# Accepttest i DK_Test

Udføres af BC-partneren med den dedikerede Entra-app og de endelige rettighedssæt. Brug særskilte testkunder og testvarer. Gem forventet og faktisk resultat uden tokens eller kundebilag. Kompilering alene er ikke godkendelse til drift.

| Test | Forventet resultat |
|---|---|
| Kun READ: GET på alle 20 læseendpoints | 200; korrekte felter og data. Inventory kan beregnes med de endelige rettigheder. |
| Kun READ: POST requests, POST/PATCH/DELETE læsesider | Afvist; ingen nye dokumenter eller ændringer. |
| Paginering og filtre på debitor, eksternt bilagsnr. og dokumenttype | Ingen tabte sider; korrekt udvælgelse. |
| Attribut-, tekst-, kontakt- og arkivjoins | Matcher de samme data i BC-klienten, også firma/person, sprog og arkivversion. |
| Varereferencer og priser | Kontroller kunde, variant, enhed, gyldighed, minimumsantal, valuta og aktiv status. |
| WRITE: opret tilbud og ordre | Åben status, rigtig kunde og betingelser; dokumentet kan ses af kundecenteret. |
| Sammenlign pris med manuel oprettelse | Samme BC-enhedspris og linjerabat ved kundeprisgruppe, kundeaftale, rabatgruppe, dato, valuta, variant og mængdetrin. |
| Ukendt vare, spærret kunde/vare, forkert enhed eller fejl på linje 2 | Hele handlingen fejler. Intet delvist salgsdokument består. Request kan være oprettet med completed=false. |
| Pris/rabat/status eller ukendte felter i payload | Afvist, ingen databaseændring. |
| Samme request-id og identisk payload, også to samtidige kald | Ét dokument/bilag; samme resultat ved genforsøg. |
| Genforsøg med payload med linjeskift og danske tegn | Identisk payload accepteres, også ved vedhæftninger; intet dubletdokument. |
| Samme gennemførte request-id med ændret payload | Afvist. |
| Nyt request-id med samme kunde og eksterne bilagsnr. | Nyt salgsdokument afvises, hvis tilbud/ordre allerede findes. |
| Update af agentens åbne dokument | Antal ændres med ny BC-prisberegning; nye linjer tilføjes, udeladte bevares. |
| Update efter medarbejderændring i hoved eller linje | Forældet expectedModifiedAt afvises; medarbejderændring bevares. |
| Update/attach til manuelt oprettet eller frigivet dokument | Afvist. |
| Forsøg på at ændre varenummer/enhed/variant/lokation på eksisterende linje | Afvist. |
| Upload PDF, Excel og Word | Originalfil kan åbnes fra dokumentets vedhæftninger; gentaget anmodning giver ét bilag. |
| Tomt bilag, ugyldig base64 eller fil over grænsen | Afvist uden vedhæftning. |
| Forsøg på DELETE, release, post, send og standard salgs-API-skrivning med serviceidentiteten | Alle afvises; kontroller også andre installerede endpoints og rettighedssæt. |
| Produktionsadgang og andet sandboxnavn | Egne API'er afvises. Entra-appen må ikke være registreret med adgang i produktion. |
| Rettigheder og lokale udvidelser | Ingen brede direkte skriverettigheder eller bogføringsadgang tilføjet. Nødvendige indirekte rettigheder dokumenteret. |
| Fejl og underliggende Commit() | Fejl ruller dokumentændringer tilbage. Eksplicitte commits afvises; partnerudvidelsers øvrige sideeffekter gennemgået. |
| Telemetri, gatewaylog, HTTP-fejl og 429-genforsøg | Succes og fejl kan spores med correlation-id. Ingen tokens eller bilagsindhold i log. |

Godkend først fase 1 særskilt. Fase 2 må først tildeles efter brugerens/organisationens godkendelse. Datakopi, AI-databehandling og opbevaringsperiode afklares administrativt.
