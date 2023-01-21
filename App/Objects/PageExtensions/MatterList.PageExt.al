pageextension 50101 "WSB SLP Matter List" extends "Project List (PGS)"
{


    actions
    {

        // addlast(processing)
        // {
        //     action("Test")
        //     {
        //         // AccessByPermission = TableData "Project Attribute PGS" = R;
        //         ApplicationArea = All;
        //         Caption = 'Test Derp';
        //         Image = Filter;
        //         Promoted = true;
        //         PromotedCategory = Category5;
        //         PromotedOnly = true;
        //         Scope = Repeater;
        //         ToolTip = 'View or edit the project''s attributes, such as characteristics that help to describe the project.';

        //         trigger OnAction()
        //         begin
        //             Message('derp');
        //         end;
        //     }

        // }

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
                    MatterSummary.SetTableView(Job);
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
                    if Rec.GetFilter("No.") <> '' then
                        Job.SetFilter("No.", Rec.GetFilter("No."))
                    else
                        Job.SetRange("No.", Rec."No.");
                    ResourceSummary.SetTableView(Job);
                    ResourceSummary.RunModal();
                end;
            }
        }
    }
}