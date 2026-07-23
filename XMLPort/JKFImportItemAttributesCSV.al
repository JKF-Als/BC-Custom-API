xmlport 50290 "Import Item Attributes CSV"
{
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    FieldSeparator = ';';
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'Row';
                SourceTableView = sorting(Number) where(Number = const(1));

                textelement(CsvTableID) { }
                textelement(CsvItemNo) { }
                textelement(CsvAttributeID) { }
                textelement(CsvAttributeValueID) { }
                textelement(CsvPrimary) { }

                trigger OnBeforeInsertRecord()
                var
                    ItemAttrMapping: Record "Item Attribute Value Mapping";
                    TblID: Integer;
                    AttrID: Integer;
                    AttrValID: Integer;
                begin
                    // Skip the header row (assuming 'Tabel-id' is the header)
                    if CsvTableID = 'Tabel-id' then begin
                        currXMLport.Skip();
                    end;

                    // Evaluate the text values into Integers
                    Evaluate(TblID, CsvTableID);
                    Evaluate(AttrID, CsvAttributeID);
                    Evaluate(AttrValID, CsvAttributeValueID);

                    // Initialize and insert the mapping record
                    ItemAttrMapping.Init();
                    ItemAttrMapping."Table ID" := TblID;
                    ItemAttrMapping."No." := CsvItemNo;
                    ItemAttrMapping."Item Attribute ID" := AttrID;
                    ItemAttrMapping."Item Attribute Value ID" := AttrValID;

                    if ItemAttrMapping.Insert() then; // Silent insert to ignore duplicates if they exist 

                    // Skip the dummy Integer table insertion
                    currXMLport.Skip();
                end;
            }
        }
    }
}
