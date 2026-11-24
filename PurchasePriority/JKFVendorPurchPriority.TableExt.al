tableextension 50212 "JKF Vendor Purch. Priority" extends Vendor
{
    fields
    {
        field(50210; "JKF Purchase Priority"; Code[20])
        {
            Caption = 'Indkøbsprioritet';
            DataClassification = CustomerContent;
            TableRelation = "JKF Purchase Priority";
        }
    }

    keys
    {
        key(JKFPurchasePriority; "JKF Purchase Priority") { }
    }
}
