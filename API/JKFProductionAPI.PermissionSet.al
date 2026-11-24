permissionset 50273 "JKF PRODUCTION API"
{
    Assignable = true;
    Caption = 'JKF Production API';
    // Add to a user that already has the standard manufacturing permissions
    // required for release, flushing, reservations and capacity scheduling.
    Permissions =
        tabledata "Production Order" = R,
        tabledata "Prod. Order Routing Line" = RM,
        page "JKF Production Orders API" = X,
        page "JKF Prod Order Routing API" = X,
        page "JKF Prod Schedule API" = X,
        codeunit "Prod. Order Status Management" = X,
        codeunit "JKF Release And Schedule" = X;
}

