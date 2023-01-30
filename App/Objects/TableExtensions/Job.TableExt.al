tableextension 50110 "WSB SLP Job" extends Job
{
    fields
    {
        field(50100; "WSB SLP Selected"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Selected';
        }
        field(50101; "WSB SLP Marked"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Marked';
            Editable = false;
        }
    }
}