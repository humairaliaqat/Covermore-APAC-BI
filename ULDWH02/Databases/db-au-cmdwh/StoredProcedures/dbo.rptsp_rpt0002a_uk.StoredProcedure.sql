USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0002a_uk]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0002a_uk]
    @Country varchar(2),
    @AgencyGroup varchar(2) = null,
    @AgencyCode varchar(max) = null,
    @ReportingPeriod varchar(30),
    @EndDate varchar(10) = null

as
begin

/****************************************************************************************************/
--  Name:           rptsp_rpt0002a
--  Author:         Leonardus Setyabudi
--  Date Created:   20120820
--  Description:    This stored procedure returns debtors that fall within the parameter values
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: Optional Agency Group Code; e.g. TI
--                  @AgencyCode: Opitonal csv form Agency Codes; e.g. TIN1121,TIN1122
--                  @ReportingPeriod: Value is valid date range
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2012-12-01
--
--  Change History: 20120820 - LS - Migrated from OXLYE.RPTDB.dbo.rptsp_rpt0002a
--                  20120903 - LS - bug fix, for DD only before 01/01/2008 (as in old Oxley code)
--                  20121004 - LS - Case 17870, combine RPT0105 (NZ version)
--                  20130109 - LS - Case 18133, Exclude AU Travel Managers
--                  20130110 - LS - Case 18133, update NZ's default email address.
--                  20130111 - LS - Case 18133, update NZ's ABN
--                  20130213 - LS - Case 18232, change policy date reference from CreateDate to IssuedDate
--                  20130218 - LS - TFS 7664, add UK conditions
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @AgencyCode varchar(max)
declare @ReportingPeriod varchar(30)
declare @EndDate varchar(10)
select
    @Country = 'AU',
    @AgencyGroup = 'TI',
    @AgencyCode = 'AANL050,TIN1121',
    @ReportingPeriod = 'Last Month',
    @EndDate = null
*/

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime

    /* get reporting dates */
    if @ReportingPeriod <> '_User Defined'
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod

    else
        select
            @rptStartDate = '1900-01-01',
            @rptEndDate = @EndDate

    /* parse csv on agency parameter */
    if object_id('tempdb..#agencies') is not null
        drop table #agencies

    select
        left(t.Item, 7) AgencyCode
    into #agencies
    from
        dbo.fn_DelimitedSplit8K(@AgencyCode, ',') t

    create clustered index idx on #agencies(AgencyCode)

    /* main body */
    -- this still use old field names to keep compatibility with old CR report
    select
        a.CountryKey,
        case
            when a.CountryKey = 'AU' then 'ABN: 95 003 114 145'
            when a.CountryKey = 'NZ' then 'IRD: 96884018'
        end ABN,
        a.AgencyCode PPALPHA,
        case
            when a.CountryKey in ('AU', 'UK') then p.ProductCode
            when a.CountryKey in ('NZ') then
                case
                    when p.ProductCode = 'CMB' then 'TSB'
                    when p.ProductCode = 'CMC' then 'TSC'
                    when p.ProductCode = 'CMC' then 'TSC'
                    when p.ProductCode = 'CME' then 'TSE'
                    when p.ProductCode = 'CMO' then 'TSO'
                    when p.ProductCode = 'CMS' then 'TSS'
                    when p.ProductCode = 'CMT' then 'TSL'
                end
        end PPPOLTP,
        case
            when a.CountryKey in ('AU', 'UK') then
                case
                    when a.CommissionPayTypeID not in (4, 5) then p.ProductCode
                    when op.PolicyKey is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More'
                    else 'Credit Card Policies -  Commission payable to Agent'
                end
            when a.CountryKey in ('NZ') then
                case
                    when a.CommissionPayTypeID not in (3, 4, 5) then
                        case
                            when p.ProductCode = 'CMB' then 'TSB'
                            when p.ProductCode = 'CMC' then 'TSC'
                            when p.ProductCode = 'CMC' then 'TSC'
                            when p.ProductCode = 'CME' then 'TSE'
                            when p.ProductCode = 'CMO' then 'TSO'
                            when p.ProductCode = 'CMS' then 'TSS'
                            when p.ProductCode = 'CMT' then 'TSL'
                        end
                    when op.PolicyKey is null then 'Non Credit card Policies - Net Amounts Payable to Travelsure Ltd'
                    else 'Credit Card Policies -  Commission payable to Agent'
                end
        end ORDERBY,
        a.AgencyStatusCode CLPROS,
        a.AgencyGroupCode CLGROUP,
        a.AgencyName CLCONAM,
        case
            when a.CountryKey = 'UK' then GrossPremiumExGSTBeforeDiscount
            when a.AgencyGroupCode = 'FL' then GrossPremiumExGSTBeforeDiscount
            else ActualGrossPremiumAfterDiscount
        end + GSTonGrossPremium GROSS,
        a.Branch CLBRAN,
        AgencyGroupState CLGRSTATE,
        AddressStreet CLADD1,
        AddressSuburb CLADD2,
        AddressState CLADD3,
        AddressPostCode CLPOST,
        ContactTitle CLCON1,
        ContactMiddleInitial CLCON2,
        ContactLastName CLCON3,
        ContactFirstName CLCON4,
        upper(p.ConsultantInitial) PPTC,
        p.AgentReference PPREF,
        p.PolicyNo PPPOLYN,
        convert(datetime,p.IssuedDate) PPDISS,
        dbo.fn_dtCurMonthEnd(p.IssuedDate) PPACT,
        p.DepartureDate PPDEP,
        p.PolicyType PPNER,
        case
            when a.CountryKey = 'UK' then CommissionAmount
            else ActualCommissionAfterDiscount
        end PPPSD,
        case
            when a.CountryKey = 'UK' then
                GrossPremiumExGSTBeforeDiscount + GSTonGrossPremium - CommissionAmount

            -- direct credit
            when a.CommissionPayTypeID = 3 then
                GrossPremiumExGSTBeforeDiscount + GSTonGrossPremium - CommissionAmount - GSTonCommission

            when op.PolicyKey is null then
                case
                    when a.AgencyGroupCode = 'FL' then GrossPremiumExGSTBeforeDiscount - CommissionAmount
                    else ActualGrossPremiumAfterDiscount - ActualCommissionAfterDiscount
                end +
                GSTonGrossPremium -
                GSTOnCommission

            else
                -(ActualCommissionAfterDiscount + GSTOnCommission)
        end NETT,
        a.Phone CLPHONE,
        c.Customer FIRSTOFPPNAME,
        GSTonGrossPremium PPRGTGST,
        GSTOnCommission PPSDGST,
        a.ABN CLABN,
        case 
            when a.CommissionPayTypeID = 1 then 'No Commission'
            when a.CommissionPayTypeID = 2 then 'Discount'
            when a.CommissionPayTypeID = 3 then 'Direct Credit'
            when a.CommissionPayTypeID = 4 then 'Offset'
            when a.CommissionPayTypeID = 5 then 'Direct Debit'
            else 'Unknown'
        end CCCOMMPAYTYPEID,
        isnull(ua.Unallocated, 0) UNALLOCATED,
        isnull(fa.FinanceAdmin, 'Accounts') ADMINEXEC,
        fa.Phone,
        case
            when a.CountryKey in ('AU') then isnull(fa.Email, 'accounts@covermore.com.au')
            when a.CountryKey in ('NZ') then isnull(fa.Email, 'enquiries@covermore.co.nz')
            when a.CountryKey in ('UK') then isnull(fa.Email, '')
        end ADMINEMAIL,
        case
            when a.CountryKey in ('AU') then isnull(fa.Fax, '(02) 92028260')
            when a.CountryKey in ('NZ') then isnull(fa.Fax, '')
            when a.CountryKey in ('UK') then isnull(fa.Fax, '')
        end FAX,
        a.AgencyKey,
        @rptstartDate StartDate,
        @rptEndDate EndDate
    from
        Agency a
        outer apply
        (
            select top 1
                fa.Name FinanceAdmin,
                fa.Phone,
                fa.Email,
                fa.Fax
            from
                FinanceAdmin fa
            where
                fa.CountryKey = a.CountryKey and
                fa.Initial = a.CustomerServiceInitial and
                fa.InUse = 1
            order by 1
        ) fa
        outer apply
        (
            select
                sum(isnull(Amount, 0)) Unallocated
            from
                BankPayment bp
                inner join BankReturn br on
                    bp.ReturnKey = br.ReturnKey
            where
                br.AgencyKey = a.AgencyKey and
                (
                    bp.Allocated is null or
                    bp.Allocated = 0
                ) and
                (
                    br.Op is not null or
                    br.Op <> 'WS'
                )
        ) ua
        inner join Policy p on
            p.AgencyKey = a.AgencyKey
        outer apply
        (
            select top 1
                c.FirstName + ' ' + c.LastName Customer
            from
                Customer c
            where
                c.CustomerKey = p.CustomerKey
            order by
                c.CustomerID
        ) c
        left join OnlinePayment op on
            op.PolicyKey = p.CountryPolicyKey
        left join #agencies ta on
            ta.AgencyCode = a.AgencyCode
    where
        a.AgencyStatus = 'Current' and
        a.CountryKey = @Country and
        (
            @AgencyGroup is null or
            a.AgencyGroupCode = @AgencyGroup
        ) and
        (
            @AgencyCode is null or
            ta.AgencyCode is not null
        ) and
        a.AgencyStatusCode <> 'Z' and
        --exclude AU Travel Managers
        not
        (
            a.CountryKey = 'AU' and
            a.AgencyGroupCode = 'AA' and
            a.AgencySubGroupCode = 'TM'
        ) and
        p.PaymentDate is null and
        (
            (
                a.CountryKey <> 'UK' and
                p.IssuedDate >= '2003-01-05' /* not sure what this date refers to, copied from old proc */
            ) or
            (
                a.CountryKey = 'UK' and
                p.IssuedDate >= @rptStartDate
            )
        ) and
        p.IssuedDate < dateadd(day, 1, @rptEndDate) and
        (
            a.CommissionPayTypeID <> 5 or
            p.IssuedDate <= '2008-01-01'
        ) and
        --for direct credit agents only cash sales are shown and not credit card sales
        (
            a.CountryKey = 'NZ' or
            a.CommissionPayTypeID <> 3 or
            op.PolicyKey is null
        ) and
        -- UK, excludes web agencies
        (
            a.CountryKey <> 'UK' or
            a.AgencyName not like '%web%'
        )
    order by
        a.AgencyCode,
        case
            when a.CountryKey in ('AU', 'UK') then
                case
                    when a.CommissionPayTypeID not in (4, 5) then p.ProductCode
                    when op.PolicyKey is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More'
                    else 'Credit Card Policies -  Commission payable to Agent'
                end
            when a.CountryKey in ('NZ') then
                case
                    when a.CommissionPayTypeID not in (3, 4, 5) then
                        case
                            when p.ProductCode = 'CMB' then 'TSB'
                            when p.ProductCode = 'CMC' then 'TSC'
                            when p.ProductCode = 'CMC' then 'TSC'
                            when p.ProductCode = 'CME' then 'TSE'
                            when p.ProductCode = 'CMO' then 'TSO'
                            when p.ProductCode = 'CMS' then 'TSS'
                            when p.ProductCode = 'CMT' then 'TSL'
                        end
                    when op.PolicyKey is null then 'Non Credit card Policies - Net Amounts Payable to Travelsure Ltd'
                    else 'Credit Card Policies -  Commission payable to Agent'
                end
        end,
        p.PolicyNo

end


GO
