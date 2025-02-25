USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0921]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0921] 
	@Country nvarchar(10),
	@ReportingPeriod varchar(30),
	@StartDate date,
	@EndDate date

as

Begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0921
--  Author:         Saurabh Date
--  Date Created:   20171107
--  Description:    This is the main stored procedure for RPT0921 - Flight Centre BDM Incentive Report
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--                  @Country: Outlet country
--					Parameters for incentive structure
--
--  Change History: 
--                  20171107 - SD - Created
--                  20171221 - SD - Added Policy Count and Ticket Count to calculate Strike Rate, INC0052579
--					20180130 - SD - Added International and Domestic policy count, also added Quote count (To show conversion rate in the report), INC0055112
--					20180226 - SD - Corrected calculations to fetch correct Latest Outlet Reference, similar to policy cube
--					20180228 - SD - Included Corporate Sell Price into sales figures

/****************************************************************************************************/

set nocount on 

/*Uncomment to debug*/
--Declare
--	@Country nvarchar(10),
--	@ReportingPeriod varchar(30),
--	@StartDate date,
--	@EndDate date

--Select
--	@country = 'AU',
--	@ReportingPeriod = 'Month-To-Date',
--	@StartDate = null,
--	@EndDate = null

/**************************************************************************/


--Incentive Structure - BDM - Flight Centre
declare @FC_BDM_OTE_Threshold numeric(10,4)
declare @FC_BDM_OTE1_ThresholdMax numeric(10,4) 
declare @FC_BDM_OTE1_Pay money 
declare @FC_BDM_OTE2_Pay money

Set @FC_BDM_OTE_Threshold = 0.9
Set @FC_BDM_OTE1_ThresholdMax = 0.95
Set @FC_BDM_OTE1_Pay = 416.65 
Set @FC_BDM_OTE2_Pay = 833.33

declare @FC_BDM_ATE_Threshold numeric(10,4)
declare @FC_BDM_ATE1_ThresholdMax numeric(10,4)
declare @FC_BDM_ATE1_Pay numeric(10,4)
declare @FC_BDM_ATE2_Pay numeric(10,4)

Set @FC_BDM_ATE_Threshold = 1
Set @FC_BDM_ATE1_ThresholdMax = 1.05
Set @FC_BDM_ATE1_Pay = 0.02
Set @FC_BDM_ATE2_Pay = 0.03


--Incentive Structure - SM - Flight Centre
declare @FC_SM_OTE_Threshold numeric(10,4)
declare @FC_SM_OTE1_ThresholdMax numeric(10,4) 
declare @FC_SM_OTE1_Pay money 
declare @FC_SM_OTE2_Pay money

Set @FC_SM_OTE_Threshold = 0.95
Set @FC_SM_OTE1_ThresholdMax = 0.975
Set @FC_SM_OTE1_Pay = 350
Set @FC_SM_OTE2_Pay = 700

declare @FC_SM_ATE_Threshold numeric(10,4)
declare @FC_SM_ATE1_ThresholdMax numeric(10,4)
declare @FC_SM_ATE1_Pay numeric(10,4)
declare @FC_SM_ATE2_Pay numeric(10,4)

Set @FC_SM_ATE_Threshold = 1
Set @FC_SM_ATE1_ThresholdMax = 1.05
Set @FC_SM_ATE1_Pay = 0.005
Set @FC_SM_ATE2_Pay = 0.0075


declare
    @rptStartDate datetime,
    @rptEndDate datetime

DECLARE @rptStartDateLY datetime
DECLARE @rptEndDateLY datetime

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

SELECT @rptStartDateLY = DATEADD(year,-1,@rptStartDate)
	, @rptEndDateLY = DATEADD(year,-1,@rptEndDate)

/**************************************************************************/

--This is the Ticket Count Calculation for each outlet

IF OBJECT_ID('tempdb..#temp_tc') IS NOT NULL DROP TABLE #temp_tc
Select
	DATEADD(month, DATEDIFF(month, 0, ft.IssueDate), 0) [IssueDate],
	o.LatestBDMName,
	count(ft.DocumentNumber) as [Ticket Count]
Into
	#temp_tc
From
	[db-au-cmdwh].dbo.fltTickets ft
	inner join [db-au-star].dbo.dimOutlet o
		on	ft.OutletKey = o.OutletKey
Where
	ft.IssueDate >= dateadd(month,-12,@rptStartDate) and ft.IssueDate < dateadd(day,1,@rptEndDate)
	and ft.Domain = @country
	and ft.Tickettype = 'issued'
	and ft.RefundedDate is null
	and ft.TravelType in ('International', 'TransTasman') 
	and
        (
            (
                ft.Domain = 'NZ' and 
                ft.DocumentType <> 'EMD'
            ) 
			or 
            (
                ft.DocumentType not in ('EMD', 'VMPD')
            )
        )
	and o.isLatest = 'Y'
Group BY
	DATEADD(month, DATEDIFF(month, 0, ft.IssueDate), 0),
	o.LatestBDMName


--This is the Quote Count Calculation for each outlet

IF OBJECT_ID('tempdb..#temp_tq') IS NOT NULL DROP TABLE #temp_tq
Select
	DATEADD(month, DATEDIFF(month, 0, d.[Date]), 0) [Date],
	o.LatestBDMName,
    Sum(qq.SelectedQuoteCount) [Quote Count]
Into
	#temp_tq
From
	(
		Select
			q.DateSK,
			q.OutletSK,
			case
				--use quote count for integrated
				when exists
				(
					select
						null
					from
						[db-au-star]..dimIntegratdOutlet r
					where
						r.OutletSK = q.OutletSK
				) then q.QuoteCount
				when c.ConsultantSK is not null then q.QuoteSessionCount
				else q.QuoteCount
			end SelectedQuoteCount
		From
			[db-au-star]..factQuoteSummary q
			outer apply
			(
				select top 1 
					ConsultantSK
				from
					[db-au-star]..dimConsultant c
				where
					c.ConsultantSK = q.ConsultantSK and
					c.ConsultantName like '%webuser%'
			) c
		union all

		Select
			q.DateSK,
			q.OutletSK,
			case
				--use quote count for integrated
				when exists
				(
					select
						null
					from
						[db-au-star]..dimIntegratdOutlet r
					where
						r.OutletSK = q.OutletSK
				) then q.QuoteCount
				when c.ConsultantSK is not null then q.QuoteSessionCount
				else q.QuoteCount
			end SelectedQuoteCount
		From
			[db-au-star]..factQuoteSummarybot q
			outer apply
			(
				select top 1 
					ConsultantSK
				from
					[db-au-star]..dimConsultant c
				where
					c.ConsultantSK = q.ConsultantSK and
					c.ConsultantName like '%webuser%'
			) c
	) qq
	inner join [db-au-star].dbo.Dim_Date d on d.Date_SK = qq.DateSK
	inner join [db-au-star].dbo.dimOutlet o2 on o2.OutletSK = qq.OutletSK
	inner join [db-au-star].dbo.dimOutlet o on o.OutletSK = o2.LatestOutletSK
Where
	d.Date >= dateadd(month,-12,@rptStartDate) and d.Date < dateadd(day,1,@rptEndDate) and
	o.Country = @country and
	o.SuperGroupName = 'Flight Centre'
Group BY
	DATEADD(month, DATEDIFF(month, 0, d.[Date]), 0),
	o.LatestBDMName


--This is the Corporate sell price Calculation for each outlet

IF OBJECT_ID('tempdb..#temp_tcc') IS NOT NULL DROP TABLE #temp_tcc
Select
	DATEADD(month, DATEDIFF(month, 0, d.[Date]), 0) [Date],
	o.LatestBDMName,
    Sum(c.SellPrice) [SellPrice]
Into
	#temp_tcc
From
	[db-au-star].dbo.FactCorporate c
	inner join [db-au-star].dbo.Dim_Date d on d.Date_SK = c.DateSK
	inner join [db-au-star].dbo.dimOutlet o2 on o2.OutletSK = c.OutletSK
	inner join [db-au-star].dbo.dimOutlet o on o.OutletSK = o2.LatestOutletSK
Where
	d.Date >= dateadd(month,-12,@rptStartDate) and d.Date < dateadd(day,1,@rptEndDate) and
	o.Country = @country and
	o.SuperGroupName = 'Flight Centre'
Group BY
	DATEADD(month, DATEDIFF(month, 0, d.[Date]), 0),
	o.LatestBDMName


--This is the Last year International and Domestic Policy Count Calculation for each outlet

IF OBJECT_ID('tempdb..#temp_tly') IS NOT NULL DROP TABLE #temp_tly
Select
	DATEADD(month, DATEDIFF(month, 0, DATEADD(year,1,d.date)), 0) [Date],
	o.LatestOutletSK,
	o.LatestBDMName,
	sum(p.InternationalPolicyCount) as [LY International Policy Count],
	sum(p.DomesticPolicyCount) as [LY Domestic Policy Count]
Into
	#temp_tly
From
	[db-au-star].dbo.factPolicyTransaction p
	inner join [db-au-star].dbo.Dim_Date d on d.Date_SK = p.DateSK
	inner join [db-au-star].dbo.dimOutlet o2 on o2.OutletSK = p.OutletSK
	inner join [db-au-star].dbo.dimOutlet o on o.OutletSK = o2.LatestOutletSK
Where
	d.Date >= @rptStartDateLY and d.Date < dateadd(day,1,@rptEndDateLY) and
	o.Country = @country and
	o.SuperGroupName = 'Flight Centre'
Group BY
	DATEADD(month, DATEDIFF(month, 0, DATEADD(year,1,d.date)), 0),
	o.LatestOutletSK,
	o.LatestBDMName


-- This is the month reference table for FC ATE calculation.
-- FC ATE is calculated and paid bi-monthly instead of monthly.

IF OBJECT_ID('tempdb..#temp_mth') IS NOT NULL DROP TABLE #temp_mth
create table #temp_mth ([Month_ID] int, [FC_ATE PeriodID] int, [Is Period End] nvarchar(1))

insert into #temp_mth
select 7,1,'N' union all
select 8,1,'Y' union all
select 9,2,'N' union all
select 10,2,'Y' union all
select 11,3,'N' union all
select 12,3,'Y' union all
select 1,4,'N' union all
select 2,4,'Y' union all
select 3,5,'N' union all
select 4,5,'Y' union all
select 5,6,'N' union all
select 6,7,'Y'

-- Sell Price and Budget by BDM (no change to this section)

IF OBJECT_ID('tempdb..#temp_inc') IS NOT NULL DROP TABLE #temp_inc
select
	DATEADD(month, DATEDIFF(month, 0, aa.[Date]), 0) as [Month],
	aa.[BDM Latest],
	sum(aa.[Sell Price]) as [Sell Price],
	sum(aa.[Policy Count]) as [Policy Count],
	sum(aa.[International Policy Count]) as [International Policy Count],
	sum(aa.[Domestic Policy Count]) as [Domestic Policy Count],
	sum(aa.Budget) as [Target]
into #temp_inc
from
	(
	select 
		d.[Date],
		o.LatestBDMName as [BDM Latest],
		o.BDMName as [BDM PIT],
		o.LatestOutletSK,
		o.SuperGroupName,
		sum(p.SellPrice) as [Sell Price],
		sum(p.PolicyCount) as [Policy Count],
		sum(p.InternationalPolicyCount) as [International Policy Count],
		sum(p.DomesticPolicyCount) as [Domestic Policy Count],
		0 as [Budget]
	from 
		[db-au-star].dbo.factPolicyTransaction p
		inner join [db-au-star].dbo.Dim_Date d on d.Date_SK = p.DateSK
		inner join [db-au-star].dbo.dimOutlet o2 on o2.OutletSK = p.OutletSK
		inner join [db-au-star].dbo.dimOutlet o on o.OutletSK = o2.LatestOutletSK
	where
		d.[Date] >= dateadd(month,-12,@rptStartDate) and d.[Date] < dateadd(day,1,@rptEndDate) and
		o.Country = @country and
		o.SuperGroupName = 'Flight Centre'
	group by
		d.[Date],
		o.LatestBDMName,
		o.BDMName,
		o.LatestOutletSK,
		o.SuperGroupName

	union all

	select 
		d.[Date],
		o.LatestBDMName as [BDM Latest],
		o.BDMName as [BDM PIT],
		o.LatestOutletSK,
		o.SuperGroupName,
		0 as [Sell Price],
		0 as [Policy Count],
		0 as [International Policy Count],
		0 as [Domestic Policy Count],
		sum(p.BudgetAmount) as [Budget]
	from 
		[db-au-star].dbo.factPolicyTarget p
		inner join [db-au-star].dbo.Dim_Date d on d.Date_SK = p.DateSK
		inner join [db-au-star].dbo.dimOutlet o2 on o2.OutletSK = p.OutletSK
		inner join [db-au-star].dbo.dimOutlet o on o.OutletSK = o2.LatestOutletSK
	where
		d.[Date] >= dateadd(month,-12,@rptStartDate) 
		and o.Country = @country
		and o.SuperGroupName = 'Flight Centre'
	group by
		d.[Date],
		o.LatestBDMName,
		o.BDMName,
		o.LatestOutletSK,
		o.SuperGroupName
	)as aa
group by
	DATEADD(month, DATEDIFF(month, 0, aa.[Date]), 0),
	aa.[BDM Latest]


/**************************************************************************/
IF OBJECT_ID('tempdb..#temp_inc_new') IS NOT NULL DROP TABLE #temp_inc_new
select
	i.[Month],
	i.[BDM Latest],
	i.[Sell Price],
	i.[Policy Count],
	i.[International Policy Count],
	i.[Domestic Policy Count],
	i.[Target],
	case
		when mth.[Is Period End] = 'N' then i.[Sell Price]
		else pt.[Sell Price New]
	end [Sell Price for FC ATE],
	pt.[Target New] [Target for FC ATE]
into #temp_inc_new
from #temp_inc i
inner join #temp_mth mth on mth.Month_ID = month(i.[month])
outer apply
	(-- pt (perid total)
	select
		sum(a_i.[Sell Price]) as [Sell Price New],
		sum(a_i.[Policy Count]) as [Policy Count New],
		sum(a_i.[International Policy Count]) as [International Policy Count New],
		sum(a_i.[Domestic Policy Count]) as [Domestic Policy Count New],
		sum(a_i.[Target]) as [Target New]
	from #temp_inc a_i
	inner join #temp_mth a_mth on a_mth.Month_ID = month(a_i.[month])
	where
		a_i.[BDM Latest] = i.[BDM Latest] and
		year(a_i.[Month]) = year(i.[Month]) and
		a_mth.[FC_ATE PeriodID] = mth.[FC_ATE PeriodID]
	) as pt



/**************************************************************************/

-- Calcutating OTE and ATE incentives and putting them together
select
	case when bb.[Month] = DATEADD(month, DATEDIFF(month, 0, @rptStartDate), 0) then 1 else 0 end as [Is Reporting Month],
	bb.[Month],
	bb.[Role],
	bb.[Employee Name],
	bb.[State Manager Latest],
	(IsNull(bb.[Sell Price],0) + IsNull([CorporateSellPrice],0)) [Sell Price],
	bb.[Policy Count],
	[Ticket Count],
	bb.[International Policy Count],
	bb.[Domestic Policy Count],
	[LY International Policy Count],
	[LY Domestic Policy Count],
	[Quote Count],
	bb.[Target],
	bb.[Var $],
	bb.[Var %],
	bb.[Sell Price for FC ATE],
	bb.[Target for FC ATE],
	bb.[Var $ for FC ATE],
	bb.[Var % for FC ATE],
	case 
        when bb.[Role] = 'State Manager' then bb.[OTE Amount]
		when bb.[Role] = 'BDM' and bb.[Employee Name] <> bb.[State Manager Latest] then bb.[OTE Amount] else 0 -- State Manager doesn't get BDM incentive bonus
	end as [OTE Amount],
	case 
        when bb.[Role] = 'State Manager' then bb.[ATE Amount]
		when bb.[Role] = 'BDM' and bb.[Employee Name] <> bb.[State Manager Latest] then bb.[ATE Amount] else 0 -- State Manager doesn't get BDM incentive bonus
	end as [ATE Amount],
	@ReportingPeriod as [Reporting Period],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate],
	@FC_BDM_OTE_Threshold as [FC_BDM_OTE_Threshold],
	@FC_BDM_OTE1_ThresholdMax as [FC_BDM_OTE1_ThresholdMax],
	@FC_BDM_OTE1_Pay as [FC_BDM_OTE1_Pay],
	@FC_BDM_OTE2_Pay as [FC_BDM_OTE2_Pay],
	@FC_BDM_ATE_Threshold as [FC_BDM_ATE_Threshold],
	@FC_BDM_ATE1_ThresholdMax as [FC_BDM_ATE1_ThresholdMax],
	@FC_BDM_ATE1_Pay as [FC_BDM_ATE1_Pay],
	@FC_BDM_ATE2_Pay as [FC_BDM_ATE2_Pay],
	@FC_SM_OTE_Threshold as [FC_SM_OTE_Threshold],
	@FC_SM_OTE1_ThresholdMax as [FC_SM_OTE1_ThresholdMax],
	@FC_SM_OTE1_Pay as [FC_SM_OTE1_Pay],
	@FC_SM_OTE2_Pay as [FC_SM_OTE2_Pay],
	@FC_SM_ATE_Threshold as [FC_SM_ATE_Threshold],
	@FC_SM_ATE1_ThresholdMax as [FC_SM_ATE1_ThresholdMax],
	@FC_SM_ATE1_Pay as [FC_SM_ATE1_Pay],
	@FC_SM_ATE2_Pay as [FC_SM_ATE2_Pay]
from
	(
	select 
		distinct
		i.[Month],
		'BDM' as [Role],
		o.LatestBDMName as [Employee Name],
		isnull(o.TerritoryManager,'Unknown') as [State Manager Latest],
		i.[Sell Price],
		i.[Policy Count],
		i.[International Policy Count],
		i.[Domestic Policy Count],
		i.[Target],
		i.[Var $],
		i.[Var %],
		i.[OTE Amount],
		i.[ATE Amount],
		i.[Sell Price for FC ATE],
		i.[Target for FC ATE],
		i.[Var $ for FC ATE],
		i.[Var % for FC ATE]
	from 
		[db-au-star].dbo.dimOutlet o
	outer apply
	(
	select
		case 
			when i.[Var %] >= @FC_BDM_OTE_Threshold and i.[Var %] <= @FC_BDM_OTE1_ThresholdMax then @FC_BDM_OTE1_Pay
			when i.[Var %] > @FC_BDM_OTE1_ThresholdMax then @FC_BDM_OTE2_Pay
			else 0
		end [OTE Amount], 
		case 
			when i.[Var % for FC ATE] >= @FC_BDM_ATE_Threshold and i.[Var % for FC ATE] <= @FC_BDM_ATE1_ThresholdMax then i.[Var $ for FC ATE] * @FC_BDM_ATE1_Pay
			when i.[Var % for FC ATE] > @FC_BDM_ATE1_ThresholdMax then i.[Var $ for FC ATE] * @FC_BDM_ATE2_Pay
			else 0
		end [ATE Amount],
		i.*
	from 
		(
		select
			i.*,
			i.[Sell Price] - (i.[Target] * @FC_BDM_ATE_Threshold) [Var $],
			((i.[Sell Price] - (i.[Target] * @FC_BDM_ATE_Threshold)) / nullif(i.[Target],0)  + 1) [Var %],
			i.[Sell Price for FC ATE] - (i.[Target for FC ATE] * @FC_BDM_ATE_Threshold) [Var $ for FC ATE],
			((i.[Sell Price for FC ATE] - (i.[Target for FC ATE] * @FC_BDM_ATE_Threshold)) / nullif(i.[Target for FC ATE],0)  + 1) [Var % for FC ATE]
		from 
			#temp_inc_new i
		) i
	where
		i.[BDM Latest] = o.LatestBDMName and
		o.SuperGroupName = 'Flight Centre'
	) as i
	where
		o.Country = @Country and
		o.SuperGroupName = 'Flight Centre' and
		o.TradingStatus in ('Prospect','Stocked') -- Exclude currently stopped outlet
		and i.[Month] is not null

	Union all

	-- State Manager
	select
		aa.[Month],
		aa.[Role],
		aa.[Employee Name],
		aa.[State Manager Latest],
		aa.[Sell Price],
		aa.[Policy Count],
		aa.[International Policy Count],
		aa.[Domestic Policy Count],
		aa.[Target],
		aa.[Var $],
		aa.[Var %],
		case 
			when aa.[Var %] >= @FC_SM_OTE_Threshold and aa.[Var %] <= @FC_SM_OTE1_ThresholdMax then @FC_SM_OTE1_Pay
			when aa.[Var %] > @FC_SM_OTE1_ThresholdMax then @FC_SM_OTE2_Pay
			else 0
		end [OTE Amount],
		case 
			when aa.[Var % for FC ATE] >= @FC_SM_ATE_Threshold and aa.[Var % for FC ATE] <= @FC_SM_ATE1_ThresholdMax then aa.[Var $ for FC ATE] * @FC_SM_ATE1_Pay
			when aa.[Var % for FC ATE] > @FC_SM_ATE1_ThresholdMax then aa.[Var $ for FC ATE] * @FC_SM_ATE2_Pay
			else 0
		end [ATE Amount],
		aa.[Sell Price for FC ATE],
		aa.[Target for FC ATE],
		aa.[Var $ for FC ATE],
		aa.[Var % for FC ATE]
	from
	(
	select
		i.[Month],
		'State Manager' as [Role],
		isnull(o.TerritoryManager,'Unknown') as [Employee Name],
		isnull(o.TerritoryManager,'Unknown') as [State Manager Latest],
		sum(i.[Sell Price]) as [Sell Price],
		sum(i.[Policy Count]) as [Policy Count],
		sum(i.[International Policy Count]) as [International Policy Count],
		sum(i.[Domestic Policy Count]) as [Domestic Policy Count],
		sum(i.[Target]) as [Target],
		sum(i.[Sell Price for FC ATE]) as [Sell Price for FC ATE],
		sum(i.[Target for FC ATE]) as [Target for FC ATE],
		sum(i.[Sell Price]) - (sum(i.[Target]) * @FC_SM_ATE_Threshold) [Var $],
		(sum(i.[Sell Price]) - (sum(i.[Target]) * @FC_SM_ATE_Threshold)) / nullif(sum(i.[Target]),0)  + 1 [Var %],
		sum(i.[Sell Price for FC ATE]) - (sum(i.[Target for FC ATE]) * @FC_SM_ATE_Threshold) [Var $ for FC ATE],
		(sum(i.[Sell Price for FC ATE]) - (sum(i.[Target for FC ATE]) * @FC_SM_ATE_Threshold)) / nullif(sum(i.[Target for FC ATE]),0)  + 1 [Var % for FC ATE]
	from 
		#temp_inc_new i
	left join (select distinct o.LatestBDMName, o.TerritoryManager from [db-au-star].dbo.dimOutlet o) as o on o.LatestBDMName = i.[BDM Latest]
	group by
		i.[Month],
		o.TerritoryManager
	)as aa
)as bb
outer apply
	(
		Select
			Sum([LY International Policy Count]) [LY International Policy Count],
			sum([LY Domestic Policy Count]) [LY Domestic Policy Count]
		From
			#temp_tly tly
		Where
			tly.Date = bb.Month
			and tly.LatestBDMName = bb.[Employee Name]
	) tly
outer apply
	(
		Select
			Sum([Quote Count]) [Quote Count]
		From
			#temp_tq tq
		Where
			tq.Date = bb.Month
			and tq.LatestBDMName = bb.[Employee Name]
	) tq
outer apply
	(
		Select
			Sum(tcc.[SellPrice]) [CorporateSellPrice]
		From
			#temp_tcc tcc
		Where
			tcc.Date = bb.Month
			and tcc.LatestBDMName = bb.[Employee Name]
	) tcc
outer apply
	(
		Select
			Sum([Ticket Count]) [Ticket Count]
		From
			#temp_tc tc
		Where
			tc.IssueDate = bb.Month
			and tc.LatestBDMName = bb.[Employee Name]
	) tc

End
GO
