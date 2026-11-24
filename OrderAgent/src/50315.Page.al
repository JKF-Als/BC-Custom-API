namespace JKF.OrderAgent;
using Microsoft.Sales.Archive;
page 50315 "JKF Agent Archive Lines"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'archiveLine';
    EntitySetName = 'archiveLines';
    SourceTable = "Sales Line Archive";
    SourceTableView = where("Document Type" = filter(Quote | Order));
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
                field(documentType; Rec."Document Type") { }
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
                field(lineAmount; Rec."Line Amount") { }
                field(locationCode; Rec."Location Code") { }
                field(versionNumber; Rec."Version No.") { }
                field(occurrenceNumber; Rec."Doc. No. Occurrence") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('archiveLine');
    end;
    
}