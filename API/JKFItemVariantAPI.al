page 50262 "JKF Item Variant API"
{
    PageType = API;
    Caption = 'JKF Item Variant API';
    SourceTable = "Item Variant";
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'variant';
    EntitySetName = 'variants';
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { }
                field(itemNumber; Rec."Item No.") { }
                field(code; Rec.Code) { }
                field(description; Rec.Description) { }
                field(description2; Rec."Description 2") { }
            }
        }
    }
}
