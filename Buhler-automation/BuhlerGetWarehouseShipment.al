page 50202 "Buhler Get Warehouse Shipment"
{
    PageType = API;
    Caption = 'Buhler Get Warehouse Shipment';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'BuhlerGetWarehouseShipment';
    EntitySetName = 'BuhlerGetWarehouseShipments';

    SourceTable = "Warehouse Shipment Header";
    DelayedInsert = true;

    ODataKeyFields = "No.";

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(no; Rec."No.")
                {
                    Caption = 'Warehouse Shipment No.';
                    Editable = false;
                }

                field(salesOrderNoEVAS; Rec."Sales Order No._EVAS")
                {
                    Caption = 'Sales Order No.';
                    Editable = false;
                }
            }
        }
    }
}