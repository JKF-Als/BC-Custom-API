table 50206 "Buhler Register Pick Buffer"
{
    Caption = 'Buhler Register Pick Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Pick No."; Code[20])
        {
            Caption = 'Pick No.';
        }

        field(3; Success; Boolean)
        {
            Caption = 'Success';
        }

        field(4; Message; Text[250])
        {
            Caption = 'Message';
        }

        field(5; "Registered At"; DateTime)
        {
            Caption = 'Registered At';
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


page 50206 "Buhler Register Warehouse Pick"
{
    PageType = API;
    Caption = 'Buhler Register Warehouse Pick';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'BuhlerRegisterWarehousePick';
    EntitySetName = 'BuhlerRegisterWarehousePicks';

    SourceTable = "Buhler Register Pick Buffer";
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

                field(pickNo; Rec."Pick No.")
                {
                    Caption = 'Pick No.';
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

                field(registeredAt; Rec."Registered At")
                {
                    Caption = 'Registered At';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Success := false;
        Rec.Message := '';
        Rec."Registered At" := 0DT;

        RegisterWarehousePick();

        Rec.Success := true;
        Rec."Registered At" := CurrentDateTime();

        Rec.Message :=
            CopyStr(
                StrSubstNo(
                    'Pluk %1 blev registreret.',
                    Rec."Pick No."),
                1,
                MaxStrLen(Rec.Message));

        exit(true);
    end;


    local procedure RegisterWarehousePick()
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        PickNo: Code[20];
    begin
        PickNo :=
            CopyStr(
                DelChr(
                    Rec."Pick No.",
                    '<>',
                    ' '),
                1,
                MaxStrLen(PickNo));

        if PickNo = '' then
            Error(
                'Feltet pickNo skal udfyldes.');

        Rec."Pick No." := PickNo;

        WarehouseActivityHeader.Reset();

        WarehouseActivityHeader.SetRange(
            Type,
            WarehouseActivityHeader.Type::Pick);

        WarehouseActivityHeader.SetRange(
            "No.",
            PickNo);

        if not WarehouseActivityHeader.FindFirst() then
            Error(
                'Pluk %1 blev ikke fundet.',
                PickNo);

        WarehouseActivityLine.Reset();

        WarehouseActivityLine.SetRange(
            "Activity Type",
            WarehouseActivityLine."Activity Type"::Pick);

        WarehouseActivityLine.SetRange(
            "No.",
            PickNo);

        if not WarehouseActivityLine.FindFirst() then
            Error(
                'Der blev ikke fundet nogen linjer på pluk %1.',
                PickNo);

        ValidateWarehousePickLines(
            WarehouseActivityLine,
            PickNo);

        /*
        FindFirst placerer recorden på den første
        pluklinje. Standard-codeunit 7307 registrerer
        hele lageraktiviteten ud fra den filtrerede linje.
        */
        WarehouseActivityLine.FindFirst();

        Codeunit.Run(
            Codeunit::"Whse.-Activity-Register",
            WarehouseActivityLine);
    end;


    local procedure ValidateWarehousePickLines(
        var WarehouseActivityLine: Record "Warehouse Activity Line";
        PickNo: Code[20])
    var
        HasQuantityToHandle: Boolean;
    begin
        HasQuantityToHandle := false;

        if not WarehouseActivityLine.FindSet() then
            Error(
                'Der blev ikke fundet nogen linjer på pluk %1.',
                PickNo);

        repeat
            if WarehouseActivityLine."Qty. to Handle" > 0 then
                HasQuantityToHandle := true;

            if WarehouseActivityLine."Qty. to Handle" >
               WarehouseActivityLine."Qty. Outstanding"
            then
                Error(
                    'Håndteringsantallet er større end det udestående antal på linje %1 i pluk %2.',
                    WarehouseActivityLine."Line No.",
                    PickNo);
        until WarehouseActivityLine.Next() = 0;

        if not HasQuantityToHandle then
            Error(
                'Pluk %1 har intet håndteringsantal og kan derfor ikke registreres.',
                PickNo);
    end;
}