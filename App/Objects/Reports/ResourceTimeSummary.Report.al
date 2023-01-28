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

                trigger OnPreDataItem()
                begin
                    Clear(ResourceValues);
                    Clear(MatterList);
                    Clear(MatterDict);
                    Clear(MatterCount);
                    if JobNoFilter <> '' then
                        SetFilter("No.", JobNoFilter);
                end;

                trigger OnAfterGetRecord()
                var
                    ProjectEntry: Record "Proj Detailed Led Entry (PGS)";
                    ValueList: List of [Decimal];
                    i: Integer;
                begin
                    Clear(MatterValues);
                    ProjectEntry.SetCurrentKey("Project No.", "Project Task No.", "Amount Type", "Entry Type", Positive, Chargeable, Type, "No.", "Resource Group No.", "Resource Sub Group No.", "Global Dimension 1 Code", "Global Dimension 2 Code", Payment, Expense, "Posting Date");
                    ProjectEntry.SetRange("Project No.", Matter."No.");
                    ProjectEntry.SetRange("Entry Type", ProjectEntry."Entry Type"::Usage);
                    ProjectEntry.SetRange(Type, ProjectEntry.Type::Resource);
                    ProjectEntry.SetRange("No.", Resource."No.");

                    if not ProjectEntry.FindSet() then
                        exit;
                    repeat
                        MatterValues[1] += ProjectEntry."Total Price (LCY)";
                        MatterValues[2] += ProjectEntry."Total Cost (LCY)";
                        MatterValues[3] += ProjectEntry.Quantity;
                    until ProjectEntry.Next() = 0;

                    MatterCount += 1;
                    MatterList.Add(Matter.Description);
                    ValueList.Add(MatterValues[1]);
                    ValueList.Add(MatterValues[2]);
                    ValueList.Add(MatterValues[3]);
                    MatterDict.Add(MatterCount, ValueList);
                    for i := 1 to ArrayLen(MatterValues) do
                        ResourceValues[i] += MatterValues[i];
                end;

                trigger OnPostDataItem()
                var
                    ValueList: List of [Decimal];
                begin
                    if (MatterCount = 0) or
                            (ResourceValues[1] = 0) and (ResourceValues[2] = 0) and (ResourceValues[3] = 0) then
                        exit;

                    ResourceCount += 1;
                    ResourceList.Add(StrSubstNo('%1 - %2', Resource."No.", Resource.Name));
                    ValueList.Add(ResourceValues[1]);
                    ValueList.Add(ResourceValues[2]);
                    ValueList.Add(ResourceValues[3]);
                    ValueList.Add(MatterCount);
                    ResourceDict.Add(ResourceCount, ValueList);
                    MatterDictList.Add(MatterDict);
                    MatterListList.Add(MatterList);
                end;
            }

            trigger OnPreDataItem()
            begin
                if ResourceNoFilter <> '' then
                    SetFilter("No.", ResourceNoFilter);
            end;
        }


        dataitem(ResourceDisplay; Integer)
        {
            column(ResourceDesc; ResourceDescription) { }
            column(ResourceQty; ResourceValues[3]) { }
            column(ResourcePrice; ResourceValues[1] + ResourceValues[2]) { }

            dataitem(MatterDisplay; Integer)
            {
                column(MatterDesc; MatterDescription) { }
                column(MatterQty; MatterValues[3]) { }
                column(MatterPrice; MatterValues[1] + MatterValues[2]) { }

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, MatterCount);
                end;

                trigger OnAfterGetRecord()
                var
                    ValueList: List of [Decimal];
                    i: Integer;
                begin
                    MatterList.Get(Number, MatterDescription);
                    MatterDict.Get(Number, ValueList);
                    for i := 1 to ArrayLen(MatterValues) do
                        ValueList.Get(i, MatterValues[i]);
                end;
            }

            // dataitem(ResourceTotal; Integer)
            // {
            //     DataItemTableView = sorting(Number) where(Number = const(1));

            //     column(ResourceQty; ResourceValues[3]) { }
            //     column(ResourceCost; ResourceValues[2]) { }
            //     column(ResourcePrice; ResourceValues[1] + ResourceValues[2]) { }

            //     trigger OnAfterGetRecord()
            //     var
            //         i: Integer;
            //     begin
            //         for i := 1 to ArrayLen(ResourceValues) do
            //             TotalValues[i] += ResourceValues[i];
            //     end;
            // }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, ResourceCount);
            end;

            trigger OnAfterGetRecord()
            var
                ValueList: List of [Decimal];
                TempDec: Decimal;
                i: Integer;
            begin
                ResourceList.Get(Number, ResourceDescription);
                ResourceDict.Get(Number, ValueList);
                for i := 1 to ArrayLen(ResourceValues) do begin
                    ValueList.Get(i, ResourceValues[i]);
                    TotalValues[i] += ResourceValues[i];
                end;
                ValueList.Get(4, TempDec);
                MatterCount := Round(TempDec);
                MatterListList.Get(Number, MatterList);
                MatterDictList.Get(Number, MatterDict);
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

        MatterDictList: List of [Dictionary of [Integer, List of [Decimal]]];
        MatterListList: List of [List of [Text]];
        ResourceDict, MatterDict : Dictionary of [Integer, List of [Decimal]];
        ResourceList, MatterList : List of [Text];
        JobNoFilter, ResourceNoFilter, ResourceDescription, MatterDescription : Text;
        ResourceValues, MatterValues, TotalValues : array[3] of Decimal;
        ResourceCount, MatterCount : Integer;




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