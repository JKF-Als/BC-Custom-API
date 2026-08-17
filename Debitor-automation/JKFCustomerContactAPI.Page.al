page 50221 "JKF Customer Contact API"
{
    PageType = API;
    Caption = 'Customer Contact API';

    APIPublisher = 'jkf';
    APIGroup = 'debitor';
    APIVersion = 'v1.0';

    EntityName = 'customerContact';
    EntitySetName = 'customerContacts';

    SourceTable = "JKF Customer Contact Buffer";

    DelayedInsert = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
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

                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }

                field(email; Rec.Email)
                {
                    Caption = 'Email';
                }

                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                }

                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                }

                field(number; Rec."Contact No.")
                {
                    Caption = 'Contact No.';
                    Editable = false;
                }

                field(companyNo; Rec."Company Contact No.")
                {
                    Caption = 'Company Contact No.';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        CompanyContact: Record Contact;
        PersonContact: Record Contact;
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if Rec."Customer No." = '' then
            Error('Customer No. must be specified.');

        if Rec.Name = '' then
            Error('Name must be specified.');

        if Rec."Salesperson Code" = '' then
            Error('Salesperson Code must be specified.');

        if not Customer.Get(Rec."Customer No.") then
            Error(
                'Customer %1 does not exist.',
                Rec."Customer No."
            );

        if not Salesperson.Get(Rec."Salesperson Code") then
            Error(
                'Salesperson %1 does not exist.',
                Rec."Salesperson Code"
            );

        ContactBusinessRelation.Reset();

        ContactBusinessRelation.SetRange(
            "Link to Table",
            ContactBusinessRelation."Link to Table"::Customer
        );

        ContactBusinessRelation.SetRange(
            "No.",
            Rec."Customer No."
        );

        if not ContactBusinessRelation.FindFirst() then
            Error(
                'Customer %1 does not have a related company contact.',
                Rec."Customer No."
            );

        if not CompanyContact.Get(
            ContactBusinessRelation."Contact No."
        ) then
            Error(
                'Company contact %1 could not be found.',
                ContactBusinessRelation."Contact No."
            );

        if CompanyContact.Type <> CompanyContact.Type::Company then
            Error(
                'Contact %1 related to customer %2 is not a company contact.',
                CompanyContact."No.",
                Rec."Customer No."
            );

        PersonContact.Init();

        PersonContact.Type :=
            PersonContact.Type::Person;

        PersonContact.Name :=
            Rec.Name;

        PersonContact."E-Mail" :=
            Rec.Email;

        PersonContact."Phone No." :=
            Rec."Phone No.";

        PersonContact."Company No." :=
            CompanyContact."No.";

        PersonContact."Company Name" :=
            CompanyContact.Name;

        PersonContact.Validate(
            "Salesperson Code",
            Rec."Salesperson Code"
        );

        PersonContact.Insert(true);

        Rec."Contact No." :=
            PersonContact."No.";

        Rec."Company Contact No." :=
            CompanyContact."No.";

        exit(true);
    end;
}