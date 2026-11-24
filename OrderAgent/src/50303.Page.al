namespace JKF.OrderAgent;
using Microsoft.Inventory.Item;
page 50303 "JKF Agent Items"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'item';
    EntitySetName = 'items';
    SourceTable = "Item";
    
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
                field(number; Rec."No.") { }
                field(description; Rec."Description") { }
                field(description2; Rec."Description 2") { }
                field(itemDiscountGroup; Rec."Item Disc. Group") { }
                field(itemCategoryCode; Rec."Item Category Code") { }
                field(baseUnitOfMeasure; Rec."Base Unit of Measure") { }
                field(salesUnitOfMeasure; Rec."Sales Unit of Measure") { }
                field(blocked; Rec."Blocked") { }
                field(salesBlocked; Rec."Sales Blocked") { }
                field(inventory; Rec."Inventory") { }
                field(leadTimeCalculation; Rec."Lead Time Calculation") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('item');
    end;
    trigger OnAfterGetRecord()
begin
    Rec.CalcFields(Inventory);
end;
}
