namespace JKF.OrderAgent;
using Microsoft.Sales.Customer;
page 50300 "JKF Agent Customers"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    SourceTable = "Customer";
    
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { }
                field(lastModifiedAt; Rec.SystemModifiedAt) { }
                field(number; Rec."No.") { }
                field(name; Rec."Name") { }
                field(vatRegistrationNumber; Rec."VAT Registration No.") { }
                field(address; Rec."Address") { }
                field(address2; Rec."Address 2") { }
                field(city; Rec."City") { }
                field(postCode; Rec."Post Code") { }
                field(countryCode; Rec."Country/Region Code") { }
                field(customerPriceGroup; Rec."Customer Price Group") { }
                field(customerDiscountGroup; Rec."Customer Disc. Group") { }
                field(paymentTermsCode; Rec."Payment Terms Code") { }
                field(shipmentMethodCode; Rec."Shipment Method Code") { }
                field(locationCode; Rec."Location Code") { }
                field(languageCode; Rec."Language Code") { }
                field(blocked; Rec."Blocked") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('customer');
    end;
    
}