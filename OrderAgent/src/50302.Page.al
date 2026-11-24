namespace JKF.OrderAgent;
using Microsoft.CRM.BusinessRelation;
page 50302 "JKF Agent Contact Relations"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'contactRelation';
    EntitySetName = 'contactRelations';
    SourceTable = "Contact Business Relation";
    
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
                field(contactNumber; Rec."Contact No.") { }
                field(linkToTable; Rec."Link to Table") { }
                field(relatedNumber; Rec."No.") { }
                field(businessRelationCode; Rec."Business Relation Code") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('contactRelation');
    end;
    
}