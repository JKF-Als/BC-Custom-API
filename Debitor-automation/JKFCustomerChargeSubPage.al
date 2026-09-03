page 50223 "JKF Customer Charge API"
{
    PageType = API;
    Caption = 'JKF Customer Charge API';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'customerCharge';
    EntitySetName = 'customerCharges';

    SourceTable = "Customer Charge_EVAS"; // Table 60010
    DelayedInsert = true;

    // Use SystemId or the composite PK
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(customerChargeType; Rec."Customer Charge Type")
                {
                    Caption = 'Customer Charge Type';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(itemChargeNo; Rec."Item Charge No.")
                {
                    Caption = 'Item Charge No.';
                }
                field(chargeSalesLineType; Rec."Charge Sales Line Type")
                {
                    Caption = 'Charge Sales Line Type';
                }
                field(glAccountNo; Rec."G/L Account No.")
                {
                    Caption = 'G/L Account No.';
                }
                field(itemChargeAmount; Rec."Item Charge %")
                {
                    Caption = 'Item Charge %';
                }
                field(InsertOnSalesQuote; Rec."Insert on Sales Quote")
                {
                    Caption = 'Insert on Sales Quote';
                }
                field(InsertOnSalesOrder; Rec."Insert on Sales Orders")
                {
                    Caption = 'Insert on Sales Order';
                }
                field(InsertOnSalesInvoice; Rec."Insert on Sales Invoices")
                {
                    Caption = 'Insert on Sales Invoice';
                }

            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        // Fallback default values if not explicitly provided in the payload
        if Rec."Customer Charge Type" = Rec."Customer Charge Type"::" " then
            Rec."Customer Charge Type" := Rec."Customer Charge Type"::"Environmental Fee";

        if Rec."Item Charge No." = '' then
            Rec."Item Charge No." := 'DA MILJØTILLÆG';

        Rec."Charge Sales Line Type" := Rec."Charge Sales Line Type"::"G/L Account";

        if Rec."G/L Account No." = '' then
            Rec."G/L Account No." := '100740';

        Rec."Item Charge %" := 2.46;

        Rec."Insert on Sales Quote" := true;
        Rec."Insert on Sales Orders" := true;
        Rec."Insert on Sales Invoices" := true;

        exit(true);
    end;
}