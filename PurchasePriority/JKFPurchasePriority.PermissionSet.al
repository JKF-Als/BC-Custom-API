permissionset 50212 "JKF PURCH PRIO"
{
    Assignable = true;
    Caption = 'JKF Indkøbsprioriteter';

    Permissions =
        tabledata "JKF Purchase Priority" = RIMD,
        table "JKF Purchase Priority" = X,
        page "JKF Vendor Purch. Priorities" = X,
        tabledata "JKF Item Purchase Priority" = RIMD,
        table "JKF Item Purchase Priority" = X,
        page "JKF Item Purch. Priorities" = X;
}

permissionsetextension 50213 "JKF Purch Prio D365 Read" extends "D365 READ"
{
    Permissions =
        tabledata "JKF Purchase Priority" = R,
        tabledata "JKF Item Purchase Priority" = R;
}

permissionsetextension 50214 "JKF Purch Prio D365 Full" extends "D365 BUS FULL ACCESS"
{
    Permissions =
        tabledata "JKF Purchase Priority" = RIMD,
        tabledata "JKF Item Purchase Priority" = RIMD;
}
