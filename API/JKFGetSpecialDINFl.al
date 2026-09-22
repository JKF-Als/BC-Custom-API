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
        dataitem(Item; Item)
        {
            column(itemNo; "No.") { }
            column(description; Description) { }
            // Add other item fields you need
            column(description2; "Description 2") { }

            dataitem(Extended_Text_Line; "Extended Text Line")
            {
                // 1. Link the tables together using only field names
                DataItemLink = "No." = Item."No.";

                // 2. Apply the constant filter for the table name
                DataItemTableFilter = "Table Name" = const(Item);

                SqlJoinType = InnerJoin;

                column(languageCode; "Language Code") { }
                column(textLine; Text) { }
            }
        }
    }
}