report 50203 "ISD Backfill Descriptions"
{
    Caption = 'Udfyld interne beskrivelser på eksisterende salgsordre/salgstilbud';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesLine; "Sales Line")
        {
            DataItemTableView = sorting("Document Type", "Document No.", "Line No.")
                where("Document Type" = filter(Quote | Order), Type = const(Item));
            RequestFilterFields = "Document Type", "Document No.", "Sell-to Customer No.", "No.";

            trigger OnPreDataItem()
            begin
                SalesLine.SetRange("ISD Internal Description", '');
                SalesLine.SetRange("ISD Internal Description 2", '');
                if GuiAllowed() then
                    if not Confirm(ConfirmLbl, false, SalesLine.Count(), SalesLine.GetFilters()) then
                        CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            var
                CurrentLine: Record "Sales Line";
            begin
                // Re-read under an update lock to preserve any concurrent edits.
                CurrentLine.LockTable();
                if not CurrentLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then
                    exit;
                if CurrentLine.Type <> CurrentLine.Type::Item then
                    exit;
                if (CurrentLine."ISD Internal Description" <> '') or
                   (CurrentLine."ISD Internal Description 2" <> '') then
                    exit;

                CurrentLine.ISDPopulateInternalDescriptions();
                if (CurrentLine."ISD Internal Description" = '') and
                   (CurrentLine."ISD Internal Description 2" = '') then begin
                    SkippedCount += 1;
                    exit;
                end;

                // Do not validate the item or run the standard line modify trigger.
                CurrentLine.Modify(false);
                UpdatedCount += 1;
            end;
        }
    }

    trigger OnPostReport()
    begin
        if GuiAllowed() then
            Message(ResultLbl, UpdatedCount, SkippedCount);
    end;

    var
        UpdatedCount: Integer;
        SkippedCount: Integer;
        ConfirmLbl: Label 'Fill internal descriptions on up to %1 existing sales quote/order item lines using current item/variant descriptions? Only lines with both internal fields blank will be updated. Filters: %2', Comment = '%1 = candidate line count, %2 = line filters';
        ResultLbl: Label '%1 line(s) updated. %2 line(s) skipped because no nonblank source descriptions were found.', Comment = '%1 = updated count, %2 = empty-source count';
}
