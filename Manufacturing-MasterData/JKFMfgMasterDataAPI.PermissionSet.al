permissionset 50320 "JKF MFG MASTER API"
{
    Assignable = true;
    Caption = 'JKF Ruter og styklister API (læs)';

    Permissions =
        tabledata "Routing Header" = R,
        tabledata "Routing Line" = R,
        tabledata "Routing Link" = R,
        tabledata "Routing Version" = R,
        tabledata "Production BOM Header" = R,
        tabledata "Production BOM Line" = R,
        tabledata "Production BOM Version" = R,
        tabledata "Work Center" = R,
        tabledata "Machine Center" = R,
        tabledata "BOM Component" = R,
        page "JKF Routings API" = X,
        page "JKF Routing Lines API" = X,
        page "JKF Routing Links API" = X,
        page "JKF Routing Versions API" = X,
        page "JKF Production BOMs API" = X,
        page "JKF Production BOM Lines API" = X,
        page "JKF Prod. BOM Versions API" = X,
        page "JKF Work Centers API" = X,
        page "JKF Machine Centers API" = X,
        page "JKF Assembly BOM API" = X;
}
