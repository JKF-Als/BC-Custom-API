// Ruter, rutelinjer, rutebindinger og ruteversioner (skrivebeskyttet).
//
// GET .../api/jkf/manufacturing/v1.0/companies({id})/routings?$expand=routingLines
// GET .../routingLines?$filter=routingLinkCode ne ''
// GET .../routingLinks
// GET .../routingVersions?$expand=routingLines
page 50320 "JKF Routings API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'routing';
    EntitySetName = 'routings';
    Caption = 'Ruter';
    SourceTable = "Routing Header";
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
                field(description; Rec.Description) { Caption = 'Description'; }
                field(description2; Rec."Description 2") { Caption = 'Description 2'; }
                field(type; Rec.Type) { Caption = 'Type'; }
                field(status; Rec.Status) { Caption = 'Status'; }
                field(versionNos; Rec."Version Nos.") { Caption = 'Version Nos.'; }
                field(lastDateModified; Rec."Last Date Modified") { Caption = 'Last Date Modified'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }

                // Kun linjerne uden version. Versionernes linjer ligger under routingVersions.
                part(routingLines; "JKF Routing Lines API")
                {
                    Caption = 'Lines';
                    EntityName = 'routingLine';
                    EntitySetName = 'routingLines';
                    SubPageLink = "Routing No." = field("No."), "Version Code" = const('');
                }
            }
        }
    }
}

page 50321 "JKF Routing Lines API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'routingLine';
    EntitySetName = 'routingLines';
    Caption = 'Rutelinjer';
    SourceTable = "Routing Line";
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
                field(routingNo; Rec."Routing No.") { Caption = 'Routing No.'; }
                field(versionCode; Rec."Version Code") { Caption = 'Version Code'; }
                field(operationNo; Rec."Operation No.") { Caption = 'Operation No.'; }
                field(previousOperationNo; Rec."Previous Operation No.") { Caption = 'Previous Operation No.'; }
                field(nextOperationNo; Rec."Next Operation No.") { Caption = 'Next Operation No.'; }
                field(type; Rec.Type) { Caption = 'Type'; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(workCenterNo; Rec."Work Center No.") { Caption = 'Work Center No.'; }
                field(workCenterGroupCode; Rec."Work Center Group Code") { Caption = 'Work Center Group Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(description2; Rec."Description 2") { Caption = 'Description 2'; }
                field(routingLinkCode; Rec."Routing Link Code") { Caption = 'Routing Link Code'; }
                field(standardTaskCode; Rec."Standard Task Code") { Caption = 'Standard Task Code'; }
                field(setupTime; Rec."Setup Time") { Caption = 'Setup Time'; }
                field(setupTimeUnitOfMeasureCode; Rec."Setup Time Unit of Meas. Code") { Caption = 'Setup Time Unit of Meas. Code'; }
                field(runTime; Rec."Run Time") { Caption = 'Run Time'; }
                field(runTimeUnitOfMeasureCode; Rec."Run Time Unit of Meas. Code") { Caption = 'Run Time Unit of Meas. Code'; }
                field(waitTime; Rec."Wait Time") { Caption = 'Wait Time'; }
                field(waitTimeUnitOfMeasureCode; Rec."Wait Time Unit of Meas. Code") { Caption = 'Wait Time Unit of Meas. Code'; }
                field(moveTime; Rec."Move Time") { Caption = 'Move Time'; }
                field(moveTimeUnitOfMeasureCode; Rec."Move Time Unit of Meas. Code") { Caption = 'Move Time Unit of Meas. Code'; }
                field(fixedScrapQuantity; Rec."Fixed Scrap Quantity") { Caption = 'Fixed Scrap Quantity'; }
                field(scrapFactorPercent; Rec."Scrap Factor %") { Caption = 'Scrap Factor %'; }
                field(lotSize; Rec."Lot Size") { Caption = 'Lot Size'; }
                field(concurrentCapacities; Rec."Concurrent Capacities") { Caption = 'Concurrent Capacities'; }
                field(sendAheadQuantity; Rec."Send-Ahead Quantity") { Caption = 'Send-Ahead Quantity'; }
                field(unitCostPer; Rec."Unit Cost per") { Caption = 'Unit Cost per'; }
                field(sequenceNoForward; Rec."Sequence No. (Forward)") { Caption = 'Sequence No. (Forward)'; }
                field(sequenceNoBackward; Rec."Sequence No. (Backward)") { Caption = 'Sequence No. (Backward)'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }
            }
        }
    }
}

page 50322 "JKF Routing Links API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'routingLink';
    EntitySetName = 'routingLinks';
    Caption = 'Rutebindinger';
    SourceTable = "Routing Link";
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
                field(code; Rec.Code) { Caption = 'Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }
            }
        }
    }
}

page 50323 "JKF Routing Versions API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'routingVersion';
    EntitySetName = 'routingVersions';
    Caption = 'Ruteversioner';
    SourceTable = "Routing Version";
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
                field(routingNo; Rec."Routing No.") { Caption = 'Routing No.'; }
                field(versionCode; Rec."Version Code") { Caption = 'Version Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(startingDate; Rec."Starting Date") { Caption = 'Starting Date'; }
                field(type; Rec.Type) { Caption = 'Type'; }
                field(status; Rec.Status) { Caption = 'Status'; }
                field(lastDateModified; Rec."Last Date Modified") { Caption = 'Last Date Modified'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }

                part(routingLines; "JKF Routing Lines API")
                {
                    Caption = 'Lines';
                    EntityName = 'routingLine';
                    EntitySetName = 'routingLines';
                    SubPageLink = "Routing No." = field("Routing No."), "Version Code" = field("Version Code");
                }
            }
        }
    }
}
