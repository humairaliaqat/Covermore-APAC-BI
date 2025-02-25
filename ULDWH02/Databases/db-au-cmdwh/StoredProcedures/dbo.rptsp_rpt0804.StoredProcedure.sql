USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0804]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0804] 
	@Country nvarchar(10),
    @ReportingPeriod varchar(30),
    @StartDate date,
    @EndDate date,
	@Agency nvarchar(50),
	@BDMName nvarchar(50),
	@StateManagerName nvarchar(50)

as

begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0804
--  Author:         Peter Zhuo
--  Date Created:   20160817
--  Description:    This is a supplementary report for RPT0803, showing outlets that meet the bonus criteria
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  @Country: Outlet country
--					@BDMName: BDM name
--					@BI_Threshold: The amount the sell price has to reach for the BDM to get the bonus
--					@BI: Bounus Incentive amount BDMs get when the threshold is reached
--
--  Change History: 
--                  20160817	-	PZ	-	Created
--					20170505	-	LT	-	Added Travel Manager group to the bonus incentive rule.
--	Business Rule:
--					20160817
--						This bonus incentive applies to Helloworld and Magellan stocked and prospect agents who in FY16 sold $0.
--						For each of these agents that sells $7,500 in FY17 (accumulated across the entire year), you will be paid an additional $200.
--					20170505 - Added Travel Manager to the bonus rule.
--					
/****************************************************************************************************/

set nocount on 

--Uncomment to debug
--declare	
--	@Country nvarchar(10),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date,
--	@Agency nvarchar(50),
--	@BDMName nvarchar(50),
--	@StateManagerName nvarchar(50)

--select
--	@country = 'AU',
--    @ReportingPeriod = 'current Month',
--    @StartDate = '2016-05-01',
--    @EndDate = '2016-05-04',
--	@Agency = 'All',
--	@BDMName = null,
--	@StateManagerName = 'all'

Declare
	@BI_Threshold money,
	@BI money
Select
	@BI_Threshold = 7500,
	@BI = 200

declare
    @rptStartDate datetime,
    @rptEndDate datetime

--get reporting dates
    if @ReportingPeriod = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod


IF OBJECT_ID('tempdb..#temp_a') IS NOT NULL DROP TABLE #temp_a
select
	lo.AlphaCode
into #temp_a
from [db-au-star].dbo.dimOutlet o
inner join [db-au-star].dbo.dimOutlet lo on o.LatestOutletSK = lo.OutletSK
outer apply
	(
	select
		sum(a_P.SellPrice) as [SellPrice FY16]
	from [db-au-star].dbo.factPolicyTransaction a_p
	inner join [db-au-star].dbo.Dim_Date a_d on a_d.Date_SK = a_p.DateSK
	where
		a_d.[Date] >= '2015-07-01' and a_d.[Date] < '2016-07-01' and
		a_p.OutletSK = o.OutletSK
	) as FY16
where
	lo.Country = 'AU' and
	(lo.SuperGroupName in ('helloworld') or lo.SubGroupName in ('MAGELLAN','Travel Managers'))
group by
	lo.AlphaCode
having 
	isnull(sum(fy16.[SellPrice FY16]),0) <= 0


--------------------------------------------------------


select
	'BDM' as [Role],
	cc.LatestBDMName as [Employee Name],
	isnull(cc.TerritoryManager,'Unknown') as [State Manager Latest],
	'H & I' as [Agency Category],
	cc.AlphaCode,
	cc.OutletName,
	cc.SubGroupCode,
	cc.SubGroupName,
	cc.GroupCode,
	cc.GroupName,
	cc.SuperGroupName,
	cc.SellPrice,
	cc.[Running Total] as [YTD SellPrice Total],
	@BI_Threshold as [Bonus Incentive Threshold],
	@BI as [Bonus Incentive],
	@ReportingPeriod as [Reporting Period],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate]
from
(--cc
select
	*,
	ROW_NUMBER() over (partition by bb.[AlphaCode] order by bb.[Month] asc) as [Month Rank]
from
	(--bb
	select 
	aa.Country,
	aa.AlphaCode,
	aa.LatestBDMName,
	aa.TerritoryManager,
	aa.SuperGroupName,
	aa.GroupName,
	aa.SubGroupName,
	aa.OutletName,
	aa.GroupCode,
	aa.SubGroupCode,
	aa.[Month], 
	aa.[SellPrice],
	sum(aa.[SellPrice]) over (partition by aa.AlphaCode order by aa.[Month] asc) as [Running Total]
	from
		(--aa
		select
			sales.[Month],
			lo.Country,
			lo.AlphaCode,
			lo.LatestBDMName,
			lo.TerritoryManager,
			sum(sales.[SellPrice]) as [SellPrice],
			lo.SuperGroupName,
			lo.GroupName,
			lo.SubGroupName,
			lo.OutletName,
			lo.GroupCode,
			lo.SubGroupCode
		from [db-au-star].dbo.dimOutlet o
		inner join [db-au-star].dbo.dimOutlet lo on o.LatestOutletSK = lo.OutletSK
		outer apply
			(
			select
				DATEADD(month, DATEDIFF(month, 0, a_d.[Date]), 0) as [Month],
				sum(a_P.SellPrice) as [SellPrice]
			from [db-au-star].dbo.factPolicyTransaction a_p
			inner join [db-au-star].dbo.Dim_Date a_d on a_d.Date_SK = a_p.DateSK
			where
				a_d.[Date] >= '2016-07-01' and a_d.[Date] < dateadd(d,1,@rptEndDate) and
				a_p.OutletSK = o.OutletSK
			group by
				DATEADD(month, DATEDIFF(month, 0, a_d.[Date]), 0)
			) as sales
		where
			lo.Country = 'AU' and
			(lo.SuperGroupName in ('helloworld') or lo.SubGroupName in ('MAGELLAN','Travel Managers'))
			and sales.[Month] is not null
		group by
			sales.[Month],
			lo.Country,
			lo.AlphaCode,
			lo.LatestBDMName,
			lo.TerritoryManager,
			lo.SuperGroupName,
			lo.GroupName,
			lo.SubGroupName,
			lo.OutletName,
			lo.GroupCode,
			lo.SubGroupCode
		)as aa
	)as bb
where
	bb.[Running Total] >= @BI_Threshold -- For each of these agents that sells $7,500 in FY17 (accumulated across the entire year), you will be paid an additional $200.
) as cc
inner join #temp_a a on a.AlphaCode = cc.AlphaCode
where
	cc.Country = @Country
	and cc.[Month Rank] = 1 -- BDMs only get the bonus once in the first month when sell price reaches the threshold
	and	cc.[Month] >= @rptStartDate and cc.[Month] < dateadd(day,1,@rptEndDate)
	and (@Agency = 'H & I' or isnull(@Agency,'All') = 'All') 
	and (cc.LatestBDMName = @BDMName or isnull(@BDMName,'All') = 'All')
	and	((isnull(cc.TerritoryManager,'Unknown')) = @StateManagerName or isnull(@StateManagerName,'All') = 'All')

    end
GO
