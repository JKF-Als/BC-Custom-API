page 50215 "JKF Item Purch. Priorities"
{
    Caption = 'Vareindkøbsprioriteter';
    PageType = List;
    SourceTable = "JKF Item Purchase Priority";
    ApplicationArea = All;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Item Purchase Priorities, Indkøbsprioritet, Købsprioritet';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Angiver koden for indkøbsprioriteten.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Angiver en beskrivelse af indkøbsprioriteten.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ShowItems)
            {
                Caption = 'Varer';
                ToolTip = 'Vis de varer, der har den valgte indkøbsprioritet.';
                Image = Item;
                RunObject = page "Item List";
                RunPageLink = "JKF Purchase Priority" = field("Code");
            }
        }
        area(Promoted)
        {
            actionref(ShowItems_Promoted; ShowItems) { }
        }
    }
}
