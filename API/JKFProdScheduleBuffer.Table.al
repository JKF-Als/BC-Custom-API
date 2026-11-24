table 50275 "JKF Prod Schedule Buffer"
{
    TableType = Temporary;
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Order No."; Code[20]) { }
        field(3; "Operation No."; Code[10]) { }
        field(4; "Starting Date-Time"; DateTime) { }
        field(5; "Ending Date-Time"; DateTime) { }
        field(6; "Production Order Id"; Guid) { }
        field(7; "Routing Line Id"; Guid) { }
        field(8; Status; Text[20]) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
