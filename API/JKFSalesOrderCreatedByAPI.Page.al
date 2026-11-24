page 50272 "JKF Sales Order Created By API"
{
    PageType = API;
    Caption = 'JKF Sales Order Created By';
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'salesOrderCreatedBy';
    EntitySetName = 'salesOrderCreatedByEntries';
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Order));
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
                field(createdByInitials; CreatedByInitials)
                {
                    Caption = 'Created By Initials';
                    ToolTip = 'Specifies the existing ITI IIC Created By value from Advanced Intercompany.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        SalesHeaderRef: RecordRef;
        CreatedByField: FieldRef;
    begin
        Clear(CreatedByInitials);
        SalesHeaderRef.GetTable(Rec);
        // Read the existing extension field without a compile-time dependency.
        if not SalesHeaderRef.FieldExist(20020770) then
            Error(MissingFieldErr);

        CreatedByField := SalesHeaderRef.Field(20020770);
        if (CreatedByField.Name <> 'ITI IIC Created By') or
           (CreatedByField.Type <> FieldType::Code) or
           (CreatedByField.Length <> MaxStrLen(CreatedByInitials))
        then
            Error(UnexpectedFieldErr);

        CreatedByInitials := Format(CreatedByField.Value);
    end;

    var
        CreatedByInitials: Code[50];
        MissingFieldErr: Label 'Sales Header field 20020770 (ITI IIC Created By) is missing. Install Advanced Intercompany before using this API.';
        UnexpectedFieldErr: Label 'Sales Header field 20020770 must be ITI IIC Created By with type Code[50].';
}
