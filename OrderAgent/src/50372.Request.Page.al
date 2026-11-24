namespace JKF.OrderAgent;
page 50372 "JKF Agent Requests"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'request';
    EntitySetName = 'requests';
    SourceTable = "JKF Agent Request";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
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
                field(requestId; Rec."Request Id") { }
                field(completed; Rec.Completed) { Editable = false; }
                field(documentId; Rec."Document Id") { Editable = false; }
                field(documentNumber; Rec."Document No.") { Editable = false; }
            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        if IsNullGuid(Rec."Request Id") then
            Error('requestId must be a nonempty GUID.');
        exit(true);
    end;

    [ServiceEnabled]
    procedure Execute(payload: Text; var ActionContext: WebServiceActionContext)
    var
        Writer: Codeunit "JKF Agent Writer";
    begin
        Writer.Execute(Rec, payload);
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"JKF Agent Requests");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
