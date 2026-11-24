page 50273 "JKF Production Orders API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'productionOrder';
    EntitySetName = 'productionOrders';
    SourceTable = "Production Order";
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId) { }
                field(number; Rec."No.") { }
                field(status; Rec.Status) { }
                field(description; Rec.Description) { }
            }
        }
    }

    [ServiceEnabled]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure Release(var ActionContext: WebServiceActionContext)
    var
        ProductionOrder: Record "Production Order";
        ReleasedOrder: Record "Production Order";
        StatusManagement: Codeunit "Prod. Order Status Management";
    begin
        ProductionOrder.LockTable();
        ProductionOrder.GetBySystemId(Rec.SystemId);
        case ProductionOrder.Status of
            ProductionOrder.Status::Released:
                ReleasedOrder := ProductionOrder;
            ProductionOrder.Status::Planned,
            ProductionOrder.Status::"Firm Planned":
                begin
                    // Transfer the header and related records using standard BC logic.
                    // The released order can receive a different number and SystemId.
                    StatusManagement.ChangeProdOrderStatus(
                        ProductionOrder, ReleasedOrder,
                        ProductionOrder.Status::Released, WorkDate(), false);
                    ReleasedOrder.TestField(Status, ReleasedOrder.Status::Released);
                end;
            else
                Error('Only Planned or Firm Planned production orders can be released through this API.');
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"JKF Production Orders API");
        ActionContext.AddEntityKey(ReleasedOrder.FieldNo(SystemId), ReleasedOrder.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
