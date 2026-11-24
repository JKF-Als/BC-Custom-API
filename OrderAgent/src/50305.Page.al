namespace JKF.OrderAgent;
using Microsoft.Inventory.Item.Attribute;
page 50305 "JKF Agent Attributes"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'attribute';
    EntitySetName = 'attributes';
    SourceTable = "Item Attribute";
    
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
                field(attributeId; Rec."ID") { }
                field(name; Rec."Name") { }
                field(type; Rec."Type") { }
                field(unitOfMeasure; Rec."Unit of Measure") { }
                field(blocked; Rec."Blocked") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('attribute');
    end;
    
}