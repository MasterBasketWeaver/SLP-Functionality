pageextension 50100 "WSB SLP Invoice Suggestion" extends "Invoice Suggestion (PGS)"
{
    actions
    {
        addlast(processing)
        {
            action("WSB SLP Print Test Invoice")
            {
                ApplicationArea = all;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Test Invoice';

                trigger OnAction()
                var
                    TestInvoice: Report "WSB SLP Test Invoice";
                    Job: Record Job;
                begin
                    Job.SetRange("No.", Rec."No.");
                    TestInvoice.SetTableView(Job);
                    TestInvoice.RunModal();
                end;
            }
        }
    }
}