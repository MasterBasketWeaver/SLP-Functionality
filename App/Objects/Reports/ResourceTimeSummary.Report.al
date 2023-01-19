report 50102 "WSB SLP Resource Time Summary"
{
    Caption = 'Resource Time Summary';
    DefaultLayout = Word;
    WordLayout = '.\Objects\Reports\Layouts\ResourceTimeSummary.docx';

    dataset
    {

        dataitem(Matter; Job)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }

        dataitem(Resource; Resource)
        {
            RequestFilterFields = "No.";

            column(CurrDateTime; CurrentDateTime()) { }
            column(CompanyName; CompInfo.Name) { }


            trigger OnAfterGetRecord()
            var
                ProjectEntry: Record "Proj Detailed Led Entry (PGS)";
                NameList: List of [Text];
                JobList: List of [Decimal];
                ResourceFeeAmt, ResourceQty : Decimal;
            begin


                ProjectEntry.SetCurrentKey("Project No.", "Project Task No.", "Amount Type", "Entry Type", Positive, Chargeable, Type, "No.", "Resource Group No.", "Resource Sub Group No.", "Global Dimension 1 Code", "Global Dimension 2 Code", Payment, Expense, "Posting Date");
                if Matter.GetFilter("No.") <> '' then
                    ProjectEntry.SetFilter("Project No.", Matter.GetFilter("No."));
                ProjectEntry.SetRange("Entry Type", ProjectEntry."Entry Type"::Usage);
                ProjectEntry.SetRange(Type, ProjectEntry.Type::Resource);
                ProjectEntry.SetRange("No.", Resource."No.");

                if ProjectEntry.FindSet() then
                    repeat
                        ResourceFeeAmt += ProjectEntry."Total Price (LCY)";
                        ResourceQty += ProjectEntry.Quantity;
                    until ProjectEntry.Next() = 0
                else
                    CurrReport.Skip();

                TotalFees += ResourceFeeAmt;
                TotalQty += ResourceQty;

                Index += 1;
                JobList.Add(ResourceFeeAmt);
                JobList.Add(ResourceQty);
                Values.Add(Index, JobList);

                NameList.Add(Resource."No.");
                NameList.Add(Resource.Name);
                Names.Add(Index, NameList);
            end;
        }


        dataitem(ResourceDisplay; Integer)
        {
            column(DisplayNo; DisplayNo) { }
            column(DisplayName; DisplayName) { }
            column(ResourceExp; DisplayFee) { }
            column(ResourceTime; DisplayQty) { }
            column(ResourceTotal; DisplayFee + DisplayQty) { }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, Index);
            end;

            trigger OnAfterGetRecord()
            var
                JobList: List of [Decimal];
                NameList: List of [Text];
            begin
                Names.Get(Number, NameList);
                NameList.Get(1, DisplayNo);
                NameList.Get(2, DisplayName);

                Values.Get(Number, JobList);
                JobList.Get(1, DisplayFee);
                JobList.Get(2, DisplayQty);
            end;
        }

        dataitem(Total; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(TotalFees; TotalFees) { }
            column(TotalTotal; TotalFees + TotalQty) { }
            column(TotalTime; TotalQty) { }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(TaskDetail; TaskDetail)
                    {
                        ApplicationArea = all;
                        Caption = 'Task Detail';
                        ToolTip = 'Specifies if the report displays information by Matter Task.';

                        trigger OnValidate()
                        begin
                            if not TaskDetail then
                                DetailedEntries := false;
                        end;
                    }
                    field(DetailedEntries; DetailedEntries)
                    {
                        ApplicationArea = all;
                        Caption = 'Detailed Entries';
                        ToolTip = 'Specifies if the detailed entries are displayed for each Matter Task. Entries are grouped by Resource.';
                        Enabled = TaskDetail;
                    }
                }
            }
        }
    }

    var

        CompInfo: Record "Company Information";
        TaskDetail, DetailedEntries : Boolean;
        Index: Integer;
        Values: Dictionary of [Integer, List of [Decimal]];
        TotalFees, TotalQty, DisplayFee, DisplayQty : Decimal;
        Names: Dictionary of [Integer, List of [Text]];
        DisplayName, DisplayNo : Text;




    trigger OnPreReport()
    begin
        CompInfo.Get();
    end;


}