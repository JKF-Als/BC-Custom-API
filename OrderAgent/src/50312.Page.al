namespace JKF.OrderAgent;
using Microsoft.Sales.Document;
page 50312 "JKF Agent Sales Headers"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'salesHeader';
    EntitySetName = 'salesHeaders';
    SourceTable = "Sales Header";
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
                field(number; Rec."No.") { }
                field(customerNumber; Rec."Sell-to Customer No.") { }
                field(externalDocumentNumber; Rec."External Document No.") { }
                field(orderDate; Rec."Order Date") { }
                field(documentDate; Rec."Document Date") { }
                field(currencyCode; Rec."Currency Code") { }
                field(status; Rec."Status") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('salesHeader');
    end;
    
}