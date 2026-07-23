page 50200 "JKF Customer EVMP API"
{
    PageType = API;
    Caption = 'JKF Customer EVMP API';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'JKFCustomDebitorCreation';
    EntitySetName = 'JKFCustomDebitorCreations';

    SourceTable = Customer;
    DelayedInsert = true;

    ODataKeyFields = "No.";

    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }

                field(eMailShipmentEVMP; Rec."E-Mail (Shipment)_EVMP")
                {
                    Caption = 'E-Mail Shipment EVMP';
                }

                field(eMailInvoicingEVMP; Rec."E-Mail (Invoicing)_EVMP")
                {
                    Caption = 'E-Mail Invoicing EVMP';
                }

                field(eMailFinancialEVMP; Rec."E-Mail (Financial)_EVMP")
                {
                    Caption = 'E-Mail Financial EVMP';
                }
            }
        }
    }
}