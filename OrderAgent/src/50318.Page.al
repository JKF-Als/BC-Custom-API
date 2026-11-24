namespace JKF.OrderAgent;
using Microsoft.Sales.History;
page 50318 "JKF Agent Invoice Headers"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'invoiceHeader';
    EntitySetName = 'invoiceHeaders';
    SourceTable = "Sales Invoice Header";
    
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
                field(customerNumber; Rec."Sell-to Customer No.") { }
                field(externalDocumentNumber; Rec."External Document No.") { }
                field(postingDate; Rec."Posting Date") { }
                field(orderNumber; Rec."Order No.") { }
                field(currencyCode; Rec."Currency Code") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('invoiceHeader');
    end;
    
}