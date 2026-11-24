namespace JKF.ManagementReporting;

using Microsoft.Sales.Archive;

page 50380 "JKF MR Order Archive Headers"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'orderArchiveHeader';
    EntitySetName = 'orderArchiveHeaders';
    SourceTable = "Sales Header Archive";
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
                field(number; Rec."No.") { }
                field(occurrence; Rec."Doc. No. Occurrence") { }
                field(version; Rec."Version No.") { }
                field(orderDate; Rec."Order Date") { }
                field(archivedDate; Rec."Date Archived") { }
                field(archivedTime; Rec."Time Archived") { }
                field(customerNumber; Rec."Sell-to Customer No.") { }
                field(currencyCode; Rec."Currency Code") { }
                field(currencyFactor; Rec."Currency Factor") { }
            }
        }
    }
}
