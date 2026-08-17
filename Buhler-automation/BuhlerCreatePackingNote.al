table 50219 "Buhler Create Packing Note Buf"
{
    Caption = 'Buhler Create Packing Note Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
        }

        field(3; "Packing Note No."; Code[20])
        {
            Caption = 'Packing Note No.';
        }

        field(4; Success; Boolean)
        {
            Caption = 'Success';
        }

        field(5; Message; Text[250])
        {
            Caption = 'Message';
        }

        field(6; "Created At"; DateTime)
        {
            Caption = 'Created At';
        }

        field(7; "Warehouse Shipment No."; Code[20])
        {
            Caption = 'Warehouse Shipment No.';
        }

        field(8; "Package Count"; Integer)
        {
            Caption = 'Package Count';
        }

        field(9; "Created Packing Notes"; Integer)
        {
            Caption = 'Created Packing Notes';
        }

        field(10; "Packages Json"; Text[2048])
        {
            Caption = 'Packages Json';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}


page 50209 "Buhler Create Packing Note"
{
    PageType = API;
    Caption = 'Buhler Create Packing Note';

    APIPublisher = 'jkf';
    APIGroup = 'integration';
    APIVersion = 'v1.0';

    EntityName = 'buhlerCreatePackingNote';
    EntitySetName = 'buhlerCreatePackingNotes';

    SourceTable = "Buhler Create Packing Note Buf";

    ODataKeyFields = SystemId;

    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;

    Permissions =
        tabledata "Packing Note Header_EVAS" = RIMD,
        tabledata "Packing Note Line_EVAS" = RIMD,
        tabledata "Sales Header" = R;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Editable = false;
                }

                field(salesOrderNo; Rec."Sales Order No.")
                {
                    Caption = 'Sales Order No.';
                }

                field(warehouseShipmentNo; Rec."Warehouse Shipment No.")
                {
                    Caption = 'Warehouse Shipment No.';
                }

                field(packagesJson; Rec."Packages Json")
                {
                    Caption = 'Packages Json';
                }

                field(packageCount; Rec."Package Count")
                {
                    Caption = 'Package Count';
                    Editable = false;
                }

                field(packingNoteNo; Rec."Packing Note No.")
                {
                    Caption = 'Packing Note No.';
                    Editable = false;
                }

                field(createdPackingNotes; Rec."Created Packing Notes")
                {
                    Caption = 'Created Packing Notes';
                    Editable = false;
                }

                field(success; Rec.Success)
                {
                    Caption = 'Success';
                    Editable = false;
                }

                field(message; Rec.Message)
                {
                    Caption = 'Message';
                    Editable = false;
                }

                field(createdAt; Rec."Created At")
                {
                    Caption = 'Created At';
                    Editable = false;
                }
            }
        }
    }


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Success := false;
        Rec.Message := '';
        Rec."Packing Note No." := '';
        Rec."Created Packing Notes" := 0;
        Rec."Package Count" := 0;
        Rec."Created At" := CurrentDateTime();

        CreatePackingNotes();

        exit(true);
    end;


    local procedure CreatePackingNotes()
    var
        SalesHeader: Record "Sales Header";

        Packages: JsonArray;
        PackageToken: JsonToken;
        PackageObject: JsonObject;

        PackageNo: Integer;
        PackageCount: Integer;

        NetWeight: Decimal;
        GrossWeight: Decimal;
        Volume: Decimal;

        Dimensions: Text;
        Packaging: Text;

        LengthValue: Text;
        WidthValue: Text;
        HeightValue: Text;

        HUType: Text[30];

        PackingNoteNo: Code[20];
    begin
        if Rec."Sales Order No." = '' then
            Error(
                'Sales Order No. must be specified.'
            );

        if Rec."Warehouse Shipment No." = '' then
            Error(
                'Warehouse Shipment No. must be specified.'
            );

        if Rec."Packages Json" = '' then
            Error(
                'Packages Json must be specified.'
            );


        SalesHeader.Reset();

        SalesHeader.SetRange(
            "Document Type",
            SalesHeader."Document Type"::Order
        );

        SalesHeader.SetRange(
            "No.",
            Rec."Sales Order No."
        );

        if not SalesHeader.FindFirst() then
            Error(
                'Sales Order %1 was not found.',
                Rec."Sales Order No."
            );


        if not Packages.ReadFrom(
            Rec."Packages Json"
        ) then
            Error(
                'Packages Json is not valid JSON.'
            );


        PackageCount := Packages.Count();

        if PackageCount = 0 then
            Error(
                'Packages Json contains no packages.'
            );


        Rec."Package Count" := PackageCount;


        // -----------------------------------------------------
        // Opret ét pakkebrev pr. frontend-linje.
        //
        // Hver frontend-linje svarer til ét kolli.
        //
        // Vægt, dimensioner og faktisk ladmeter
        // kommer derfor fra DET ENKELTE kolli.
        // -----------------------------------------------------

        PackageNo := 0;

        foreach PackageToken in Packages do begin
            PackageNo += 1;

            PackageObject :=
                PackageToken.AsObject();


            // -------------------------------------------------
            // Nettovægt for det aktuelle kolli.
            // -------------------------------------------------

            NetWeight :=
                GetDecimalValue(
                    PackageObject,
                    'netWeight'
                );


            // -------------------------------------------------
            // Bruttovægt for det aktuelle kolli.
            // -------------------------------------------------

            GrossWeight :=
                GetDecimalValue(
                    PackageObject,
                    'grossWeight'
                );


            // -------------------------------------------------
            // Faktisk ladmeter for det aktuelle kolli.
            //
            // Frontend sender værdien som "volume".
            //
            // Denne værdi må IKKE summeres med de øvrige kolli,
            // når den sættes på pakkebrevet.
            // -------------------------------------------------

            Volume :=
                GetDecimalValue(
                    PackageObject,
                    'volume'
                );


            // -------------------------------------------------
            // Dimensioner for det aktuelle kolli.
            // -------------------------------------------------

            Dimensions :=
                GetTextValue(
                    PackageObject,
                    'dimensions'
                );


            // -------------------------------------------------
            // Emballagetype for det aktuelle kolli.
            // -------------------------------------------------

            Packaging :=
                GetTextValue(
                    PackageObject,
                    'packaging'
                );


            ParseDimensions(
                Dimensions,
                LengthValue,
                WidthValue,
                HeightValue
            );


            HUType :=
                GetHUType(
                    Packaging
                );


            // -------------------------------------------------
            // Opret pakkebrev.
            //
            // Volume sendes direkte med som kolliets
            // faktiske ladmeter.
            // -------------------------------------------------

            PackingNoteNo :=
                CreatePackingNoteHeader(
                    SalesHeader,
                    Rec."Warehouse Shipment No.",
                    PackageNo,
                    NetWeight,
                    GrossWeight,
                    LengthValue,
                    WidthValue,
                    HeightValue,
                    PackageCount,
                    Volume,
                    HUType
                );


            RunGetLinesReport(
                PackingNoteNo,
                Rec."Warehouse Shipment No.",
                PackageNo
            );


            Rec."Packing Note No." :=
                PackingNoteNo;

            Rec."Created Packing Notes" +=
                1;
        end;


        Rec.Success := true;

        Rec.Message :=
            StrSubstNo(
                '%1 packing note(s) created.',
                Rec."Created Packing Notes"
            );

        Rec."Created At" :=
            CurrentDateTime();
    end;


    local procedure CreatePackingNoteHeader(
        SalesHeader: Record "Sales Header";
        WarehouseShipmentNo: Code[20];
        PackageNo: Integer;
        NetWeight: Decimal;
        GrossWeight: Decimal;
        LengthValue: Text;
        WidthValue: Text;
        HeightValue: Text;
        PackageCount: Integer;
        PackageLoadMeter: Decimal;
        HUType: Text[30]
    ): Code[20]
    var
        PackingNoteHeader:
            Record "Packing Note Header_EVAS";

        NoSeries:
            Codeunit "No. Series";

        PackingNoteNo:
            Code[20];

        HUIdentPrefix:
            Text[7];

        HUIdentNumber:
            Text[20];
    begin
        PackingNoteNo :=
            NoSeries.GetNextNo(
                'PACK'
            );


        PackingNoteHeader.Init();


        // -----------------------------------------------------
        // Nummer
        // -----------------------------------------------------

        PackingNoteHeader."No." :=
            PackingNoteNo;


        // -----------------------------------------------------
        // Kunde
        // -----------------------------------------------------

        PackingNoteHeader."Sell-to Customer No." :=
            SalesHeader."Sell-to Customer No.";

        PackingNoteHeader."Sell-to Customer Name" :=
            SalesHeader."Sell-to Customer Name";

        PackingNoteHeader."Sell-to Customer Name 2" :=
            SalesHeader."Sell-to Customer Name 2";

        PackingNoteHeader."Sell-to Address" :=
            SalesHeader."Sell-to Address";

        PackingNoteHeader."Sell-to Address 2" :=
            SalesHeader."Sell-to Address 2";

        PackingNoteHeader."Sell-to City" :=
            SalesHeader."Sell-to City";

        PackingNoteHeader."Sell-to Contact" :=
            SalesHeader."Sell-to Contact";

        PackingNoteHeader."Sell-to Post Code" :=
            SalesHeader."Sell-to Post Code";

        PackingNoteHeader."Sell-to County" :=
            SalesHeader."Sell-to County";

        PackingNoteHeader."Sell-to Country/Region Code" :=
            SalesHeader."Sell-to Country/Region Code";


        // -----------------------------------------------------
        // Referencefelter
        // -----------------------------------------------------

        PackingNoteHeader."Your Reference" :=
            SalesHeader."Your Reference";

        PackingNoteHeader."Salesperson Code" :=
            SalesHeader."Salesperson Code";

        PackingNoteHeader."External Document No." :=
            SalesHeader."External Document No.";


        // -----------------------------------------------------
        // Ship-to
        // -----------------------------------------------------

        PackingNoteHeader."Ship-to Code" :=
            SalesHeader."Ship-to Code";

        PackingNoteHeader."Ship-to Name" :=
            SalesHeader."Ship-to Name";

        PackingNoteHeader."Ship-to Name 2" :=
            SalesHeader."Ship-to Name 2";

        PackingNoteHeader."Ship-to Address" :=
            SalesHeader."Ship-to Address";

        PackingNoteHeader."Ship-to Address 2" :=
            SalesHeader."Ship-to Address 2";

        PackingNoteHeader."Ship-to City" :=
            SalesHeader."Ship-to City";

        PackingNoteHeader."Ship-to Post Code" :=
            SalesHeader."Ship-to Post Code";

        PackingNoteHeader."Ship-to County" :=
            SalesHeader."Ship-to County";

        PackingNoteHeader."Ship-to Country/Region Code" :=
            SalesHeader."Ship-to Country/Region Code";

        PackingNoteHeader."Ship-to Contact" :=
            SalesHeader."Ship-to Contact";


        // -----------------------------------------------------
        // Forsendelse
        // -----------------------------------------------------

        PackingNoteHeader."Shipment Method Code" :=
            SalesHeader."Shipment Method Code";

        PackingNoteHeader."Shipping Agent Code" :=
            SalesHeader."Shipping Agent Code";

        PackingNoteHeader."Shipping Agent Service Code" :=
            SalesHeader."Shipping Agent Service Code";

        PackingNoteHeader."Shipping Time" :=
            SalesHeader."Shipping Time";


        // -----------------------------------------------------
        // Dato / sprog
        // -----------------------------------------------------

        PackingNoteHeader."Document Date" :=
            SalesHeader."Document Date";

        PackingNoteHeader."Language Code" :=
            SalesHeader."Language Code";


        // -----------------------------------------------------
        // Salgsordre / source
        // -----------------------------------------------------

        PackingNoteHeader."Sales Order No." :=
            SalesHeader."No.";

        PackingNoteHeader."Source Type" :=
            PackingNoteHeader."Source Type"::"Warehouse Shipment";

        PackingNoteHeader."Source No." :=
            WarehouseShipmentNo;


        // -----------------------------------------------------
        // Country / Region på pakkeliste
        // -----------------------------------------------------

        PackingNoteHeader."Country/Reg. Code Packing List" :=
            SalesHeader."Sell-to Country/Region Code";


        // -----------------------------------------------------
        // PO-nummer
        //
        // Kilde:
        // Sales Header.Barcode_EVAS
        //
        // Destination:
        // Packing Note Header."PO-Number"
        //
        // Eksempel:
        //
        // Barcode_EVAS = ABC123
        //
        // PO-Number = ABC123
        // -----------------------------------------------------

        PackingNoteHeader."PO-Number" :=
            CopyStr(
                SalesHeader.Barcode_EVAS,
                1,
                MaxStrLen(
                    PackingNoteHeader."PO-Number"
                )
            );


        // -----------------------------------------------------
        // Colli nummer
        // -----------------------------------------------------

        PackingNoteHeader."Colli No." :=
            Format(
                PackageNo
            );


        // -----------------------------------------------------
        // Nettovægt / bruttovægt
        //
        // Værdierne gælder kun det aktuelle kolli.
        // -----------------------------------------------------

        PackingNoteHeader."Total Net Weight (Kg)" :=
            NetWeight;

        PackingNoteHeader."Total Weight (Kg)" :=
            GrossWeight;


        // -----------------------------------------------------
        // Dimensioner
        //
        // Dimensionerne gælder kun det aktuelle kolli.
        // -----------------------------------------------------

        PackingNoteHeader.Length :=
            CopyStr(
                LengthValue,
                1,
                MaxStrLen(
                    PackingNoteHeader.Length
                )
            );


        PackingNoteHeader.Width :=
            CopyStr(
                WidthValue,
                1,
                MaxStrLen(
                    PackingNoteHeader.Width
                )
            );


        PackingNoteHeader.Height :=
            CopyStr(
                HeightValue,
                1,
                MaxStrLen(
                    PackingNoteHeader.Height
                )
            );


        // -----------------------------------------------------
        // Faktisk antal kolli
        //
        // Antal frontend-linjer.
        //
        // Denne værdi er fortsat samlet antal kolli
        // og er derfor den samme på alle pakkebreve.
        // -----------------------------------------------------

        PackingNoteHeader."Act. Number of Packag." :=
            PackageCount;


        // -----------------------------------------------------
        // Faktisk ladmeter
        //
        // VIGTIGT:
        //
        // Dette er KUN ladmeteren for det aktuelle kolli.
        //
        // PackageLoadMeter kommer direkte fra "volume"
        // på den aktuelle frontend-linje i Packages Json.
        //
        // Der summeres IKKE på tværs af kolli her.
        //
        // Eksempel:
        //
        // Kolli 1 volume = 1.20
        // Kolli 2 volume = 0.80
        //
        // Pakkebrev 1:
        // Actual Load Meter = 1.20
        //
        // Pakkebrev 2:
        // Actual Load Meter = 0.80
        // -----------------------------------------------------

        PackingNoteHeader."Actual Load Meter" :=
            PackageLoadMeter;


        // -----------------------------------------------------
        // PO-Vare / PO-Item
        //
        // Skal altid være 1.
        // -----------------------------------------------------

        PackingNoteHeader."PO-Item" :=
            '1';


        // -----------------------------------------------------
        // HU Type
        //
        // OSB            -> Case
        // JKF emballage  -> Crate
        // Papkasse       -> carbon box
        // -----------------------------------------------------

        PackingNoteHeader."HU Type" :=
            HUType;


        // -----------------------------------------------------
        // HU Ident. nummer
        //
        // Kilde:
        // Sales Header."HU Ident No._EVAS"
        //
        // Eksempel:
        //
        // 7115987XXX
        //
        // De første 7 tegn:
        // 7115987
        //
        // Herefter tilføjes kollinummer som 3 cifre:
        //
        // Colli 1:
        // 7115987001
        //
        // Colli 2:
        // 7115987002
        //
        // Colli 10:
        // 7115987010
        //
        // Colli 100:
        // 7115987100
        // -----------------------------------------------------

        if SalesHeader."HU Ident No._EVAS" <> '' then begin

            HUIdentPrefix :=
                CopyStr(
                    SalesHeader."HU Ident No._EVAS",
                    1,
                    7
                );

            HUIdentNumber :=
                HUIdentPrefix +
                Format(
                    PackageNo,
                    0,
                    '<Integer,3><Filler Character,0>'
                );

            PackingNoteHeader."HU Ident Number" :=
                CopyStr(
                    HUIdentNumber,
                    1,
                    MaxStrLen(
                        PackingNoteHeader."HU Ident Number"
                    )
                );

        end;


        // -----------------------------------------------------
        // Opret pakkebrevshoved
        // -----------------------------------------------------

        PackingNoteHeader.Insert(
            true
        );


        exit(
            PackingNoteNo
        );
    end;


    local procedure RunGetLinesReport(
        PackingNoteNo: Code[20];
        WarehouseShipmentNo: Code[20];
        PackageNo: Integer
    )
    var
        Parameters: Text;
    begin
        Parameters :=
            '<?xml version="1.0" standalone="yes"?>' +
            '<ReportParameters ' +
            'name="CopyLinesToPackingNote_EVAS" ' +
            'id="60013">' +

            '<Options>' +

            '<Field name="PackingNoteNo">' +
            XmlEscape(
                PackingNoteNo
            ) +
            '</Field>' +

            '<Field name="SourceType">1</Field>' +

            '<Field name="WarehouseShipmentNo">' +
            XmlEscape(
                WarehouseShipmentNo
            ) +
            '</Field>' +

            '<Field name="PostedWarehouseShipmentNo" />' +

            '<Field name="PackageNo">' +
            Format(
                PackageNo
            ) +
            '</Field>' +

            '</Options>' +

            '<DataItems>' +

            '<DataItem name="Integer">' +
            'VERSION(1) SORTING(Field1)' +
            '</DataItem>' +

            '</DataItems>' +

            '</ReportParameters>';


        Report.Execute(
            60013,
            Parameters
        );
    end;


    local procedure ParseDimensions(
        Dimensions: Text;
        var LengthValue: Text;
        var WidthValue: Text;
        var HeightValue: Text
    )
    var
        DimensionParts:
            List of [Text];

        Part1:
            Text;

        Part2:
            Text;

        Part3:
            Text;
    begin
        Clear(
            LengthValue
        );

        Clear(
            WidthValue
        );

        Clear(
            HeightValue
        );


        if Dimensions = '' then
            Error(
                'L x B x H is missing.'
            );


        DimensionParts :=
            Dimensions.Split(
                'x'
            );


        if DimensionParts.Count() <> 3 then
            Error(
                'Dimensions %1 are invalid. ' +
                'Expected format is LxBxH.',
                Dimensions
            );


        DimensionParts.Get(
            1,
            Part1
        );

        DimensionParts.Get(
            2,
            Part2
        );

        DimensionParts.Get(
            3,
            Part3
        );


        LengthValue :=
            Part1.Trim();

        WidthValue :=
            Part2.Trim();

        HeightValue :=
            Part3.Trim();


        if (
            (LengthValue = '') or
            (WidthValue = '') or
            (HeightValue = '')
        ) then
            Error(
                'Dimensions %1 are invalid. ' +
                'Length, width and height ' +
                'must all be specified.',
                Dimensions
            );
    end;


    local procedure GetHUType(
        Packaging: Text
    ): Text[30]
    begin
        case LowerCase(
            Packaging.Trim()
        ) of

            'osb':
                exit(
                    'Case'
                );

            'jkf emballage':
                exit(
                    'Crate'
                );

            'papkasse':
                exit(
                    'Cardboard box'
                );

        end;


        Error(
            'Unknown packaging type %1.',
            Packaging
        );
    end;


    local procedure GetDecimalValue(
        JsonObjectValue: JsonObject;
        PropertyName: Text
    ): Decimal
    var
        JsonTokenValue:
            JsonToken;
    begin
        if not JsonObjectValue.Get(
            PropertyName,
            JsonTokenValue
        ) then
            exit(
                0
            );


        if JsonTokenValue
            .AsValue()
            .IsNull()
        then
            exit(
                0
            );


        exit(
            JsonTokenValue
                .AsValue()
                .AsDecimal()
        );
    end;


    local procedure GetTextValue(
        JsonObjectValue: JsonObject;
        PropertyName: Text
    ): Text
    var
        JsonTokenValue:
            JsonToken;
    begin
        if not JsonObjectValue.Get(
            PropertyName,
            JsonTokenValue
        ) then
            exit(
                ''
            );


        if JsonTokenValue
            .AsValue()
            .IsNull()
        then
            exit(
                ''
            );


        exit(
            JsonTokenValue
                .AsValue()
                .AsText()
        );
    end;


    local procedure XmlEscape(
        Value: Text
    ): Text
    var
        Result:
            Text;
    begin
        Result :=
            Value;


        Result :=
            Result.Replace(
                '&',
                '&amp;'
            );


        Result :=
            Result.Replace(
                '<',
                '&lt;'
            );


        Result :=
            Result.Replace(
                '>',
                '&gt;'
            );


        Result :=
            Result.Replace(
                '"',
                '&quot;'
            );


        Result :=
            Result.Replace(
                '''',
                '&apos;'
            );


        exit(
            Result
        );
    end;
}