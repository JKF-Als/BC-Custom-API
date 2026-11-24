/// <summary>
/// Planlægningskladdens linjer som API.
/// GET  .../api/jkf/purchasing/v1.0/companies({id})/planningLines?$filter=journalBatchName eq 'AI' and vendorNo eq '5707'
/// PATCH .../planningLines({systemId})  { "acceptActionMessage": true }
/// Kun feltet acceptActionMessage kan ændres, og kun på linjer i den tilladte kladde.
/// </summary>
page 50213 "JKF Planning Lines API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'purchasing';
    APIVersion = 'v1.0';
    EntityName = 'planningLine';
    EntitySetName = 'planningLines';
    EntityCaption = 'Planning Line';
    EntitySetCaption = 'Planning Lines';
    SourceTable = "Requisition Line";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(worksheetTemplateName; Rec."Worksheet Template Name") { Caption = 'Worksheet Template Name'; Editable = false; }
                field(journalBatchName; Rec."Journal Batch Name") { Caption = 'Journal Batch Name'; Editable = false; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; Editable = false; }
                field(type; Rec.Type) { Caption = 'Type'; Editable = false; }
                field(itemNo; Rec."No.") { Caption = 'No.'; Editable = false; }
                field(variantCode; Rec."Variant Code") { Caption = 'Variant Code'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; Editable = false; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; Editable = false; }
                field(vendorNo; Rec."Vendor No.") { Caption = 'Vendor No.'; Editable = false; }
                field(replenishmentSystem; Rec."Replenishment System") { Caption = 'Replenishment System'; Editable = false; }
                field(actionMessage; Rec."Action Message") { Caption = 'Action Message'; Editable = false; }
                field(acceptActionMessage; Rec."Accept Action Message") { Caption = 'Accept Action Message'; }
                field(originalQuantity; Rec."Original Quantity") { Caption = 'Original Quantity'; Editable = false; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; Editable = false; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; Editable = false; }
                field(directUnitCost; Rec."Direct Unit Cost") { Caption = 'Direct Unit Cost'; Editable = false; }
                field(orderDate; Rec."Order Date") { Caption = 'Order Date'; Editable = false; }
                field(dueDate; Rec."Due Date") { Caption = 'Due Date'; Editable = false; }
                field(originalDueDate; Rec."Original Due Date") { Caption = 'Original Due Date'; Editable = false; }
                field(refOrderType; Rec."Ref. Order Type") { Caption = 'Ref. Order Type'; Editable = false; }
                field(refOrderNo; Rec."Ref. Order No.") { Caption = 'Ref. Order No.'; Editable = false; }
                field(refLineNo; Rec."Ref. Line No.") { Caption = 'Ref. Line No.'; Editable = false; }
                field(planningLineOrigin; Rec."Planning Line Origin") { Caption = 'Planning Line Origin'; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date Time'; Editable = false; }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    var
        PlanningApiMgt: Codeunit "JKF Planning API Mgt.";
    begin
        PlanningApiMgt.CheckBatchAllowed(Rec."Worksheet Template Name", Rec."Journal Batch Name");
        exit(true);
    end;
}

/// <summary>
/// Planlægningskladdenavne som API med to bundne handlinger.
/// POST .../api/jkf/purchasing/v1.0/companies({id})/planningBatches({systemId})/Microsoft.NAV.calculatePlan
///      { "vendorFilter": "5707", "locationFilter": "JKF", "startDate": "2026-11-20", "endDate": "2026-12-04" }
/// POST .../planningBatches({systemId})/Microsoft.NAV.carryOutAcceptedPurchaseLines
/// </summary>
page 50214 "JKF Planning Batches API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'purchasing';
    APIVersion = 'v1.0';
    EntityName = 'planningBatch';
    EntitySetName = 'planningBatches';
    EntityCaption = 'Planning Batch';
    EntitySetCaption = 'Planning Batches';
    SourceTable = "Requisition Wksh. Name";
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Batches)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(worksheetTemplateName; Rec."Worksheet Template Name") { Caption = 'Worksheet Template Name'; }
                field(name; Rec.Name) { Caption = 'Name'; }
                field(description; Rec.Description) { Caption = 'Description'; }
            }
        }
    }

    /// <summary>Beregn totalplan (regenerativ) for varer hos de angivne kreditorer. Udfører IKKE aktionsmeddelelser.</summary>
    [ServiceEnabled]
    procedure calculatePlan(var ActionContext: WebServiceActionContext; vendorFilter: Text; locationFilter: Text; startDate: Date; endDate: Date)
    var
        PlanningApiMgt: Codeunit "JKF Planning API Mgt.";
    begin
        PlanningApiMgt.CalculatePlan(Rec, vendorFilter, locationFilter, startDate, endDate);
        SetActionResult(ActionContext);
    end;

    /// <summary>Udfør aktionsmeddelelser for linjer med acceptActionMessage = true. Laver kun købsordrer.</summary>
    [ServiceEnabled]
    procedure carryOutAcceptedPurchaseLines(var ActionContext: WebServiceActionContext)
    var
        PlanningApiMgt: Codeunit "JKF Planning API Mgt.";
    begin
        PlanningApiMgt.CarryOutAcceptedPurchaseLines(Rec);
        SetActionResult(ActionContext);
    end;

    local procedure SetActionResult(var ActionContext: WebServiceActionContext)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"JKF Planning Batches API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}

/// <summary>
/// Logik bag planlægnings-API'et. Sikkerhedsregler håndhæves her og ikke kun i assistentens prompt:
/// - kun kladden AllowedBatchName (AI)
/// - beregning kræver et kreditorfilter (aldrig alle varer)
/// - udførsel laver kun købsordrer og afviser, hvis accepterede linjer ikke er køb
/// </summary>
codeunit 50215 "JKF Planning API Mgt."
{
    var
        AllowedBatchName: Label 'AI', Locked = true;
        BatchNotAllowedErr: Label 'Kun planlægningskladden %1 må bruges via API. Fik %2.', Comment = '%1 = tilladt kladde, %2 = anvendt kladde';
        VendorFilterRequiredErr: Label 'Kreditorfilter skal udfyldes. Beregning for alle varer er ikke tilladt via API.';
        DatesInvalidErr: Label 'Startdato og slutdato skal udfyldes, og slutdato skal ligge efter startdato.';
        HorizonTooLongErr: Label 'Planlægningsperioden må højst være %1 dage.', Comment = '%1 = antal dage';
        NothingAcceptedErr: Label 'Der er ingen linjer med Accepter aktionsmeddelelse i kladden %1.', Comment = '%1 = kladde';
        NonPurchaseAcceptedErr: Label 'Der er accepterede linjer, som ikke er køb (fx produktion eller overførsel). Kun købslinjer må udføres via API.';
        MaxHorizonDays: Integer;

    procedure CheckBatchAllowed(TemplateName: Code[10]; BatchName: Code[10])
    begin
        if BatchName <> AllowedBatchName then
            Error(BatchNotAllowedErr, AllowedBatchName, BatchName);
    end;

    procedure CalculatePlan(ReqWkshName: Record "Requisition Wksh. Name"; VendorFilter: Text; LocationFilter: Text; StartDate: Date; EndDate: Date)
    var
        Item: Record Item;
        PlanningErrorLog: Record "Planning Error Log";
        CalculatePlanPlanWksh: Report "Calculate Plan - Plan. Wksh.";
    begin
        CheckBatchAllowed(ReqWkshName."Worksheet Template Name", ReqWkshName.Name);
        if DelChr(VendorFilter, '=', ' ') = '' then
            Error(VendorFilterRequiredErr);
        if (StartDate = 0D) or (EndDate = 0D) or (EndDate < StartDate) then
            Error(DatesInvalidErr);
        MaxHorizonDays := 62;
        if EndDate - StartDate > MaxHorizonDays then
            Error(HorizonTooLongErr, MaxHorizonDays);

        Item.SetFilter("Vendor No.", VendorFilter);
        if LocationFilter <> '' then
            Item.SetFilter("Location Filter", LocationFilter);

        // Rapporten spørger med Confirm, hvis der ligger en fejllog fra en tidligere kørsel.
        // Confirm fejler i API-kald, så loggen ryddes først (= svaret "Nej", start forfra).
        PlanningErrorLog.SetRange("Worksheet Template Name", ReqWkshName."Worksheet Template Name");
        PlanningErrorLog.SetRange("Journal Batch Name", ReqWkshName.Name);
        PlanningErrorLog.DeleteAll();

        CalculatePlanPlanWksh.SetTemplAndWorksheet(ReqWkshName."Worksheet Template Name", ReqWkshName.Name, true);
        CalculatePlanPlanWksh.InitializeRequest(StartDate, EndDate, false);
        CalculatePlanPlanWksh.SetTableView(Item);
        CalculatePlanPlanWksh.UseRequestPage(false);
        CalculatePlanPlanWksh.RunModal();
    end;

    procedure CarryOutAcceptedPurchaseLines(ReqWkshName: Record "Requisition Wksh. Name")
    var
        RequisitionLine: Record "Requisition Line";
        CarryOutActionMsgPlan: Report "Carry Out Action Msg. - Plan.";
    begin
        CheckBatchAllowed(ReqWkshName."Worksheet Template Name", ReqWkshName.Name);

        RequisitionLine.SetRange("Worksheet Template Name", ReqWkshName."Worksheet Template Name");
        RequisitionLine.SetRange("Journal Batch Name", ReqWkshName.Name);
        RequisitionLine.SetRange("Accept Action Message", true);
        if RequisitionLine.IsEmpty() then
            Error(NothingAcceptedErr, ReqWkshName.Name);

        RequisitionLine.SetFilter("Replenishment System", '<>%1', RequisitionLine."Replenishment System"::Purchase);
        if not RequisitionLine.IsEmpty() then
            Error(NonPurchaseAcceptedErr);
        RequisitionLine.SetRange("Replenishment System");

        RequisitionLine.FindFirst();
        CarryOutActionMsgPlan.SetReqWkshLine(RequisitionLine);
        // InitializeRequest2 tager Option-parametre (kontrolleret mod Base App 28.5), derfor AsInteger().
        CarryOutActionMsgPlan.InitializeRequest2(
            Enum::"Planning Create Prod. Order"::" ".AsInteger(),
            Enum::"Planning Create Purchase Order"::"Make Purch. Orders".AsInteger(),
            Enum::"Planning Create Transfer Order"::" ".AsInteger(),
            Enum::"Planning Create Assembly Order"::" ".AsInteger(),
            '', '', '', '');
        CarryOutActionMsgPlan.UseRequestPage(false);
        CarryOutActionMsgPlan.RunModal();
    end;
}

/// <summary>
/// Tildeles assistentens app-bruger sammen med jeres almindelige planlægnings-/indkøbsrettigheder
/// (beregning og udførsel rører mange standardtabeller, som ikke er med her).
/// </summary>
permissionset 50216 "JKF PLAN API"
{
    Assignable = true;
    Caption = 'JKF Planning Worksheet API';

    Permissions =
        tabledata "Requisition Line" = RIMD,
        tabledata "Requisition Wksh. Name" = R,
        tabledata "Planning Error Log" = RD,
        page "JKF Planning Lines API" = X,
        page "JKF Planning Batches API" = X,
        codeunit "JKF Planning API Mgt." = X;
}
