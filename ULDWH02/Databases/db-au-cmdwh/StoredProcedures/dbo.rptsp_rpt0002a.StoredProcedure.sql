USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0002a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0002a]
    @Country varchar(2),
    @AgencyGroup varchar(2) = null,
    @AgencyCode varchar(max) = null,
    @ExcludeAgencyCode varchar(max) = null,
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
--                  @ExcludeAgencyCode: Opitonal csv form Agency Codes; e.g. TIN1121,TIN1122,TKN0001
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
--                  20130618 - LS - TFS 7664/8556, use Penguin data
--                  20130620 - LS - no more different treatment for FL pricing, use adjusted for all
--                  20130814 - LS - bug fix, non consultant created should be included (inner -> left)
--                  20130916 - LS - case 18898, change Travelsure -> Covermore
--                  20131016 - LS - case 19342, include admin fee in commission
--                  20131104 - LS - case 19496, part payment, only applies to non cc policies
--                  20131118 - LS - case 19600, exclude cancelled part allocations in part allocation value
--                  20140218 - LS - case 20358, round prices to 2 decimal points
--                  20141001 - LS - case 22058, revert to old format
--                                  change to posting date
--                  20150401 - LT - F23843, amend contact and mailing address details
--                  20170314 - SD - INC0025975, amend parameter to exclude agency code
--					20170809 - LT - Added PaymentDueDate column
--					20180115 - SD - Added condition to exclude subgroup MTA from the report, INC0054839
--					20180201 - SD - Added condition to Exclude alpha AAQN020 (MTA Travel), INC0054839
--					20181101 - LL - Exclude CBA, REQ-618
--					20190207 - DM - Exlude list of Alpha's provided by Shilu - REQ-1020
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @AgencyCode varchar(max)
declare @ExcludeAgencyCode varchar(max)
declare @ReportingPeriod varchar(30)
declare @EndDate varchar(10)
select
    @Country = 'AU',
    @AgencyGroup = null,
    @AgencyCode = null,
    @ExcludeAgencyCode = 'TKN0001',
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
        rtrim(ltrim((t.Item))) AgencyCode
    into #agencies
    from
        dbo.fn_DelimitedSplit8K(@AgencyCode, ',') t

    create clustered index idx on #agencies(AgencyCode)

     /* parse csv on exclude agency parameter */
    if object_id('tempdb..#excludeagencies') is not null
        drop table #excludeagencies

    select
        rtrim(ltrim((t.Item))) AgencyCode
    into #excludeagencies
    from
        dbo.fn_DelimitedSplit8K(@ExcludeAgencyCode, ',') t

	/* Added to exclude Agencies as per rules from Shilu JIRA TICKET: REQ-1020 */
	if(@Country = 'AU')
	begin
		insert into #excludeagencies
		select AlphaCode
		from penOutlet
		where 
			OutletStatus = 'Current'
			AND CountryKey = @Country
		and (
				GroupCode = 'MB' --Medibank
				OR AlphaCode IN ('CMN0100', 'CMFL000', 'CMN0576', 'CFV0001') --Internal CoverMore Web Alphas
				OR AlphaCode IN ('AZAW001') --Flybuys Integrated
				OR AlphaCode IN ('AZAI001') --Integrated AU
				OR AlphaCode IN ('AHN0001', 'AHN0002') --AHM WHITELABEL
				OR AlphaCode IN ('VAA0002, VAA0003, VAA0004, VAN0001,VAN0015, VAN0016,VAQ0001, VAA0001') --VIRGIN AIRLINES AGENCIES
				--REQ-618, eclude CBA
				OR GroupCode in ('CB', 'BW')-- CBA Group
			)
	end

    create clustered index idx on #excludeagencies(AgencyCode)

    /* main body */
    -- this still use old field names to keep compatibility with old CR report
    select
        a.CountryKey,
        case
            when a.CountryKey = 'AU' then 'ABN: 95 003 114 145'
            when a.CountryKey = 'NZ' then 'IRD: 96884018'
        end ABN,
        a.AlphaCode PPALPHA,
        p.ProductCode PPPOLTP,
        convert(
            varchar(255),
            case
                when a.CountryKey in ('AU', 'UK') then
                    case
                        when a.PaymentType not in ('Offset', 'Direct Debit') then p.ProductCode
                        when op.PolicyTransactionKey is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More'
                        else 'Credit Card Policies -  Commission payable to Agent'
                    end
                when a.CountryKey in ('NZ') then
                    case
                        when a.PaymentType not in ('Direct Credit', 'Offset', 'Direct Debit') then p.ProductCode
                        when op.PolicyTransactionKey is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More (NZ)'
                        else 'Credit Card Policies -  Commission payable to Agent'
                    end
            end
        ) ORDERBY,
        a.TradingStatus CLPROS,
        a.GroupCode CLGROUP,
        a.OutletName CLCONAM,
        case
            when a.CountryKey = 'UK' then pt.UnAdjGrossPremium
            else pt.GrossPremium
        end GROSS,
        a.Branch CLBRAN,
        StateSalesArea CLGRSTATE,
        case when isnull(ltrim(rtrim(ContactPOBox)),'') = '' or isnull(ltrim(rtrim(ContactMailSuburb)),'') = '' then ContactStreet
             else ContactPOBox
        end CLADD1,
        case when isnull(ltrim(rtrim(ContactPOBox)),'') = '' or isnull(ltrim(rtrim(ContactMailSuburb)),'') = '' then ContactSuburb
             else ContactMailSuburb
        end CLADD2,
        case when isnull(ltrim(rtrim(ContactPOBox)),'') = '' or isnull(ltrim(rtrim(ContactMailSuburb)),'') = '' then ContactState
             else ContactMailState
        end CLADD3,
        case when isnull(ltrim(rtrim(ContactPOBox)),'') = '' or isnull(ltrim(rtrim(ContactMailSuburb)),'') = '' then ContactPostCode
             else ContactMailPostCode
        end CLPOST,
        case when isnull(ltrim(rtrim(AcctOfficerTitle)),'') = '' or isnull(ltrim(rtrim(AcctOfficerFirstName)),'') = '' or isnull(ltrim(rtrim(AcctOfficerLastName)),'') = '' then ContactTitle
             else ltrim(rtrim(AcctOfficerTitle))
        end CLCON1,
        case when isnull(ltrim(rtrim(AcctOfficerTitle)),'') = '' or isnull(ltrim(rtrim(AcctOfficerFirstName)),'') = '' or isnull(ltrim(rtrim(AcctOfficerLastName)),'') = '' then ContactInitial
             else ''
        end CLCON2,
        case when isnull(ltrim(rtrim(AcctOfficerTitle)),'') = '' or isnull(ltrim(rtrim(AcctOfficerFirstName)),'') = '' or isnull(ltrim(rtrim(AcctOfficerLastName)),'') = '' then ContactLastName
             else ltrim(rtrim(AcctOfficerLastName))
        end CLCON3,
        case when isnull(ltrim(rtrim(AcctOfficerTitle)),'') = '' or isnull(ltrim(rtrim(AcctOfficerFirstName)),'') = '' or isnull(ltrim(rtrim(AcctOfficerLastName)),'') = '' then ContactFirstName
             else ltrim(rtrim(AcctOfficerFirstName))
        end CLCON4,
        upper(u.Initial) PPTC,
        p.ExternalReference PPREF,
        pt.PolicyNumber PPPOLYN,
        convert(datetime,pt.IssueDate) PPDISS,
        dbo.fn_dtCurMonthEnd(pt.PostingDate) PPACT,
        p.Tripstart PPDEP,
        p.PolicyType PPNER,
        case
            when a.CountryKey = 'UK' then round(UnAdjCommission - UnAdjTaxOnAgentCommissionGST + UnadjGrossAdminFee, 2)
            else round(Commission - TaxOnAgentCommissionGST + GrossAdminFee, 2)
        end PPPSD,
        case
            when a.CountryKey = 'UK' then
                round(UnAdjGrossPremium, 2) + round(UnAdjCommission + UnAdjGrossAdminFee, 2)

            when a.PaymentType = 'Direct Credit' then
                round(UnAdjGrossPremium, 2) - round(UnAdjCommission + UnAdjGrossAdminFee, 2)

            when op.PolicyTransactionKey is null then
                round(GrossPremium, 2) - round(Commission + GrossAdminFee, 2) - isnull(PartAllocation, 0)

            else
                -round(Commission + GrossAdminFee, 2)
        end NETT,
        a.ContactPhone CLPHONE,
        c.Customer FIRSTOFPPNAME,
        TaxAmountGST PPRGTGST,
        TaxOnAgentCommissionGST PPSDGST,
        a.ABN CLABN,
        a.PaymentType CCCOMMPAYTYPEID,
        isnull(a.AdminExecName, 'Accounts') ADMINEXEC,
        case
            when a.CountryKey = 'AU' then '1300-728-554'
            when a.CountryKey = 'NZ' then '+61 2 8907 5176'
            when a.CountryKey = 'UK' then '1300-728-554'
            else '1300-728-554'
        end Phone,
        'AdminAgentEnquiries@covermore.com.au' ADMINEMAIL,
        case
            when a.CountryKey = 'AU' then '(02) 92028260'
            when a.CountryKey = 'NZ' then '(02) 92028260'
            when a.CountryKey = 'UK' then '(02) 92028260'
            else '(02) 92028260'
        end FAX,
        a.OutletKey AgencyKey,
        @rptstartDate StartDate,
        @rptEndDate EndDate,
		convert(datetime,convert(varchar(8),dateadd(m,1,@rptEndDate),120)+'08') as PaymentDueDate
    from
        penOutlet a
        inner join penPolicy p on
            p.OutletAlphaKey = a.OutletAlphaKey
        inner join penPolicyTransSummary pt on
            pt.PolicyKey = p.PolicyKey
        left join penUser u on
            u.UserKey = pt.UserKey and
            u.UserStatus = 'Current'
        outer apply
        (
            select top 1
                c.FirstName + ' ' + c.LastName Customer
            from
                penPolicyTraveller c
            where
                c.PolicyKey = p.PolicyKey and
                c.isPrimary = 1
        ) c
        left join penPayment op on
            op.PolicyTransactionKey = pt.PolicyTransactionKey
        left join #agencies ta on
            ta.AgencyCode = a.AlphaCode
        outer apply
        (
            select
                sum(pta.AllocationAmount) PartAllocation
            from
                penPolicyTransactionAllocation pta
                inner join penPaymentAllocation pa on
                    pa.PaymentAllocationKey = pta.PaymentAllocationKey and
                    pa.CreateDateTime < dateadd(day, 1, @rptEndDate)
            where
                pta.PolicyTransactionKey = pt.PolicyTransactionKey and
                pta.Status <> 'CANCELLED' and
                pa.Status <> 'CANCELLED'
        ) pta
    where
        a.OutletStatus = 'Current' and
		a.SubGroupName <> 'MTA' and
		a.AlphaCode <> 'AAQN020' and
		(
			@ExcludeAgencyCode is null or
            a.AlphaCode not in (select AgencyCode from #excludeagencies)
		) and
        a.CountryKey = @Country and
        (
            @AgencyGroup is null or
            a.GroupCode = @AgencyGroup
        ) and
        (
            @AgencyCode is null or
            ta.AgencyCode is not null
        ) and
        --exclude AU Travel Managers
        not
        (
            a.CountryKey = 'AU' and
            a.GroupCode = 'AA' and
            a.SubGroupCode = 'TM'
        ) and
        pt.PaymentDate is null and
        (
            (
                a.CountryKey <> 'UK' and
                pt.IssueDate >= '2003-01-05' /* not sure what this date refers to, copied from old proc */
            ) or
            (
                a.CountryKey = 'UK' and
                pt.PostingDate >= @rptStartDate
            )
        ) and
        pt.PostingDate < dateadd(day, 1, @rptEndDate) and
        (
            a.PaymentType <> 'Direct Debit' or
            pt.IssueDate <= '2008-01-01'
        ) and
        --for direct credit agents only cash sales are shown and not credit card sales
        (
            a.CountryKey = 'NZ' or
            a.PaymentType <> 'Direct Credit' or
            op.PolicyTransactionKey is null
        ) and
        -- UK, excludes web agencies
        (
            a.CountryKey <> 'UK' or
            a.OutletName not like '%web%'
        )
    order by
        a.AlphaCode,
        convert(
            varchar(255),
            case
                when a.CountryKey in ('AU', 'UK') then
                    case
                        when a.PaymentType not in ('Offset', 'Direct Debit') then p.ProductCode
                        when op.PolicyTransactionKey is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More'
                        else 'Credit Card Policies -  Commission payable to Agent'
                    end
                when a.CountryKey in ('NZ') then
                    case
                        when a.PaymentType not in ('Direct Credit', 'Offset', 'Direct Debit') then p.ProductCode
                        when op.PolicyTransactionKey is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More (NZ)'
                        else 'Credit Card Policies -  Commission payable to Agent'
                    end
            end
        ),
        p.PolicyNumber

end
GO
