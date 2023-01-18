pageextension 50101 "WSB SLP Matter List" extends "Project List (PGS)"
{
    actions
    {
        addafter("Project Profitability")
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
                    if Rec.GetFilter("No.") <> '' then
                        Job.SetFilter("No.", Rec.GetFilter("No."))
                    else
                        Job.SetRange("No.", Rec."No.");
                    MatterSummary.SetTableView(Job);
                    MatterSummary.RunModal();
                end;
            }
        }
    }
}