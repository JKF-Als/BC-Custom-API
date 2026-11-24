page 50342 "JKF API Items"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'scanner';
    APIVersion = 'v1.0';
    EntityName = 'item';
    EntitySetName = 'items';
    EntityCaption = 'Vare';
    EntitySetCaption = 'Varer';
    SourceTable = Item;
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
                field(number; Rec."No.") { }
                field(description; Rec.Description) { }
                field(description2; Rec."Description 2") { }
                field(baseUnitOfMeasure; Rec."Base Unit of Measure") { }
                field(vendorNumber; Rec."Vendor No.") { }
                field(vendorName; VendorName) { }
                field(blocked; Rec.Blocked) { }
            }
        }
    }

    var
        VendorName: Text[100];

    trigger OnAfterGetRecord()
    var
        Vendor: Record Vendor;
    begin
        VendorName := '';
        if Rec."Vendor No." <> '' then
            if Vendor.Get(Rec."Vendor No.") then
                VendorName := Vendor.Name;
    end;
}
