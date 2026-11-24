table 50208 "Buhler Verify Packing Note Buf"
{
    Caption = 'Buhler Verify Packing Note Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
        }

        field(3; "Warehouse Shipment No."; Code[20])
        {
            Caption = 'Warehouse Shipment No.';
        }

        field(4; "Ignore Item Nos."; Text[250])
        {
            Caption = 'Ignore Item Nos.';
        }

        field(5; Success; Boolean)
        {
            Caption = 'Success';
        }

        field(6; Message; Text[250])
        {
            Caption = 'Message';
        }

        field(7; "Checked Line Count"; Integer)
        {
            Caption = 'Checked Line Count';
        }

        field(8; "Missing Line Count"; Integer)
        {
            Caption = 'Missing Line Count';
        }

        field(9; "Missing Lines"; Text[2048])
        {
            Caption = 'Missing Lines';
        }

        field(10; "Checked At"; DateTime)
        {
            Caption = 'Checked At';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}


// Compares every warehouse shipment line for the sales order with the
// packing note lines created for it, matched on source line no. and item no.
// Report 60013 skips lines silently, so this is the only place a gap shows.
page 50208 "Buhler Verify Packing Notes"
{
    PageType = API;
    Caption = 'Buhler Verify Packing Notes';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'buhlerVerifyPackingNote';
    EntitySetName = 'buhlerVerifyPackingNotes';

    SourceTable = "Buhler Verify Packing Note Buf";
    ODataKeyFields = SystemId;

    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;

    Permissions =
        tabledata "Packing Note Header_EVAS" = R,
        tabledata "Packing Note Line_EVAS" = R,
        tabledata "Warehouse Shipment Line" = R;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(salesOrderNo; Rec."Sales Order No.")
                {
                    Caption = 'Sales Order No.';
                }

                field(warehouseShipmentNo; Rec."Warehouse Shipment No.")
                {
                    Caption = 'Warehouse Shipment No.';
                }

                field(ignoreItemNos; Rec."Ignore Item Nos.")
                {
                    Caption = 'Ignore Item Nos.';
                }

                field(success; Rec.Success)
                {
                    Caption = 'Success';
                    Editable = false;
                }

                field(message; Rec.Message)
                {
                    Caption = 'Message';
                    Editable = false;
                }

                field(checkedLineCount; Rec."Checked Line Count")
                {
                    Caption = 'Checked Line Count';
                    Editable = false;
                }

                field(missingLineCount; Rec."Missing Line Count")
                {
                    Caption = 'Missing Line Count';
                    Editable = false;
                }

                field(missingLines; Rec."Missing Lines")
                {
                    Caption = 'Missing Lines';
                    Editable = false;
                }

                field(checkedAt; Rec."Checked At")
                {
                    Caption = 'Checked At';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Success := false;
        Rec.Message := '';
        Rec."Checked Line Count" := 0;
        Rec."Missing Line Count" := 0;
        Rec."Missing Lines" := '';

        VerifyPackingNotes();

        Rec."Checked At" := CurrentDateTime();

        exit(true);
    end;


    local procedure VerifyPackingNotes()
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        QtyOnPackingNotes: Dictionary of [Text, Decimal];
        IgnoredItemNos: List of [Text];
        LineKey: Text;
        QtyOnNotes: Decimal;
        MissingLines: Text;
    begin
        Rec."Sales Order No." := DelChr(Rec."Sales Order No.", '<>', ' ');
        Rec."Warehouse Shipment No." := DelChr(Rec."Warehouse Shipment No.", '<>', ' ');

        if Rec."Sales Order No." = '' then
            Error('Feltet salesOrderNo skal udfyldes.');

        if Rec."Warehouse Shipment No." = '' then
            Error('Feltet warehouseShipmentNo skal udfyldes.');

        ReadIgnoredItemNos(IgnoredItemNos);
        SumPackingNoteLines(QtyOnPackingNotes);

        WarehouseShipmentLine.SetRange("No.", Rec."Warehouse Shipment No.");
        WarehouseShipmentLine.SetRange("Source Type", Database::"Sales Line");
        WarehouseShipmentLine.SetRange("Source No.", Rec."Sales Order No.");
        WarehouseShipmentLine.SetFilter("Qty. Outstanding", '<>0');

        if not WarehouseShipmentLine.FindSet() then
            Error(
                'Lagerstedsforsendelse %1 har ingen linjer for salgsordre %2.',
                Rec."Warehouse Shipment No.",
                Rec."Sales Order No.");

        repeat
            if not IgnoredItemNos.Contains(WarehouseShipmentLine."Item No.") then begin
                Rec."Checked Line Count" += 1;

                LineKey := GetLineKey(WarehouseShipmentLine."Source Line No.", WarehouseShipmentLine."Item No.");

                if not QtyOnPackingNotes.Get(LineKey, QtyOnNotes) then
                    QtyOnNotes := 0;

                if QtyOnNotes <> WarehouseShipmentLine."Qty. Outstanding" then begin
                    Rec."Missing Line Count" += 1;

                    MissingLines +=
                        StrSubstNo(
                            '%1 (linje %2): %3 på forsendelsen, %4 på pakkebreve. ',
                            WarehouseShipmentLine."Item No.",
                            WarehouseShipmentLine."Source Line No.",
                            WarehouseShipmentLine."Qty. Outstanding",
                            QtyOnNotes);
                end;
            end;
        until WarehouseShipmentLine.Next() = 0;

        Rec.Success := Rec."Missing Line Count" = 0;

        Rec."Missing Lines" :=
            CopyStr(MissingLines.TrimEnd(), 1, MaxStrLen(Rec."Missing Lines"));

        if Rec.Success then
            Rec.Message :=
                CopyStr(
                    StrSubstNo(
                        'Alle %1 forsendelseslinjer står på pakkebrevene.',
                        Rec."Checked Line Count"),
                    1,
                    MaxStrLen(Rec.Message))
        else
            Rec.Message :=
                CopyStr(
                    StrSubstNo(
                        '%1 af %2 forsendelseslinjer mangler på pakkebrevene eller har forkert antal.',
                        Rec."Missing Line Count",
                        Rec."Checked Line Count"),
                    1,
                    MaxStrLen(Rec.Message));
    end;


    local procedure SumPackingNoteLines(var QtyOnPackingNotes: Dictionary of [Text, Decimal])
    var
        PackingNoteHeader: Record "Packing Note Header_EVAS";
        PackingNoteLine: Record "Packing Note Line_EVAS";
        LineKey: Text;
        Qty: Decimal;
    begin
        PackingNoteHeader.SetRange("Sales Order No.", Rec."Sales Order No.");
        PackingNoteHeader.SetRange("Source No.", Rec."Warehouse Shipment No.");

        if not PackingNoteHeader.FindSet() then
            exit;

        repeat
            PackingNoteLine.SetRange("Document No.", PackingNoteHeader."No.");

            if PackingNoteLine.FindSet() then
                repeat
                    // Item no. is part of the key so exploded component lines never count toward their parent line.
                    LineKey := GetLineKey(PackingNoteLine."Source Line No.", PackingNoteLine."No.");

                    if QtyOnPackingNotes.Get(LineKey, Qty) then
                        QtyOnPackingNotes.Set(LineKey, Qty + PackingNoteLine.Quantity)
                    else
                        QtyOnPackingNotes.Add(LineKey, PackingNoteLine.Quantity);
                until PackingNoteLine.Next() = 0;
        until PackingNoteHeader.Next() = 0;
    end;


    local procedure ReadIgnoredItemNos(var IgnoredItemNos: List of [Text])
    var
        RawItemNo: Text;
        ItemNo: Text;
    begin
        foreach RawItemNo in Rec."Ignore Item Nos.".Split(',') do begin
            ItemNo := UpperCase(RawItemNo.Trim());

            if ItemNo <> '' then
                IgnoredItemNos.Add(ItemNo);
        end;
    end;


    local procedure GetLineKey(SourceLineNo: Integer; ItemNo: Code[20]): Text
    begin
        exit(Format(SourceLineNo) + '|' + ItemNo);
    end;
}
