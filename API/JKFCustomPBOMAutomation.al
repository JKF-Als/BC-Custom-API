page 50201 "JKF Item API"
{
    PageType = API;
    Caption = 'JKF Item API';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'JKFCustomPBOMAutomation';
    EntitySetName = 'JKFCustomPBOMAutomations';

    SourceTable = Item;
    DelayedInsert = true;

    ODataKeyFields = "No.";

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }

                field(productionBomNo; Rec."Production BOM No.")
                {
                    Caption = 'Production BOM No.';
                }
            }
        }
    }
}