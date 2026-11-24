page 50212 "JKF Vendor Purch. Priorities"
{
    Caption = 'Kreditorindkøbsprioriteter';
    PageType = List;
    SourceTable = "JKF Purchase Priority";
    ApplicationArea = All;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Vendor Purchase Priorities, Indkøbsprioritet, Købsprioritet';

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
            action(ShowVendors)
            {
                Caption = 'Kreditorer';
                ToolTip = 'Vis de kreditorer, der har den valgte indkøbsprioritet.';
                Image = Vendor;
                RunObject = page "Vendor List";
                RunPageLink = "JKF Purchase Priority" = field("Code");
            }
        }
        area(Promoted)
        {
            actionref(ShowVendors_Promoted; ShowVendors) { }
        }
    }
}
