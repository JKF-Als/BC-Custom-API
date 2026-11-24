namespace JKF.ManagementReporting;

using Microsoft.Sales.History;

page 50383 "JKF MR Invoice Supplement"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'invoiceSupplement';
    EntitySetName = 'invoiceSupplements';
    SourceTable = "Sales Invoice Header";
    ODataKeyFields = SystemId;
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { }
                field(modifiedAt; Rec.SystemModifiedAt) { }
                field(number; Rec."No.") { }
                field(postingDate; Rec."Posting Date") { }
                field(orderDate; Rec."Order Date") { }
                field(orderNumber; Rec."Order No.") { }
                field(currencyCode; Rec."Currency Code") { }
                field(currencyFactor; Rec."Currency Factor") { }
            }
        }
    }
}
