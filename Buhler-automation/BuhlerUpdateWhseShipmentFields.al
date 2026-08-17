table 50207 "Buhler Update Whse Shpt Buf"
{
    Caption = 'Buhler Update Warehouse Shipment Buffer';
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

        field(3; "Actual Weight"; Decimal)
        {
            Caption = 'Actual Weight';
            DecimalPlaces = 0 : 5;
        }

        field(4; "Actual Load Meter"; Decimal)
        {
            Caption = 'Actual Load Meter';
            DecimalPlaces = 0 : 5;
        }

        field(5; "Actual Number of Packages"; Decimal)
        {
            Caption = 'Actual Number of Packages';
            DecimalPlaces = 0 : 5;
        }

        field(6; Success; Boolean)
        {
            Caption = 'Success';
        }

        field(7; Message; Text[250])
        {
            Caption = 'Message';
        }

        field(8; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
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


page 50207 "Buhler Update Whse Shipment"
{
    PageType = API;
    Caption = 'Buhler Update Warehouse Shipment';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'BuhlerUpdateWarehouseShipment';
    EntitySetName = 'BuhlerUpdateWarehouseShipments';

    SourceTable = "Buhler Update Whse Shpt Buf";
    ODataKeyFields = SystemId;

    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;

    Permissions =
        tabledata "Warehouse Shipment Header" = RM;

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

                field(actualWeight; Rec."Actual Weight")
                {
                    Caption = 'Actual Weight';
                }

                field(actualLoadMeter; Rec."Actual Load Meter")
                {
                    Caption = 'Actual Load Meter';
                }

                field(actualNumberOfPackages; Rec."Actual Number of Packages")
                {
                    Caption = 'Actual Number of Packages';
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

                field(updatedAt; Rec."Updated At")
                {
                    Caption = 'Updated At';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Success := false;
        Rec.Message := '';
        Rec."Updated At" := 0DT;

        UpdateWarehouseShipment();

        Rec.Success := true;
        Rec."Updated At" := CurrentDateTime();

        Rec.Message :=
            CopyStr(
                StrSubstNo(
                    'Lagerstedsforsendelse %1 blev opdateret.',
                    Rec."Warehouse Shipment No."),
                1,
                MaxStrLen(Rec.Message));

        exit(true);
    end;


    local procedure UpdateWarehouseShipment()
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentNo: Code[20];
    begin
        WarehouseShipmentNo :=
            CopyStr(
                DelChr(
                    Rec."Warehouse Shipment No.",
                    '<>',
                    ' '),
                1,
                MaxStrLen(WarehouseShipmentNo));

        if WarehouseShipmentNo = '' then
            Error(
                'Feltet warehouseShipmentNo skal udfyldes.');

        Rec."Warehouse Shipment No." := WarehouseShipmentNo;

        if Rec."Actual Weight" < 0 then
            Error(
                'Actual Weight må ikke være mindre end 0.');

        if Rec."Actual Load Meter" < 0 then
            Error(
                'Actual Load Meter må ikke være mindre end 0.');

        if Rec."Actual Number of Packages" < 0 then
            Error(
                'Actual Number of Packages må ikke være mindre end 0.');

        if not WarehouseShipmentHeader.Get(
            WarehouseShipmentNo)
        then
            Error(
                'Lagerstedsforsendelse %1 blev ikke fundet.',
                WarehouseShipmentNo);

        WarehouseShipmentHeader.Validate(
            "Actual Weight_EVAS",
            Rec."Actual Weight");

        WarehouseShipmentHeader.Validate(
            "Actual Load Meter_EVAS",
            Rec."Actual Load Meter");

        WarehouseShipmentHeader.Validate(
            "Act. Number of Packag._EVAS",
            Rec."Actual Number of Packages");

        WarehouseShipmentHeader.Modify(true);
    end;
}