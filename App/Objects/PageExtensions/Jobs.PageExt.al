pageextension 50102 "WSB SLP Job List" extends "Job List"
{
    actions
    {
        addlast(reporting)
        {
            action("WSB SLP Case List Summary")
            {
                ApplicationArea = All;
                Caption = 'Case List Summary';
                Image = PrintInstallment;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = false;

                trigger OnAction()
                var
                    Job: Record Job;
                    MatterSummary: Report "WSB SLP Case List Summary";
                begin
                    CopyPageFilter(Job);
                    MatterSummary.SetJobNoFilter(Job.GetFilter("No."));
                    MatterSummary.RunModal();
                end;
            }
            action("WSB SLP Resource Time Summary")
            {
                ApplicationArea = All;
                Caption = 'Resource Time Summary';
                Image = PrintInstallment;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = false;

                trigger OnAction()
                var
                    Job: Record Job;
                    ResourceSummary: Report "WSB SLP Resource Time Summary";
                begin
                    CopyPageFilter(Job);
                    ResourceSummary.SetJobNoFilter(Job.GetFilter("No."));
                    ResourceSummary.RunModal();
                end;
            }
        }
    }

    local procedure CopyPageFilter(var Job: Record Job)
    var
        FilterText: TextBuilder;
    begin
        CurrPage.SetSelectionFilter(Job);
        if Job.FindSet() then begin
            FilterText.Append(Job."No.");
            if Job.Next() <> 0 then
                repeat
                    FilterText.Append(StrSubstNo('|%1', Job."No."));
                until Job.Next() = 0;
            Job.Reset();
            Job.SetFilter("No.", FilterText.ToText());
        end;
    end;
}