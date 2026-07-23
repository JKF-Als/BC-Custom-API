table 50205 "Buhler Create Pick Buffer"
{
    Caption = 'Buhler Create Pick Buffer';
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

        field(3; Success; Boolean)
        {
            Caption = 'Success';
        }

        field(4; Message; Text[250])
        {
            Caption = 'Message';
        }

        field(5; "Created At"; DateTime)
        {
            Caption = 'Created At';
        }

        field(6; "Pick No."; Code[20])
        {
            Caption = 'Pick No.';
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


page 50205 "Buhler Create Warehouse Pick"
{
    PageType = API;
    Caption = 'Buhler Create Warehouse Pick';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'BuhlerCreateWarehousePick';
    EntitySetName = 'BuhlerCreateWarehousePicks';

    SourceTable = "Buhler Create Pick Buffer";
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

                field(pickNo; Rec."Pick No.")
                {
                    Caption = 'Pick No.';
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
        Rec."Pick No." := '';
        Rec."Created At" := CurrentDateTime();

        CreateWarehousePick();

        Rec.Success := true;

        Rec.Message :=
            CopyStr(
                StrSubstNo(
                    'Pluk %1 blev oprettet for lagerstedsforsendelse %2.',
                    Rec."Pick No.",
                    Rec."Warehouse Shipment No."),
                1,
                MaxStrLen(Rec.Message));

        exit(true);
    end;


    local procedure CreateWarehousePick()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
        CreatePickReport: Report "Whse.-Shipment - Create Pick";
        SortingMethod: Enum "Whse. Activity Sorting Method";
        ExistingPickNumbers: Dictionary of [Code[20], Boolean];
        WarehouseShipmentNo: Code[20];
        PickLineCountBefore: Integer;
        PickLineCountAfter: Integer;
    begin
        WarehouseShipmentNo :=
            DelChr(
                Rec."Warehouse Shipment No.",
                '<>',
                ' ');

        if WarehouseShipmentNo = '' then
            Error(
                'Feltet warehouseShipmentNo skal udfyldes.');

        Rec."Warehouse Shipment No." :=
            WarehouseShipmentNo;

        if not WarehouseShipmentHeader.Get(
            WarehouseShipmentNo)
        then
            Error(
                'Lagerstedsforsendelse %1 blev ikke fundet.',
                WarehouseShipmentNo);

        /*
        Hvis lagerstedsforsendelsen er frigivet,
        genåbnes den først.
        */
        if WarehouseShipmentHeader.Status =
           WarehouseShipmentHeader.Status::Released
        then begin
            WhseShipmentRelease.Reopen(
                WarehouseShipmentHeader);

            WarehouseShipmentHeader.Get(
                WarehouseShipmentNo);
        end;

        /*
        Kontrollér, at lagerstedsforsendelsen
        nu er åben.
        */
        if WarehouseShipmentHeader.Status <>
           WarehouseShipmentHeader.Status::Open
        then
            Error(
                'Lagerstedsforsendelse %1 kunne ikke åbnes. Aktuel status er %2.',
                WarehouseShipmentNo,
                Format(WarehouseShipmentHeader.Status));

        WarehouseShipmentLine.Reset();

        WarehouseShipmentLine.SetRange(
            "No.",
            WarehouseShipmentNo);

        WarehouseShipmentLine.SetFilter(
            "Qty. (Base)",
            '>0');

        if not WarehouseShipmentLine.FindFirst() then
            Error(
                'Lagerstedsforsendelse %1 har ingen linjer med et antal større end 0.',
                WarehouseShipmentNo);

        /*
        Plukrapporten kræver en frigivet
        lagerstedsforsendelse.
        */
        WarehouseShipmentHeader.Get(
            WarehouseShipmentNo);

        WhseShipmentRelease.Release(
            WarehouseShipmentHeader);

        WarehouseShipmentHeader.Get(
            WarehouseShipmentNo);

        if WarehouseShipmentHeader.Status <>
           WarehouseShipmentHeader.Status::Released
        then
            Error(
                'Lagerstedsforsendelse %1 kunne ikke frigives. Aktuel status er %2.',
                WarehouseShipmentNo,
                Format(WarehouseShipmentHeader.Status));

        /*
        Hent linjerne igen efter genåbning og
        frigivelse, så rapporten får en opdateret
        record og de korrekte filtre.
        */
        WarehouseShipmentLine.Reset();

        WarehouseShipmentLine.SetRange(
            "No.",
            WarehouseShipmentNo);

        WarehouseShipmentLine.SetFilter(
            "Qty. (Base)",
            '>0');

        if not WarehouseShipmentLine.FindFirst() then
            Error(
                'Lagerstedsforsendelse %1 har ingen linjer, der kan bruges til oprettelse af pluk.',
                WarehouseShipmentNo);

        /*
        Gem alle eksisterende pluknumre for
        lagerstedsforsendelsen, før rapporten køres.
        */
        SaveExistingPickNumbers(
            WarehouseShipmentNo,
            ExistingPickNumbers);

        /*
        Tæl eksisterende pluklinjer før
        rapporten køres.
        */
        WarehouseActivityLine.Reset();

        WarehouseActivityLine.SetRange(
            "Activity Type",
            WarehouseActivityLine."Activity Type"::Pick);

        WarehouseActivityLine.SetRange(
            "Whse. Document Type",
            WarehouseActivityLine."Whse. Document Type"::Shipment);

        WarehouseActivityLine.SetRange(
            "Whse. Document No.",
            WarehouseShipmentNo);

        PickLineCountBefore :=
            WarehouseActivityLine.Count();

        Clear(CreatePickReport);
        Clear(SortingMethod);

        CreatePickReport.SetWhseShipmentLine(
            WarehouseShipmentLine,
            WarehouseShipmentHeader);

        CreatePickReport.Initialize(
            '',
            SortingMethod,
            false,
            false,
            false,
            false);

        CreatePickReport.SetHideValidationDialog(
            true);

        CreatePickReport.SetHideNothingToHandleError(
            false);

        CreatePickReport.UseRequestPage(
            false);

        CreatePickReport.RunModal();

        /*
        Kontrollér, at rapporten har oprettet
        nye lageraktivitetslinjer.
        */
        WarehouseActivityLine.Reset();

        WarehouseActivityLine.SetRange(
            "Activity Type",
            WarehouseActivityLine."Activity Type"::Pick);

        WarehouseActivityLine.SetRange(
            "Whse. Document Type",
            WarehouseActivityLine."Whse. Document Type"::Shipment);

        WarehouseActivityLine.SetRange(
            "Whse. Document No.",
            WarehouseShipmentNo);

        PickLineCountAfter :=
            WarehouseActivityLine.Count();

        if PickLineCountAfter <= PickLineCountBefore then
            Error(
                'Rapporten blev kørt, men der blev ikke oprettet nye pluklinjer for lagerstedsforsendelse %1. Kontrollér, om der allerede findes et pluk, eller om der stadig er et antal, der skal plukkes.',
                WarehouseShipmentNo);

        /*
        Find det pluknummer, som ikke eksisterede
        før rapporten blev kørt.
        */
        Rec."Pick No." :=
            FindNewPickNumber(
                WarehouseShipmentNo,
                ExistingPickNumbers);

        if Rec."Pick No." = '' then
            Error(
                'Pluklinjerne blev oprettet, men det nye pluknummer kunne ikke findes.');
    end;


    local procedure SaveExistingPickNumbers(
        WarehouseShipmentNo: Code[20];
        var ExistingPickNumbers: Dictionary of [Code[20], Boolean])
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        PickNo: Code[20];
    begin
        Clear(ExistingPickNumbers);

        WarehouseActivityLine.Reset();

        WarehouseActivityLine.SetRange(
            "Activity Type",
            WarehouseActivityLine."Activity Type"::Pick);

        WarehouseActivityLine.SetRange(
            "Whse. Document Type",
            WarehouseActivityLine."Whse. Document Type"::Shipment);

        WarehouseActivityLine.SetRange(
            "Whse. Document No.",
            WarehouseShipmentNo);

        if not WarehouseActivityLine.FindSet() then
            exit;

        repeat
            PickNo :=
                WarehouseActivityLine."No.";

            if not ExistingPickNumbers.ContainsKey(PickNo) then
                ExistingPickNumbers.Add(
                    PickNo,
                    true);
        until WarehouseActivityLine.Next() = 0;
    end;


    local procedure FindNewPickNumber(
        WarehouseShipmentNo: Code[20];
        ExistingPickNumbers: Dictionary of [Code[20], Boolean]): Code[20]
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        PickNo: Code[20];
    begin
        WarehouseActivityLine.Reset();

        WarehouseActivityLine.SetRange(
            "Activity Type",
            WarehouseActivityLine."Activity Type"::Pick);

        WarehouseActivityLine.SetRange(
            "Whse. Document Type",
            WarehouseActivityLine."Whse. Document Type"::Shipment);

        WarehouseActivityLine.SetRange(
            "Whse. Document No.",
            WarehouseShipmentNo);

        WarehouseActivityLine.SetCurrentKey(
            "Activity Type",
            "No.",
            "Line No.");

        if not WarehouseActivityLine.FindSet() then
            exit('');

        repeat
            PickNo :=
                WarehouseActivityLine."No.";

            if not ExistingPickNumbers.ContainsKey(PickNo) then
                exit(PickNo);
        until WarehouseActivityLine.Next() = 0;

        exit('');
    end;
}