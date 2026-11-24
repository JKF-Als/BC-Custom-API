namespace JKF.ManagementReporting;

using Microsoft.Sales.History;

page 50386 "JKF MR Shipment Line Supp"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'shipmentLineSupplement';
    EntitySetName = 'shipmentLineSupplements';
    SourceTable = "Sales Shipment Line";
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
                field(orderNumber; Rec."Order No.") { }
                field(orderLineNumber; Rec."Order Line No.") { }
            }
        }
    }
}
