namespace JKF.ManagementReporting;

using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

permissionset 50398 "JKF REPORT READ"
{
    Assignable = true;
    Permissions =
        tabledata "Sales Header Archive" = R,
        tabledata "Sales Line Archive" = R,
        tabledata "Sales Line" = R,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Cr.Memo Header" = R,
        tabledata "Sales Cr.Memo Line" = R,
        tabledata "Sales Shipment Line" = R,
        page "JKF MR Order Archive Headers" = X,
        page "JKF MR Order Archive Lines" = X,
        page "JKF MR Order Line Supplement" = X,
        page "JKF MR Invoice Supplement" = X,
        page "JKF MR Credit Header Supp" = X,
        page "JKF MR Credit Line Supp" = X,
        page "JKF MR Shipment Line Supp" = X;
}
