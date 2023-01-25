report 50102 "WSB SLP Resource Time Summary"
{
    Caption = 'Resource Time Summary';
    DefaultLayout = Word;
    WordLayout = '.\Objects\Reports\Layouts\ResourceTimeSummary.docx';

    dataset
    {
        dataitem(Resource; Resource)
        {
            column(CurrDateTime; CurrentDateTime()) { }
            column(CompanyName; CompInfo.Name) { }
            column(ResourceNo; "No.") { }
            column(ResourceName; Name) { }

            dataitem(Matter; Job)
            {
                DataItemTableView = sorting(Description);
                column(MatterNo; "No.") { }
                column(MatterName; Description) { }
                column(MatterQty; MatterValues[3]) { }
                column(MatterCost; MatterValues[2]) { }
                column(MatterPrice; MatterValues[1] + MatterValues[2]) { }

                trigger OnPreDataItem()
                begin
                    Clear(ResourceValues);
                    if JobNoFilter <> '' then
                        SetFilter("No.", JobNoFilter);
                end;

                trigger OnAfterGetRecord()
                var
                    Resource2: Record Resource;
                    ProjectEntry: Record "Proj Detailed Led Entry (PGS)";
                    i: Integer;
                    AddValues: Boolean;
                begin
                    Clear(MatterValues);
                    ProjectEntry.SetCurrentKey("Project No.", "Project Task No.", "Amount Type", "Entry Type", Positive, Chargeable, Type, "No.", "Resource Group No.", "Resource Sub Group No.", "Global Dimension 1 Code", "Global Dimension 2 Code", Payment, Expense, "Posting Date");
                    ProjectEntry.SetRange("Project No.", Matter."No.");
                    ProjectEntry.SetRange("Entry Type", ProjectEntry."Entry Type"::Usage);
                    ProjectEntry.SetRange(Type, ProjectEntry.Type::Resource);
                    ProjectEntry.SetRange("No.", Resource."No.");
                    if not ShowZeroLines then
                        ProjectEntry.SetFilter(Quantity, '<>%1', 0);
                    if ProjectEntry.FindSet() then begin
                        repeat
                            MatterValues[1] += ProjectEntry."Total Price (LCY)";
                            MatterValues[2] += ProjectEntry."Total Cost (LCY)";
                            MatterValues[3] += ProjectEntry.Quantity;
                        until ProjectEntry.Next() = 0;
                        AddValues := true;
                    end;

                    if not MatterList.Contains(Matter."No.") then begin
                        MatterList.Add(Matter."No.");
                        ProjectEntry.SetRange("Entry Type", ProjectEntry."Entry Type"::Usage);
                        ProjectEntry.SetRange(Type, ProjectEntry.Type::"G/L Account");
                        ProjectEntry.SetRange("No.");
                        ProjectEntry.SetRange(Expense, true);
                        ProjectEntry.SetFilter("Expense Resource", '<>%1', '');
                        ProjectEntry.SetFilter("Total Cost (LCY)", '<>%1', 0);
                        ProjectEntry.SetFilter(Quantity, '<>%1', 0);
                        if ProjectEntry.FindSet() then begin
                            repeat
                                if Resource2.Get(ProjectEntry."Expense Resource") then
                                    if not TempResource.Get(ProjectEntry."Expense Resource") then begin
                                        TempResource := Resource2;
                                        TempResource."Unit Cost" := ProjectEntry."Total Cost (LCY)";
                                        TempResource."Unit Price" := ProjectEntry.Quantity;
                                        TempResource.Insert(false);
                                    end else begin
                                        TempResource."Unit Cost" += ProjectEntry."Total Cost (LCY)";
                                        TempResource."Unit Price" += ProjectEntry.Quantity;
                                        TempResource.Modify(false);
                                    end;
                            until ProjectEntry.Next() = 0;
                            AddValues := true;
                        end;
                    end;

                    if AddValues then
                        for i := 1 to ArrayLen(MatterValues) do
                            ResourceValues[i] += MatterValues[i];
                end;
            }



            dataitem(derp; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));

                column(ResourceQty; ResourceValues[3]) { }
                column(ResourceCost; ResourceValues[2]) { }
                column(ResourcePrice; ResourceValues[1] + ResourceValues[2]) { }

                trigger OnAfterGetRecord()
                var
                    i: Integer;
                begin
                    for i := 1 to ArrayLen(ResourceValues) do
                        TotalValues[i] += ResourceValues[i];
                end;
            }

            trigger OnPreDataItem()
            begin
                if ResourceNoFilter <> '' then
                    SetFilter("No.", ResourceNoFilter);
            end;
        }
        dataitem(ExpenseResource; Integer)
        {
            column(ExpResourceNo; TempResource."No.") { }
            column(ExpResourceName; TempResource.Name) { }
            column(ExpResourceQty; TempResource."Unit Price") { }
            column(ExpResourceCost; TempResource."Unit Cost") { }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, TempResource.Count());
            end;

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempResource.FindSet()
                else
                    TempResource.Next();
                TotalValues[2] += TempResource."Unit Cost";
                TotalValues[3] += TempResource."Unit Price";
                // if not Confirm(StrSubstNo('%1: %2, %3 -> %4, %5', TempResource."No.", TempResource."Unit Cost", TempResource."Unit Price", TotalValues[2], TotalValues[3])) then
                //     Error('');
            end;

            trigger OnPostDataItem()
            begin
                TempResource.Reset();
                TempResource.DeleteAll();
            end;
        }


        dataitem(Total; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(TotalQty; TotalValues[3]) { }
            column(TotalCost; TotalValues[2]) { }
            column(TotalPrice; TotalValues[1] + TotalValues[2]) { }
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                // group(Options)
                // {
                //     field(ShowZeroLines; ShowZeroLines)
                //     {
                //         ApplicationArea = all;
                //         Caption = 'Show Zero Lines';
                //     }
                // }
                group("Filter: Matter")
                {
                    field(MatterFilter; JobNoFilter)
                    {
                        ApplicationArea = all;
                        Caption = 'No.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Job: Record Job;
                            JobList: Page "Job List";
                            FilterTxt: TextBuilder;
                        begin
                            JobList.LookupMode(true);
                            if JobList.RunModal() <> Action::LookupOK then
                                exit;
                            JobList.SetSelectionFilter(Job);
                            if not Job.FindSet() then
                                exit;
                            FilterTxt.Append(Job."No.");
                            if Job.Next() <> 0 then
                                repeat
                                    FilterTxt.Append('|' + Job."No.");
                                until job.Next() = 0;
                            JobNoFilter := FilterTxt.ToText();
                        end;
                    }
                }
                group("Filter: Resource")
                {
                    field(ResourceFilter; ResourceNoFilter)
                    {
                        ApplicationArea = all;
                        Caption = 'No.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Resource: Record Resource;
                            ResourceList: Page "Resource List";
                            FilterTxt: TextBuilder;
                        begin
                            ResourceList.LookupMode(true);
                            if ResourceList.RunModal() <> Action::LookupOK then
                                exit;
                            ResourceList.SetSelectionFilter(Resource);
                            if not Resource.FindSet() then
                                exit;
                            FilterTxt.Append(Resource."No.");
                            if Resource.Next() <> 0 then
                                repeat
                                    FilterTxt.Append('|' + Resource."No.");
                                until Resource.Next() = 0;
                            ResourceNoFilter := FilterTxt.ToText();
                        end;
                    }
                }
            }
        }
    }

    var

        CompInfo: Record "Company Information";
        TaskDetail, DetailedEntries, ShowZeroLines : Boolean;
        MatterValues, ResourceValues, TotalValues : array[3] of Decimal;
        JobNoFilter, ResourceNoFilter : Text;
        TempResource: Record Resource temporary;
        MatterList: List of [Code[20]];




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