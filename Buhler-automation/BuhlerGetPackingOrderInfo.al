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
                // New field bound to the global variable instead of a table field
                field(shipToCountryRegionName; ShipToCountryRegionName)
                {
                    Caption = 'Delivery Country Name';
                    Editable = false;
                }
            }
        }
    }

    // Declare a global variable to hold the resolved name
    var
        ShipToCountryRegionName: Text[50];

    // Look up the country name every time a record is read
    trigger OnAfterGetRecord()
    var
        CountryRegion: Record "Country/Region";
    begin
        // Clear the variable to prevent residual data from previous records
        Clear(ShipToCountryRegionName);

        // If a matching Country/Region record exists, grab its Name
        if CountryRegion.Get(Rec."Ship-to Country/Region Code") then
            ShipToCountryRegionName := CountryRegion.Name;
    end;
}