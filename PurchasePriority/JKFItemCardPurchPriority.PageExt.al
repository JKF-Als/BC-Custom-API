pageextension 50214 "JKF Item Card Purch. Prio." extends "Item Card"
{
    layout
    {
        addafter("Vendor No.")
        {
            field("JKF Purchase Priority"; Rec."JKF Purchase Priority")
            {
                ApplicationArea = All;
                ToolTip = 'Angiver varens indkøbsprioritet. Koderne vedligeholdes på siden Vareindkøbsprioriteter.';
            }
        }
    }
}
