// Kopierer ladmeter-estimatet til den bogførte lagerstedsforsendelse,
// så estimat og faktisk ladmeter kan sammenlignes bagefter.
codeunit 50231 "JKF Loadmeter Est. Transfer"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforePostedWhseShptHeaderInsert', '', false, false)]
    local procedure CopyEstimateToPostedHeader(var PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header"; WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        PostedWhseShipmentHeader."JKF Est. Load Meter" := WarehouseShipmentHeader."JKF Est. Load Meter";
        PostedWhseShipmentHeader."JKF Est. Number of Packages" := WarehouseShipmentHeader."JKF Est. Number of Packages";
        PostedWhseShipmentHeader."JKF Estimate Note" := WarehouseShipmentHeader."JKF Estimate Note";
        PostedWhseShipmentHeader."JKF Estimated At" := WarehouseShipmentHeader."JKF Estimated At";
    end;
}
