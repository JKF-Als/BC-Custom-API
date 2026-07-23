page 50210 "JKF Requisition Lines API"
{
    PageType = API;
    Caption = 'JKF Requisition Lines API';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'requisitionLine';
    EntitySetName = 'requisitionLines';

    SourceTable = "Requisition Line";
    ODataKeyFields = SystemId;

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    Extensible = false;

    Permissions =
        tabledata "Requisition Line" = RD;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(worksheetTemplateName; Rec."Worksheet Template Name")
                {
                    Caption = 'Worksheet Template Name';
                    Editable = false;
                }

                field(journalBatchName; Rec."Journal Batch Name")
                {
                    Caption = 'Journal Batch Name';
                    Editable = false;
                }

                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                    Editable = false;
                }

                field(type; Rec.Type)
                {
                    Caption = 'Type';
                    Editable = false;
                }

                field(no; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }

                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                }

                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                    Editable = false;
                }

                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    Editable = false;
                }

                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                    Editable = false;
                }

                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                    Editable = false;
                }

                field(vendorNo; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.';
                    Editable = false;
                }

                field(actionMessage; Rec."Action Message")
                {
                    Caption = 'Action Message';
                    Editable = false;
                }

                field(orderDate; Rec."Order Date")
                {
                    Caption = 'Order Date';
                    Editable = false;
                }

                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'System Modified At';
                    Editable = false;
                }
            }
        }
    }

    [ServiceEnabled]
    procedure DeleteRobotAPlanningLines(
        confirmation: Text;
        var ActionContext: WebServiceActionContext)
    var
        ReqWkshTemplate: Record "Req. Wksh. Template";
        RequisitionLine: Record "Requisition Line";
        DeletedCount: Integer;
        MaxLinesToDelete: Integer;
    begin
        if confirmation <> 'DELETE_ROBOT_A' then
            Error(
                'Sletningen blev ikke udført. Confirmation skal være DELETE_ROBOT_A.');

        MaxLinesToDelete := 7000;
        DeletedCount := 0;

        ReqWkshTemplate.Reset();
        ReqWkshTemplate.SetRange(
            Type,
            ReqWkshTemplate.Type::Planning);

        if ReqWkshTemplate.FindSet() then
            repeat
                RequisitionLine.Reset();
                RequisitionLine.SetRange(
                    "Worksheet Template Name",
                    ReqWkshTemplate.Name);
                RequisitionLine.SetRange(
                    "Journal Batch Name",
                    'ROBOT_A');

                while
                    (DeletedCount < MaxLinesToDelete) and
                    RequisitionLine.FindFirst()
                do begin
                    RequisitionLine.Delete(true);
                    DeletedCount += 1;
                end;

            until
                (ReqWkshTemplate.Next() = 0) or
                (DeletedCount >= MaxLinesToDelete);

        ActionContext.SetResultCode(
            WebServiceActionResultCode::Deleted);
    end;
}