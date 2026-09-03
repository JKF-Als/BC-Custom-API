page 50224 "JKF Customer Dimension API"
{
    PageType = API;
    Caption = 'JKF Customer Dimension API';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'customerDimension';
    EntitySetName = 'customerDimensions';

    SourceTable = "Default Dimension"; // Table 352
    DelayedInsert = true;

    // Use SystemId or the composite PK
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(tableId; Rec."Table ID")
                {
                    Caption = 'Table ID';
                    Visible = false;
                }
                field(No; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code';
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    Caption = 'Dimension Value Code';
                }
                field(valuePosting; Rec."Value Posting")
                {
                    Caption = 'Value Posting';
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ExistingDefDim: Record "Default Dimension";
    begin
        Rec."Table ID" := Database::Customer;

        // Check if the template already created this dimension for the customer
        if ExistingDefDim.Get(Database::Customer, Rec."No.", Rec."Dimension Code") then begin
            // Overwrite existing template values
            ExistingDefDim.Validate("Dimension Value Code", Rec."Dimension Value Code");
            ExistingDefDim.Validate("Value Posting", Rec."Value Posting");
            ExistingDefDim.Modify(true);

            // Point Rec to the modified record so OData returns the correct entity state
            Rec := ExistingDefDim;
            exit(false); // Handled manually; suppresses default insert
        end;

        // If it doesn't exist, proceed with standard insert
        exit(true);
    end;
}