namespace JKF.OrderAgent;
using Microsoft.Inventory.Item.Attribute;
page 50307 "JKF Agent Attribute Mapping"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'attributeMapping';
    EntitySetName = 'attributeMappings';
    SourceTable = "Item Attribute Value Mapping";
    SourceTableView = where("Table ID" = const(27));
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { }
                field(lastModifiedAt; Rec.SystemModifiedAt) { }
                field(itemNumber; Rec."No.") { }
                field(attributeId; Rec."Item Attribute ID") { }
                field(valueId; Rec."Item Attribute Value ID") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('attributeMapping');
    end;
    
}