permissionset 50211 "JKF VENDOR CAT"
{
    Assignable = true;
    Caption = 'JKF Kreditorkategorier';

    Permissions =
        tabledata "JKF Vendor Category" = RIMD,
        table "JKF Vendor Category" = X,
        page "JKF Vendor Categories" = X;
}

permissionsetextension 50211 "JKF Vendor Cat D365 Read" extends "D365 READ"
{
    Permissions =
        tabledata "JKF Vendor Category" = R;
}

permissionsetextension 50212 "JKF Vendor Cat D365 Full" extends "D365 BUS FULL ACCESS"
{
    Permissions =
        tabledata "JKF Vendor Category" = RIMD;
}
