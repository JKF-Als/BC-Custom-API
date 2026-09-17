page 50225 "JKF German Item List"
{
    PageType = List;
    SourceTable = "Item Translation";

    Caption = 'Tyske varetekster';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Caption = 'Nummer';
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        if Item.Get(Rec."Item No.") then
                            Page.Run(Page::"Item Card", Item);
                    end;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Beskrivelse';
                }

                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Caption = 'Beskrivelse 2';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Language Code", 'DEU');
        Rec.SetRange("Variant Code", '');
    end;
}