page 50200 "JKF Customer EVMP API"
{
    PageType = API;
    Caption = 'JKF Customer EVMP API';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'JKFCustomDebitorCreation';
    EntitySetName = 'JKFCustomDebitorCreations';

    SourceTable = Customer;
    DelayedInsert = true;

    ODataKeyFields = "No.";

    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }

                field(eMailShipmentEVMP; Rec."E-Mail (Shipment)_EVMP")
                {
                    Caption = 'E-Mail Shipment EVMP';
                }

                field(eMailInvoicingEVMP; Rec."E-Mail (Invoicing)_EVMP")
                {
                    Caption = 'E-Mail Invoicing EVMP';
                }

                field(eMailFinancialEVMP; Rec."E-Mail (Financial)_EVMP")
                {
                    Caption = 'E-Mail Financial EVMP';
                }

                field(bankAccountNoPrintEVAS; Rec."Bank Account No. (print)_EVAS")
                {
                    Caption = 'Bank Account No. (print) EVAS';
                }
                // Subpage for Customer Charges :: See JKFCustomerChargeSubPage.al
                part(customerCharges; "JKF Customer Charge API")
                {
                    Caption = 'Customer Charges';
                    EntityName = 'customerCharge';
                    EntitySetName = 'customerCharges';
                    SubPageLink = "Customer No." = field("No.");
                }
            }
        }
    }
    trigger OnModifyRecord(): Boolean
    begin
        CreateDefaultInvoiceDiscounts(Rec."No.", Rec."Currency Code");
        exit(true);
    end;

    local procedure CreateDefaultInvoiceDiscounts(CustomerNo: Code[20]; CurrencyCode: Code[10])
    var
        TargetCurrency: Code[10];
        Tier1MinAmount: Decimal;
        Tier1ServiceCharge: Decimal;
        Tier2MinAmount: Decimal;
        Tier2ServiceCharge: Decimal;
    begin
        if CustomerNo = '' then
            exit;

        // Map currency and thresholds
        case CurrencyCode of
            'EUR':
                begin
                    TargetCurrency := 'EUR';
                    Tier1MinAmount := 0;
                    Tier1ServiceCharge := 30.0;
                    Tier2MinAmount := 200.0;
                    Tier2ServiceCharge := 0;
                end;
            '', 'DKK': // Blank or DKK uses LCY table standard (blank Currency Code)
                begin
                    TargetCurrency := '';
                    Tier1MinAmount := 0;
                    Tier1ServiceCharge := 225.0;
                    Tier2MinAmount := 1500.0;
                    Tier2ServiceCharge := 0;
                end;
            else
                // Fallback default for any other currency (e.g., SEK, USD, etc.)
                begin
                TargetCurrency := CurrencyCode;
                Tier1MinAmount := 0;
                Tier1ServiceCharge := 0;
                Tier2MinAmount := 0;
                Tier2ServiceCharge := 0;
            end;
        end;

        // Line 1: Tier 1
        UpsertInvoiceDiscountLine(CustomerNo, TargetCurrency, Tier1MinAmount, Tier1ServiceCharge);

        // Line 2: Tier 2
        if Tier2MinAmount > 0 then
            UpsertInvoiceDiscountLine(CustomerNo, TargetCurrency, Tier2MinAmount, Tier2ServiceCharge);
    end;

    local procedure UpsertInvoiceDiscountLine(CustomerNo: Code[20]; CurrencyCode: Code[10]; MinAmount: Decimal; ServiceCharge: Decimal)
    var
        CustInvoiceDisc: Record "Cust. Invoice Disc.";
    begin
        // Primary Key: (Code, Currency Code, Minimum Amount)
        if not CustInvoiceDisc.Get(CustomerNo, CurrencyCode, MinAmount) then begin
            CustInvoiceDisc.Init();
            CustInvoiceDisc.Validate(Code, CustomerNo);
            CustInvoiceDisc.Validate("Currency Code", CurrencyCode);
            CustInvoiceDisc.Validate("Minimum Amount", MinAmount);
            CustInvoiceDisc.Validate("Service Charge", ServiceCharge);
            CustInvoiceDisc.Insert(true);
        end else begin
            CustInvoiceDisc.Validate("Service Charge", ServiceCharge);
            CustInvoiceDisc.Modify(true);
        end;
    end;
}