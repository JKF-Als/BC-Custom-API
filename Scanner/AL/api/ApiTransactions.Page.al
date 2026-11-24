/// <summary>
/// Skrive-API: appen POST'er hertil. Posten indsættes og behandles i samme kald.
///   UnplannedMove: itemNumber, locationCode, binCode, newLocationCode, newBinCode, quantity
///   PickLine:      activityNumber, activityLineNumber, quantity  (gemmes som "Afventer")
///   PickRegister:  activityNumber  (registrerer pluk med de afventende linjer)
/// </summary>
page 50347 "JKF API Transactions"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'scanner';
    APIVersion = 'v1.0';
    EntityName = 'transaction';
    EntitySetName = 'transactions';
    EntityCaption = 'Scanner-transaktion';
    EntitySetCaption = 'Scanner-transaktioner';
    SourceTable = "JKF Scanner Transaction";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { Editable = false; }
                field(entryNumber; Rec."Entry No.") { Editable = false; }
                field(type; Rec.Type) { }
                field(status; Rec.Status) { Editable = false; }
                field(itemNumber; Rec."Item No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { }
                field(quantity; Rec.Quantity) { }
                field(locationCode; Rec."Location Code") { }
                field(binCode; Rec."Bin Code") { }
                field(newLocationCode; Rec."New Location Code") { }
                field(newBinCode; Rec."New Bin Code") { }
                field(activityNumber; Rec."Activity No.") { }
                field(activityLineNumber; Rec."Activity Line No.") { }
                field(documentNumber; Rec."Document No.") { Editable = false; }
                field(userId; Rec."User ID") { Editable = false; }
                field(deviceId; Rec."Device Id") { }
                field(processedAt; Rec."Processed At") { Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ScannerMgt: Codeunit "JKF Scanner Mgt.";
    begin
        Rec.Insert(true);
        ScannerMgt.Process(Rec);
        exit(false);
    end;
}
