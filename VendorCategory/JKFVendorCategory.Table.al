table 50211 "JKF Vendor Category"
{
    Caption = 'Kreditorkategori';
    DataClassification = CustomerContent;
    LookupPageId = "JKF Vendor Categories";
    DrillDownPageId = "JKF Vendor Categories";

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
        CategoryInUseErr: Label 'Kreditorkategorien %1 kan ikke slettes, da den bruges på %2 kreditor(er).', Comment = '%1 = kategorikode, %2 = antal kreditorer';
    begin
        Vendor.SetRange("JKF Vendor Category", Rec."Code");
        if not Vendor.IsEmpty() then
            Error(CategoryInUseErr, Rec."Code", Vendor.Count());
    end;
}
