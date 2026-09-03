permissionset 50399 "JKF CUSTOM APIS"
{
    Assignable = true;
    Caption = 'JKF Custom APIs';

    Permissions =
        tabledata "Buhler Source Document Buffer" = RIMD,
        tabledata "Buhler Create Pick Buffer" = RIMD,
        tabledata "Buhler Register Pick Buffer" = RIMD,
        tabledata "JKF Requisition Line Count" = RIMD,

        tabledata "Buhler Create Packing Note Buf" = RIMD,
        tabledata "Buhler Update Whse Shpt Buf" = RIMD,
        tabledata "JKF Customer Contact Buffer" = RIMD;
}