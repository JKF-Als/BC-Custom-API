// Felter til Claudes ladmeter-estimat.
// Estimatet skrives på lagerstedsforsendelsen og følger med til den bogførte
// lagerstedsforsendelse (se codeunit 50231), så det kan sammenlignes med
// de faktiske ladmeter ("Actual Load Meter_EVAS").

tableextension 50231 "JKF Whse. Shpt. Header Est." extends "Warehouse Shipment Header"
{
    fields
    {
        field(50231; "JKF Est. Load Meter"; Decimal)
        {
            Caption = 'Estimeret ladmeter';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "JKF Estimated At" := CurrentDateTime();
            end;
        }
        field(50232; "JKF Est. Number of Packages"; Decimal)
        {
            Caption = 'Estimeret antal kolli';
            DecimalPlaces = 0 : 0;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(50233; "JKF Estimate Note"; Text[250])
        {
            Caption = 'Estimat-begrundelse';
            DataClassification = CustomerContent;
        }
        field(50234; "JKF Estimated At"; DateTime)
        {
            Caption = 'Estimeret';
            Editable = false;
            DataClassification = SystemMetadata;
        }
    }
}

tableextension 50232 "JKF Posted Whse. Shpt. Hdr Est" extends "Posted Whse. Shipment Header"
{
    fields
    {
        field(50231; "JKF Est. Load Meter"; Decimal)
        {
            Caption = 'Estimeret ladmeter';
            DecimalPlaces = 0 : 2;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50232; "JKF Est. Number of Packages"; Decimal)
        {
            Caption = 'Estimeret antal kolli';
            DecimalPlaces = 0 : 0;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50233; "JKF Estimate Note"; Text[250])
        {
            Caption = 'Estimat-begrundelse';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50234; "JKF Estimated At"; DateTime)
        {
            Caption = 'Estimeret';
            Editable = false;
            DataClassification = SystemMetadata;
        }
    }
}
