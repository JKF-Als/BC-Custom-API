namespace JKF.CustomAPIs;

using Microsoft.Sales.History;
using Microsoft.Warehouse.History;
using Microsoft.Sales.Document;
page 50229 "JKF CMR API"
{
    PageType = API;
    Caption = 'JKF CMR API';
    APIPublisher = 'jkf';
    APIGroup = 'cmr';
    APIVersion = 'v1.0';
    EntityName = 'cmrShipment';
    EntitySetName = 'cmrShipments';
    SourceTable = "Sales Shipment Header";
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Shipments)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(shipmentNumber; Rec."No.")
                {
                    Caption = 'Shipment Number';
                    Editable = false;
                }
                field(orderNumber; Rec."Order No.")
                {
                    Caption = 'Order Number';
                    Editable = false;
                }
                field(plannedShipmentDate; PlannedShipmentDate)
                {
                    Caption = 'Planned Shipment Date';
                    Editable = false;
                }
                field(customerNumber; Rec."Sell-to Customer No.")
                {
                    Caption = 'Customer Number';
                    Editable = false;
                }
                field(customerName; Rec."Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    Editable = false;
                }
                field(customerName2; Rec."Sell-to Customer Name 2")
                {
                    Caption = 'Customer Name 2';
                    Editable = false;
                }
                field(customerAddress; Rec."Sell-to Address")
                {
                    Caption = 'Customer Address';
                    Editable = false;
                }
                field(customerAddress2; Rec."Sell-to Address 2")
                {
                    Caption = 'Customer Address 2';
                    Editable = false;
                }
                field(customerPostCode; Rec."Sell-to Post Code")
                {
                    Caption = 'Customer Post Code';
                    Editable = false;
                }
                field(customerCity; Rec."Sell-to City")
                {
                    Caption = 'Customer City';
                    Editable = false;
                }
                field(customerCountryRegionCode; Rec."Sell-to Country/Region Code")
                {
                    Caption = 'Customer Country/Region Code';
                    Editable = false;
                }
                field(shipToName; Rec."Ship-to Name")
                {
                    Caption = 'Ship-to Name';
                    Editable = false;
                }
                field(shipToName2; Rec."Ship-to Name 2")
                {
                    Caption = 'Ship-to Name 2';
                    Editable = false;
                }
                field(shipToAddress; Rec."Ship-to Address")
                {
                    Caption = 'Ship-to Address';
                    Editable = false;
                }
                field(shipToAddress2; Rec."Ship-to Address 2")
                {
                    Caption = 'Ship-to Address 2';
                    Editable = false;
                }
                field(shipToPostCode; Rec."Ship-to Post Code")
                {
                    Caption = 'Ship-to Post Code';
                    Editable = false;
                }
                field(shipToCity; Rec."Ship-to City")
                {
                    Caption = 'Ship-to City';
                    Editable = false;
                }
                field(shipToCountryRegionCode; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Ship-to Country/Region Code';
                    Editable = false;
                }
                field(actualPackageCount; ActualPackageCount)
                {
                    Caption = 'Actual Package Count';
                    Editable = false;
                }
                field(actualLoadingMeters; ActualLoadingMeters)
                {
                    Caption = 'Actual Loading Meters';
                    Editable = false;
                }
                field(actualWeight; ActualWeight)
                {
                    Caption = 'Actual Weight';
                    Editable = false;
                }
                field(shipmentMethodCode; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method Code';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
    end;

    trigger OnAfterGetRecord()
    begin
        PlannedShipmentDate := GetDateFieldValue(Rec, 60013);
        CalculateActualShipmentValues();
    end;

    local procedure CalculateActualShipmentValues()
    var
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        ProcessedShipmentNumbers: List of [Code[20]];
    begin
        Clear(ActualPackageCount);
        Clear(ActualLoadingMeters);
        Clear(ActualWeight);

        if Rec."Order No." = '' then
            exit;

        // Prefer the posted sales shipment number. This prevents values from
        // other partial shipments on the same sales order from being included.
        PostedWhseShipmentLine.SetRange("Source Type", Database::"Sales Line");
        PostedWhseShipmentLine.SetRange("Posted Source No.", Rec."No.");

        if PostedWhseShipmentLine.FindSet() then begin
            AddActualShipmentValues(
                PostedWhseShipmentLine,
                ProcessedShipmentNumbers);
            exit;
        end;

        // Fallback for older migrated records where Posted Source No. is blank.
        PostedWhseShipmentLine.Reset();
        PostedWhseShipmentLine.SetRange("Source Type", Database::"Sales Line");
        PostedWhseShipmentLine.SetRange("Source No.", Rec."Order No.");

        if PostedWhseShipmentLine.FindSet() then
            AddActualShipmentValues(
                PostedWhseShipmentLine,
                ProcessedShipmentNumbers);
    end;

    local procedure AddActualShipmentValues(
        var PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        var ProcessedShipmentNumbers: List of [Code[20]])
    var
        PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header";
    begin
        repeat
            if not ProcessedShipmentNumbers.Contains(PostedWhseShipmentLine."No.") then begin
                ProcessedShipmentNumbers.Add(PostedWhseShipmentLine."No.");

                if PostedWhseShipmentHeader.Get(PostedWhseShipmentLine."No.") then begin
                    ActualPackageCount +=
                        GetDecimalFieldValue(
                            PostedWhseShipmentHeader,
                            60005);
                    ActualLoadingMeters +=
                        GetDecimalFieldValue(
                            PostedWhseShipmentHeader,
                            60004);
                    ActualWeight +=
                        GetDecimalFieldValue(
                            PostedWhseShipmentHeader,
                            60003);
                end;
            end;
        until PostedWhseShipmentLine.Next() = 0;
    end;

    local procedure GetDecimalFieldValue(RecordVariant: Variant; FieldNo: Integer): Decimal
    var
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        DecimalValue: Decimal;
    begin
        RecordReference.GetTable(RecordVariant);

        if not RecordReference.FieldExist(FieldNo) then
            Error(MissingFieldErr, FieldNo, RecordReference.Caption);

        FieldReference := RecordReference.Field(FieldNo);

        if not Evaluate(DecimalValue, Format(FieldReference)) then
            Error(InvalidDecimalFieldErr, FieldNo, RecordReference.Caption);

        exit(DecimalValue);
    end;

    local procedure GetDateFieldValue(RecordVariant: Variant; FieldNo: Integer): Date
    var
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        DateValue: Date;
        FormattedValue: Text;
    begin
        RecordReference.GetTable(RecordVariant);

        if not RecordReference.FieldExist(FieldNo) then
            Error(MissingFieldErr, FieldNo, RecordReference.Caption);

        FieldReference := RecordReference.Field(FieldNo);
        FormattedValue := Format(FieldReference);

        if FormattedValue = '' then
            exit(0D);

        if not Evaluate(DateValue, FormattedValue) then
            Error(InvalidDateFieldErr, FieldNo, RecordReference.Caption);

        exit(DateValue);
    end;

    var
        PlannedShipmentDate: Date;
        ActualPackageCount: Decimal;
        ActualLoadingMeters: Decimal;
        ActualWeight: Decimal;
        MissingFieldErr: Label 'Field %1 does not exist in table %2.';
        InvalidDecimalFieldErr: Label 'Field %1 in table %2 is not a decimal value.';
        InvalidDateFieldErr: Label 'Field %1 in table %2 is not a date value.';
}

permissionset 50230 "JKF CMR API"
{
    Assignable = true;
    Caption = 'JKF CMR API';

    Permissions =
        tabledata "Sales Shipment Header" = R,
        tabledata "Posted Whse. Shipment Header" = R,
        tabledata "Posted Whse. Shipment Line" = R,
        page "JKF CMR API" = X;
}
