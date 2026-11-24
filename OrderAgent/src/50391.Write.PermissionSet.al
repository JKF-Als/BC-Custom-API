namespace JKF.OrderAgent;
using Microsoft.Sales.Document;
using Microsoft.Foundation.Attachment;
permissionset 50391 "JKF AGENT WRITE"
{
    Assignable = true;
    Caption = 'JKF agent phase 2 drafts';
    IncludedPermissionSets = "JKF AGENT READ";
    Permissions =
        page "JKF Agent Requests" = X,
        codeunit "JKF Agent Writer" = X,
        tabledata "JKF Agent Request" = RIM,
        table "JKF Agent Request" = X,
        tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rim,
        tabledata "Document Attachment" = ri;
}
