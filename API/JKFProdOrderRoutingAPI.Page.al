page 50274 "JKF Prod Order Routing API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'productionOrderRoutingLine';
    EntitySetName = 'productionOrderRoutingLines';
    SourceTable = "Prod. Order Routing Line";
    SourceTableView = where(Status = const(Released));
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { Editable = false; }
                field(productionOrderNo; Rec."Prod. Order No.") { Editable = false; }
                field(status; Rec.Status) { Editable = false; }
                field(routingReferenceNo; Rec."Routing Reference No.") { Editable = false; }
                field(routingNo; Rec."Routing No.") { Editable = false; }
                field(operationNo; Rec."Operation No.") { Editable = false; }
                field(description; Rec.Description) { Editable = false; }
                field(startingDateTime; RequestedStart)
                {
                    trigger OnValidate()
                    begin
                        StartSpecified := true;
                    end;
                }
                field(endingDateTime; RequestedEnd)
                {
                    trigger OnValidate()
                    begin
                        EndSpecified := true;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RequestedStart := Rec."Starting Date-Time";
        RequestedEnd := Rec."Ending Date-Time";
        StartSpecified := false;
        EndSpecified := false;
    end;

    trigger OnModifyRecord(): Boolean
    var
        RoutingLine: Record "Prod. Order Routing Line";
        StartValue: DateTime;
        EndValue: DateTime;
    begin
        // Defer validation until all PATCH properties have been read.
        StartValue := RequestedStart;
        EndValue := RequestedEnd;
        if not (StartSpecified or EndSpecified) then
            Error('Specify startingDateTime or endingDateTime.');
        if StartSpecified and (StartValue = 0DT) then
            Error('startingDateTime cannot be empty.');
        if EndSpecified and (EndValue = 0DT) then
            Error('endingDateTime cannot be empty.');
        if StartSpecified and EndSpecified and (StartValue > EndValue) then
            Error('startingDateTime must be before endingDateTime.');

        RoutingLine.LockTable();
        RoutingLine.GetBySystemId(Rec.SystemId);
        RoutingLine.TestField(Status, RoutingLine.Status::Released);
        if RoutingLine."Routing Status" = RoutingLine."Routing Status"::Finished then
            Error('A finished routing operation cannot be rescheduled.');
        RoutingLine.SetHideValidationDialog(true);

        if StartSpecified then
            RoutingLine.Validate("Starting Date-Time", StartValue);
        if EndSpecified then
            RoutingLine.Validate("Ending Date-Time", EndValue);

        // Standard scheduling may recalculate either endpoint. Never silently
        // accept a pair of requested timestamps that BC cannot preserve.
        if StartSpecified and (RoutingLine."Starting Date-Time" <> StartValue) then
            Error('BC recalculated the start. Submit only one endpoint, or adjust the operation duration/calendar.');
        if EndSpecified and (RoutingLine."Ending Date-Time" <> EndValue) then
            Error('BC recalculated the end. Submit only one endpoint, or adjust the operation duration/calendar.');
        RoutingLine.Modify(true);
        Rec := RoutingLine;
        RequestedStart := Rec."Starting Date-Time";
        RequestedEnd := Rec."Ending Date-Time";
        // We have already saved with triggers. Prevent a second platform write.
        exit(false);
    end;

    var
        RequestedStart: DateTime;
        RequestedEnd: DateTime;
        StartSpecified: Boolean;
        EndSpecified: Boolean;
}
