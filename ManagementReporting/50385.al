namespace JKF.ManagementReporting;

using Microsoft.Sales.History;

page 50385 "JKF MR Credit Line Supp"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'creditLineSupplement';
    EntitySetName = 'creditLineSupplements';
    SourceTable = "Sales Cr.Memo Line";
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
                field(documentNumber; Rec."Document No.") { }
                field(lineNumber; Rec."Line No.") { }
                field(lineType; Rec.Type) { }
                field(number; Rec."No.") { }
                field(amountExVat; Rec.Amount) { }
                field(quantity; Rec.Quantity) { }
                field(unitCostLcy; Rec."Unit Cost (LCY)") { }
            }
        }
    }
}
