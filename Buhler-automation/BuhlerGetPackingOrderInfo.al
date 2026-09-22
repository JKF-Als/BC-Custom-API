page 50220 "Buhler Get Packing Order Info"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'buhlerGetPackingOrderInfo';
    EntitySetName = 'buhlerGetPackingOrderInfo';
    SourceTable = "Sales Header";
    DelayedInsert = true;
    ODataKeyFields = "No.";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(documentType; Rec."Document Type") { Caption = 'Document Type'; }
                field(no; Rec."No.") { Caption = 'No.'; }
                field(sellToCustomerNo; Rec."Sell-to Customer No.") { Caption = 'Sell-to Customer No.'; }
                field(externalDocumentNo; Rec."External Document No.") { Caption = 'External Document No.'; }
                field(shipToCountryRegionCode; Rec."Ship-to Country/Region Code") { Caption = 'Delivery Country Code'; }

                field(shipToCountryRegionName; ShipToCountryRegionName)
                {
                    Caption = 'Delivery Country Name';
                    Editable = false;
                }
                field(barcode_EVAS; Rec.Barcode_EVAS) { Caption = 'Barcode EVAS'; }

                field("PlannedShipmentDate_EVAS"; Rec."Planned Shipment Date_EVAS") { Caption = 'Planned Shipment Date'; }

                // --- NEW: The nested array of Packing Notes ---
                part(packingNotes; "Buhler Packing Note Sub API")
                {
                    Caption = 'Packing Notes';
                    EntityName = 'packingNote';
                    EntitySetName = 'packingNotes';

                    SubPageLink = "Sales Order No." = field("No.");
                }
            }
        }
    }

    var
        ShipToCountryRegionName: Text[50];

    trigger OnAfterGetRecord()
    var
        CountryRegion: Record "Country/Region";
    begin
        Clear(ShipToCountryRegionName);
        if CountryRegion.Get(Rec."Ship-to Country/Region Code") then
            ShipToCountryRegionName := CountryRegion.Name;
    end;

    [ServiceEnabled]
    procedure generatePackingListExcel(): Text
    var
        PackingNoteHeader: Record "Packing Note Header_EVAS";
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        OStream: OutStream;
        IStream: InStream;
        RecRef: RecordRef;
    begin
        TempBlob.CreateOutStream(OStream);

        // 1. Filter for ALL packing notes linked to this Order
        PackingNoteHeader.SetRange("Sales Order No.", Rec."No.");

        if not PackingNoteHeader.FindFirst() then
            Error('No packing notes found for Order %1', Rec."No.");

        // 2. Put the filtered table directly into the RecordRef.
        // We DO NOT use SetRecFilter() here, so it keeps the SetRange for all packing notes!
        RecRef.GetTable(PackingNoteHeader);

        // 3. Run the report
        Report.SaveAs(60017, '', ReportFormat::Excel, OStream, RecRef);

        // 4. Return as Base64
        TempBlob.CreateInStream(IStream);
        exit(Base64Convert.ToBase64(IStream));
    end;
}