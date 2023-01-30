page 50112 "WSB SLP Search Dialog"
{
    PageType = ConfirmationDialog;

    layout
    {
        area(Content)
        {
            field("Search For"; FilterText)
            {
                ApplicationArea = all;
                Caption = 'Search For';
            }
        }
    }

    var
        FilterText: Text;

    procedure GetFilterText(): Text
    begin
        exit(FilterText);
    end;
}