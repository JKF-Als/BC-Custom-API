permissionset 50236 "JKF LOADMETER API"
{
    Assignable = true;
    Caption = 'JKF Ladmeter-estimat API';

    Permissions =
        tabledata "Warehouse Shipment Header" = RM,
        tabledata "Warehouse Shipment Line" = R,
        tabledata "Posted Whse. Shipment Header" = R,
        tabledata "Posted Whse. Shipment Line" = R,
        tabledata Item = R,
        tabledata "Sales Shipment Header" = R,
        tabledata "Sales Header" = R,
        tabledata "Packing Note Header_EVAS" = R,
        query "JKF Loadmeter Packing Notes" = X,
        page "JKF Loadmeter Whse. Shpt. API" = X,
        page "JKF Loadmeter Whse. Line API" = X,
        query "JKF Loadmeter History API" = X,
        codeunit "JKF Loadmeter Est. Transfer" = X;
}
