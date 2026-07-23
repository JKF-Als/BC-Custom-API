page 50291 "Attribute Population via CSV"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks; // This property makes the page searchable!
    Caption = 'Attribute Population via CSV';

    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(Instructions)
            {
                Caption = 'Import Details';

                // A simple text label to guide the user
                field(InfoText; 'Click the "Run CSV Import" button in the menu to select and process your file.')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunImport)
            {
                ApplicationArea = All;
                Caption = 'Run CSV Import';
                Image = Import;

                // Promote the action so it appears as a large button at the top of the page
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    // Runs the XMLport from our previous steps
                    Xmlport.Run(Xmlport::"Import Item Attributes CSV", false, true);
                    Message('Import complete!');
                end;
            }
        }
    }
}