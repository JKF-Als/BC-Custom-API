namespace JKF.OrderAgent;
using Microsoft.Foundation.ExtendedText;
page 50309 "JKF Agent Text Headers"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'extendedTextHeader';
    EntitySetName = 'extendedTextHeaders';
    SourceTable = "Extended Text Header";
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
                field(allLanguages; Rec."All Language Codes") { }
                field(textNumber; Rec."Text No.") { }
                field(startingDate; Rec."Starting Date") { }
                field(endingDate; Rec."Ending Date") { }
                field(salesQuote; Rec."Sales Quote") { }
                field(salesOrder; Rec."Sales Order") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('extendedTextHeader');
    end;
    
}