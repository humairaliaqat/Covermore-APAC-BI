USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0236]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0236]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
                    
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0236
--  Author:         Leonardus Setyabudi
--  Date Created:   20111101
--  Description:    This stored procedure returns cancelled policies
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: agency group code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20111101 - LS - Created
--                  20120120 - LS - put in new fields (sales channel, store code, member number)
--                  20120301 - LS - use subgroupname for channel
--                  20120302 - LS - Optimize repurchase count process
--                                  Use Channel for empty store code
--                  20130213 - LS - Case 18232, change policy date reference from CreateDate to IssuedDate
--                  20140129 - LS - migrate to penguin data set
--                                  use posting date
--                                  use new policy count def
--                                  use new price def
--					20160830 - PZ - Include AHM (groupcode = 'AH') in Medibank (groupcode = 'MB') extract 
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select 
    @Country = 'AU',
    @AgencyGroup = 'MB',
    @ReportingPeriod = 'Fiscal Year-To-Date', 
    @StartDate = null, 
    @EndDate = null
*/

    set nocount on

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = convert(smalldatetime,@StartDate), 
            @rptEndDate = convert(smalldatetime,@EndDate)

    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod

    /* clean up temp tables */
    if object_id('tempdb..#policy') is not null
        drop table #policy

    if object_id('tempdb..#customer') is not null
        drop table #customer

    if object_id('tempdb..#repeatcustomer') is not null
        drop table #repeatcustomer

	if object_id('tempdb..#agencygroup') is not null
        drop table #agencygroup

    /* generate cancelled policies */
    select
        pt.PolicyKey,
        pt.IssueDate,
        o.GroupCode,
        pt.ProductCode,
        isnull(convert(varchar(250), upper(pt.StoreCode)), o.SubGroupName) Agency,
        ptv.[State] AgencyGroupState,
        o.SubGroupName MPLSalesChannel, 
        case
            when isnull(MemberNumber, '') <> '' then 'Member'
            else 'Non Member'
        end MemberStatus,
        pt.IssueDate CreateDate,
        -BasePolicyCount PolicyCount,
        -[Sell Price] SellPrice,
        cast('New Customer' as varchar(50)) CustomerType
    into #policy
    from 
        penOutlet o
        inner join penPolicyTransSummary pt on 
            pt.OutletAlphaKey = o.OutletAlphaKey
        inner join vPenguinPolicyPremiums pp on
            pp.PolicyTransactionKey = pt.PolicyTransactionKey
        cross apply
        (
            select top 1 
                ptv.[State],
                ptv.MemberNumber
            from
                penPolicyTraveller ptv
            where
                ptv.PolicyKey = pt.PolicyKey and
                ptv.isPrimary = 1
        ) ptv
    where 
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
		o.GroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
        pt.PostingDate >= @rptStartDate and 
        pt.PostingDate <  dateadd(day, 1, @rptEndDate) and
        pt.TransactionStatus like 'Cancel%'

    /* generate customers */
    select distinct
        ptv.PolicyKey,
        t.GroupCode,
        t.IssueDate,
        ptv.PolicyTravellerID,
        ptv.MemberNumber,
        ptv.FirstName,
        ptv.LastName,
        ptv.DOB
    into #customer
    from
        #policy t
        inner join penPolicyTraveller ptv on
            ptv.PolicyKey = t.PolicyKey

    /* repurchase based on member number or name & dob combination for prior purchase for the same agency group */
    select 
        PolicyKey,
        case
            when exists
            (
                select null
                from
                    penPolicyTraveller ptv
                    inner join penPolicy p on
                        p.PolicyKey = ptv.PolicyKey
                    inner join penOutlet o on
                        o.OutletAlphaKey = p.OutletAlphaKey and
                        o.OutletStatus = 'Current'
                where
                    t.MemberNumber is not null and
                    t.MemberNumber <> '' and
                    ptv.MemberNumber = t.MemberNumber and
                    ptv.PolicyTravellerID < t.PolicyTravellerID and 
                    p.IssueDate < t.IssueDate and 
                    o.GroupCode = t.GroupCode
            ) then 1
            when exists
            (
                select null
                from
                    penPolicyTraveller ptv
                    inner join penPolicy p on
                        p.PolicyKey = ptv.PolicyKey
                    inner join penOutlet o on
                        o.OutletAlphaKey = p.OutletAlphaKey and
                        o.OutletStatus = 'Current'
                where
                    ptv.FirstName = t.FirstName and
                    ptv.LastName = t.LastName and
                    ptv.DOB = t.DOB and
                    ptv.PolicyTravellerID < t.PolicyTravellerID and 
                    p.IssueDate < t.IssueDate and 
                    o.GroupCode = t.GroupCode
            ) then 1
            else 0
        end Flag
    into #repeatcustomer
    from
        #customer t

    create index t on #repeatcustomer (PolicyKey) include (Flag)

    update p
    set 
        CustomerType = 
            case
                when isnull(f.Flag, 0) > 0 then 'Repeat'
                else 'New Customer'
            end
    from 
        #policy p
        outer apply
        (
            select 
                sum(Flag) Flag
            from
                #repeatcustomer rc
            where
                rc.PolicyKey = p.PolicyKey
        ) f


    select
        ProductCode,
        Agency,
        AgencyGroupState,
        MPLSalesChannel,
        MemberStatus,
        CustomerType,
        'Count' Field,
        PolicyCount Value,
        @rptStartDate StartDate, 
        @rptEndDate EndDate
    from 
        #policy

    union all

    select
        ProductCode,
        Agency,
        AgencyGroupState,
        MPLSalesChannel,
        MemberStatus,
        CustomerType,
        'Value' Field,
        SellPrice Value,
        @rptStartDate StartDate, 
        @rptEndDate EndDate
    from 
        #policy

end
GO
