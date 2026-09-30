page 50241 "Unused Items API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'unusedItem';
    EntitySetName = 'unusedItems';
    SourceTable = Item;
    SourceTableView = where(
        "Cleanup Has Item Ledger Entry" = const(false),
        "Cleanup Has Sales Invoice Line" = const(false),
        "Cleanup Has Sales Line" = const(false),
        "Cleanup Has Purch Invoice Line" = const(false));
    ODataKeyFields = SystemId;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field(id; Rec.SystemId) { }
                field(itemNo; Rec."No.") { }
                field(description; Rec.Description) { }
                field(description2; Rec."Description 2") { }
                field(baseUnitOfMeasure; Rec."Base Unit of Measure") { }
                field(inventoryPostingGroup; Rec."Inventory Posting Group") { }
                field(masterSpecialItemEvas; Rec."Master Special Item_EVAS") { }
            }
        }
    }
    trigger OnOpenPage()
    var
        ItemNoFilter: Text;
        Letter: Text[1];
        LetterIndex: Integer;
        PreviousFilterGroup: Integer;
        Letters: Text[29];
    begin
        // Item No. is a Code field, so its value is stored in uppercase.
        Letters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅ';
        ItemNoFilter := '<>E????&<>E_*&<>*ECON*';
        for LetterIndex := 1 to StrLen(Letters) do begin
            Letter := CopyStr(Letters, LetterIndex, 1);
            ItemNoFilter += '&<>*6' + Letter + '*';
        end;
        PreviousFilterGroup := Rec.FilterGroup();
        Rec.FilterGroup(10);
        Rec.SetFilter("No.", ItemNoFilter);
        Rec.SetFilter(Description, '<>@*ECON*');
        Rec.FilterGroup(PreviousFilterGroup);
    end;
}