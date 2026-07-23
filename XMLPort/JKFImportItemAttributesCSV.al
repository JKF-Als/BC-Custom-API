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

                    //Check if mapping exists already.
                    if ItemAttrMapping.Get(TblID, CsvItemNo, AttrID) then begin

                        //If it exists, update it with the new Value ID from the CSV
                        ItemAttrMapping."Item Attribute Value ID" := AttrValID;
                        ItemAttrMapping.Modify();

                    end else begin

                        //If it does not exist, insert a brand new record
                        ItemAttrMapping.Init();
                        ItemAttrMapping."Table ID" := TblID;
                        ItemAttrMapping."No." := CsvItemNo;
                        ItemAttrMapping."Item Attribute ID" := AttrID;
                        ItemAttrMapping."Item Attribute Value ID" := AttrValID;
                        ItemAttrMapping.Insert();

                    end;

                    // Skip the dummy Integer table insertion
                    currXMLport.Skip();
                end;
            }
        }
    }
}
