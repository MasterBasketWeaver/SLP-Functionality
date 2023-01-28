page 50111 "WSB SLP Select Resource"
{
    Caption = 'Select Resource';
    PageType = List;
    SourceTable = Resource;
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("No.") order(ascending);

    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field("WSB SLP Selected"; Rec."WSB SLP Selected")
                {
                    ApplicationArea = all;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }
                field(Description; Rec.Name)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Select")
            {
                ApplicationArea = all;
                Image = Approval;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    SelectRec(true);
                end;
            }
            action("Deselect")
            {
                ApplicationArea = all;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    SelectRec(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Resource: Record Resource;
    begin
        if Resource.FindSet() then
            repeat
                Rec := Resource;
                Rec.Insert(false);
            until Resource.Next() = 0;
    end;

    local procedure SelectRec(Set: Boolean)
    var
        Resource: Record Resource;
    begin
        Resource.CopyFilters(Rec);
        Rec.Reset();
        CurrPage.SetSelectionFilter(Rec);
        Rec.ModifyAll("WSB SLP Selected", set, false);
        Rec.Reset();
        Rec.CopyFilters(Resource);
    end;

    procedure GetSelectedFilter(): Text
    var
        FilterTxt: TextBuilder;
    begin
        Rec.Reset();
        Rec.SetRange("WSB SLP Selected", true);
        if not Rec.FindSet() then
            exit('');
        FilterTxt.Append(Rec."No.");
        if Rec.Next() <> 0 then
            repeat
                FilterTxt.Append('|' + Rec."No.");
            until Rec.Next() = 0;
        exit(FilterTxt.ToText());
    end;


}