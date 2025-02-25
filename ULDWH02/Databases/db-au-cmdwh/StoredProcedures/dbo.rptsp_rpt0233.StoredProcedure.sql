USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0233]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0233]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
                      
as  
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0233
--  Author:         Leonardus Setyabudi
--  Date Created:   20111028
--  Description:    This stored procedure returns Policy & Quote measures
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: agency group code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20111028 - LS - Created
--                  20111101 - LS - most common bug fix, agency status
--                                - change agencysubgroupcode to blank, this will be replaced by
--                                  MPL Sales Channel, pending changes on penguin side    
--                  20111117 - LS - Conversion Count -> Conversion Rate
--                                - rewrite, cross tab is not flexible change to grouped detail
--                  20120120 - LS - put in new fields (sales channel, store code)
--                  20120301 - LS - Use subgroup name for sales channel
--                  20120302 - LS - Optimize repurchase count process
--                                  Use Channel for empty store code
--                  20130213 - LS - Case 18232, change policy date reference from CreateDate to IssuedDate
--                  20140128 - LS - migrate to penguin data set
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
    @ReportingPeriod = 'Current Month', 
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

    if object_id('tempdb..#quote') is not null
        drop table #quote

    if object_id('tempdb..#summary') is not null
        drop table #summary

	if object_id('tempdb..#agencygroup') is not null
        drop table #agencygroup

    /* create temporary tables */
    create table #summary
    (
        ProductCode varchar(50),
        Outlet varchar(250),
        [State] varchar(50),
        [Channel] varchar(50),
        Period varchar(50),
        PolicyCount float,
        FirstPurchaseCount float,
        RepurchaseCount float,
        NetPrice float,
        SellPrice float,
        QuoteCount float,
        ConversionCount float
    )

    /* generate policies */
    select
        pt.PolicyKey,
        pt.IssueDate,
        o.GroupCode,
        pt.ProductCode,
        isnull(convert(varchar(250), upper(pt.StoreCode)), o.SubGroupName) [Outlet],
        ptv.[State],
        o.SubGroupName [Channel], -- MPL Sales Channel
        pt.PostingDate CreateDate,
        case
            when convert(date, pt.PostingDate) between @rptStartDate and @rptEndDate then 'Current Period'
            when convert(date, pt.PostingDate) between dateadd(month, -1, @rptStartDate) and dateadd(month, -1, @rptEndDate) then 'Month Ago'
            when convert(date, pt.PostingDate) between dateadd(year, -1, @rptStartDate) and dateadd(year, -1, @rptEndDate) then 'Year Ago'
        end Period,
        pt.BasePolicyCount PolicyCount,
        0 FirstPurchaseCount,
        0 RepurchaseCount,
        pp.[NAP (incl Tax)] NetPrice,
        pp.[Sell Price] SellPrice
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
                ptv.[State]
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
        (
            (
                pt.PostingDate >= @rptStartDate and 
                pt.PostingDate <  dateadd(day, 1, @rptEndDate) 
            ) or
            (
                pt.PostingDate >= dateadd(month, -1, @rptStartDate) and 
                pt.PostingDate <  dateadd(day, 1, dateadd(month, -1, @rptEndDate)) 
            ) or
            (
                pt.PostingDate >= dateadd(year, -1, @rptStartDate) and 
                pt.PostingDate <  dateadd(day, 1, dateadd(year, -1, @rptEndDate)) 
            )
        )      

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
        FirstPurchaseCount = 
            case
                when isnull(f.Flag, 0) > 0 then 0
                else PolicyCount
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

    /* generate quotes */
    select
        'N/A' ProductCode,
        isnull(convert(varchar(250), upper(q.StoreCode)), o.SubGroupName) [Outlet],
        qc.[State],
        o.SubGroupName [Channel], -- MPL Sales Channel
        case
            when q.CreateDate between @rptStartDate and @rptEndDate then 'Current Period'
            when q.CreateDate between dateadd(month, -1, @rptStartDate) and dateadd(month, -1, @rptEndDate) then 'Month Ago'
            when q.CreateDate between dateadd(year, -1, @rptStartDate) and dateadd(year, -1, @rptEndDate) then 'Year Ago'
        end Period,
        1 QuoteCount,
        case
            when q.PolicyKey is not null then 1
            else 0
        end ConversionCount
    into #quote
    from 
        penOutlet o
        inner join penQuote q on 
            q.OutletAlphaKey = o.OutletAlphaKey
        cross apply
        (
            select top 1 
                c.[State]
            from
                penQuoteCustomer qc
                inner join penCustomer c on
                    c.CustomerKey = qc.CustomerKey
            where
                qc.QuoteCountryKey = q.QuoteCountryKey and
                qc.IsPrimary = 1
        ) qc
    where 
        o.OutletStatus = 'Current' and
        o.CountryKey = @Country and
		o.GroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
        (
            (
                q.CreateDate >= @rptStartDate and 
                q.CreateDate <  dateadd(day, 1, @rptEndDate)
            ) or
            (
                q.CreateDate >= dateadd(month, -1, @rptStartDate) and 
                q.CreateDate <  dateadd(day, 1, dateadd(month, -1, @rptEndDate))
            ) or
            (
                q.CreateDate >= dateadd(year, -1, @rptStartDate) and 
                q.CreateDate <  dateadd(day, 1, dateadd(year, -1, @rptEndDate))
            ) 
        )      

    /* merge */
    insert into #summary
    select
        ProductCode,
        Outlet,
        [State],
        [Channel],
        Period,
        PolicyCount,
        FirstPurchaseCount,
        RepurchaseCount,
        NetPrice,
        SellPrice,
        0 QuoteCount,
        0 ConversionCount
    from 
        #policy

    union all 

    select
        ProductCode,
        Outlet,
        [State],
        [Channel],
        Period,
        0 PolicyCount,
        0 FirstPurchaseCount,
        0 RepurchaseCount,
        0 NetPrice,
        0 SellPrice,
        QuoteCount,
        ConversionCount 
    from 
        #quote


    -- by product  
    select 
        @rptStartDate StartDate,
        @rptEndDate EndDate,
        'Product' GroupBy,
        ProductCode [Group],
        sum(
            case
                when Period = 'Current Period' then PolicyCount
                else 0
            end
        ) CPPolicy,
        sum(
            case
                when Period = 'Current Period' then FirstPurchaseCount
                else 0
            end
        ) CPPolicyFirst,
        sum(
            case
                when Period = 'Current Period' then RepurchaseCount
                else 0
            end
        ) CPPolicyRepurchase,
        sum(
            case
                when Period = 'Current Period' then NetPrice
                else 0
            end
        ) CPNetPrice,
        sum(
            case
                when Period = 'Current Period' then SellPrice
                else 0
            end
        ) CPSellPrice,
        sum(
            case
                when Period = 'Current Period' then QuoteCount
                else 0
            end
        ) CPQuoteCount,
        sum(
            case
                when Period = 'Current Period' then ConversionCount
                else 0
            end
        ) CPQuoteConverted,
        sum(
            case
                when Period = 'Month Ago' then PolicyCount
                else 0
            end
        ) MAGOPolicy,
        sum(
            case
                when Period = 'Month Ago' then FirstPurchaseCount
                else 0
            end
        ) MAGOPolicyFirst,
        sum(
            case
                when Period = 'Month Ago' then RepurchaseCount
                else 0
            end
        ) MAGOPolicyRepurchase,
        sum(
            case
                when Period = 'Month Ago' then NetPrice
                else 0
            end
        ) MAGONetPrice,
        sum(
            case
                when Period = 'Month Ago' then SellPrice
                else 0
            end
        ) MAGOSellPrice,
        sum(
            case
                when Period = 'Month Ago' then QuoteCount
                else 0
            end
        ) MAGOQuoteCount,
        sum(
            case
                when Period = 'Month Ago' then ConversionCount
                else 0
            end
        ) MAGOQuoteConverted,
        sum(
            case
                when Period = 'Year Ago' then PolicyCount
                else 0
            end
        ) YAGOPolicy,
        sum(
            case
                when Period = 'Year Ago' then FirstPurchaseCount
                else 0
            end
        ) YAGOPolicyFirst,
        sum(
            case
                when Period = 'Year Ago' then RepurchaseCount
                else 0
            end
        ) YAGOPolicyRepurchase,
        sum(
            case
                when Period = 'Year Ago' then NetPrice
                else 0
            end
        ) YAGONetPrice,
        sum(
            case
                when Period = 'Year Ago' then SellPrice
                else 0
            end
        ) YAGOSellPrice,
        sum(
            case
                when Period = 'Year Ago' then QuoteCount
                else 0
            end
        ) YAGOQuoteCount,
        sum(
            case
                when Period = 'Year Ago' then ConversionCount
                else 0
            end
        ) YAGOQuoteConverted
    from 
        #summary
    group by 
        ProductCode

    union all

    -- by channel  
    select 
        @rptStartDate StartDate,
        @rptEndDate EndDate,
        'Channel' GroupBy,
        [Channel] [Group],
        sum(
            case
                when Period = 'Current Period' then PolicyCount
                else 0
            end
        ) CPPolicy,
        sum(
            case
                when Period = 'Current Period' then FirstPurchaseCount
                else 0
            end
        ) CPPolicyFirst,
        sum(
            case
                when Period = 'Current Period' then RepurchaseCount
                else 0
            end
        ) CPPolicyRepurchase,
        sum(
            case
                when Period = 'Current Period' then NetPrice
                else 0
            end
        ) CPNetPrice,
        sum(
            case
                when Period = 'Current Period' then SellPrice
                else 0
            end
        ) CPSellPrice,
        sum(
            case
                when Period = 'Current Period' then QuoteCount
                else 0
            end
        ) CPQuoteCount,
        sum(
            case
                when Period = 'Current Period' then ConversionCount
                else 0
            end
        ) CPQuoteConverted,
        sum(
            case
                when Period = 'Month Ago' then PolicyCount
                else 0
            end
        ) MAGOPolicy,
        sum(
            case
                when Period = 'Month Ago' then FirstPurchaseCount
                else 0
            end
        ) MAGOPolicyFirst,
        sum(
            case
                when Period = 'Month Ago' then RepurchaseCount
                else 0
            end
        ) MAGOPolicyRepurchase,
        sum(
            case
                when Period = 'Month Ago' then NetPrice
                else 0
            end
        ) MAGONetPrice,
        sum(
            case
                when Period = 'Month Ago' then SellPrice
                else 0
            end
        ) MAGOSellPrice,
        sum(
            case
                when Period = 'Month Ago' then QuoteCount
                else 0
            end
        ) MAGOQuoteCount,
        sum(
            case
                when Period = 'Month Ago' then ConversionCount
                else 0
            end
        ) MAGOQuoteConverted,
        sum(
            case
                when Period = 'Year Ago' then PolicyCount
                else 0
            end
        ) YAGOPolicy,
        sum(
            case
                when Period = 'Year Ago' then FirstPurchaseCount
                else 0
            end
        ) YAGOPolicyFirst,
        sum(
            case
                when Period = 'Year Ago' then RepurchaseCount
                else 0
            end
        ) YAGOPolicyRepurchase,
        sum(
            case
                when Period = 'Year Ago' then NetPrice
                else 0
            end
        ) YAGONetPrice,
        sum(
            case
                when Period = 'Year Ago' then SellPrice
                else 0
            end
        ) YAGOSellPrice,
        sum(
            case
                when Period = 'Year Ago' then QuoteCount
                else 0
            end
        ) YAGOQuoteCount,
        sum(
            case
                when Period = 'Year Ago' then ConversionCount
                else 0
            end
        ) YAGOQuoteConverted
    from 
        #summary
    group by 
        [Channel]

    union all

    -- by state  
    select 
        @rptStartDate StartDate,
        @rptEndDate EndDate,
        'State' GroupBy,
        [State] [Group],
        sum(
            case
                when Period = 'Current Period' then PolicyCount
                else 0
            end
        ) CPPolicy,
        sum(
            case
                when Period = 'Current Period' then FirstPurchaseCount
                else 0
            end
        ) CPPolicyFirst,
        sum(
            case
                when Period = 'Current Period' then RepurchaseCount
                else 0
            end
        ) CPPolicyRepurchase,
        sum(
            case
                when Period = 'Current Period' then NetPrice
                else 0
            end
        ) CPNetPrice,
        sum(
            case
                when Period = 'Current Period' then SellPrice
                else 0
            end
        ) CPSellPrice,
        sum(
            case
                when Period = 'Current Period' then QuoteCount
                else 0
            end
        ) CPQuoteCount,
        sum(
            case
                when Period = 'Current Period' then ConversionCount
                else 0
            end
        ) CPQuoteConverted,
        sum(
            case
                when Period = 'Month Ago' then PolicyCount
                else 0
            end
        ) MAGOPolicy,
        sum(
            case
                when Period = 'Month Ago' then FirstPurchaseCount
                else 0
            end
        ) MAGOPolicyFirst,
        sum(
            case
                when Period = 'Month Ago' then RepurchaseCount
                else 0
            end
        ) MAGOPolicyRepurchase,
        sum(
            case
                when Period = 'Month Ago' then NetPrice
                else 0
            end
        ) MAGONetPrice,
        sum(
            case
                when Period = 'Month Ago' then SellPrice
                else 0
            end
        ) MAGOSellPrice,
        sum(
            case
                when Period = 'Month Ago' then QuoteCount
                else 0
            end
        ) MAGOQuoteCount,
        sum(
            case
                when Period = 'Month Ago' then ConversionCount
                else 0
            end
        ) MAGOQuoteConverted,
        sum(
            case
                when Period = 'Year Ago' then PolicyCount
                else 0
            end
        ) YAGOPolicy,
        sum(
            case
                when Period = 'Year Ago' then FirstPurchaseCount
                else 0
            end
        ) YAGOPolicyFirst,
        sum(
            case
                when Period = 'Year Ago' then RepurchaseCount
                else 0
            end
        ) YAGOPolicyRepurchase,
        sum(
            case
                when Period = 'Year Ago' then NetPrice
                else 0
            end
        ) YAGONetPrice,
        sum(
            case
                when Period = 'Year Ago' then SellPrice
                else 0
            end
        ) YAGOSellPrice,
        sum(
            case
                when Period = 'Year Ago' then QuoteCount
                else 0
            end
        ) YAGOQuoteCount,
        sum(
            case
                when Period = 'Year Ago' then ConversionCount
                else 0
            end
        ) YAGOQuoteConverted
    from 
        #summary
    group by 
        [State]

    union all

    -- by outlet  
    select 
        @rptStartDate StartDate,
        @rptEndDate EndDate,
        'Outlet' GroupBy,
        Outlet [Group],
        sum(
            case
                when Period = 'Current Period' then PolicyCount
                else 0
            end
        ) CPPolicy,
        sum(
            case
                when Period = 'Current Period' then FirstPurchaseCount
                else 0
            end
        ) CPPolicyFirst,
        sum(
            case
                when Period = 'Current Period' then RepurchaseCount
                else 0
            end
        ) CPPolicyRepurchase,
        sum(
            case
                when Period = 'Current Period' then NetPrice
                else 0
            end
        ) CPNetPrice,
        sum(
            case
                when Period = 'Current Period' then SellPrice
                else 0
            end
        ) CPSellPrice,
        sum(
            case
                when Period = 'Current Period' then QuoteCount
                else 0
            end
        ) CPQuoteCount,
        sum(
            case
                when Period = 'Current Period' then ConversionCount
                else 0
            end
        ) CPQuoteConverted,
        sum(
            case
                when Period = 'Month Ago' then PolicyCount
                else 0
            end
        ) MAGOPolicy,
        sum(
            case
                when Period = 'Month Ago' then FirstPurchaseCount
                else 0
            end
        ) MAGOPolicyFirst,
        sum(
            case
                when Period = 'Month Ago' then RepurchaseCount
                else 0
            end
        ) MAGOPolicyRepurchase,
        sum(
            case
                when Period = 'Month Ago' then NetPrice
                else 0
            end
        ) MAGONetPrice,
        sum(
            case
                when Period = 'Month Ago' then SellPrice
                else 0
            end
        ) MAGOSellPrice,
        sum(
            case
                when Period = 'Month Ago' then QuoteCount
                else 0
            end
        ) MAGOQuoteCount,
        sum(
            case
                when Period = 'Month Ago' then ConversionCount
                else 0
            end
        ) MAGOQuoteConverted,
        sum(
            case
                when Period = 'Year Ago' then PolicyCount
                else 0
            end
        ) YAGOPolicy,
        sum(
            case
                when Period = 'Year Ago' then FirstPurchaseCount
                else 0
            end
        ) YAGOPolicyFirst,
        sum(
            case
                when Period = 'Year Ago' then RepurchaseCount
                else 0
            end
        ) YAGOPolicyRepurchase,
        sum(
            case
                when Period = 'Year Ago' then NetPrice
                else 0
            end
        ) YAGONetPrice,
        sum(
            case
                when Period = 'Year Ago' then SellPrice
                else 0
            end
        ) YAGOSellPrice,
        sum(
            case
                when Period = 'Year Ago' then QuoteCount
                else 0
            end
        ) YAGOQuoteCount,
        sum(
            case
                when Period = 'Year Ago' then ConversionCount
                else 0
            end
        ) YAGOQuoteConverted
    from 
        #summary
    group by 
        Outlet
    order by 
        3, 
        4

end
GO
