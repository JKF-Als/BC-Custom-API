tableextension 50240 "Item Cleanup Checks" extends Item
{
    fields
    {
        field(50100; "Cleanup Has Item Ledger Entry"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Item Ledger Entry"
                where("Item No." = field("No.")));
        }
        field(50101; "Cleanup Has Sales Invoice Line"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Sales Invoice Line"
                where(Type = const(Item), "No." = field("No.")));
        }
        field(50102; "Cleanup Has Sales Line"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Sales Line"
                where(Type = const(Item), "No." = field("No.")));
        }
        field(50103; "Cleanup Has Purch Invoice Line"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Purch. Inv. Line"
                where(Type = const(Item), "No." = field("No.")));
        }
    }
}