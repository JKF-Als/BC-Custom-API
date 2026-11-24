// Pakkebreve (ét pr. kolli) med mål, vægt og kolliets ladmeter.
// Koblet til den bogførte lagerstedsforsendelse, så kolli-mål kan sammenlignes med forsendelsens faktiske ladmeter.
//
// "Source No." er enten en lagerstedsforsendelse (LL...) eller en bogført lagerstedsforsendelse (BLL...),
// afhængigt af "Source Type". Er det en åben lagerstedsforsendelse, findes den bogførte via "Whse. Shipment No.".
//
// GET .../api/jkf/integration/v1.0/companies({id})/loadmeterPackingNotes
query 50237 "JKF Loadmeter Packing Notes"
{
    QueryType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'loadmeterPackingNote';
    EntitySetName = 'loadmeterPackingNotes';
    Caption = 'Ladmeter pakkebreve';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(PackingNote; "Packing Note Header_EVAS")
        {
            column(packingNoteNo; "No.") { }
            column(documentDate; "Document Date") { }
            column(sellToCustomerNo; "Sell-to Customer No.") { }
            column(shipToCountry; "Ship-to Country/Region Code") { }
            column(shipmentMethodCode; "Shipment Method Code") { }
            column(salesOrderNo; "Sales Order No.") { }
            column(salesShipmentNo; "Sales Shipment No.") { }
            column(sourceType; "Source Type") { }
            column(sourceNo; "Source No.") { }
            column(colliNo; "Colli No.") { }
            column(huType; "HU Type") { }
            column(length; Length) { }
            column(width; Width) { }
            column(height; Height) { }
            column(netWeightKg; "Total Net Weight (Kg)") { }
            column(grossWeightKg; "Total Weight (Kg)") { }
            column(packageLoadMeter; "Actual Load Meter") { }
            column(numberOfPackages; "Act. Number of Packag.") { }

            dataitem(PostedWhseShptHeader; "Posted Whse. Shipment Header")
            {
                DataItemLink = "Whse. Shipment No." = PackingNote."Source No.";
                SqlJoinType = LeftOuterJoin;

                column(postedWhseShipmentNo; "No.") { }
                column(shipmentActualLoadMeter; "Actual Load Meter_EVAS") { }
                column(shipmentActualWeight; "Actual Weight_EVAS") { }
                column(shipmentActualNumberOfPackages; "Act. Number of Packag._EVAS") { }
            }
        }
    }
}
