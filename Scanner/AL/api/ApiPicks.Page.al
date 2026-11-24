page 50343 "JKF API Picks"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'scanner';
    APIVersion = 'v1.0';
    EntityName = 'pick';
    EntitySetName = 'picks';
    EntityCaption = 'Pluk';
    EntitySetCaption = 'Pluk';
    SourceTable = "Warehouse Activity Header";
    SourceTableView = where(Type = const(Pick));
    ODataKeyFields = SystemId;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { }
                field(number; Rec."No.") { }
                field(locationCode; Rec."Location Code") { }
                field(assignedUserId; Rec."Assigned User ID") { }
                field(assignedToMe; AssignedToMe) { }
                field(numberOfLines; NoOfLines) { }
                field(documentType; DocumentType) { }
                field(documentNumber; DocumentNo) { }
                field(destinationName; DestinationName) { }
            }
        }
    }

    var
        AssignedToMe: Boolean;
        NoOfLines: Integer;
        DocumentType: Text[50];
        DocumentNo: Code[20];
        DestinationName: Text[100];

    trigger OnAfterGetRecord()
    var
        WhseActivLine: Record "Warehouse Activity Line";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
    begin
        AssignedToMe := Rec."Assigned User ID" = UserId();
        Clear(DocumentType);
        Clear(DocumentNo);
        Clear(DestinationName);

        WhseActivLine.SetRange("Activity Type", Rec.Type);
        WhseActivLine.SetRange("No.", Rec."No.");
        WhseActivLine.SetFilter("Action Type", '%1|%2', WhseActivLine."Action Type"::Take, WhseActivLine."Action Type"::" ");
        NoOfLines := WhseActivLine.Count();
        if not WhseActivLine.FindFirst() then
            exit;

        DocumentType := Format(WhseActivLine."Whse. Document Type");
        DocumentNo := WhseActivLine."Whse. Document No.";
        case WhseActivLine."Destination Type" of
            WhseActivLine."Destination Type"::Customer:
                if Customer.Get(WhseActivLine."Destination No.") then
                    DestinationName := Customer.Name;
            WhseActivLine."Destination Type"::Vendor:
                if Vendor.Get(WhseActivLine."Destination No.") then
                    DestinationName := Vendor.Name;
            WhseActivLine."Destination Type"::Location:
                if Location.Get(WhseActivLine."Destination No.") then
                    DestinationName := Location.Name;
        end;
    end;
}
