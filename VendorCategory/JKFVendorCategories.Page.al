page 50211 "JKF Vendor Categories"
{
    Caption = 'Kreditorkategorier';
    PageType = List;
    SourceTable = "JKF Vendor Category";
    ApplicationArea = All;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Vendor Categories, Leverandørkategorier, Kreditor kategori';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Angiver koden for kreditorkategorien.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Angiver en beskrivelse af kreditorkategorien.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Vendors)
            {
                Caption = 'Kreditorer';
                ToolTip = 'Vis de kreditorer, der har den valgte kategori.';
                Image = Vendor;
                RunObject = page "Vendor List";
                RunPageLink = "JKF Vendor Category" = field("Code");
            }
        }
        area(Promoted)
        {
            actionref(Vendors_Promoted; Vendors) { }
        }
    }
}
