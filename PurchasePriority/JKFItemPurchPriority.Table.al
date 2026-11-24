table 50213 "JKF Item Purchase Priority"
{
    Caption = 'Vareindkøbsprioritet';
    DataClassification = CustomerContent;
    LookupPageId = "JKF Item Purch. Priorities";
    DrillDownPageId = "JKF Item Purch. Priorities";

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
        Item: Record Item;
        PriorityInUseErr: Label 'Indkøbsprioriteten %1 kan ikke slettes, da den bruges på %2 vare(r).', Comment = '%1 = prioritetskode, %2 = antal';
    begin
        Item.SetRange("JKF Purchase Priority", Rec."Code");
        if not Item.IsEmpty() then
            Error(PriorityInUseErr, Rec."Code", Item.Count());
    end;
}
