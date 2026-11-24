namespace JKF.OrderAgent;
using Microsoft.Sales.History;
page 50317 "JKF Agent Shipment Lines"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'shipmentLine';
    EntitySetName = 'shipmentLines';
    SourceTable = "Sales Shipment Line";
    
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
                field(documentNumber; Rec."Document No.") { }
                field(lineNumber; Rec."Line No.") { }
                field(type; Rec."Type") { }
                field(itemNumber; Rec."No.") { }
                field(description; Rec."Description") { }
                field(description2; Rec."Description 2") { }
                field(variantCode; Rec."Variant Code") { }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { }
                field(quantity; Rec."Quantity") { }
                field(unitPrice; Rec."Unit Price") { }
                field(lineDiscountPercent; Rec."Line Discount %") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('shipmentLine');
    end;
    
}