page 50275 "JKF Prod Schedule API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'productionOrderSchedule';
    EntitySetName = 'productionOrderSchedules';
    SourceTable = "JKF Prod Schedule Buffer";
    SourceTableTemporary = true;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { Editable = false; }
                field(number; Rec."Order No.") { }
                field(operationNo; Rec."Operation No.") { }
                field(startingDateTime; Rec."Starting Date-Time") { }
                // Calculated by BC from setup/run time and calendar; any input value is ignored.
                field(endingDateTime; Rec."Ending Date-Time") { }
                field(productionOrderId; Rec."Production Order Id") { Editable = false; }
                field(routingLineId; Rec."Routing Line Id") { Editable = false; }
                field(status; Rec.Status) { Editable = false; }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Scheduling: Codeunit "JKF Release And Schedule";
        RoutingLine: Record "Prod. Order Routing Line";
        ReleasedOrder: Record "Production Order";
    begin
        Rec."Routing Line Id" := Scheduling.ReleaseAndSchedule(
            Rec."Order No.", Rec."Operation No.",
            Rec."Starting Date-Time");
        RoutingLine.GetBySystemId(Rec."Routing Line Id");
        ReleasedOrder.Get(ReleasedOrder.Status::Released, RoutingLine."Prod. Order No.");
        Rec."Order No." := ReleasedOrder."No.";
        Rec."Production Order Id" := ReleasedOrder.SystemId;
        Rec.Status := 'Released';
        Rec."Starting Date-Time" := RoutingLine."Starting Date-Time";
        Rec."Ending Date-Time" := RoutingLine."Ending Date-Time";
        Rec."Entry No." := 1;
        exit(true);
    end;
}
