table 50100 "WSB SLP Timekeeper"
{
    Caption = 'Timekeeper';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Resource No."; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Resource."No.";
        }
        field(2; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(3; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(4; Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Resource Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Resource.Name where("No." = field("Resource No.")));
            Editable = false;
        }
    }

    keys
    {
        key(k1; "Resource No.", "Unit Price")
        {
            Clustered = true;
        }
    }
}