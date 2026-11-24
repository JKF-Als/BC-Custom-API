permissionset 50340 "JKF SCANNER"
{
    Caption = 'JKF Scanner-app';
    Assignable = true;
    Permissions =
        tabledata "JKF Scanner Transaction" = RIMD,
        table "JKF Scanner Transaction" = X,
        codeunit "JKF Scanner Mgt." = X,
        page "JKF Scanner Transactions" = X,
        page "JKF API Locations" = X,
        page "JKF API Items" = X,
        page "JKF API Picks" = X,
        page "JKF API Pick Lines" = X,
        page "JKF API Bin Contents" = X,
        page "JKF API Item References" = X,
        page "JKF API Transactions" = X;
}
