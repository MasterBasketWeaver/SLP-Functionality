report 50101 "WSB SLP Matter Summary"
{
    Caption = 'Matter Summary';
    DefaultLayout = Word;
    WordLayout = '.\Objects\Reports\Layouts\MatterSummary.docx';

    dataset
    {
        dataitem(Job; Job)
        {
            RequestFilterFields = "No.";


            column(CurrDateTime; CurrentDateTime()) { }
            column(CompanyName; CompInfo.Name) { }




            trigger OnAfterGetRecord()
            var
                JobTask: Record "Job Task";
                JobFeeAmt, JobCostAmt, JobTime : Decimal;
                JobList: List of [Decimal];
                NameList: List of [Text];
            begin
                JobTask.SetRange("Job No.", Job."No.");
                JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);

                // if not Confirm(StrSubstNo('%1 -> %2', JobTask.GetFilters, JobTask.Count)) then
                //     Error('');

                if JobTask.FindSet() then
                    repeat
                        JobTask.CalcFields("Total Usage Price (LCY) PGS", "Total Usage Cost (LCY) PGS", "Resource Usage Qty. PGS");
                        JobFeeAmt += JobTask."Total Usage Price (LCY) PGS";
                        JobCostAmt += JobTask."Total Usage Cost (LCY) PGS";
                        JobTime += JobTask."Resource Usage Qty. PGS";
                    until JobTask.Next() = 0;
                TotalFees += JobFeeAmt;
                TotalCosts += JobCostAmt;
                TotalQty += JobTime;

                // if not Confirm(StrSubstNo('%1: %2, %3 -> %4, %5', Job."No.", JobFeeAmt, JobCostAmt, TotalFees, TotalCosts)) then
                //     Error('');

                Index += 1;
                JobList.Add(JobFeeAmt);
                JobList.Add(JobCostAmt);
                JobList.Add(JobTime);
                Values.Add(Index, JobList);

                NameList.Add(Job."No.");
                NameList.Add(Job."Sell-to Customer Name");
                Names.Add(Index, NameList);
            end;

            // dataitem(JobTask; "Job Task")
            // {
            //     DataItemLink = "Job No." = field("No.");
            //     DataItemTableView = sorting("Job No.", "Job Task No.") where("Job Task Type" = const(Posting));

            //     dataitem(MatterDetailedLedgerEntry; "Proj Detailed Led Entry (PGS)")
            //     {
            //         DataItemLink = "Project No." = field("Job No."), "Project Task No." = field("Job Task No.");
            //         DataItemTableView = sorting("Project No.", "Project Task No.", "Amount Type", "Entry Type", Positive, Chargeable, Type, "No.", "Resource Group No.", "Resource Sub Group No.", "Global Dimension 1 Code", "Global Dimension 2 Code", Payment, Expense, "Posting Date") where(Type = const("Resource"), "Amount Type" = filter('Original Matter Entry|Qty. Adjustment'), "Entry Type" = const(Usage));

            //         //Job Task Detail
            //         trigger OnPreDataItem()
            //         begin
            //             // if not DetailedEntries then
            //             //     CurrReport.Break();
            //         end;

            //         trigger OnAfterGetRecord()
            //         begin
            //             // TotalUsageQty += MatterDetailedLedgerEntry.Quantity;
            //         end;
            //     }

            //     //Job Task
            //     trigger OnPreDataItem()
            //     begin
            //         // if not TaskDetail then
            //         //     CurrReport.Break();
            //     end;
            // }
            // dataitem(DisplayRows; Integer)
            // {

            // }

            //Job
            // trigger OnPreDataItem()
            // begin

            // end;

            // trigger OnAfterGetRecord()
            // var
            //     JobTask: Record "Job Task";
            //     Totals: List of [Decimal];
            // begin
            //     Clear(TotalUsages);
            //     Clear(MatterTotalTime);
            //     Clear(MatterTotalPrice);

            //     JobTask.SetRange("Job No.", Job."No.");
            //     JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);
            //     if JobTask.FindSet() then
            //         repeat
            //             TotalUsages[1] += JobTask."Usage Qty. PGS";
            //             TotalUsages[2] += JobTask."Total Usage Price (LCY) PGS";
            //             TotalUsages[3] += JobTask."Expense Usage Price (LCY) PGS";
            //             TotalUsages[4] += JobTask."Total Usage Cost (LCY) PGS";
            //         until JobTask.Next() = 0;
            //     MatterTotalTime := TotalUsages[1] * TotalUsages[2];
            //     MatterTotalPrice := MatterTotalTime + TotalUsages[3];
            //     OverallTotalPrice += MatterTotalPrice;
            //     OverallTotalTime += TotalUsages[1];
            //     Index += 1;

            //     Totals.Add(TotalUsages[1]);
            //     Totals.Add(TotalUsages[2]);
            //     Totals.Add(TotalUsages[3]);
            //     Totals.Add(TotalUsages[4]);
            //     Totals.Add(MatterTotalTime);
            //     Totals.Add(MatterTotalPrice);
            //     Values.Add(Index, Totals);
            // end;
        }
        // dataitem(Totals; Integer)
        // {
        //     column(TimePercent; Percents[1]) { }
        //     column(AmountPercent; Percents[2]) { }
        //     column(MatterNo; Job."No.") { }
        //     column(MatterDescription; Job.Description) { }
        //     column(TotalUsageQty; TotalUsages[1]) { }
        //     column(TotalUsagePrice; TotalUsages[2]) { }
        //     column(TotalExpenseUsagePrice; TotalUsages[3]) { }
        //     column(TotalUsageCosts; TotalUsages[4]) { }
        //     column(ClientNo; Job."Sell-To Customer No.") { }
        //     column(ClientName; Job."Sell-To Customer Name") { }


        //     trigger OnPreDataItem()
        //     begin
        //         if Index = 0 then
        //             CurrReport.Break();
        //         SetRange(Number, 1, Index);
        //     end;

        //     trigger OnAfterGetRecord()
        //     var
        //         MatterTotals: List of [Decimal];
        //         TempDec: Decimal;
        //         i: Integer;
        //     begin
        //         if Number = 1 then
        //             Job.FindSet()
        //         else
        //             Job.Next();
        //         Clear(Percents);
        //         Values.Get(Number, MatterTotals);

        //         for i := 1 to ArrayLen(TotalUsages) do
        //             MatterTotals.Get(i, TotalUsages[i]);

        //         MatterTotals.Get(1 + ArrayLen(TotalUsages), TempDec);
        //         if TempDec <> 0 then
        //             Percents[1] := TempDec / OverallTotalTime;
        //         MatterTotals.Get(2 + ArrayLen(TotalUsages), TempDec);
        //         if TempDec <> 0 then
        //             Percents[2] := TempDec / OverallTotalPrice;
        //     end;





        // }


        dataitem(Matters; Integer)
        {
            column(MatterNo; DisplayNo) { }
            column(MatterName; DisplayName) { }
            column(MatterFees; DisplayFee) { }
            column(MatterCosts; DisplayCost) { }
            column(MatterTimes; DisplayQty) { }
            column(MatterTotal; DisplayFee + DisplayCost) { }
            column(FeePercent; DisplayFeePer) { }
            column(TimePercent; DisplayTimePer) { }
            column(TotalPercent; DisplayTotalPer) { }
            column(CostPercent; DisplayCostPer) { }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, Index);
            end;

            trigger OnAfterGetRecord()
            var
                NameList: List of [Text];
                JobList: List of [Decimal];
                Total: Decimal;
            begin
                FeePercent := 0;
                TimePercent := 0;
                CostPercent := 0;
                TotalPercent := 0;
                DisplayFeePer := '';
                DisplayTimePer := '';
                DisplayCostPer := '';
                DisplayTotalPer := '';

                Values.Get(Number, JobList);
                JobList.Get(1, DisplayFee);
                JobList.Get(2, DisplayCost);
                JobList.Get(3, DisplayQty);
                if TotalFees <> 0 then
                    FeePercent := DisplayFee / TotalFees * 100;
                if TotalQty <> 0 then
                    TimePercent := DisplayQty / TotalQty * 100;
                if TotalCosts <> 0 then
                    CostPercent := DisplayCost / TotalCosts * 100;
                Total := TotalFees + TotalCosts;
                if Total <> 0 then
                    TotalPercent := (DisplayFee + DisplayCost) / (Total) * 100;
                DisplayFeePer := StrSubstNo('%1%', Round(FeePercent, 0.01));
                DisplayTimePer := StrSubstNo('%1%', Round(TimePercent, 0.01));
                DisplayCostPer := StrSubstNo('%1%', Round(CostPercent, 0.01));
                DisplayTotalPer := StrSubstNo('%1%', Round(TotalPercent, 0.01));

                Names.Get(Number, NameList);
                NameList.Get(1, DisplayNo);
                NameList.Get(2, DisplayName);
            end;
        }

        dataitem(Total; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(TotalCosts; TotalCosts) { }
            column(TotalFees; TotalFees) { }
            column(TotalTotal; TotalFees + TotalCosts) { }
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
        TotalFees, TotalCosts, TotalQty : Decimal;
        Index: Integer;
        // TotalUsages: array[4] of Decimal;
        // MatterTotalPrice, MatterTotalTime, OverallTotalPrice, OverallTotalTime : Decimal;
        // Percents: array[2] of Decimal;
        Values: Dictionary of [Integer, List of [Decimal]];
        DisplayFee, DisplayCost, DisplayQty, FeePercent, TimePercent, CostPercent, TotalPercent : Decimal;

        Names: Dictionary of [Integer, List of [Text]];
        DisplayName, DisplayNo, DisplayFeePer, DisplayTimePer, DisplayCostPer, DisplayTotalPer : Text;


    trigger OnPreReport()
    begin
        CompInfo.Get();
    end;


}