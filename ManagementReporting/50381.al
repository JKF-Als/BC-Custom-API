namespace JKF.ManagementReporting;

using Microsoft.Sales.Archive;

page 50381 "JKF MR Order Archive Lines"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'orderArchiveLine';
    EntitySetName = 'orderArchiveLines';
    SourceTable = "Sales Line Archive";
    SourceTableView = where("Document Type" = const(Order));
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
                field(documentType; Rec."Document Type") { }
                field(documentNumber; Rec."Document No.") { }
                field(occurrence; Rec."Doc. No. Occurrence") { }
                field(version; Rec."Version No.") { }
                field(lineNumber; Rec."Line No.") { }
                field(lineType; Rec.Type) { }
                field(number; Rec."No.") { }
                field(quantity; Rec.Quantity) { }
                field(outstandingQuantity; Rec."Outstanding Quantity") { }
                field(quantityShipped; Rec."Quantity Shipped") { }
                field(quantityInvoiced; Rec."Quantity Invoiced") { }
                field(amountExVat; Rec.Amount) { }
                field(amountIncludingVat; Rec."Amount Including VAT") { }
                field(outstandingLcy; Rec."Outstanding Amount (LCY)") { }
                field(shippedNotInvoicedLcy; Rec."Shipped Not Invoiced (LCY)") { }
                field(currencyCode; Rec."Currency Code") { }
            }
        }
    }
}
