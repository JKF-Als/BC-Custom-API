codeunit 50275 "JKF Release And Schedule"
{
    // Business logic called by the API page.
    // One request releases an existing order and schedules one routing operation.
    // The starting date-time is binding; BC calculates the ending date-time
    // forward from setup/run time and the work/machine center calendar.
    //
    // Time zones: BC plans on local wall-clock dates/times (calendars, shifts)
    // and derives the Date-Time fields in the session's time zone. An Entra app
    // (S2S) session runs in UTC, which would shift everything by the UTC offset.
    // The request is therefore converted to local time (PlanningTimeZoneTok)
    // explicitly, and Date-Time fields written in the session's time zone are
    // corrected afterwards.
    var
        PlanningTimeZoneTok: Label 'Romance Standard Time', Locked = true;

    [CommitBehavior(CommitBehavior::Ignore)]
    procedure ReleaseAndSchedule(number: Code[20]; operationNo: Code[10]; startingDateTime: DateTime): Guid
    var
        ProductionOrder: Record "Production Order";
        ReleasedOrder: Record "Production Order";
        RoutingLine: Record "Prod. Order Routing Line";
        StatusManagement: Codeunit "Prod. Order Status Management";
        LocalStartDate: Date;
        LocalStartTime: Time;
    begin
        if number = '' then
            Error('number is required.');
        if operationNo = '' then
            Error('operationNo is required.');
        if startingDateTime = 0DT then
            Error('startingDateTime is required.');
        UtcToLocal(startingDateTime, LocalStartDate, LocalStartTime);

        ProductionOrder.LockTable();
        ProductionOrder.SetRange("No.", number);
        ProductionOrder.SetFilter(Status, '%1|%2|%3', ProductionOrder.Status::Planned,
            ProductionOrder.Status::"Firm Planned", ProductionOrder.Status::Released);
        if ProductionOrder.Count() <> 1 then
            Error('Order %1 must identify exactly one Planned, Firm Planned or Released production order.', number);
        ProductionOrder.FindFirst();

        // Validate the selection before release; operation numbers can repeat
        // across production order lines/routing references.
        RoutingLine.LockTable();
        FindOperation(ProductionOrder, operationNo, RoutingLine);
        case ProductionOrder.Status of
            ProductionOrder.Status::Released:
                ReleasedOrder := ProductionOrder;
            else
                StatusManagement.ChangeProdOrderStatus(ProductionOrder, ReleasedOrder,
                    ProductionOrder.Status::Released, WorkDate(), false);
        end;
        ReleasedOrder.TestField(Status, ReleasedOrder.Status::Released);
        SetPlanningFlexibilityNone(ReleasedOrder);

        // Standard release can change both the order number and SystemId.
        FindOperation(ReleasedOrder, operationNo, RoutingLine);
        RoutingLine.SetHideValidationDialog(true);
        // CreateDateTime uses the session time zone, so BC splits it back into
        // exactly the local date/time requested.
        RoutingLine.Validate("Starting Date-Time", CreateDateTime(LocalStartDate, LocalStartTime));
        CheckStartTime(RoutingLine, LocalStartDate, LocalStartTime);
        RoutingLine.Modify(true);
        RoutingLine.GetBySystemId(RoutingLine.SystemId);
        CheckStartTime(RoutingLine, LocalStartDate, LocalStartTime);

        NormalizeOrderDateTimes(ReleasedOrder);
        exit(RoutingLine.SystemId);
    end;

    local procedure FindOperation(ProductionOrder: Record "Production Order"; OperationNo: Code[10]; var RoutingLine: Record "Prod. Order Routing Line")
    begin
        RoutingLine.Reset();
        RoutingLine.SetRange(Status, ProductionOrder.Status);
        RoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        RoutingLine.SetRange("Operation No.", OperationNo);
        if RoutingLine.Count() <> 1 then
            Error('Operation %1 must identify exactly one routing line on order %2. Missing or ambiguous operations cannot be scheduled.', OperationNo, ProductionOrder."No.");
        RoutingLine.FindFirst();
        if RoutingLine."Routing Status" = RoutingLine."Routing Status"::Finished then
            Error('A finished routing operation cannot be rescheduled.');
    end;

    local procedure SetPlanningFlexibilityNone(ProductionOrder: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        // Lock the released order against replanning; Validate also updates
        // the planning flexibility on related reservation entries.
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if ProdOrderLine.FindSet(true) then
            repeat
                if ProdOrderLine."Planning Flexibility" <> ProdOrderLine."Planning Flexibility"::None then begin
                    ProdOrderLine.Validate("Planning Flexibility", ProdOrderLine."Planning Flexibility"::None);
                    ProdOrderLine.Modify(true);
                end;
            until ProdOrderLine.Next() = 0;
    end;

    local procedure CheckStartTime(RoutingLine: Record "Prod. Order Routing Line"; LocalDate: Date; LocalTime: Time)
    begin
        if (RoutingLine."Starting Date" <> LocalDate) or (RoutingLine."Starting Time" <> LocalTime) then
            Error('BC scheduling moved the operation start from %1 %2 to %3 %4 (%5), e.g. outside working hours in the calendar. The request has been cancelled.',
                Format(LocalDate, 0, 9), Format(LocalTime, 0, 9),
                Format(RoutingLine."Starting Date", 0, 9), Format(RoutingLine."Starting Time", 0, 9),
                PlanningTimeZoneTok);
    end;

    // Fixes Date-Time fields on the order that BC derived from local date/time
    // in the session's time zone. Records whose Date-Time does not match that
    // pattern (e.g. created by normal users) are left untouched.
    local procedure NormalizeOrderDateTimes(ProductionOrder: Record "Production Order")
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        RoutingLine: Record "Prod. Order Routing Line";
        Component: Record "Prod. Order Component";
        CapacityNeed: Record "Prod. Order Capacity Need";
        Changed: Boolean;
    begin
        ProdOrder.Get(ProductionOrder.Status, ProductionOrder."No.");
        Changed := FixDateTime(ProdOrder."Starting Date", ProdOrder."Starting Time", ProdOrder."Starting Date-Time");
        if FixDateTime(ProdOrder."Ending Date", ProdOrder."Ending Time", ProdOrder."Ending Date-Time") then
            Changed := true;
        if Changed then
            ProdOrder.Modify(false);

        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if ProdOrderLine.FindSet(true) then
            repeat
                Changed := FixDateTime(ProdOrderLine."Starting Date", ProdOrderLine."Starting Time", ProdOrderLine."Starting Date-Time");
                if FixDateTime(ProdOrderLine."Ending Date", ProdOrderLine."Ending Time", ProdOrderLine."Ending Date-Time") then
                    Changed := true;
                if Changed then
                    ProdOrderLine.Modify(false);
            until ProdOrderLine.Next() = 0;

        RoutingLine.SetRange(Status, ProductionOrder.Status);
        RoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if RoutingLine.FindSet(true) then
            repeat
                Changed := FixDateTime(RoutingLine."Starting Date", RoutingLine."Starting Time", RoutingLine."Starting Date-Time");
                if FixDateTime(RoutingLine."Ending Date", RoutingLine."Ending Time", RoutingLine."Ending Date-Time") then
                    Changed := true;
                if Changed then
                    RoutingLine.Modify(false);
            until RoutingLine.Next() = 0;

        Component.SetRange(Status, ProductionOrder.Status);
        Component.SetRange("Prod. Order No.", ProductionOrder."No.");
        if Component.FindSet(true) then
            repeat
                if FixDateTime(Component."Due Date", Component."Due Time", Component."Due Date-Time") then
                    Component.Modify(false);
            until Component.Next() = 0;

        CapacityNeed.SetRange(Status, ProductionOrder.Status);
        CapacityNeed.SetRange("Prod. Order No.", ProductionOrder."No.");
        if CapacityNeed.FindSet(true) then
            repeat
                Changed := FixDateTime(CapacityNeed.Date, CapacityNeed."Starting Time", CapacityNeed."Starting Date-Time");
                if FixDateTime(CapacityNeed.Date, CapacityNeed."Ending Time", CapacityNeed."Ending Date-Time") then
                    Changed := true;
                if Changed then
                    CapacityNeed.Modify(false);
            until CapacityNeed.Next() = 0;
    end;

    local procedure FixDateTime(LocalDate: Date; LocalTime: Time; var Value: DateTime): Boolean
    var
        Corrected: DateTime;
    begin
        if (LocalDate = 0D) or (LocalTime = 0T) or (Value = 0DT) then
            exit(false);
        // Only values derived in this session's time zone.
        if Value <> CreateDateTime(LocalDate, LocalTime) then
            exit(false);
        Corrected := LocalToUtc(LocalDate, LocalTime);
        if Corrected = Value then
            exit(false);
        Value := Corrected;
        exit(true);
    end;

    local procedure UtcToLocal(UtcValue: DateTime; var LocalDate: Date; var LocalTime: Time)
    var
        TimeZone: Codeunit "Time Zone";
        Iso: Text;
    begin
        // Format 9 renders the shifted value as UTC, i.e. as local wall-clock time.
        Iso := Format(UtcValue + TimeZone.GetTimezoneOffset(UtcValue, PlanningTimeZoneTok), 0, 9);
        Evaluate(LocalDate, CopyStr(Iso, 1, 10), 9);
        Evaluate(LocalTime, CopyStr(Iso, 12, 8), 9);
    end;

    local procedure LocalToUtc(LocalDate: Date; LocalTime: Time): DateTime
    var
        TimeZone: Codeunit "Time Zone";
        WallAsUtc: DateTime;
        Offset: Duration;
    begin
        Evaluate(WallAsUtc, StrSubstNo('%1T%2Z', Format(LocalDate, 0, 9), Format(LocalTime, 0, 9)), 9);
        Offset := TimeZone.GetTimezoneOffset(WallAsUtc, PlanningTimeZoneTok);
        // Re-evaluate at the resulting instant to handle DST changes correctly.
        Offset := TimeZone.GetTimezoneOffset(WallAsUtc - Offset, PlanningTimeZoneTok);
        exit(WallAsUtc - Offset);
    end;
}
