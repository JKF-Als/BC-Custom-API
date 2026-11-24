namespace JKF.OrderAgent;
table 50370 "JKF Agent Request"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Request Id"; Guid) { }
        field(2; Completed; Boolean) { }
        field(3; "Document Id"; Guid) { }
        field(4; "Document No."; Code[20]) { }
        field(5; Payload; Blob) { }
    }
    keys { key(PK; "Request Id") { Clustered = true; } }
}
