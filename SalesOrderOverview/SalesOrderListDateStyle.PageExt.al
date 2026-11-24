pageextension 50390 "JKF Sales Order Date Style" extends "Sales Order List"
{
    layout
    {
        modify("Planned Shipment Date_EVAS")
        {
            Style = Unfavorable;
            StyleExpr = PlannedShipmentDateIsTooEarly;
        }
    }

    trigger OnAfterGetRecord()
    begin
        // Calculate the FlowField before using it in the comparison.
        Rec.CalcFields("Earliest Shipment Date_EVM");

        // Assign for every row so the style is reset for valid or empty dates.
        PlannedShipmentDateIsTooEarly :=
            (Rec."Planned Shipment Date_EVAS" <> 0D) and
            (Rec."Earliest Shipment Date_EVM" <> 0D) and
            (Rec."Planned Shipment Date_EVAS" < Rec."Earliest Shipment Date_EVM");
    end;

    var
        PlannedShipmentDateIsTooEarly: Boolean;
}

