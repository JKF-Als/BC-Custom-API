page 50220 "Buhler Get Packing Order Info"
{
    PageType = API;
    APIPublisher = 'custom';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'buhlerGetPackingOrderInfo';
    EntitySetName = 'buhlerGetPackingOrderInfo';
    SourceTable = "Sales Header";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(sellToCustomerNo; Rec."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer No.';
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field("ShipToCountryRegionCode"; Rec."Ship-to Country/Region Code")
                {
                    Caption = 'Delivery Country.';
                }
            }
        }
    }
}