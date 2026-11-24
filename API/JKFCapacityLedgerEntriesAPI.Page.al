page 50276 "JKF Capacity Ledger API"
{
    PageType = API;
    Caption = 'JKF Capacity Ledger Entries';
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'capacityLedgerEntry';
    EntitySetName = 'capacityLedgerEntries';
    SourceTable = "Capacity Ledger Entry";
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { }
                field(documentNo; Rec."Document No.") { }
                field(number; Rec."No.") { }
                field(quantity; Rec.Quantity) { }
                field(operationNo; Rec."Operation No.") { }
            }
        }
    }
}
