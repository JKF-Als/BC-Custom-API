namespace JKF.OrderAgent;
using System.Environment;
codeunit 50380 "JKF Agent Guard"
{
    procedure CheckEnvironment()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSandbox() then
            Error('Agent API is allowed only in a sandbox.');
        if EnvironmentInformation.GetEnvironmentName() <> 'DK_Test' then
            Error('Agent API is allowed only in DK_Test.');
    end;

    procedure LogRead(Entity: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('entity', Entity);
        Session.LogMessage('JKFAG001', 'Order agent API opened.', Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
    end;
}