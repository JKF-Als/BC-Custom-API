table 50220 "JKF Customer Contact Buffer"
{
    Caption = 'JKF Customer Contact Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; SystemId; Guid)
        {
            Caption = 'SystemId';
        }

        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }

        field(20; Name; Text[100])
        {
            Caption = 'Name';
        }

        field(30; Email; Text[80])
        {
            Caption = 'Email';
        }

        field(40; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
        }

        field(50; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
        }

        field(60; "Company Contact No."; Code[20])
        {
            Caption = 'Company Contact No.';
        }

        field(70; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
    }

    keys
    {
        key(PK; SystemId)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if IsNullGuid(SystemId) then
            SystemId := CreateGuid();
    end;
}