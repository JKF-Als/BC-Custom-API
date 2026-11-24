page 50341 "JKF API Locations"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'scanner';
    APIVersion = 'v1.0';
    EntityName = 'location';
    EntitySetName = 'locations';
    EntityCaption = 'Lokation';
    EntitySetCaption = 'Lokationer';
    SourceTable = Location;
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
                field("code"; Rec.Code) { }
                field(name; Rec.Name) { }
                field(binMandatory; Rec."Bin Mandatory") { }
                field(directedPutAwayAndPick; Rec."Directed Put-away and Pick") { }
                field(requirePick; Rec."Require Pick") { }
                field(requireShipment; Rec."Require Shipment") { }
                field(useAsInTransit; Rec."Use As In-Transit") { }
            }
        }
    }
}
