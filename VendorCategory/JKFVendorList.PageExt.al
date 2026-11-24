pageextension 50212 "JKF Vendor List" extends "Vendor List"
{
    layout
    {
        addafter(Name)
        {
            field("JKF Vendor Category"; Rec."JKF Vendor Category")
            {
                ApplicationArea = All;
                ToolTip = 'Angiver kreditorens kategori (fx råvarer, underleverandører, facilities, HR, IT) til brug i indkøbsopfølgningen.';
            }
        }
    }

    actions
    {
        addlast(navigation)
        {
            action(JKFVendorCategories)
            {
                ApplicationArea = All;
                Caption = 'Kreditorkategorier';
                ToolTip = 'Opret og rediger kreditorkategorier.';
                Image = Setup;
                RunObject = page "JKF Vendor Categories";
            }
        }
    }
}
