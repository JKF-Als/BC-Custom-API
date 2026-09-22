page 50222 "Buhler Packing Note Sub API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'packingNote';
    EntitySetName = 'packingNotes';
    SourceTable = "Packing Note Header_EVAS";
    DelayedInsert = true;
    ODataKeyFields = SystemId;

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
                field(colliNo; Rec."Colli No.")
                {
                    Caption = 'Colli No.';
                }
                // --- NEW FIELDS ADDED HERE ---
                field(totalNetWeightKg; Rec."Total Net Weight (Kg)")
                {
                    Caption = 'Total Net Weight (Kg)';
                }
                field(totalWeightKg; Rec."Total Weight (Kg)")
                {
                    Caption = 'Total Weight (Kg)';
                }
                field(actualLoadMeter; Rec."Actual Load Meter")
                {
                    Caption = 'Actual Load Meter';
                }
                field(length; Rec.Length)
                {
                    Caption = 'Length';
                }
                field(width; Rec.Width)
                {
                    Caption = 'Width';
                }
                field(height; Rec.Height)
                {
                    Caption = 'Height';
                }
                // -----------------------------
                field(numberOfItems; NumberOfItems)
                {
                    Caption = 'Number of Items per Colli';
                    Editable = false;
                }
            }
        }
    }

    var
        NumberOfItems: Integer;

    trigger OnAfterGetRecord()
    var
        PackingNoteLine: Record "Packing Note Line_EVAS";
    begin
        Clear(NumberOfItems);

        // IMPORTANT: Change "Document No." to the actual field that links Line to Header
        PackingNoteLine.SetRange("Document No.", Rec."No.");
        NumberOfItems := PackingNoteLine.Count();
    end;
}