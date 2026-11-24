namespace JKF.OrderAgent;
using Microsoft.Pricing.PriceList;
page 50311 "JKF Agent Price Lines"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'orderAgent';
    APIVersion = 'v1.0';
    EntityName = 'salesPriceLine';
    EntitySetName = 'salesPriceLines';
    SourceTable = "Price List Line";
    SourceTableView = where("Price Type" = const(Sale));
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
                field(priceListCode; Rec."Price List Code") { }
                field(lineNumber; Rec."Line No.") { }
                field(sourceType; Rec."Source Type") { }
                field(sourceNumber; Rec."Source No.") { }
                field(assetType; Rec."Asset Type") { }
                field(assetNumber; Rec."Asset No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { }
                field(unitPrice; Rec."Unit Price") { }
                field(lineDiscountPercent; Rec."Line Discount %") { }
                field(minimumQuantity; Rec."Minimum Quantity") { }
                field(currencyCode; Rec."Currency Code") { }
                field(startingDate; Rec."Starting Date") { }
                field(endingDate; Rec."Ending Date") { }
                field(status; Rec."Status") { }
                field(amountType; Rec."Amount Type") { }
                field(priceIncludesVAT; Rec."Price Includes VAT") { }

            }
        }
    }
    trigger OnOpenPage()
    var
        Guard: Codeunit "JKF Agent Guard";
    begin
        Guard.CheckEnvironment();
        Guard.LogRead('salesPriceLine');
    end;
    
}