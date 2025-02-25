USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0234]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0234]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
                    
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0234
--  Author:         Leonardus Setyabudi
--  Date Created:   20111031
--  Description:    This stored procedure returns benchmark measures for consultant
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: agency group code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20111031 - LS - Created
--                  20111101 - LS - most common bug fix, agency status
--                  20111117 - LS - include store/location of consultant
--                  20120120 - LS - update store location field
--                  20120302 - LS - Optimize repurchase count process
--                                  Use Channel for empty store code
--					20120309 - LT - bug fix, wrong consultant selected.
--									Amended ConsultantInital and ConsultantName columns to select
--									from penPolicyTransaction and penUser tables.
--                  20130213 - LS - Case 18232, change policy date reference from CreateDate to IssuedDate
--                  20140129 - LS - migrate to penguin data set
--                                  use posting date
--                                  use new policy count def
--                                  use new price def
--                                  bug fix, consultant should be client's consultant instad of CM's consultant
--                                  i.e. user id instead of consultant id
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
    @ReportingPeriod = 'Last Month', 
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

    if object_id('tempdb..#summary') is not null
        drop table #summary

	if object_id('tempdb..#agencygroup') is not null
        drop table #agencygroup

    /* generate policies */
    select
        pt.PolicyKey,
        pt.IssueDate,
        o.GroupCode,
        u.Initial ConsultantInitial,
        u.FirstName + ' ' + u.LastName ConsultantName,
        u.[Login] MNumber,
        isnull(convert(varchar(250), upper(pt.StoreCode)), o.SubGroupName) Location,
        pt.IssueDate CreateDate,
        pt.BasePolicyCount PolicyCount,
        0 RepurchaseCount,
        pp.[Sell Price] SellPrice,
        0 RepurchasePrice
    into #policy
    from 
        penOutlet o
        inner join penPolicyTransSummary pt on 
            pt.OutletAlphaKey = o.OutletAlphaKey
        inner join vPenguinPolicyPremiums pp on
            pp.PolicyTransactionKey = pt.PolicyTransactionKey
        left join penUser u on
            u.UserKey = pt.UserKey and
            u.UserStatus = 'Current'
    where 
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
		o.GroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
        pt.PostingDate >= @rptStartDate and 
        pt.PostingDate <  dateadd(day, 1, @rptEndDate) and
        isnull(u.Initial, '') <> 'XX'

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
        RepurchaseCount = 
            case
                when isnull(f.Flag, 0) > 0 then PolicyCount
                else 0
            end,
        RepurchasePrice = 
            case
                when isnull(f.Flag, 0) > 0 then SellPrice
                else 0
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


    ;with cte_summary as
    (
        select
            Location,
            ConsultantInitial,
            isnull(ConsultantName, '') ConsultantName,
            MNumber,
            sum(PolicyCount) PolicyCount,
            sum(SellPrice) SellPrice,
            case
                when sum(PolicyCount) = 0 then 0
                else sum(SellPrice) / sum(PolicyCount)
            end [$/Policy],
            sum(RepurchaseCount) RepurchaseCount,
            sum(RepurchasePrice) RepurchasePrice,
            case
                when sum(PolicyCount) = 0 then 0
                else sum(RepurchaseCount)  * 1.0 / sum(PolicyCount)
            end [Repurchase % by Count],
            case
                when sum(SellPrice) = 0 then 0
                else sum(RepurchasePrice)  * 1.0/ sum(SellPrice)
            end [Repurchase % by Value]
        from 
            #policy
        group by
            Location,
            ConsultantInitial,
            isnull(ConsultantName, ''),
            MNumber
    )
    select
        Location,
        ConsultantInitial,
        ConsultantName,
        MNumber,
        PolicyCount,
        SellPrice,
        [$/Policy],
        RepurchaseCount,
        RepurchasePrice,
        [Repurchase % by Count],
        [Repurchase % by Value],
        row_number() over (order by SellPrice desc) [Rank]
    into #summary
    from 
        cte_summary

    select
        isnull(upper(Location), '') Location,
        upper(ConsultantInitial) ConsultantInitial,
        ConsultantName,
        MNumber,
        PolicyCount,
        SellPrice,
        [$/Policy],
        RepurchaseCount,
        RepurchasePrice,
        [Repurchase % by Count],
        [Repurchase % by Value],
        [Rank],
        case
            when 
                isnull(
                    (
                        select r.SellPrice
                        from 
                            #summary r
                        where 
                            [Rank] = 1
                    ),
                    0
                ) = 0 then 0
            else 
                t.SellPrice /
                (
                    select r.SellPrice
                    from 
                        #summary r
                    where 
                        [Rank] = 1
                )
        end [Benchmark],
        @rptStartDate StartDate, 
        @rptEndDate EndDate
    from 
        #summary t
    order by 
        [Rank]

end
GO
