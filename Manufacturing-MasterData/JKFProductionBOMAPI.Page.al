// Produktionsstyklister, linjer og versioner (skrivebeskyttet).
//
// GET .../api/jkf/manufacturing/v1.0/companies({id})/productionBOMs?$expand=productionBOMLines
// GET .../productionBOMLines?$filter=routingLinkCode ne ''
// GET .../productionBOMVersions?$expand=productionBOMLines
page 50324 "JKF Production BOMs API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'productionBOM';
    EntitySetName = 'productionBOMs';
    Caption = 'Produktionsstyklister';
    SourceTable = "Production BOM Header";
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
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(status; Rec.Status) { Caption = 'Status'; }
                field(versionNos; Rec."Version Nos.") { Caption = 'Version Nos.'; }
                field(lowLevelCode; Rec."Low-Level Code") { Caption = 'Low-Level Code'; }
                field(creationDate; Rec."Creation Date") { Caption = 'Creation Date'; }
                field(lastDateModified; Rec."Last Date Modified") { Caption = 'Last Date Modified'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }

                // Kun linjerne uden version. Versionernes linjer ligger under productionBOMVersions.
                part(productionBOMLines; "JKF Production BOM Lines API")
                {
                    Caption = 'Lines';
                    EntityName = 'productionBOMLine';
                    EntitySetName = 'productionBOMLines';
                    SubPageLink = "Production BOM No." = field("No."), "Version Code" = const('');
                }
            }
        }
    }
}

page 50325 "JKF Production BOM Lines API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'productionBOMLine';
    EntitySetName = 'productionBOMLines';
    Caption = 'Produktionsstyklistelinjer';
    SourceTable = "Production BOM Line";
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
                field(productionBOMNo; Rec."Production BOM No.") { Caption = 'Production BOM No.'; }
                field(versionCode; Rec."Version Code") { Caption = 'Version Code'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(type; Rec.Type) { Caption = 'Type'; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(variantCode; Rec."Variant Code") { Caption = 'Variant Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(description2; Rec."Description 2") { Caption = 'Description 2'; }
                field(quantityPer; Rec."Quantity per") { Caption = 'Quantity per'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(calculationFormula; Rec."Calculation Formula") { Caption = 'Calculation Formula'; }
                field(length; Rec.Length) { Caption = 'Length'; }
                field(width; Rec.Width) { Caption = 'Width'; }
                field(depth; Rec.Depth) { Caption = 'Depth'; }
                field(weight; Rec.Weight) { Caption = 'Weight'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(scrapPercent; Rec."Scrap %") { Caption = 'Scrap %'; }
                field(routingLinkCode; Rec."Routing Link Code") { Caption = 'Routing Link Code'; }
                field(position; Rec.Position) { Caption = 'Position'; }
                field(position2; Rec."Position 2") { Caption = 'Position 2'; }
                field(position3; Rec."Position 3") { Caption = 'Position 3'; }
                field(leadTimeOffset; Rec."Lead-Time Offset") { Caption = 'Lead-Time Offset'; }
                field(startingDate; Rec."Starting Date") { Caption = 'Starting Date'; }
                field(endingDate; Rec."Ending Date") { Caption = 'Ending Date'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }
            }
        }
    }
}

page 50326 "JKF Prod. BOM Versions API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'productionBOMVersion';
    EntitySetName = 'productionBOMVersions';
    Caption = 'Produktionsstyklisteversioner';
    SourceTable = "Production BOM Version";
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
                field(productionBOMNo; Rec."Production BOM No.") { Caption = 'Production BOM No.'; }
                field(versionCode; Rec."Version Code") { Caption = 'Version Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(startingDate; Rec."Starting Date") { Caption = 'Starting Date'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(status; Rec.Status) { Caption = 'Status'; }
                field(lastDateModified; Rec."Last Date Modified") { Caption = 'Last Date Modified'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }

                part(productionBOMLines; "JKF Production BOM Lines API")
                {
                    Caption = 'Lines';
                    EntityName = 'productionBOMLine';
                    EntitySetName = 'productionBOMLines';
                    SubPageLink = "Production BOM No." = field("Production BOM No."), "Version Code" = field("Version Code");
                }
            }
        }
    }
}
