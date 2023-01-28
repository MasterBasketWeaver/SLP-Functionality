report 50101 "WSB SLP Case List Summary"
{
    Caption = 'Case List Summary';
    DefaultLayout = Word;
    WordLayout = '.\Objects\Reports\Layouts\CaseListSummary.docx';

    dataset
    {
        dataitem(Job; Job)
        {
            column(CurrDateTime; CurrentDateTime()) { }
            column(CompanyName; CompInfo.Name) { }

            trigger OnPreDataItem()
            begin
                if JobNoFilter <> '' then
                    SetFilter("No.", JobNoFilter);
            end;

            trigger OnAfterGetRecord()
            var
                JobTask: Record "Job Task";
                JobFeeAmt, JobCostAmt, JobTime : Decimal;
                JobList: List of [Decimal];
                NameList: List of [Text];
            begin
                JobTask.SetRange("Job No.", Job."No.");
                JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);

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

                Index += 1;
                JobList.Add(JobFeeAmt);
                JobList.Add(JobCostAmt);
                JobList.Add(JobTime);
                Values.Add(Index, JobList);

                NameList.Add(Job."No.");
                NameList.Add(Job."Sell-to Customer Name");
                Names.Add(Index, NameList);
            end;
        }

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
                Total := DisplayFee + DisplayCost;
                if Total <> 0 then begin
                    FeePercent := DisplayFee / Total * 100;
                    CostPercent := DisplayCost / Total * 100;
                end;
                if TotalQty <> 0 then
                    TimePercent := DisplayQty / TotalQty * 100;
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
            column(TotalFeePercent; DisplayFeePer) { }
            column(TotalCostPercent; DisplayCostPer) { }
            column(TotalOverallPercent; DisplayTotalPer) { }

            trigger OnAfterGetRecord()
            var
                Total: Decimal;
            begin
                Total := TotalCosts + TotalFees;
                if Total = 0 then
                    exit;
                FeePercent := TotalFees / Total * 100;
                CostPercent := TotalCosts / Total * 100;
                TotalPercent := 100;

                DisplayFeePer := StrSubstNo('%1%', Round(FeePercent, 0.01));
                DisplayCostPer := StrSubstNo('%1%', Round(CostPercent, 0.01));
                DisplayTotalPer := StrSubstNo('%1%', Round(TotalPercent, 0.01));
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Filter: Matter")
                {
                    field(MatterFilter; JobNoFilter)
                    {
                        ApplicationArea = all;
                        Caption = 'No.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            JobList: Page "WSB SLP Select Matter";
                            FilterTxt: TextBuilder;
                        begin
                            JobList.LookupMode(true);
                            JobList.Editable(true);
                            if JobList.RunModal() = Action::LookupOK then
                                JobNoFilter := JobList.GetSelectedFilter();
                        end;
                    }
                }
            }
        }
    }

    var

        CompInfo: Record "Company Information";
        Names: Dictionary of [Integer, List of [Text]];
        DisplayName, DisplayNo, DisplayFeePer, DisplayTimePer, DisplayCostPer, DisplayTotalPer : Text;
        JobNoFilter: Text;
        Values: Dictionary of [Integer, List of [Decimal]];
        DisplayFee, DisplayCost, DisplayQty, FeePercent, TimePercent, CostPercent, TotalPercent : Decimal;
        TotalFees, TotalCosts, TotalQty : Decimal;
        Index: Integer;



    trigger OnPreReport()
    begin
        CompInfo.Get();
    end;

    procedure SetJobNoFilter(NewFilter: Text)
    begin
        if NewFilter <> '' then
            JobNoFilter := NewFilter;
    end;
}