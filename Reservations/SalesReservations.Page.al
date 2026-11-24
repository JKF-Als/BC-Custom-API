namespace JKF.Reservations;

using Microsoft.Inventory.Tracking;
using Microsoft.Sales.Document;

page 50270 "Sales Reservations API"
{
    PageType = API;
    Caption = 'Sales Reservations API';
    APIPublisher = 'jkf';
    APIGroup = 'reservations';
    APIVersion = 'v1.0';
    EntityName = 'salesReservation';
    EntitySetName = 'salesReservations';
    SourceTable = "Reservation Entry";
    SourceTableView = where("Source Type" = const(37),
                            "Source Subtype" = const(1),
                            Positive = const(false),
                            "Reservation Status" = const(Reservation));
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Reservations)
            {
                field(id; Rec.SystemId) { }
                field(entryNo; Rec."Entry No.") { }
                field(salesOrderNo; Rec."Source ID") { }
                field(salesOrderLineNo; Rec."Source Ref. No.") { }
                field(salesLineExists; SalesLineExists) { }
                field(salesLineId; SalesLine.SystemId) { }
                field(customerNo; SalesLine."Sell-to Customer No.") { }
                field(description; SalesLine.Description) { }
                field(unitOfMeasureCode; SalesLine."Unit of Measure Code") { }
                field(salesLineQuantity; SalesLine.Quantity) { }
                field(salesLineOutstandingQuantity; SalesLine."Outstanding Quantity") { }
                field(itemNo; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(locationCode; Rec."Location Code") { }
                field(reservedQuantity; ReservedQuantity) { }
                field(reservedQuantityBase; ReservedQuantityBase) { }
                field(shipmentDate; Rec."Shipment Date") { }
                field(lotNo; Rec."Lot No.") { }
                field(serialNo; Rec."Serial No.") { }
                field(sourceType; Rec."Source Type") { }
                field(sourceSubtype; SourceSubtype) { }
                field(sourceId; Rec."Source ID") { }
                field(sourceRefNo; Rec."Source Ref. No.") { }
                field(sourceText; SourceText) { }
                field(supplyFound; SupplyFound) { }
                field(reservedFromId; SupplyEntry.SystemId) { }
                field(reservedFromSourceType; SupplyEntry."Source Type") { }
                field(reservedFromSourceSubtype; SupplySubtype) { }
                field(reservedFromSourceId; SupplyEntry."Source ID") { }
                field(reservedFromSourceRefNo; SupplyEntry."Source Ref. No.") { }
                field(reservedFromSourceBatchName; SupplyEntry."Source Batch Name") { }
                field(reservedFromProdOrderLineNo; SupplyEntry."Source Prod. Order Line") { }
                field(reservedFromText; SupplyText) { }
                field(reservedFromItemNo; SupplyEntry."Item No.") { }
                field(reservedFromVariantCode; SupplyEntry."Variant Code") { }
                field(reservedFromLocationCode; SupplyEntry."Location Code") { }
                field(reservedFromQuantityBase; SupplyEntry."Quantity (Base)") { }
                field(reservedFromExpectedReceiptDate; SupplyEntry."Expected Receipt Date") { }
                field(reservedFromLotNo; SupplyEntry."Lot No.") { }
                field(reservedFromSerialNo; SupplyEntry."Serial No.") { }
                field(createdDate; Rec."Creation Date") { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // Always reset lookup values: API pages reuse variables between rows.
        Clear(SalesLine);
        Clear(SupplyEntry);
        Clear(SupplyText);
        Clear(SupplySubtype);

        SourceSubtype := Rec."Source Subtype";
        SourceText := SourceTextMgt.GetSourceText(Rec);
        ReservedQuantity := Abs(Rec.Quantity);
        ReservedQuantityBase := Abs(Rec."Quantity (Base)");

        SalesLineExists := SalesLine.Get(
            SalesLine."Document Type"::Order,
            Rec."Source ID", Rec."Source Ref. No.");
        if not SalesLineExists then
            Clear(SalesLine);

        SupplyFound := SupplyEntry.Get(Rec."Entry No.", true);
        if SupplyFound then
            SupplyFound := SupplyEntry."Reservation Status" =
                SupplyEntry."Reservation Status"::Reservation;

        if SupplyFound then begin
            SupplySubtype := SupplyEntry."Source Subtype";
            SupplyText := SourceTextMgt.GetSourceText(SupplyEntry);
        end else
            Clear(SupplyEntry);
    end;

    var
        SalesLine: Record "Sales Line";
        SupplyEntry: Record "Reservation Entry";
        SourceTextMgt: Codeunit "Reserv Source Text";
        SalesLineExists: Boolean;
        SupplyFound: Boolean;
        SourceSubtype: Integer;
        SupplySubtype: Integer;
        SourceText: Text[250];
        SupplyText: Text[250];
        ReservedQuantity: Decimal;
        ReservedQuantityBase: Decimal;
}
