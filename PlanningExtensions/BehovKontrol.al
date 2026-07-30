page 50251 "Behov Kontrol"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = Item;
    SourceTableTemporary = true;
    Caption = 'Behov kontrol';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Filtrering';
                field(SelectedLevel; SelectedLevel)
                {
                    ApplicationArea = All;
                    Caption = 'Vælg Niveau (0-7)';

                    trigger OnValidate()
                    begin
                        BuildVirtualList();
                    end;
                }
            }

            repeater(Items)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Low-Level Code"; Rec."Low-Level Code") { ApplicationArea = All; Caption = 'Niveau'; }

                field("Reordering Policy"; Rec."Reordering Policy")
                {
                    ApplicationArea = All;
                    Caption = 'Genbestillingsmetode';
                }

                // NEW FIELD: Shows whether it's Prod. Order, Purchase, etc.
                field("Replenishment System"; Rec."Replenishment System")
                {
                    ApplicationArea = All;
                    Caption = 'Genbestillingssystem';
                }

                field(PlannerStatus; PlannerStatus) { ApplicationArea = All; Caption = 'Status'; Style = Attention; }
                field("Reorder Point"; Rec."Reorder Point") { ApplicationArea = All; Caption = 'GBP / SL'; }
                field("Maximum Order Quantity"; Rec."Maximum Order Quantity") { ApplicationArea = All; Caption = 'Maks OQ'; }
                field(CurrentSupply; CurrentSupply) { ApplicationArea = All; Caption = 'Aktuelt Behov'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenItemCard)
            {
                ApplicationArea = All;
                Caption = 'Åbn Varekort';
                Image = Item;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Page.Run(Page::"Item Card", Rec);
                end;
            }
        }
    }

    var
        SelectedLevel: Integer;
        PlannerStatus: Text[10];
        CurrentSupply: Decimal;

    trigger OnOpenPage()
    begin
        SelectedLevel := -1;

        // Dummy row to force the Web Client to render the grid view
        Rec.Init();
        Rec."No." := 'KLAR';
        Rec.Description := 'Vælg et niveau ovenfor for at starte...';
        Rec.Insert();
    end;

    local procedure BuildVirtualList()
    var
        ItemDB: Record Item;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ItemDB.SetRange("Low-Level Code", SelectedLevel);

        // STRICT FILTER: Only consider items where Replenishment System is Prod. Order
        ItemDB.SetRange("Replenishment System", ItemDB."Replenishment System"::"Prod. Order");

        ItemDB.SetAutoCalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Prod. Order", "Trans. Ord. Receipt (Qty.)");

        if ItemDB.FindSet() then begin
            repeat
                CalculateStatus(ItemDB);

                // UPDATED RULE: Include both OVER and UNDER items
                if (PlannerStatus = 'OVER') or (PlannerStatus = 'UNDER') then begin
                    Rec := ItemDB;
                    Rec.Insert();
                end;
            until ItemDB.Next() = 0;
        end;

        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    trigger OnAfterGetRecord()
    var
        ItemLive: Record Item;
    begin
        if ItemLive.Get(Rec."No.") then begin
            ItemLive.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Prod. Order", "Trans. Ord. Receipt (Qty.)");
            CalculateStatus(ItemLive);
        end;
    end;

    local procedure CalculateStatus(ItemRecord: Record Item)
    var
        ReorderPoint: Decimal;
        MaxOrderQty: Decimal;
        AdjustedSupply: Decimal;
    begin
        ReorderPoint := ItemRecord."Reorder Point";
        MaxOrderQty := ItemRecord."Maximum Order Quantity";
        CurrentSupply := ItemRecord.Inventory + ItemRecord."Qty. on Purch. Order" + ItemRecord."Qty. on Prod. Order" + ItemRecord."Trans. Ord. Receipt (Qty.)";

        case ItemRecord."Reordering Policy" of
            ItemRecord."Reordering Policy"::Order:
                begin
                    if CurrentSupply > 0 then
                        PlannerStatus := 'OVER'
                    else if CurrentSupply < 0 then
                        PlannerStatus := 'UNDER'
                    else
                        PlannerStatus := 'OK';
                end;

            ItemRecord."Reordering Policy"::"Lot-for-Lot":
                begin
                    AdjustedSupply := CurrentSupply - 1;
                    if AdjustedSupply > (ReorderPoint + MaxOrderQty) then
                        PlannerStatus := 'OVER'
                    else if AdjustedSupply < (ReorderPoint + MaxOrderQty) then
                        PlannerStatus := 'UNDER'
                    else
                        PlannerStatus := 'OK';
                end;

            ItemRecord."Reordering Policy"::"Fixed Reorder Qty.":
                begin
                    if MaxOrderQty > 1 then begin
                        if ReorderPoint = 0 then begin
                            AdjustedSupply := CurrentSupply + 1;
                            if AdjustedSupply > (ReorderPoint + MaxOrderQty) then
                                PlannerStatus := 'OVER'
                            else if AdjustedSupply < (ReorderPoint + MaxOrderQty) then
                                PlannerStatus := 'UNDER'
                            else
                                PlannerStatus := 'OK';
                        end else begin
                            if CurrentSupply > (ReorderPoint + MaxOrderQty) then
                                PlannerStatus := 'OVER'
                            else if CurrentSupply < (ReorderPoint + MaxOrderQty) then
                                PlannerStatus := 'UNDER'
                            else
                                PlannerStatus := 'OK';
                        end;
                    end else begin
                        if CurrentSupply > ReorderPoint then
                            PlannerStatus := 'OVER'
                        else if CurrentSupply < ReorderPoint then
                            PlannerStatus := 'UNDER'
                        else
                            PlannerStatus := 'OK';
                    end;
                end;

            else
                PlannerStatus := 'OK';
        end;
    end;
}