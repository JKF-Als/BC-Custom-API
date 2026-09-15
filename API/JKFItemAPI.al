page 50261 "Custom Item API"
{
    PageType = API;
    Caption = 'JKF Customer EVMP API';
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
            }
        }
    }
}