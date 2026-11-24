pageextension 50211 "JKF Vendor Card" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field("JKF Vendor Category"; Rec."JKF Vendor Category")
            {
                ApplicationArea = All;
                ToolTip = 'Angiver kreditorens kategori (fx råvarer, underleverandører, facilities, HR, IT) til brug i indkøbsopfølgningen. Feltet overføres ikke til købsdokumenter.';
            }
        }
    }
}
