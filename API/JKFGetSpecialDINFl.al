query 50249 "Special Items Query API"
{
    QueryType = API;
    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'specialItem';
    EntitySetName = 'specialItems';

    elements
    {
        dataitem(Production_BOM_Header; "Production BOM Header")
        {
            column(bomNo; "No.") { }
            column(bomDescription; Description) { }
            column(description2; "Description 2") { }
            column(status; Status) { }

            dataitem(Production_BOM_Line; "Production BOM Line")
            {
                // Link the line to the header
                DataItemLink = "Production BOM No." = Production_BOM_Header."No.";

                // Only look at lines that are actual Items (not machine centers or sub-BOMs)
                DataItemTableFilter = Type = const(Item);
                SqlJoinType = InnerJoin;

                column(componentItemNo; "No.") { }
                column(quantityPer; "Quantity per") { }
            }
        }
    }
}