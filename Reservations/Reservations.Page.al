namespace JKF.Reservations;

using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Document;

page 50271 "Reservations API"
{
    PageType = API;
    Caption = 'Reservations API';
    APIPublisher = 'jkf';
    APIGroup = 'reservations';
    APIVersion = 'v1.0';
    EntityName = 'reservation';
    EntitySetName = 'reservations';
    SourceTable = "Reservation Entry";
    SourceTableView = where(Positive = const(false), "Reservation Status" = const(Reservation));
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
                field(itemNo; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(locationCode; Rec."Location Code") { }
                field(reservedQuantity; ReservedQuantity) { }
                field(reservedQuantityBase; ReservedQuantityBase) { }
                field(shipmentDate; Rec."Shipment Date") { }
                field(lotNo; Rec."Lot No.") { }
                field(serialNo; Rec."Serial No.") { }
                field(reservedToSourceType; Rec."Source Type") { }
                field(reservedToSourceSubtype; SourceSubtype) { }
                field(reservedToSourceId; Rec."Source ID") { }
                field(reservedToSourceRefNo; Rec."Source Ref. No.") { }
                field(reservedToText; SourceText) { }
                field(reservedToSourceBatchName; Rec."Source Batch Name") { }
                field(reservedToProdOrderLineNo; Rec."Source Prod. Order Line") { }
                field(reservedToProductionStatus; DemandProductionStatus) { }
                field(reservedFromProductionStatus; SupplyProductionStatus) { }
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
        Clear(DemandProductionStatus);
        Clear(SupplyProductionStatus);
        Clear(SupplyEntry);
        Clear(SupplyText);
        Clear(SupplySubtype);

        SourceSubtype := Rec."Source Subtype";
        SourceText := SourceTextMgt.GetSourceText(Rec);
        ReservedQuantity := Abs(Rec.Quantity);
        ReservedQuantityBase := Abs(Rec."Quantity (Base)");

        if Rec."Source Type" in [5406, 5407] then
            DemandProductionStatus := Format(Enum::"Production Order Status".FromInteger(SourceSubtype));

        SupplyFound := SupplyEntry.Get(Rec."Entry No.", true);
        if SupplyFound then
            SupplyFound := SupplyEntry."Reservation Status" =
                SupplyEntry."Reservation Status"::Reservation;

        if SupplyFound then begin
            SupplySubtype := SupplyEntry."Source Subtype";
            SupplyText := SourceTextMgt.GetSourceText(SupplyEntry);
            if SupplyEntry."Source Type" in [5406, 5407] then
                SupplyProductionStatus := Format(Enum::"Production Order Status".FromInteger(SupplySubtype));
        end else
            Clear(SupplyEntry);
    end;

    var
        DemandProductionStatus: Text[100];
        SupplyProductionStatus: Text[100];
        SupplyEntry: Record "Reservation Entry";
        SourceTextMgt: Codeunit "Reserv Source Text";

        SupplyFound: Boolean;
        SourceSubtype: Integer;
        SupplySubtype: Integer;
        SourceText: Text[250];
        SupplyText: Text[250];
        ReservedQuantity: Decimal;
        ReservedQuantityBase: Decimal;
}
