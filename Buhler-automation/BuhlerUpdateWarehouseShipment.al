
page 50204 "Buhler Get Source Document"
{
    PageType = API;
    Caption = 'Buhler Get Source Document';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'BuhlerGetSourceDocument';
    EntitySetName = 'BuhlerGetSourceDocuments';

    SourceTable = "Buhler Source Document Buffer";
    ODataKeyFields = SystemId;

    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;

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

                field(warehouseShipmentNo; Rec."Warehouse Shipment No.")
                {
                    Caption = 'Warehouse Shipment No.';
                }

                field(salesOrderNo; Rec."Sales Order No.")
                {
                    Caption = 'Sales Order No.';
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

                field(createdLineCount; Rec."Created Line Count")
                {
                    Caption = 'Created Line Count';
                    Editable = false;
                }

                field(createdAt; Rec."Created At")
                {
                    Caption = 'Created At';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Success := false;
        Rec.Message := '';
        Rec."Created Line Count" := 0;
        Rec."Created At" := CurrentDateTime();

        AddSalesOrderToWarehouseShipment();

        Rec.Success := true;

        Rec.Message :=
            CopyStr(
                StrSubstNo(
                    'Salgsordre %1 blev hentet ind på lagerstedsforsendelse %2. Der blev oprettet %3 linjer.',
                    Rec."Sales Order No.",
                    Rec."Warehouse Shipment No.",
                    Rec."Created Line Count"),
                1,
                MaxStrLen(Rec.Message));

        exit(true);
    end;

    local procedure AddSalesOrderToWarehouseShipment()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseRequest: Record "Warehouse Request";
        SalesHeader: Record "Sales Header";
        GetSourceDocuments: Report "Get Source Documents";
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
        WasWarehouseShipmentReleased: Boolean;
        LineCountBefore: Integer;
        LineCountAfter: Integer;
    begin
        Rec."Warehouse Shipment No." :=
            DelChr(
                Rec."Warehouse Shipment No.",
                '<>',
                ' ');

        Rec."Sales Order No." :=
            DelChr(
                Rec."Sales Order No.",
                '<>',
                ' ');

        if Rec."Warehouse Shipment No." = '' then
            Error(
                'Feltet warehouseShipmentNo skal udfyldes.');

        if Rec."Sales Order No." = '' then
            Error(
                'Feltet salesOrderNo skal udfyldes.');

        if not WarehouseShipmentHeader.Get(
            Rec."Warehouse Shipment No.")
        then
            Error(
                'Lagerstedsforsendelse %1 blev ikke fundet.',
                Rec."Warehouse Shipment No.");

        if not SalesHeader.Get(
            SalesHeader."Document Type"::Order,
            Rec."Sales Order No.")
        then
            Error(
                'Salgsordre %1 blev ikke fundet.',
                Rec."Sales Order No.");

        if SalesHeader.Status <> SalesHeader.Status::Released then
            Error(
                'Salgsordre %1 skal være frigivet. Aktuel status er %2.',
                Rec."Sales Order No.",
                Format(SalesHeader.Status));

        if SalesHeader."Location Code" <>
           WarehouseShipmentHeader."Location Code"
        then
            Error(
                'Salgsordre %1 bruger lagersted %2, mens lagerstedsforsendelse %3 bruger lagersted %4.',
                Rec."Sales Order No.",
                SalesHeader."Location Code",
                Rec."Warehouse Shipment No.",
                WarehouseShipmentHeader."Location Code");

        WarehouseRequest.Reset();

        WarehouseRequest.SetRange(
            Type,
            WarehouseRequest.Type::Outbound);

        WarehouseRequest.SetRange(
            "Source Type",
            Database::"Sales Line");

        WarehouseRequest.SetRange(
            "Source Subtype",
            SalesHeader."Document Type"::Order.AsInteger());

        WarehouseRequest.SetRange(
            "Source No.",
            Rec."Sales Order No.");

        WarehouseRequest.SetRange(
            "Location Code",
            WarehouseShipmentHeader."Location Code");

        WarehouseRequest.SetRange(
            "Completely Handled",
            false);

        if WarehouseRequest.IsEmpty() then
            Error(
                'Der blev ikke fundet en åben lageranmodning for salgsordre %1 på lagersted %2.',
                Rec."Sales Order No.",
                WarehouseShipmentHeader."Location Code");

        WarehouseShipmentLine.Reset();

        WarehouseShipmentLine.SetRange(
            "No.",
            Rec."Warehouse Shipment No.");

        LineCountBefore :=
            WarehouseShipmentLine.Count();

        WasWarehouseShipmentReleased :=
            WarehouseShipmentHeader.Status =
            WarehouseShipmentHeader.Status::Released;

        if WasWarehouseShipmentReleased then begin
            WhseShipmentRelease.Reopen(
                WarehouseShipmentHeader);

            WarehouseShipmentHeader.Get(
                Rec."Warehouse Shipment No.");
        end;

        Clear(GetSourceDocuments);

        GetSourceDocuments.SetTableView(
            WarehouseRequest);

        GetSourceDocuments.SetHideDialog(true);

        GetSourceDocuments.SetOneCreatedShptHeader(
            WarehouseShipmentHeader);

        GetSourceDocuments.UseRequestPage(false);

        GetSourceDocuments.RunModal();

        WarehouseShipmentLine.Reset();

        WarehouseShipmentLine.SetRange(
            "No.",
            Rec."Warehouse Shipment No.");

        LineCountAfter :=
            WarehouseShipmentLine.Count();

        Rec."Created Line Count" :=
            LineCountAfter - LineCountBefore;

        if Rec."Created Line Count" <= 0 then
            Error(
                'Business Central gennemførte Hent kildedokumenter, men der blev ikke oprettet nye linjer på lagerstedsforsendelse %1. Kontrollér om salgsordren allerede er hentet, eller om linjerne har et resterende antal til afsendelse.',
                Rec."Warehouse Shipment No.");

        if WasWarehouseShipmentReleased then begin
            WarehouseShipmentHeader.Get(
                Rec."Warehouse Shipment No.");

            WhseShipmentRelease.Release(
                WarehouseShipmentHeader);
        end;
    end;
}


table 50204 "Buhler Source Document Buffer"
{
    Caption = 'Buhler Source Document Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Warehouse Shipment No."; Code[20])
        {
            Caption = 'Warehouse Shipment No.';
        }

        field(3; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
        }

        field(4; Success; Boolean)
        {
            Caption = 'Success';
        }

        field(5; Message; Text[250])
        {
            Caption = 'Message';
        }

        field(6; "Created Line Count"; Integer)
        {
            Caption = 'Created Line Count';
        }

        field(7; "Created At"; DateTime)
        {
            Caption = 'Created At';
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
