page 50340 "JKF Scanner Transactions"
{
    Caption = 'Scanner-transaktioner';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "JKF Scanner Transaction";
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { }
                field(Type; Rec.Type) { }
                field(Status; Rec.Status) { }
                field("Item No."; Rec."Item No.") { }
                field(Quantity; Rec.Quantity) { }
                field("Location Code"; Rec."Location Code") { }
                field("Bin Code"; Rec."Bin Code") { }
                field("New Location Code"; Rec."New Location Code") { }
                field("New Bin Code"; Rec."New Bin Code") { }
                field("Activity No."; Rec."Activity No.") { }
                field("Activity Line No."; Rec."Activity Line No.") { }
                field("Document No."; Rec."Document No.") { }
                field("User ID"; Rec."User ID") { }
                field("Device Id"; Rec."Device Id") { }
                field(SystemCreatedAt; Rec.SystemCreatedAt) { Caption = 'Oprettet'; }
                field("Processed At"; Rec."Processed At") { }
            }
        }
    }
}
