namespace JKF.OrderAgent;
using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Contact;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Pricing.PriceList;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.Environment;
using Microsoft.Inventory.Ledger;
permissionset 50390 "JKF AGENT READ"
{
    Assignable = true;
    Caption = 'JKF agent phase 1 read';
    Permissions =
        codeunit "JKF Agent Guard" = X,
        tabledata "Item Ledger Entry" = R,
        page "JKF Agent Customers" = X,
        page "JKF Agent Contacts" = X,
        page "JKF Agent Contact Relations" = X,
        page "JKF Agent Items" = X,
        page "JKF Agent Item Units" = X,
        page "JKF Agent Attributes" = X,
        page "JKF Agent Attribute Values" = X,
        page "JKF Agent Attribute Mapping" = X,
        page "JKF Agent Item References" = X,
        page "JKF Agent Text Headers" = X,
        page "JKF Agent Text Lines" = X,
        page "JKF Agent Price Lines" = X,
        page "JKF Agent Sales Headers" = X,
        page "JKF Agent Sales Lines" = X,
        page "JKF Agent Archive Headers" = X,
        page "JKF Agent Archive Lines" = X,
        page "JKF Agent Shipment Headers" = X,
        page "JKF Agent Shipment Lines" = X,
        page "JKF Agent Invoice Headers" = X,
        page "JKF Agent Invoice Lines" = X,
        tabledata "Contact" = R,
        tabledata "Contact Business Relation" = R,
        tabledata "Customer" = R,
        tabledata "Extended Text Header" = R,
        tabledata "Extended Text Line" = R,
        tabledata "Item" = R,
        tabledata "Item Attribute" = R,
        tabledata "Item Attribute Value" = R,
        tabledata "Item Attribute Value Mapping" = R,
        tabledata "Item Reference" = R,
        tabledata "Item Unit of Measure" = R,
        tabledata "Price List Line" = R,
        tabledata "Sales Header" = R,
        tabledata "Sales Header Archive" = R,
        tabledata "Sales Invoice Header" = R,
        tabledata "Sales Invoice Line" = R,
        tabledata "Sales Line" = R,
        tabledata "Sales Line Archive" = R,
        tabledata "Sales Shipment Header" = R,
        tabledata "Sales Shipment Line" = R;
}
