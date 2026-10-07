pageextension 50204 "ISD Sales Quote Subform" extends "Sales Quote Subform"
{
    layout
    {
        addafter(Description)
        {
            field("ISD Internal Description"; Rec."ISD Internal Description")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
                ToolTip = 'Specifies the original item or variant description copied when the item or variant was selected.';
            }
            field("ISD Internal Description 2"; Rec."ISD Internal Description 2")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
                ToolTip = 'Specifies the original additional item or variant description copied when the item or variant was selected.';
            }
        }
    }
}
