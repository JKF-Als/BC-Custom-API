page 50261 "Custom Item API"
{
    PageType = API;
    Caption = 'JKF Item API';
    SourceTable = Item;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'JKFItems';
    EntitySetName = 'JKFItems';
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { }
                field(number; Rec."No.") { }
                field(displayName; Rec.Description) { }
                field(description2; Rec."Description 2") { }
                field(itemCategoryCode; Rec."Item Category Code") { }
                field(productGroupCode; Rec."Item Group Code_EVAS") { }
                field(baseUnitOfMeasure; Rec."Base Unit of Measure") { }
                field(blocked; Rec.Blocked) { }
                field(netWeight; Rec."Net Weight") { }
                field(grossWeight; Rec."Gross Weight") { }
            }
            part(variants; "JKF Item Variant API")
            {
                EntityName = 'variant';
                EntitySetName = 'variants';
                SubPageLink = "Item No." = field("No.");
            }
        }
    }
}
