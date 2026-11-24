namespace JKF.Reservations;

using Microsoft.Inventory.Tracking;
using Microsoft.Sales.Document;

permissionset 50270 "SALES RES API"
{
    Assignable = true;
    Caption = 'Read sales reservation API';
    Permissions =
        tabledata "Reservation Entry" = R,
        tabledata "Sales Line" = R,
        page "Sales Reservations API" = X,
        page "Reservations API" = X,
        codeunit "Reserv Source Text" = X;
}
