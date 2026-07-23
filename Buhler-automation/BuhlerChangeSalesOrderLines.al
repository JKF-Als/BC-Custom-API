page 50203 "Buhler Change S Order Lines"
{
    PageType = API;
    Caption = 'Buhler Change Sales Order Lines';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'BuhlerChangeSalesOrderLine';
    EntitySetName = 'BuhlerChangeSalesOrderLines';

    SourceTable = "Sales Line";
    SourceTableView = where("Document Type" = const(Order));

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

                field(documentNo; DocumentNo)
                {
                    Caption = 'Document No.';
                }

                field(number; ItemNo)
                {
                    Caption = 'Item No.';
                }

                field(quantity; LineQuantity)
                {
                    Caption = 'Quantity';
                }

                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                    Editable = false;
                }

                field(type; Rec.Type)
                {
                    Caption = 'Type';
                    Editable = false;
                }

                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                }

                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SalesHeader: Record "Sales Header";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        WasReleased: Boolean;
    begin
        ValidateRequest();

        if not SalesHeader.Get(
            SalesHeader."Document Type"::Order,
            DocumentNo)
        then
            Error(
                'Salgsordre %1 blev ikke fundet.',
                DocumentNo);

        WasReleased :=
            SalesHeader.Status = SalesHeader.Status::Released;

        if WasReleased then
            ReleaseSalesDocument.PerformManualReopen(SalesHeader);

        Rec.Init();
        Rec.Validate(
            "Document Type",
            Rec."Document Type"::Order);

        Rec.Validate(
            "Document No.",
            DocumentNo);

        Rec."Line No." := GetNextLineNo(DocumentNo);

        Rec.Validate(
            Type,
            Rec.Type::Item);

        Rec.Validate(
            "No.",
            ItemNo);

        Rec.Validate(
            Quantity,
            LineQuantity);

        Rec.Insert(true);

        if WasReleased then begin
            SalesHeader.Get(
                SalesHeader."Document Type"::Order,
                DocumentNo);

            ReleaseSalesDocument.PerformManualRelease(
                SalesHeader);
        end;

        // Linjen er allerede indsat manuelt ovenfor.
        // False forhindrer API-siden i at indsætte den igen.
        exit(false);
    end;

    local procedure ValidateRequest()
    var
        Item: Record Item;
    begin
        if DocumentNo = '' then
            Error('Feltet documentNo skal udfyldes.');

        if ItemNo = '' then
            Error('Feltet number skal udfyldes.');

        if LineQuantity <= 0 then
            Error('Quantity skal være større end 0.');

        if not Item.Get(ItemNo) then
            Error(
                'Varen %1 blev ikke fundet.',
                ItemNo);
    end;

    local procedure GetNextLineNo(
        SalesOrderNo: Code[20]
    ): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange(
            "Document Type",
            SalesLine."Document Type"::Order);

        SalesLine.SetRange(
            "Document No.",
            SalesOrderNo);

        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000);

        exit(10000);
    end;

    var
        DocumentNo: Code[20];
        ItemNo: Code[20];
        LineQuantity: Decimal;
}