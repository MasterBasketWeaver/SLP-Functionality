page 50110 "WSB SLP Select Matter"
{
    Caption = 'Select Matter';
    PageType = List;
    SourceTable = Job;
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
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
        Job: Record Job;
    begin
        if Job.FindSet() then
            repeat
                Rec := Job;
                Rec.Insert(false);
            until Job.Next() = 0;
    end;

    local procedure SelectRec(Set: Boolean)
    var
        Job: Record Job;
    begin
        Job.CopyFilters(Rec);
        Rec.Reset();
        CurrPage.SetSelectionFilter(Rec);
        Rec.ModifyAll("WSB SLP Selected", set, false);
        Rec.Reset();
        Rec.CopyFilters(Job);
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