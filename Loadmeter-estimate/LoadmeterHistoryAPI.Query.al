// Træningsdata til ladmeter-modellen.
// Én række pr. bogført lagerstedsforsendelseslinje med:
//  - faktisk vægt, ladmeter og antal kolli fra hovedet (EV-felter)
//  - kunde (destination), vare, antal, beskrivelse 2 (diameter/godstykkelse)
//  - varekategori og vægt fra varekortet
//  - modtagerland/-postnr. fra salgsleverancen
//
// GET .../api/jkf/integration/v1.0/companies({id})/loadmeterHistoryLines
//     ?$filter=postingDate ge 2024-01-01 and actualLoadMeter gt 0
query 50233 "JKF Loadmeter History API"
{
    QueryType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'loadmeterHistoryLine';
    EntitySetName = 'loadmeterHistoryLines';
    Caption = 'Ladmeter-historik';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(PostedWhseShptHeader; "Posted Whse. Shipment Header")
        {
            column(postedWhseShipmentNo; "No.") { }
            column(whseShipmentNo; "Whse. Shipment No.") { }
            column(postingDate; "Posting Date") { }
            column(locationCode; "Location Code") { }
            column(shipmentMethodCode; "Shipment Method Code") { }
            column(shippingAgentCode; "Shipping Agent Code") { }
            column(shippingAgentServiceCode; "Shipping Agent Service Code") { }
            column(actualWeight; "Actual Weight_EVAS") { }
            column(actualLoadMeter; "Actual Load Meter_EVAS") { }
            column(actualNumberOfPackages; "Act. Number of Packag._EVAS") { }
            column(packageDescription; "Package Description_EVAS") { }
            column(estimatedLoadMeter; "JKF Est. Load Meter") { }
            column(estimatedNumberOfPackages; "JKF Est. Number of Packages") { }

            dataitem(PostedWhseShptLine; "Posted Whse. Shipment Line")
            {
                DataItemLink = "No." = PostedWhseShptHeader."No.";
                SqlJoinType = InnerJoin;

                column(lineNo; "Line No.") { }
                column(sourceDocument; "Source Document") { }
                column(sourceNo; "Source No.") { }
                column(postedSourceNo; "Posted Source No.") { }
                column(destinationType; "Destination Type") { }
                column(destinationNo; "Destination No.") { }
                column(itemNo; "Item No.") { }
                column(variantCode; "Variant Code") { }
                column(description; Description) { }
                column(description2; "Description 2") { }
                column(quantity; Quantity) { }
                column(quantityBase; "Qty. (Base)") { }
                column(unitOfMeasureCode; "Unit of Measure Code") { }

                dataitem(Item; Item)
                {
                    DataItemLink = "No." = PostedWhseShptLine."Item No.";
                    SqlJoinType = LeftOuterJoin;

                    column(itemCategoryCode; "Item Category Code") { }
                    column(grossWeight; "Gross Weight") { }
                    column(netWeight; "Net Weight") { }
                    column(unitVolume; "Unit Volume") { }
                    column(metalSheetWeight; "Metal Sheet Weight_EVAS") { }

                    dataitem(SalesShipmentHeader; "Sales Shipment Header")
                    {
                        DataItemLink = "No." = PostedWhseShptLine."Posted Source No.";
                        SqlJoinType = LeftOuterJoin;

                        column(sellToCustomerNo; "Sell-to Customer No.") { }
                        column(shipToCode; "Ship-to Code") { }
                        column(shipToCountry; "Ship-to Country/Region Code") { }
                        column(shipToPostCode; "Ship-to Post Code") { }
                    }
                }
            }
        }
    }
}
