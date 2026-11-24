namespace JKF.OrderAgent;
using Microsoft.Inventory.Item.Attribute;
page 50306 "JKF Agent Attribute Values"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'attributeValue';
    EntitySetName = 'attributeValues';
    SourceTable = "Item Attribute Value";
    
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
                field(attributeId; Rec."Attribute ID") { }
                field(valueId; Rec."ID") { }
                field(value; Rec."Value") { }
                field(numericValue; Rec."Numeric Value") { }
                field(blocked; Rec."Blocked") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('attributeValue');
    end;
    
}