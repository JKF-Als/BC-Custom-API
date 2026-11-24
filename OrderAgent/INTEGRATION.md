# Integration i JKF Custom APIs

OrderAgent/src er lagt ind i det eksisterende AL-projekt. Rodens app.json er bevaret, og der er ikke indsat et separat manifest. AL-kompileren medtager automatisk de nye kildefiler.

Hele projektet med 80 AL-filer er kompileret uden fejl mod projektets egne .alpackages. Der er én eksisterende advarsel AL0567 i Debitor-automation/JKFCustomerContactBuffer.Table.al om feltet SystemId. Den vedrører ikke den nye ordreagentkode.

JKF.CustomAPIs.WithOrderAgent.POC.app er det samlede projekts POC-build med ordreagenten. App-identitet og version er uændret. Før en senere publicering skal projektets normale versions- og udgivelsesprocedure følges. Intet er publiceret eller installeret.

README.md beskriver den oprindelige selvstændige POC-pakke. I dette repository anvendes det eksisterende rodmanifest og projektets eksisterende buildopsætning. Installer ikke den oprindelige selvstændige POC-app samtidig med denne integrerede løsning.

Fase 1 og fase 2 tildeles fortsat særskilt via JKF AGENT READ og JKF AGENT WRITE. De er ikke tilføjet til projektets brede eksisterende rettighedssæt. Miljøværnet kræver sandbox med navnet DK_Test. Kør TESTPLAN.md inden brug.
