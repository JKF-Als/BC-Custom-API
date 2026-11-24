// Montagestyklister (BOM Component, skrivebeskyttet).
//
// GET .../api/jkf/manufacturing/v1.0/companies({id})/assemblyBOMComponents?$filter=parentItemNo eq 'XXX'
page 50329 "JKF Assembly BOM API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'manufacturing';
    APIVersion = 'v1.0';
    EntityName = 'assemblyBOMComponent';
    EntitySetName = 'assemblyBOMComponents';
    Caption = 'Montagestyklistekomponenter';
    SourceTable = "BOM Component";
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
                field(parentItemNo; Rec."Parent Item No.") { Caption = 'Parent Item No.'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(type; Rec.Type) { Caption = 'Type'; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(variantCode; Rec."Variant Code") { Caption = 'Variant Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(quantityPer; Rec."Quantity per") { Caption = 'Quantity per'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(assemblyBOM; Rec."Assembly BOM") { Caption = 'Assembly BOM'; }
                field(position; Rec.Position) { Caption = 'Position'; }
                field(leadTimeOffset; Rec."Lead-Time Offset") { Caption = 'Lead-Time Offset'; }
                field(resourceUsageType; Rec."Resource Usage Type") { Caption = 'Resource Usage Type'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; }
            }
        }
    }
}
