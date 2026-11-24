/// <summary>
/// Log over alt hvad scanner-appen har bogført. Hver POST fra appen indsætter én post,
/// som straks behandles af "JKF Scanner Mgt.". Fejler behandlingen, rulles hele kaldet tilbage
/// og appen får fejlteksten.
/// </summary>
table 50340 "JKF Scanner Transaction"
{
    Caption = 'Scanner-transaktion';
    DataClassification = CustomerContent;
    LookupPageId = "JKF Scanner Transactions";
    DrillDownPageId = "JKF Scanner Transactions";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Løbenr.';
            AutoIncrement = true;
        }
        field(2; Type; Enum "JKF Scanner Trans. Type")
        {
            Caption = 'Type';
        }
        field(3; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Pending,Processed;
            OptionCaption = 'Afventer,Behandlet';
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Varenr.';
            TableRelation = Item;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variantkode';
        }
        field(12; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Enhedskode';
        }
        field(13; Quantity; Decimal)
        {
            Caption = 'Antal';
            DecimalPlaces = 0 : 5;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Lokation';
            TableRelation = Location;
        }
        field(21; "Bin Code"; Code[20])
        {
            Caption = 'Fra-placering';
        }
        field(22; "New Location Code"; Code[10])
        {
            Caption = 'Ny lokation';
            TableRelation = Location;
        }
        field(23; "New Bin Code"; Code[20])
        {
            Caption = 'Til-placering';
        }
        field(30; "Activity No."; Code[20])
        {
            Caption = 'Pluknr.';
        }
        field(31; "Activity Line No."; Integer)
        {
            Caption = 'Pluklinjenr.';
        }
        field(40; "Document No."; Code[20])
        {
            Caption = 'Bilagsnr.';
        }
        field(50; "User ID"; Code[50])
        {
            Caption = 'Bruger-id';
            Editable = false;
        }
        field(51; "Device Id"; Text[50])
        {
            Caption = 'Enheds-id';
        }
        field(52; "Processed At"; DateTime)
        {
            Caption = 'Behandlet';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Activity; Type, "Activity No.", Status)
        {
        }
    }

    trigger OnInsert()
    begin
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
    end;
}
