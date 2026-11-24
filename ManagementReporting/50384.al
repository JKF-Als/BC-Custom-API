namespace JKF.ManagementReporting;

using Microsoft.Sales.History;

page 50384 "JKF MR Credit Header Supp"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'creditHeaderSupplement';
    EntitySetName = 'creditHeaderSupplements';
    SourceTable = "Sales Cr.Memo Header";
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
                field(customerNumber; Rec."Sell-to Customer No.") { }
                field(currencyCode; Rec."Currency Code") { }
                field(currencyFactor; Rec."Currency Factor") { }
                field(appliesToNumber; Rec."Applies-to Doc. No.") { }
            }
        }
    }
}
