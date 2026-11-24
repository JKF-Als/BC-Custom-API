namespace JKF.OrderAgent;
using Microsoft.Inventory.Item.Catalog;
page 50308 "JKF Agent Item References"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'itemReference';
    EntitySetName = 'itemReferences';
    SourceTable = "Item Reference";
    
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
                field(referenceType; Rec."Reference Type") { }
                field(referenceTypeNumber; Rec."Reference Type No.") { }
                field(referenceNumber; Rec."Reference No.") { }
                field(itemNumber; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(unitOfMeasure; Rec."Unit of Measure") { }
                field(startingDate; Rec."Starting Date") { }
                field(endingDate; Rec."Ending Date") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('itemReference');
    end;
    
}