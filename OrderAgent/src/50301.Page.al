namespace JKF.OrderAgent;
using Microsoft.CRM.Contact;
page 50301 "JKF Agent Contacts"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'contact';
    EntitySetName = 'contacts';
    SourceTable = "Contact";
    
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
                field(lastModifiedAt; Rec.SystemModifiedAt) { }
                field(number; Rec."No.") { }
                field(name; Rec."Name") { }
                field(email; Rec."E-Mail") { }
                field(phoneNumber; Rec."Phone No.") { }
                field(companyNumber; Rec."Company No.") { }
                field(type; Rec."Type") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('contact');
    end;
    
}