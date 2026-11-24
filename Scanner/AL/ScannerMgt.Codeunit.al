codeunit 50340 "JKF Scanner Mgt."
{
    Permissions = tabledata "JKF Scanner Transaction" = rimd;

    var
        ReclassTemplateTok: Label 'JKFSCAN', Locked = true;
        ReclassBatchTok: Label 'SCANNER', Locked = true;
        ReclassTemplateDescTxt: Label 'Scanner-app (uplanlagt flyt)';
        DirectedNotSupportedErr: Label 'Lokation %1 bruger "Styret læg-på-lager og pluk". Det understøttes ikke af scanner-appen endnu.', Comment = '%1 = Lokationskode';
        SameBinErr: Label 'Fra- og til-placering er den samme (%1).', Comment = '%1 = Placering';
        QtyMustBePositiveErr: Label 'Antal skal være større end 0.';
        NotTakeLineErr: Label 'Linje %1 på pluk %2 er ikke en tag-linje.', Comment = '%1 = Linjenr., %2 = Pluknr.';
        TooMuchErr: Label 'Du kan højst plukke %1 af vare %2 på linje %3.', Comment = '%1 = Antal, %2 = Varenr., %3 = Linjenr.';
        NoPlaceLineErr: Label 'Der findes ingen læg-linje til linje %1 på pluk %2.', Comment = '%1 = Linjenr., %2 = Pluknr.';
        NothingToRegisterErr: Label 'Der er intet at registrere på pluk %1.', Comment = '%1 = Pluknr.';
        DocNoTok: Label 'SCN%1', Locked = true, Comment = '%1 = Løbenr.';

    /// <summary>Kaldes fra API'et når appen POST'er en transaktion.</summary>
    procedure Process(var ScannerTrans: Record "JKF Scanner Transaction")
    begin
        case ScannerTrans.Type of
            ScannerTrans.Type::UnplannedMove:
                PostUnplannedMove(ScannerTrans);
            ScannerTrans.Type::PickLine:
                ValidatePickLine(ScannerTrans);
            ScannerTrans.Type::PickRegister:
                RegisterPick(ScannerTrans);
        end;
    end;

    #region Uplanlagt flyt
    local procedure PostUnplannedMove(var ScannerTrans: Record "JKF Scanner Transaction")
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        ScannerTrans.TestField("Item No.");
        if ScannerTrans.Quantity <= 0 then
            Error(QtyMustBePositiveErr);
        if ScannerTrans."New Location Code" = '' then
            ScannerTrans."New Location Code" := ScannerTrans."Location Code";
        CheckLocation(ScannerTrans."Location Code");
        CheckLocation(ScannerTrans."New Location Code");
        if (ScannerTrans."Location Code" = ScannerTrans."New Location Code") and (ScannerTrans."Bin Code" = ScannerTrans."New Bin Code") then
            Error(SameBinErr, ScannerTrans."Bin Code");

        ScannerTrans."Document No." := StrSubstNo(DocNoTok, ScannerTrans."Entry No.");

        EnsureReclassBatch();
        ItemJnlLine.SetRange("Journal Template Name", ReclassTemplateTok);
        ItemJnlLine.SetRange("Journal Batch Name", ReclassBatchTok);
        ItemJnlLine.DeleteAll(true);

        ItemJnlLine.Init();
        ItemJnlLine."Journal Template Name" := ReclassTemplateTok;
        ItemJnlLine."Journal Batch Name" := ReclassBatchTok;
        ItemJnlLine."Line No." := 10000;
        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Transfer);
        ItemJnlLine.Validate("Posting Date", WorkDate());
        ItemJnlLine.Validate("Document No.", ScannerTrans."Document No.");
        ItemJnlLine.Validate("Item No.", ScannerTrans."Item No.");
        if ScannerTrans."Variant Code" <> '' then
            ItemJnlLine.Validate("Variant Code", ScannerTrans."Variant Code");
        ItemJnlLine.Validate("Location Code", ScannerTrans."Location Code");
        if ScannerTrans."Bin Code" <> '' then
            ItemJnlLine.Validate("Bin Code", ScannerTrans."Bin Code");
        ItemJnlLine.Validate("New Location Code", ScannerTrans."New Location Code");
        if ScannerTrans."New Bin Code" <> '' then
            ItemJnlLine.Validate("New Bin Code", ScannerTrans."New Bin Code");
        if ScannerTrans."Unit of Measure Code" <> '' then
            ItemJnlLine.Validate("Unit of Measure Code", ScannerTrans."Unit of Measure Code");
        ItemJnlLine.Validate(Quantity, ScannerTrans.Quantity);
        ItemJnlLine.Insert(true);

        // Standard-bogføring: laver både vareposter og lagerposter (placeringer).
        Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJnlLine);

        ScannerTrans.Status := ScannerTrans.Status::Processed;
        ScannerTrans."Processed At" := CurrentDateTime();
        ScannerTrans.Modify();
    end;

    local procedure CheckLocation(LocationCode: Code[10])
    var
        Location: Record Location;
    begin
        if LocationCode = '' then
            exit;
        Location.Get(LocationCode);
        if Location."Directed Put-away and Pick" then
            Error(DirectedNotSupportedErr, LocationCode);
    end;

    local procedure EnsureReclassBatch()
    var
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not ItemJnlTemplate.Get(ReclassTemplateTok) then begin
            if SourceCodeSetup.Get() then;
            ItemJnlTemplate.Init();
            ItemJnlTemplate.Name := ReclassTemplateTok;
            ItemJnlTemplate.Description := ReclassTemplateDescTxt;
            ItemJnlTemplate.Validate(Type, ItemJnlTemplate.Type::Transfer);
            ItemJnlTemplate."Source Code" := SourceCodeSetup."Item Reclass. Journal";
            ItemJnlTemplate.Insert(true);
        end;
        if not ItemJnlBatch.Get(ReclassTemplateTok, ReclassBatchTok) then begin
            ItemJnlBatch.Init();
            ItemJnlBatch."Journal Template Name" := ReclassTemplateTok;
            ItemJnlBatch.Name := ReclassBatchTok;
            ItemJnlBatch.Description := ReclassTemplateDescTxt;
            ItemJnlBatch."No. Series" := '';
            ItemJnlBatch."Posting No. Series" := '';
            ItemJnlBatch.Insert(true);
        end;
    end;
    #endregion

    #region Pluk
    local procedure ValidatePickLine(var ScannerTrans: Record "JKF Scanner Transaction")
    var
        TakeLine: Record "Warehouse Activity Line";
    begin
        if ScannerTrans.Quantity <= 0 then
            Error(QtyMustBePositiveErr);
        TakeLine.Get(TakeLine."Activity Type"::Pick, ScannerTrans."Activity No.", ScannerTrans."Activity Line No.");
        if TakeLine."Action Type" <> TakeLine."Action Type"::Take then
            Error(NotTakeLineErr, TakeLine."Line No.", TakeLine."No.");
        if ScannerTrans.Quantity > TakeLine."Qty. Outstanding" then
            Error(TooMuchErr, TakeLine."Qty. Outstanding", TakeLine."Item No.", TakeLine."Line No.");
        ScannerTrans."Item No." := TakeLine."Item No.";
        ScannerTrans."Location Code" := TakeLine."Location Code";
        if ScannerTrans."Bin Code" = '' then
            ScannerTrans."Bin Code" := TakeLine."Bin Code";
        ScannerTrans.Modify();
        // Linjen bliver stående som "Afventer" indtil appen sender PickRegister.
    end;

    local procedure RegisterPick(var ScannerTrans: Record "JKF Scanner Transaction")
    var
        WhseActivHeader: Record "Warehouse Activity Header";
        WhseActivLine: Record "Warehouse Activity Line";
        PendingTrans: Record "JKF Scanner Transaction";
        TakeLine: Record "Warehouse Activity Line";
        WhseActivRegister: Codeunit "Whse.-Activity-Register";
    begin
        WhseActivHeader.Get(WhseActivHeader.Type::Pick, ScannerTrans."Activity No.");
        ScannerTrans."Location Code" := WhseActivHeader."Location Code";

        // 1) Nulstil "Håndteringsantal" på alle linjer, så kun det scannede bliver registreret.
        WhseActivLine.SetRange("Activity Type", WhseActivLine."Activity Type"::Pick);
        WhseActivLine.SetRange("No.", WhseActivHeader."No.");
        if WhseActivLine.FindSet(true) then
            repeat
                if WhseActivLine."Qty. to Handle" <> 0 then begin
                    WhseActivLine.Validate("Qty. to Handle", 0);
                    WhseActivLine.Modify(true);
                end;
            until WhseActivLine.Next() = 0;

        // 2) Læg de scannede antal på tag- og læg-linjerne.
        PendingTrans.SetCurrentKey(Type, "Activity No.", Status);
        PendingTrans.SetRange(Type, PendingTrans.Type::PickLine);
        PendingTrans.SetRange("Activity No.", WhseActivHeader."No.");
        PendingTrans.SetRange(Status, PendingTrans.Status::Pending);
        if PendingTrans.FindSet() then
            repeat
                TakeLine.Get(TakeLine."Activity Type"::Pick, WhseActivHeader."No.", PendingTrans."Activity Line No.");
                AddQtyToHandle(TakeLine, PendingTrans.Quantity);
            until PendingTrans.Next() = 0;

        // 3) Registrér med standard-codeunit.
        WhseActivLine.Reset();
        WhseActivLine.SetRange("Activity Type", WhseActivLine."Activity Type"::Pick);
        WhseActivLine.SetRange("No.", WhseActivHeader."No.");
        WhseActivLine.SetFilter("Qty. to Handle", '<>0');
        if WhseActivLine.IsEmpty() then
            Error(NothingToRegisterErr, WhseActivHeader."No.");
        WhseActivLine.SetRange("Qty. to Handle");
        WhseActivLine.FindFirst();
        WhseActivRegister.ShowHideDialog(true);
        WhseActivRegister.Run(WhseActivLine);

        PendingTrans.ModifyAll("Processed At", CurrentDateTime());
        PendingTrans.ModifyAll(Status, PendingTrans.Status::Processed);
        ScannerTrans.Status := ScannerTrans.Status::Processed;
        ScannerTrans."Processed At" := CurrentDateTime();
        ScannerTrans.Modify();
    end;

    local procedure AddQtyToHandle(var TakeLine: Record "Warehouse Activity Line"; Qty: Decimal)
    var
        PlaceLine: Record "Warehouse Activity Line";
    begin
        if TakeLine."Qty. to Handle" + Qty > TakeLine."Qty. Outstanding" then
            Error(TooMuchErr, TakeLine."Qty. Outstanding", TakeLine."Item No.", TakeLine."Line No.");
        TakeLine.Validate("Qty. to Handle", TakeLine."Qty. to Handle" + Qty);
        TakeLine.Modify(true);

        // Læg-linjen er den første efterfølgende læg-linje for samme kildelinje.
        PlaceLine.SetRange("Activity Type", TakeLine."Activity Type");
        PlaceLine.SetRange("No.", TakeLine."No.");
        PlaceLine.SetFilter("Line No.", '>%1', TakeLine."Line No.");
        PlaceLine.SetRange("Action Type", PlaceLine."Action Type"::Place);
        PlaceLine.SetRange("Source Type", TakeLine."Source Type");
        PlaceLine.SetRange("Source Subtype", TakeLine."Source Subtype");
        PlaceLine.SetRange("Source No.", TakeLine."Source No.");
        PlaceLine.SetRange("Source Line No.", TakeLine."Source Line No.");
        PlaceLine.SetRange("Whse. Document No.", TakeLine."Whse. Document No.");
        PlaceLine.SetRange("Whse. Document Line No.", TakeLine."Whse. Document Line No.");
        PlaceLine.SetRange("Breakbulk No.", TakeLine."Breakbulk No.");
        if not PlaceLine.FindFirst() then
            Error(NoPlaceLineErr, TakeLine."Line No.", TakeLine."No.");
        if PlaceLine."Qty. per Unit of Measure" = TakeLine."Qty. per Unit of Measure" then
            PlaceLine.Validate("Qty. to Handle", TakeLine."Qty. to Handle")
        else
            PlaceLine.Validate("Qty. to Handle", Round(TakeLine."Qty. to Handle (Base)" / PlaceLine."Qty. per Unit of Measure", 0.00001));
        PlaceLine.Modify(true);
    end;
    #endregion
}
