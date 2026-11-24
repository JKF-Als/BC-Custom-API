pageextension 50213 "JKF Vendor Card Purch. Prio." extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field("JKF Purchase Priority"; Rec."JKF Purchase Priority")
            {
                ApplicationArea = All;
                ToolTip = 'Angiver kreditorens indkøbsprioritet. Koderne vedligeholdes på siden Kreditorindkøbsprioriteter.';
            }
        }
    }
}
