tableextension 50262 "JKF Sales Header Orig Order" extends "Sales Header"
{
    fields
    {
        field(50262; "JKF Original Order No."; Code[20])
        {
            Caption = 'Oprindeligt ordrenummer';
            DataClassification = CustomerContent;
        }
    }
}

tableextension 50266 "JKF Cr Memo Header Orig Order" extends "Sales Cr.Memo Header"
{
    fields
    {
        // Same field number and type as Sales Header for transfer during posting.
        field(50262; "JKF Original Order No."; Code[20])
        {
            Caption = 'Oprindeligt ordrenummer';
            DataClassification = CustomerContent;
        }
    }
}

tableextension 50268 "JKF Sales Inv Hdr Orig Order" extends "Sales Invoice Header"
{
    fields
    {
        // Same field number and type as Sales Header for transfer during posting.
        field(50262; "JKF Original Order No."; Code[20])
        {
            Caption = 'Oprindeligt ordrenummer';
            DataClassification = CustomerContent;
        }
    }
}

pageextension 50268 "JKF Posted Sales Inv Orig Ord" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("External Document No.")
        {
            field("JKF Original Order No."; Rec."JKF Original Order No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Angiver det oprindelige ordrenummer for den bogførte salgsfaktura.';
            }
        }
    }
}

tableextension 50269 "JKF Sales Hdr Arch Orig Order" extends "Sales Header Archive"
{
    fields
    {
        // Same field number and type as Sales Header for transfer during archiving.
        field(50262; "JKF Original Order No."; Code[20])
        {
            Caption = 'Oprindeligt ordrenummer';
            DataClassification = CustomerContent;
        }
    }
}

pageextension 50269 "JKF Sales Ord Arch Orig Order" extends "Sales Order Archive"
{
    layout
    {
        addafter("External Document No.")
        {
            field("JKF Original Order No."; Rec."JKF Original Order No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Angiver det oprindelige ordrenummer for den arkiverede salgsordre.';
            }
        }
    }
}

pageextension 50267 "JKF Posted Cr Memo Orig Order" extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter("External Document No.")
        {
            field("JKF Original Order No."; Rec."JKF Original Order No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Angiver det oprindelige ordrenummer for den bogførte salgskreditnota.';
            }
        }
    }
}

pageextension 50263 "JKF Sales Order Orig Order" extends "Sales Order"
{
    layout
    {
        addafter("External Document No.")
        {
            field("JKF Original Order No."; Rec."JKF Original Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Angiver det oprindelige ordrenummer for salgsordren.';
            }
        }
    }
}

pageextension 50265 "JKF Sales Return Orig Order" extends "Sales Return Order"
{
    layout
    {
        addafter("External Document No.")
        {
            field("JKF Original Order No."; Rec."JKF Original Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Angiver det oprindelige ordrenummer for salgsreturordren.';
            }
        }
    }
}

pageextension 50264 "JKF Sales Cr Memo Orig Order" extends "Sales Credit Memo"
{
    layout
    {
        addafter("External Document No.")
        {
            field("JKF Original Order No."; Rec."JKF Original Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Angiver det oprindelige ordrenummer for salgskreditnotaen.';
            }
        }
    }
}
