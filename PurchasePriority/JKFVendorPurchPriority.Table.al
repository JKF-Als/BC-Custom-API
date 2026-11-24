table 50212 "JKF Purchase Priority"
{
    Caption = 'Kreditorindkøbsprioritet';
    DataClassification = CustomerContent;
    LookupPageId = "JKF Vendor Purch. Priorities";
    DrillDownPageId = "JKF Vendor Purch. Priorities";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Kode';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Beskrivelse';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description) { }
        fieldgroup(Brick; "Code", Description) { }
    }

    trigger OnDelete()
    var
        Vendor: Record Vendor;
        PriorityInUseErr: Label 'Indkøbsprioriteten %1 kan ikke slettes, da den bruges på %2 kreditor(er).', Comment = '%1 = prioritetskode, %2 = antal';
    begin
        Vendor.SetRange("JKF Purchase Priority", Rec."Code");
        if not Vendor.IsEmpty() then
            Error(PriorityInUseErr, Rec."Code", Vendor.Count());
    end;
}
