tableextension 50200 "ISD Sales Line" extends "Sales Line"
{
    fields
    {
        field(50100; "ISD Internal Description"; Text[100])
        {
            Caption = 'Intern beskrivelse';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50101; "ISD Internal Description 2"; Text[50])
        {
            Caption = 'Intern beskrivelse 2';
            DataClassification = CustomerContent;
            Editable = false;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                Rec.ISDPopulateInternalDescriptions();
            end;
        }
        modify("Variant Code")
        {
            trigger OnAfterValidate()
            begin
                Rec.ISDPopulateInternalDescriptions();
            end;
        }
        modify(Type)
        {
            trigger OnAfterValidate()
            begin
                Rec.ISDPopulateInternalDescriptions();
            end;
        }
    }

    procedure ISDPopulateInternalDescriptions()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        Clear(Rec."ISD Internal Description");
        Clear(Rec."ISD Internal Description 2");

        if Rec.Type <> Rec.Type::Item then
            exit;
        if not Item.Get(Rec."No.") then
            exit;

        Rec."ISD Internal Description" := Item.Description;
        Rec."ISD Internal Description 2" := Item."Description 2";

        if Rec."Variant Code" <> '' then
            if ItemVariant.Get(Rec."No.", Rec."Variant Code") then begin
                Rec."ISD Internal Description" := ItemVariant.Description;
                Rec."ISD Internal Description 2" := ItemVariant."Description 2";
            end;
    end;
}
