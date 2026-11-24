namespace JKF.Reservations;

using Microsoft.Inventory.Tracking;

codeunit 50270 "Reserv Source Text"
{
    procedure GetSourceText(Entry: Record "Reservation Entry"): Text[250]
    var
        Prefix: Text;
    begin
        case Entry."Source Type" of
            32:
                exit(CopyStr(StrSubstNo('Item Ledger Entry %1', Entry."Source Ref. No."), 1, 250));
            37:
                Prefix := GetDocumentPrefix(true, Entry."Source Subtype");
            39:
                Prefix := GetDocumentPrefix(false, Entry."Source Subtype");
            5741:
                case Entry."Source Subtype" of
                    0: Prefix := 'Outbound Transfer';
                    1: Prefix := 'Inbound Transfer';
                    else Prefix := 'Transfer';
                end;
            246: Prefix := 'Requisition Line';
            5406: Prefix := 'Prod. Order Line';
            5407: Prefix := 'Prod. Order Component';
            900: Prefix := 'Assembly Header';
            901: Prefix := 'Assembly Line';
            5902: Prefix := 'Service Line';
            99000829: Prefix := 'Planning Component';
            99000850: Prefix := 'Planning Line';
            else
                Prefix := StrSubstNo('Source Type %1', Entry."Source Type");
        end;

        // The structured source fields in the API are the authoritative key.
        if Entry."Source ID" <> '' then
            Prefix += ' ' + Entry."Source ID";
        if Entry."Source Batch Name" <> '' then
            Prefix += '/' + Entry."Source Batch Name";
        if Entry."Source Prod. Order Line" <> 0 then
            Prefix += StrSubstNo('/%1', Entry."Source Prod. Order Line");
        if Entry."Source Ref. No." <> 0 then
            Prefix += StrSubstNo('-%1', Entry."Source Ref. No.");
        exit(CopyStr(Prefix, 1, 250));
    end;

    local procedure GetDocumentPrefix(Sales: Boolean; Subtype: Integer): Text
    var
        Prefix: Text;
        DocumentType: Text;
    begin
        if Sales then
            Prefix := 'Sales'
        else
            Prefix := 'Purchase';
        case Subtype of
            0: DocumentType := 'Quote';
            1: DocumentType := 'Order';
            2: DocumentType := 'Invoice';
            3: DocumentType := 'Credit Memo';
            4: DocumentType := 'Blanket Order';
            5: DocumentType := 'Return Order';
            else DocumentType := StrSubstNo('Document Type %1', Subtype);
        end;
        exit(Prefix + ' ' + DocumentType);
    end;
}
