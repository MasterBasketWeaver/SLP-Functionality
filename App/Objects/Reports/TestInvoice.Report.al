report 50100 "WSB SLP Test Invoice"
{
    Caption = 'Test Invoice';
    DefaultLayout = Word;
    WordLayout = '.\Objects\Reports\Layouts\TestInvoice.docx';

    dataset
    {
        dataitem(Job; Job)
        {
            RequestFilterFields = "No.", "Sell-to Customer No.";

            column(MatterNo; "No.") { }
            column(MatterDescription; Description) { }
            column(CompanyLogo; CompInfo.Picture) { }
            column(CompanyAddress1; CompAddr[1]) { }
            column(CompanyAddress2; CompAddr[2]) { }
            column(CompanyAddress3; CompAddr[3]) { }
            column(CompanyAddress4; CompAddr[4]) { }
            column(CompanyAddress5; CompAddr[5]) { }
            column(CompanyAddress6; CompAddr[6]) { }
            column(CompanyAddress7; CompAddr[7]) { }
            column(CompanyAddress8; CompAddr[8]) { }
            column(ClientNo; "Sell-to Customer No.") { }
            column(ClientName; "Sell-to Customer Name") { }
            column(CreationDate; Format("Creation Date", 0, DataFormatLabel)) { }
            column(LastDateModified; Format("Last Date Modified", 0, DataFormatLabel)) { }


            // SubPageLink = "Job No." = FIELD("No."),
            //               "Resource Group No." = FIELD(FILTER("Resource Gr. Filter")),
            //               "No." = FIELD(FILTER("Resource Filter")),
            //               "Posting Date" = FIELD("Posting Date Filter"),
            //               "Reversed PGS" = CONST(false);
            dataitem(ResourceLines; "Job Ledger Entry")
            {
                column(ResourcePostingDate; Format("Posting Date", 0, DataFormatLabel)) { }
                column(ResourceName; ResourceName) { }
                column(ResourceDescription____________________________________; Description) { }
                column(ResourceQtyToInv; "Qty to Invoice PGS") { }
                column(ResourceUnitPriceToInv; "Unit price to invoice PGS") { }
                column(ResourceTotalPriceToInv; "Qty to Invoice PGS" * "Unit price to invoice PGS") { }

                trigger OnPreDataItem()
                var
                    UserSetup: Record "User Setup";
                begin
                    Clear(ServicesTotal);
                    TempTimekeeper.Reset();
                    TempTimekeeper.DeleteAll(false);

                    SetRange("Job No.", Job."No.");
                    SetRange(Type, Type::Resource);
                    SetRange("Percent Complete PGS", false);
                    SetRange("Hour Bank No. PGS", '');
                    SetRange("Reversed PGS", false);
                    SetRange("Chargeable PGS", true);
                    SetRange("Open PGS", true);
                end;

                //Professional Services
                trigger OnAfterGetRecord()
                var
                    Resource: Record Resource;
                    Amt: Decimal;
                begin
                    Clear(ResourceName);
                    if not Resource.Get("No.") then
                        CurrReport.Skip();
                    ResourceName := Resource.Name;
                    Amt := "Qty to Invoice PGS" * "Unit price to invoice PGS";
                    ServicesTotal += Amt;

                    if not TempTimekeeper.Get(Resource."No.", "Unit price to invoice PGS") then begin
                        TempTimekeeper.Init();
                        TempTimekeeper."Resource No." := Resource."No.";
                        TempTimekeeper."Unit Price" := "Unit price to invoice PGS";
                        TempTimekeeper.Insert(false);
                    end;
                    TempTimekeeper.Quantity += "Qty to Invoice PGS";
                    TempTimekeeper.Amount += Amt;
                    TempTimekeeper.Modify(false);
                end;
            }

            dataitem(GLLines; "Job Ledger Entry")
            {
                // DataItemLink = "Job No." = field("No.");
                // DataItemTableView = sorting("Job No.", "Entry Type", Type, "No.") where(Type = const("G/L Account"));

                DataItemLink = "Job No." = field("No."), "Resource Group No." = field("Resource Gr. Filter"), "No." = field("Resource Filter"), "Posting Date" = field("Posting Date Filter");
                DataItemTableView = sorting("Job No.", "Entry Type", Type, "No.") where(Type = const("G/L Account"), "Reversed PGS" = const(false));

                column(GLPostingDate; Format("Posting Date", 0, DataFormatLabel)) { }
                column(GLName; GLName) { }
                column(GLDescription__________________________________________; Description) { }
                column(GLQtyToInv; "Qty to Invoice PGS") { }
                column(GLUnitPriceToInv; "Unit price to invoice PGS") { }
                column(GLTotalPriceToInv; "Qty to Invoice PGS" * "Unit price to invoice PGS") { }

                trigger OnPreDataItem()
                begin
                    Clear(ChargesTotal);

                    SetRange("Job No.", Job."No.");
                    SetRange(Type, Type::"G/L Account");
                    SetRange("Percent Complete PGS", false);
                    SetRange("Hour Bank No. PGS", '');
                    SetRange("Reversed PGS", false);
                    SetRange("Chargeable PGS", true);
                    SetRange("Open PGS", true);
                end;

                //Additional Charges
                trigger OnAfterGetRecord()
                var
                    GLAccount: Record "G/L Account";
                begin
                    Clear(GLName);
                    if not GLAccount.Get("No.") then
                        CurrReport.Skip();
                    GLName := GLAccount.Name;
                    ChargesTotal += "Qty to Invoice PGS" * "Unit price to invoice PGS";
                end;
            }

            dataitem(TimeKeeper; Integer)
            {
                column(TimeKeeperNo; TempTimekeeper."Resource Name") { }
                column(TimeKeeperQuantity; TempTimekeeper.Quantity) { }
                column(TimeKeeperUnitPrice; TempTimekeeper."Unit Price") { }
                column(TimeKeeperAmount; TempTimekeeper.Amount) { }

                trigger OnPreDataItem()
                begin
                    TimekeeperTotal := 0;
                    if TempTimekeeper.IsEmpty() then
                        CurrReport.Break();
                    SetRange(Number, 1, TempTimekeeper.Count());
                end;

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempTimekeeper.FindSet()
                    else
                        TempTimekeeper.Next();
                    TempTimekeeper.CalcFields("Resource Name");
                    TimekeeperTotal += TempTimekeeper.Amount;
                end;
            }


            dataitem(Totals; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(TotalProfessionalServices; ServicesTotal) { }
                column(TotalAdditionalCharges; ChargesTotal) { }
                column(OverallTotal; ServicesTotal + ChargesTotal) { }
                column(TimekeeperTotal; TimekeeperTotal) { }
            }

            //Job Header
            trigger OnPreDataItem()
            begin

            end;

            trigger OnAfterGetRecord()
            begin
                // Clear(ServicesTotal);
                // Clear(ChargesTotal);
                // Clear(OverallTotal);
            end;
        }
    }

    var
        CompInfo: Record "Company Information";
        TempTimekeeper: Record "WSB SLP Timekeeper" temporary;

        CompAddr: array[8] of Text;
        ResourceName, GLName : Text;
        ChargesTotal, ServicesTotal, TimekeeperTotal : Decimal;
        DataFormatLabel: Label '<Month,2>/<Day,2>/<Year>';

    trigger OnPreReport()
    var
        FormatAddress: Codeunit "Format Address";
    begin
        CompInfo.Get();
        CompInfo.CalcFields(Picture);
        FormatAddress.Company(CompAddr, CompInfo);
    end;

    var
        p1: page 14045941;
        p2: Page 14045942;
}