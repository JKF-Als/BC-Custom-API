tableextension 50211 "JKF Vendor" extends Vendor
{
    fields
    {
        field(50200; "JKF Vendor Category"; Code[20])
        {
            Caption = 'Kreditorkategori';
            DataClassification = CustomerContent;
            TableRelation = "JKF Vendor Category";
        }
    }

    keys
    {
        key(JKFVendorCategory; "JKF Vendor Category") { }
    }
}
