tableextension 50213 "JKF Item Purch. Priority" extends Item
{
    fields
    {
        field(50210; "JKF Purchase Priority"; Code[20])
        {
            Caption = 'Indkøbsprioritet';
            DataClassification = CustomerContent;
            TableRelation = "JKF Item Purchase Priority";
        }
    }

    keys
    {
        key(JKFPurchasePriority; "JKF Purchase Priority") { }
    }
}
