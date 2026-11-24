namespace JKF.OrderAgent;
using Microsoft.Inventory.Item;
page 50304 "JKF Agent Item Units"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'itemUnit';
    EntitySetName = 'itemUnits';
    SourceTable = "Item Unit of Measure";
    
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
                field(itemNumber; Rec."Item No.") { }
                field(code; Rec."Code") { }
                field(quantityPerUnit; Rec."Qty. per Unit of Measure") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('itemUnit');
    end;
    
}