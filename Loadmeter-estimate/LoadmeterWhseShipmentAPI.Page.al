// Åbne lagerstedsforsendelser: Claude læser linjerne og skriver estimatet tilbage.
// Kun de fire estimat-felter kan redigeres. Alt andet er skrivebeskyttet.
//
// GET   .../api/jkf/integration/v1.0/companies({id})/loadmeterWarehouseShipments?$expand=loadmeterWarehouseShipmentLines
// PATCH .../loadmeterWarehouseShipments({id})  { "estimatedLoadMeter": 1.2, "estimatedNumberOfPackages": 2, "estimateNote": "..." }
page 50234 "JKF Loadmeter Whse. Shpt. API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'loadmeterWarehouseShipment';
    EntitySetName = 'loadmeterWarehouseShipments';
    Caption = 'Ladmeter lagerstedsforsendelse';
    SourceTable = "Warehouse Shipment Header";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; Editable = false; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; Editable = false; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
                field(documentStatus; Rec."Document Status") { Caption = 'Document Status'; Editable = false; }
                field(shipmentDate; Rec."Shipment Date") { Caption = 'Shipment Date'; Editable = false; }
                field(shipmentMethodCode; Rec."Shipment Method Code") { Caption = 'Shipment Method Code'; Editable = false; }
                field(shippingAgentCode; Rec."Shipping Agent Code") { Caption = 'Shipping Agent Code'; Editable = false; }
                field(actualWeight; Rec."Actual Weight_EVAS") { Caption = 'Actual Weight'; Editable = false; }
                field(actualLoadMeter; Rec."Actual Load Meter_EVAS") { Caption = 'Actual Load Meter'; Editable = false; }
                field(actualNumberOfPackages; Rec."Act. Number of Packag._EVAS") { Caption = 'Actual Number of Packages'; Editable = false; }
                field(estimatedLoadMeter; Rec."JKF Est. Load Meter") { Caption = 'Estimated Load Meter'; }
                field(estimatedNumberOfPackages; Rec."JKF Est. Number of Packages") { Caption = 'Estimated Number of Packages'; }
                field(estimateNote; Rec."JKF Estimate Note") { Caption = 'Estimate Note'; }
                field(estimatedAt; Rec."JKF Estimated At") { Caption = 'Estimated At'; Editable = false; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified'; Editable = false; }

                part(loadmeterWarehouseShipmentLines; "JKF Loadmeter Whse. Line API")
                {
                    Caption = 'Lines';
                    EntityName = 'loadmeterWarehouseShipmentLine';
                    EntitySetName = 'loadmeterWarehouseShipmentLines';
                    SubPageLink = "No." = field("No.");
                }
            }
        }
    }
}

page 50235 "JKF Loadmeter Whse. Line API"
{
    PageType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'loadmeterWarehouseShipmentLine';
    EntitySetName = 'loadmeterWarehouseShipmentLines';
    Caption = 'Ladmeter lagerstedsforsendelseslinje';
    SourceTable = "Warehouse Shipment Line";
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(documentNo; Rec."No.") { Caption = 'Document No.'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(sourceDocument; Rec."Source Document") { Caption = 'Source Document'; }
                field(sourceNo; Rec."Source No.") { Caption = 'Source No.'; }
                field(destinationType; Rec."Destination Type") { Caption = 'Destination Type'; }
                field(destinationNo; Rec."Destination No.") { Caption = 'Destination No.'; }
                field(itemNo; Rec."Item No.") { Caption = 'Item No.'; }
                field(variantCode; Rec."Variant Code") { Caption = 'Variant Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(description2; Rec."Description 2") { Caption = 'Description 2'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(qtyToShip; Rec."Qty. to Ship") { Caption = 'Qty. to Ship'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(itemGrossWeight; ItemGrossWeight) { Caption = 'Item Gross Weight'; }
                field(itemNetWeight; ItemNetWeight) { Caption = 'Item Net Weight'; }
                field(itemCategoryCode; ItemCategoryCode) { Caption = 'Item Category Code'; }
                field(shipToCountry; ShipToCountry) { Caption = 'Ship-to Country/Region Code'; }
                field(shipToPostCode; ShipToPostCode) { Caption = 'Ship-to Post Code'; }
            }
        }
    }

    var
        ItemGrossWeight: Decimal;
        ItemNetWeight: Decimal;
        ItemCategoryCode: Code[20];
        ShipToCountry: Code[10];
        ShipToPostCode: Code[20];

    trigger OnAfterGetRecord()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
    begin
        Clear(ItemGrossWeight);
        Clear(ItemNetWeight);
        Clear(ItemCategoryCode);
        Clear(ShipToCountry);
        Clear(ShipToPostCode);

        if Item.Get(Rec."Item No.") then begin
            ItemGrossWeight := Item."Gross Weight";
            ItemNetWeight := Item."Net Weight";
            ItemCategoryCode := Item."Item Category Code";
        end;

        if Rec."Source Document" = Rec."Source Document"::"Sales Order" then
            if SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Source No.") then begin
                ShipToCountry := SalesHeader."Ship-to Country/Region Code";
                ShipToPostCode := SalesHeader."Ship-to Post Code";
            end;
    end;
}
