namespace JKF.OrderAgent;
using Microsoft.Foundation.ExtendedText;
page 50310 "JKF Agent Text Lines"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'extendedTextLine';
    EntitySetName = 'extendedTextLines';
    SourceTable = "Extended Text Line";
    SourceTableView = where("Table Name" = const(Item));
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
                field(itemNumber; Rec."No.") { }
                field(languageCode; Rec."Language Code") { }
                field(textNumber; Rec."Text No.") { }
                field(lineNumber; Rec."Line No.") { }
                field(text; Rec."Text") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('extendedTextLine');
    end;
    
}