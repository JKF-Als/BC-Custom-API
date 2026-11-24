// Arbejdscentre og produktionsressourcer (skrivebeskyttet), til opslag fra rutelinjerne.
//
// GET .../api/jkf/manufacturing/v1.0/companies({id})/workCenters
// GET .../machineCenters?$filter=workCenterNo eq 'XXX'
page 50327 "JKF Work Centers API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'workCenter';
    EntitySetName = 'workCenters';
    Caption = 'Arbejdscentre';
    SourceTable = "Work Center";
    ODataKeyFields = SystemId;
    DataAccessIntent = ReadOnly;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(name; Rec.Name) { Caption = 'Name'; }
                field(name2; Rec."Name 2") { Caption = 'Name 2'; }
                field(workCenterGroupCode; Rec."Work Center Group Code") { Caption = 'Work Center Group Code'; }
                field(alternateWorkCenter; Rec."Alternate Work Center") { Caption = 'Alternate Work Center'; }
                field(subcontractorNo; Rec."Subcontractor No.") { Caption = 'Subcontractor No.'; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(capacity; Rec.Capacity) { Caption = 'Capacity'; }
                field(efficiency; Rec.Efficiency) { Caption = 'Efficiency'; }
                field(shopCalendarCode; Rec."Shop Calendar Code") { Caption = 'Shop Calendar Code'; }
                field(flushingMethod; Rec."Flushing Method") { Caption = 'Flushing Method'; }
                field(directUnitCost; Rec."Direct Unit Cost") { Caption = 'Direct Unit Cost'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(blocked; Rec.Blocked) { Caption = 'Blocked'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }
            }
        }
    }
}

page 50328 "JKF Machine Centers API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'machineCenter';
    EntitySetName = 'machineCenters';
    Caption = 'Produktionsressourcer';
    SourceTable = "Machine Center";
    ODataKeyFields = SystemId;
    DataAccessIntent = ReadOnly;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(name; Rec.Name) { Caption = 'Name'; }
                field(name2; Rec."Name 2") { Caption = 'Name 2'; }
                field(workCenterNo; Rec."Work Center No.") { Caption = 'Work Center No.'; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; }
                field(capacity; Rec.Capacity) { Caption = 'Capacity'; }
                field(efficiency; Rec.Efficiency) { Caption = 'Efficiency'; }
                field(setupTime; Rec."Setup Time") { Caption = 'Setup Time'; }
                field(flushingMethod; Rec."Flushing Method") { Caption = 'Flushing Method'; }
                field(directUnitCost; Rec."Direct Unit Cost") { Caption = 'Direct Unit Cost'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(blocked; Rec.Blocked) { Caption = 'Blocked'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }
            }
        }
    }
}
