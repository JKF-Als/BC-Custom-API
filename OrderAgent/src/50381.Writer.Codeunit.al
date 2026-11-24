namespace JKF.OrderAgent;
using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.Attachment;
using System.Text;
using System.Utilities;

codeunit 50381 "JKF Agent Writer"
{
    // Caller receives only INDIRECT write rights. No general Sales page or posting access.
    Permissions = tabledata "Sales Header" = RIM,
                  tabledata "Sales Line" = RIM,
                  tabledata "Document Attachment" = RI;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Execute(var Request: Record "JKF Agent Request"; Payload: Text)
    var
        Guard: Codeunit "JKF Agent Guard";
        Header: Record "Sales Header";
        Body: JsonObject;
        Operation: Text;
        OldPayload: Text;
        Input: InStream;
        Output: OutStream;
        Dimensions: Dictionary of [Text, Text];
    begin
        Guard.CheckEnvironment();
        if StrLen(Payload) > 14000000 then
            Error('Payload is too large.');
        // Serializes retries and prevents duplicate execution of the same request.
        Request.LockTable();
        Request.Get(Request."Request Id");
        if Request.Completed then begin
            Request.CalcFields(Payload);
            Request.Payload.CreateInStream(Input, TextEncoding::UTF8);
            Input.Read(OldPayload);
            if OldPayload <> Payload then
                Error('This requestId has already been used with a different payload.');
            exit;
        end;
        if not Body.ReadFrom(Payload) then
            Error('payload must be a JSON object encoded as a string.');
        Operation := GetText(Body, 'operation');
        Header.LockTable();
        case Operation of
            'create': CreateDraft(Body, Header);
            'update': UpdateDraft(Body, Header);
            'attach': Attach(Body, Header);
            else Error('operation must be create, update or attach.');
        end;
        Header.TestField(Status, Header.Status::Open);
        Request.Completed := true;
        Request."Document Id" := Header.SystemId;
        Request."Document No." := Header."No.";
        Request.Payload.CreateOutStream(Output, TextEncoding::UTF8);
        // Paired binary Text Write/Read preserves embedded line endings for exact retries.
        Output.Write(Payload);
        Request.Modify(true);
        Dimensions.Add('operation', Operation);
        Session.LogMessage('JKFAG002', 'Order agent draft operation completed.', Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
    end;

    local procedure CreateDraft(Body: JsonObject; var Header: Record "Sales Header")
    var
        Existing: Record "Sales Header";
        Customer: Record Customer;
        TypeName: Text;
        CustomerNo: Code[20];
        ExternalNo: Code[35];
        Token: JsonToken;
    begin
        CheckKeys(Body, 'operation,documentType,customerNumber,externalDocumentNumber,orderDate,lines');
        CustomerNo := CheckedText(Body, 'customerNumber', 20);
        ExternalNo := CheckedText(Body, 'externalDocumentNumber', 35);
        Customer.Get(CustomerNo);
        Customer.TestField(Blocked, Customer.Blocked::" ");
        Existing.SetFilter("Document Type", '%1|%2', Existing."Document Type"::Quote, Existing."Document Type"::Order);
        Existing.SetRange("Sell-to Customer No.", CustomerNo);
        Existing.SetRange("External Document No.", ExternalNo);
        if not Existing.IsEmpty() then
            Error('An open or released quote/order already has this customer and external document number.');
        Header.Init();
        TypeName := GetText(Body, 'documentType');
        case TypeName of
            'Order': Header."Document Type" := Header."Document Type"::Order;
            'Quote': Header."Document Type" := Header."Document Type"::Quote;
            else Error('documentType must be Order or Quote.');
        end;
        Header.Insert(true);
        Header.Validate("Sell-to Customer No.", CustomerNo);
        if Body.Get('orderDate', Token) then
            Header.Validate("Order Date", Token.AsValue().AsDate());
        Header.Validate("External Document No.", ExternalNo);
        Header."JKF Agent Draft" := true;
        Header.Modify(true);
        ApplyLines(Body, Header, false);
    end;

    local procedure UpdateDraft(Body: JsonObject; var Header: Record "Sales Header")
    begin
        CheckKeys(Body, 'operation,documentId,expectedModifiedAt,lines');
        GetOwnedDraft(Body, Header);
        ApplyLines(Body, Header, true);
        // Ensure the header concurrency timestamp changes even for line-only updates.
        Header.Modify(true);
    end;

    local procedure GetOwnedDraft(Body: JsonObject; var Header: Record "Sales Header")
    var
        Token: JsonToken;
        DocumentId: Guid;
    begin
        if not Evaluate(DocumentId, GetText(Body, 'documentId')) then
            Error('documentId must be a GUID.');
        if not Header.GetBySystemId(DocumentId) then
            Error('Sales document does not exist.');
        if not (Header."Document Type" in [Header."Document Type"::Quote, Header."Document Type"::Order]) then
            Error('Only quotes and orders are supported.');
        Header.TestField("JKF Agent Draft", true);
        Header.TestField(Status, Header.Status::Open);
        Require(Body, 'expectedModifiedAt', Token);
        if Header.SystemModifiedAt <> Token.AsValue().AsDateTime() then
            Error('Document changed. Read the header and lines again before retrying.');
    end;

    local procedure ApplyLines(Body: JsonObject; Header: Record "Sales Header"; Updating: Boolean)
    var
        Lines: JsonArray;
        Token: JsonToken;
        Entry: JsonToken;
        LineBody: JsonObject;
        Line: Record "Sales Line";
        Item: Record Item;
        Customer: Record Customer;
        LineNo: Integer;
        Quantity: Decimal;
        ItemNo: Code[20];
    begin
        Customer.Get(Header."Sell-to Customer No.");
        Customer.TestField(Blocked, Customer.Blocked::" ");
        Require(Body, 'lines', Token);
        Lines := Token.AsArray();
        if (Lines.Count() = 0) or (Lines.Count() > 500) then
            Error('Use between 1 and 500 item lines.');
        Line.LockTable();
        foreach Entry in Lines do begin
            LineBody := Entry.AsObject();
            CheckKeys(LineBody, 'lineNumber,itemNumber,quantity,unitOfMeasureCode,variantCode,locationCode,expectedModifiedAt');
            Require(LineBody, 'lineNumber', Token);
            LineNo := Token.AsValue().AsInteger();
            if LineNo <= 0 then
                Error('lineNumber must be positive.');
            Require(LineBody, 'quantity', Token);
            Quantity := Token.AsValue().AsDecimal();
            if Quantity <= 0 then
                Error('quantity must be positive. Deletion and zero quantities are not supported.');
            ItemNo := CheckedText(LineBody, 'itemNumber', 20);
            Item.Get(ItemNo);
            Item.TestField(Blocked, false);
            Item.TestField("Sales Blocked", false);
            if Line.Get(Header."Document Type", Header."No.", LineNo) then begin
                if not Updating then
                    Error('Duplicate lineNumber in request.');
                Require(LineBody, 'expectedModifiedAt', Token);
                if Line.SystemModifiedAt <> Token.AsValue().AsDateTime() then
                    Error('Sales line changed. Read it again before retrying.');
                Line.TestField(Type, Line.Type::Item);
                Line.TestField("No.", ItemNo);
                Line.TestField("Quantity Shipped", 0);
                Line.TestField("Quantity Invoiced", 0);
                // Quantity-only editing avoids destructive item/variant changes and reservation side effects.
                if LineBody.Get('unitOfMeasureCode', Token) then
                    Line.TestField("Unit of Measure Code", CheckedText(LineBody, 'unitOfMeasureCode', 10));
                if LineBody.Get('variantCode', Token) then
                    Line.TestField("Variant Code", CheckedText(LineBody, 'variantCode', 10));
                if LineBody.Get('locationCode', Token) then
                    Line.TestField("Location Code", CheckedText(LineBody, 'locationCode', 10));
                Line.Validate(Quantity, Quantity);
                Line.Modify(true);
            end else begin
                Line.Init();
                Line."Document Type" := Header."Document Type";
                Line."Document No." := Header."No.";
                Line."Line No." := LineNo;
                Line.Insert(true);
                Line.Validate(Type, Line.Type::Item);
                Line.Validate("No.", ItemNo);
                if LineBody.Get('variantCode', Token) then
                    Line.Validate("Variant Code", CheckedText(LineBody, 'variantCode', 10));
                if LineBody.Get('unitOfMeasureCode', Token) then
                    Line.Validate("Unit of Measure Code", CheckedText(LineBody, 'unitOfMeasureCode', 10));
                if LineBody.Get('locationCode', Token) then
                    Line.Validate("Location Code", CheckedText(LineBody, 'locationCode', 10));
                Line.Validate(Quantity, Quantity);
                // No unit price or discount input: BC's validation calculates both.
                Line.Modify(true);
            end;
        end;
    end;

    local procedure Attach(Body: JsonObject; var Header: Record "Sales Header")
    var
        Attachment: Record "Document Attachment";
        Base64: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        Ref: RecordRef;
        Output: OutStream;
        Input: InStream;
        FileName: Text;
    begin
        CheckKeys(Body, 'operation,documentId,expectedModifiedAt,fileName,contentBase64');
        GetOwnedDraft(Body, Header);
        FileName := CheckedText(Body, 'fileName', 100);
        if (StrPos(FileName, '/') > 0) or (StrPos(FileName, '\') > 0) then
            Error('fileName must not contain a path.');
        TempBlob.CreateOutStream(Output);
        Base64.FromBase64(GetText(Body, 'contentBase64'), Output);
        if (TempBlob.Length() = 0) or (TempBlob.Length() > 10485760) then
            Error('Attachment must be between 1 byte and 10 MiB.');
        TempBlob.CreateInStream(Input);
        Ref.GetTable(Header);
        Attachment.SaveAttachmentFromStream(Input, Ref, FileName);
        Header.Modify(true);
    end;

    local procedure Require(Body: JsonObject; Name: Text; var Token: JsonToken)
    begin
        if not Body.Get(Name, Token) then
            Error('Missing property: %1.', Name);
        if Token.IsValue() then
            if Token.AsValue().IsNull() then
                Error('Property %1 cannot be null.', Name);
    end;

    local procedure GetText(Body: JsonObject; Name: Text): Text
    var
        Token: JsonToken;
    begin
        Require(Body, Name, Token);
        exit(Token.AsValue().AsText());
    end;

    local procedure CheckedText(Body: JsonObject; Name: Text; Maximum: Integer): Text
    var
        Value: Text;
    begin
        Value := GetText(Body, Name);
        if (StrLen(Value) > Maximum) or ((Value = '') and (Name in ['customerNumber', 'externalDocumentNumber', 'itemNumber', 'fileName'])) then
            Error('Invalid length for %1. Maximum is %2.', Name, Maximum);
        exit(Value);
    end;

    local procedure CheckKeys(Body: JsonObject; Allowed: Text)
    var
        Name: Text;
    begin
        foreach Name in Body.Keys() do
            if StrPos(',' + Allowed + ',', ',' + Name + ',') = 0 then
                Error('Property %1 is not allowed.', Name);
    end;
}
