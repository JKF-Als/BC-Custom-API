page 50344 "JKF API Pick Lines"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'scanner';
    APIVersion = 'v1.0';
    EntityName = 'pickLine';
    EntitySetName = 'pickLines';
    EntityCaption = 'Pluklinje';
    EntitySetCaption = 'Pluklinjer';
    SourceTable = "Warehouse Activity Line";
    SourceTableView = sorting("Activity Type", "No.", "Sorting Sequence No.") where("Activity Type" = const(Pick));
    ODataKeyFields = SystemId;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { }
                field(pickNumber; Rec."No.") { }
                field(lineNumber; Rec."Line No.") { }
                field(actionType; Rec."Action Type") { }
                field(locationCode; Rec."Location Code") { }
                field(itemNumber; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(description; Rec.Description) { }
                field(description2; Rec."Description 2") { }
                field(binCode; Rec."Bin Code") { }
                field(zoneCode; Rec."Zone Code") { }
                field(quantity; Rec.Quantity) { }
                field(quantityOutstanding; Rec."Qty. Outstanding") { }
                field(quantityToHandle; Rec."Qty. to Handle") { }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { }
                field(sourceNumber; Rec."Source No.") { }
                field(sourceLineNumber; Rec."Source Line No.") { }
                field(lotNumber; Rec."Lot No.") { }
                field(serialNumber; Rec."Serial No.") { }
                field(sortingSequenceNumber; Rec."Sorting Sequence No.") { }
            }
        }
    }
}
