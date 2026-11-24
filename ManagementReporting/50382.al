namespace JKF.ManagementReporting;

using Microsoft.Sales.Document;

page 50382 "JKF MR Order Line Supplement"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'orderLineSupplement';
    EntitySetName = 'orderLineSupplements';
    SourceTable = "Sales Line";
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
                field(lineNumber; Rec."Line No.") { }
                field(amountExVat; Rec.Amount) { }
                field(amountIncludingVat; Rec."Amount Including VAT") { }
                field(lineAmount; Rec."Line Amount") { }
                field(invoiceDiscountAmount; Rec."Inv. Discount Amount") { }
                field(vatPercent; Rec."VAT %") { }
                field(vatCalculationType; Rec."VAT Calculation Type") { }
                field(currencyCode; Rec."Currency Code") { }
            }
        }
    }
}
