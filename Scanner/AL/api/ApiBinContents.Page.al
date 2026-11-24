page 50345 "JKF API Bin Contents"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'scanner';
    APIVersion = 'v1.0';
    EntityName = 'binContent';
    EntitySetName = 'binContents';
    EntityCaption = 'Placeringsindhold';
    EntitySetCaption = 'Placeringsindhold';
    SourceTable = "Bin Content";
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
                field(locationCode; Rec."Location Code") { }
                field(binCode; Rec."Bin Code") { }
                field(itemNumber; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { }
                field(default; Rec.Default) { }
                field(fixed; Rec.Fixed) { }
                field(quantity; Rec.Quantity) { }
                field(quantityBase; Rec."Quantity (Base)") { }
                field(availableQuantity; AvailableQty) { }
                field(itemDescription; ItemDescription) { }
                field(itemDescription2; ItemDescription2) { }
                field(vendorName; VendorName) { }
            }
        }
    }

    var
        AvailableQty: Decimal;
        ItemDescription: Text[100];
        ItemDescription2: Text[50];
        VendorName: Text[100];

    trigger OnAfterGetRecord()
    var
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        AvailableQty := Rec.CalcQtyAvailToTakeUOM();
        Clear(ItemDescription);
        Clear(ItemDescription2);
        Clear(VendorName);
        if Item.Get(Rec."Item No.") then begin
            ItemDescription := Item.Description;
            ItemDescription2 := Item."Description 2";
            if Item."Vendor No." <> '' then
                if Vendor.Get(Item."Vendor No.") then
                    VendorName := Vendor.Name;
        end;
    end;
}
