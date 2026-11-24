page 50346 "JKF API Item References"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'scanner';
    APIVersion = 'v1.0';
    EntityName = 'itemReference';
    EntitySetName = 'itemReferences';
    EntityCaption = 'Varereference';
    EntitySetCaption = 'Varereferencer';
    SourceTable = "Item Reference";
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
                field(referenceNumber; Rec."Reference No.") { }
                field(referenceType; Rec."Reference Type") { }
                field(itemNumber; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(unitOfMeasure; Rec."Unit of Measure") { }
            }
        }
    }
}
