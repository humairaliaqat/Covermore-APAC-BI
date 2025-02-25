USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0803]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0803] 
	@Country nvarchar(10),
	@ReportingPeriod varchar(30),
	@StartDate date,
	@EndDate date,
	@Agency nvarchar(50),
	@BDMName nvarchar(50),
	@StateManagerName nvarchar(50)

as

Begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0803
--  Author:         Peter Zhuo
--  Date Created:   20160817
--  Description:    This is the main stored procedure for RPT0803 - BDM and State Manager Incentive Report
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  @Country: Outlet country
--					@Agency: Flight Centre / Helloworld and Independents
--					@BDMName: BDM name
--					@StateManagerName: State Manager Name
--					Parameters for incentive structure
--
--
--  Change History: 
--                  20160817	-	PZ	-	Created
--					20161025	-	PZ	-	Update how FC ATE is calculated. 
--											FC ATE is calculated and paid bi-monthly. e.g. For July the 
--											incentive amount is always $0, then for August the FC ATE is
--											calculated by comparing the total sellprice and target of July+August

/****************************************************************************************************/

set nocount on 

/*Uncomment to debug*/
--Declare
--	@Country nvarchar(10),
--	@ReportingPeriod varchar(30),
--	@StartDate date,
--	@EndDate date,
--	@Agency nvarchar(50),
--	@BDMName nvarchar(50),
--	--@Area nvarchar(50),
--	@StateManagerName nvarchar(50)

--Select
--	@country = 'AU',
--	@ReportingPeriod = 'Current Month',
--	@StartDate = '2016-05-01',
--	@EndDate = '2016-05-04',
--	@Agency = 'All',
--	@BDMName = 'all',
--	--@Area= null,
--	@StateManagerName = 'all'

/**************************************************************************/
--Incentive Structure - BDM - Flight Centre
declare @FC_BDM_OTE_Threshold numeric(10,4)
declare @FC_BDM_OTE1_ThresholdMax numeric(10,4) 
declare @FC_BDM_OTE1_Pay money 
declare @FC_BDM_OTE2_Pay money

Set @FC_BDM_OTE_Threshold = 0.9
Set @FC_BDM_OTE1_ThresholdMax = 0.95
Set @FC_BDM_OTE1_Pay = 250 
Set @FC_BDM_OTE2_Pay = 500

declare @FC_BDM_ATE_Threshold numeric(10,4)
declare @FC_BDM_ATE1_ThresholdMax numeric(10,4)
declare @FC_BDM_ATE1_Pay numeric(10,4)
declare @FC_BDM_ATE2_Pay numeric(10,4)

Set @FC_BDM_ATE_Threshold = 1
Set @FC_BDM_ATE1_ThresholdMax = 1.05
Set @FC_BDM_ATE1_Pay = 0.02
Set @FC_BDM_ATE2_Pay = 0.03


--Incentive Structure - BDM - Helloworld & Indies
declare @HI_BDM_OTE_Threshold numeric(10,4)
declare @HI_BDM_OTE1_ThresholdMax numeric(10,4) 
declare @HI_BDM_OTE1_Pay money 
declare @HI_BDM_OTE2_Pay money

Set @HI_BDM_OTE_Threshold = 0.9
Set @HI_BDM_OTE1_ThresholdMax = 0.95
Set @HI_BDM_OTE1_Pay = 133.67
Set @HI_BDM_OTE2_Pay = 333.33

declare @HI_BDM_ATE_Threshold numeric(10,4)
declare @HI_BDM_ATE1_ThresholdMax numeric(10,4)
declare @HI_BDM_ATE1_Pay numeric(10,4)
declare @HI_BDM_ATE2_Pay numeric(10,4)

Set @HI_BDM_ATE_Threshold = 1
Set @HI_BDM_ATE1_ThresholdMax = 1.05
Set @HI_BDM_ATE1_Pay = 0.02
Set @HI_BDM_ATE2_Pay = 0.03

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

--Incentive Structure - SM - Helloworld & Indies
declare @HI_SM_OTE_Threshold numeric(10,4)
declare @HI_SM_OTE1_ThresholdMax numeric(10,4) 
declare @HI_SM_OTE1_Pay money 
declare @HI_SM_OTE2_Pay money

Set @HI_SM_OTE_Threshold = 0.95
Set @HI_SM_OTE1_ThresholdMax = 0.975
Set @HI_SM_OTE1_Pay = 233.33
Set @HI_SM_OTE2_Pay = 466.67

declare @HI_SM_ATE_Threshold numeric(10,4)
declare @HI_SM_ATE1_ThresholdMax numeric(10,4)
declare @HI_SM_ATE1_Pay numeric(10,4)
declare @HI_SM_ATE2_Pay numeric(10,4)

Set @HI_SM_ATE_Threshold = 1
Set @HI_SM_ATE1_ThresholdMax = 1.05
Set @HI_SM_ATE1_Pay = 0.005
Set @HI_SM_ATE2_Pay = 0.0075
/**************************************************************************/

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

/**************************************************************************/

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

/**************************************************************************/

-- Sell Price and Budget by BDM (no change to this section)

IF OBJECT_ID('tempdb..#temp_inc') IS NOT NULL DROP TABLE #temp_inc
select
	DATEADD(month, DATEDIFF(month, 0, aa.[Date]), 0) as [Month],
	case when aa.SuperGroupName in ('helloworld','independents') then 'H & I' else 'FC' end as [Agency Category],
	aa.[BDM Latest],
	sum(aa.[Sell Price]) as [Sell Price],
	sum(aa.Budget) as [Target]
into #temp_inc
from
	(--aa
	select 
		d.[Date],
		o.LatestBDMName as [BDM Latest],
		o.BDMName as [BDM PIT],
		o.LatestOutletSK,
		o.SuperGroupName,
		sum(p.SellPrice) as [Sell Price],
		0 as [Budget]
	from 
		[db-au-star].dbo.factPolicyTransaction p
	inner join [db-au-star].dbo.Dim_Date d on d.Date_SK = p.DateSK
	inner join [db-au-star].dbo.dimOutlet o on o.OutletSK = p.OutletSK
	where
		d.[Date] >= dateadd(month,-12,@rptStartDate) and d.[Date] < dateadd(day,1,@rptEndDate) and
		o.Country = @country and
		o.SuperGroupName in ('helloworld','independents','Flight Centre')
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
		sum(p.BudgetAmount) as [Budget]
	from 
		[db-au-star].dbo.factPolicyTarget p
	inner join [db-au-star].dbo.Dim_Date d on d.Date_SK = p.DateSK
	inner join [db-au-star].dbo.dimOutlet o on o.OutletSK = p.OutletSK
	where
		d.[Date] >= dateadd(month,-12,@rptStartDate) 
		and o.Country = @country
		and o.SuperGroupName in ('helloworld','independents','Flight Centre')
	group by
		d.[Date],
		o.LatestBDMName,
		o.BDMName,
		o.LatestOutletSK,
		o.SuperGroupName
	)as aa
group by
	DATEADD(month, DATEDIFF(month, 0, aa.[Date]), 0),
	case when aa.SuperGroupName in ('helloworld','independents') then 'H & I' else 'FC' end,
	aa.[BDM Latest]


/**************************************************************************/
IF OBJECT_ID('tempdb..#temp_inc_new') IS NOT NULL DROP TABLE #temp_inc_new
select
	i.[Month],
	i.[Agency Category],
	i.[BDM Latest],
	i.[Sell Price],
	i.[Target],
	case
		when i.[Agency Category] = 'FC' then
			case 
				when mth.[Is Period End] = 'N' then i.[Sell Price]
				else pt.[Sell Price New]
			end 
		--else i.[Sell Price]
		else 0
	end as [Sell Price for FC ATE],
	case
		when i.[Agency Category] = 'FC' then pt.[Target New]
		else 0
	end as [Target for FC ATE]
into #temp_inc_new
from #temp_inc i
inner join #temp_mth mth on mth.Month_ID = month(i.[month])
outer apply
	(-- pt (perid total)
	select
		sum(a_i.[Sell Price]) as [Sell Price New],
		sum(a_i.[Target]) as [Target New]
	from #temp_inc a_i
	inner join #temp_mth a_mth on a_mth.Month_ID = month(a_i.[month])
	where
		a_i.[BDM Latest] = i.[BDM Latest] and
		a_i.[Agency Category] = i.[Agency Category] and
		year(a_i.[Month]) = year(i.[Month]) and
		a_mth.[FC_ATE PeriodID] = mth.[FC_ATE PeriodID]
	) as pt

/**************************************************************************/

-- Calcutating OTE and ATE incentives and putting together
select
	case when bb.[Month] = DATEADD(month, DATEDIFF(month, 0, @rptStartDate), 0) then 1 else 0 end as [Is Reporting Month],
	bb.[Month],
	bb.[Role],
	bb.[Employee Name],
	bb.[Agency Category],
	bb.[State Manager Latest],
	bb.[Sell Price],
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
	@HI_BDM_OTE_Threshold as [HI_BDM_OTE_Threshold],
	@HI_BDM_OTE1_ThresholdMax as [HI_BDM_OTE1_ThresholdMax],
	@HI_BDM_OTE1_Pay as [HI_BDM_OTE1_Pay],
	@HI_BDM_OTE2_Pay as [HI_BDM_OTE2_Pay],
	@HI_BDM_ATE_Threshold as [HI_BDM_ATE_Threshold],
	@HI_BDM_ATE1_ThresholdMax as [HI_BDM_ATE1_ThresholdMax],
	@HI_BDM_ATE1_Pay as [HI_BDM_ATE1_Pay],
	@HI_BDM_ATE2_Pay as [HI_BDM_ATE2_Pay],
	@FC_SM_OTE_Threshold as [FC_SM_OTE_Threshold],
	@FC_SM_OTE1_ThresholdMax as [FC_SM_OTE1_ThresholdMax],
	@FC_SM_OTE1_Pay as [FC_SM_OTE1_Pay],
	@FC_SM_OTE2_Pay as [FC_SM_OTE2_Pay],
	@FC_SM_ATE_Threshold as [FC_SM_ATE_Threshold],
	@FC_SM_ATE1_ThresholdMax as [FC_SM_ATE1_ThresholdMax],
	@FC_SM_ATE1_Pay as [FC_SM_ATE1_Pay],
	@FC_SM_ATE2_Pay as [FC_SM_ATE2_Pay],
	@HI_SM_OTE_Threshold as [HI_SM_OTE_Threshold],
	@HI_SM_OTE1_ThresholdMax as [HI_SM_OTE1_ThresholdMax],
	@HI_SM_OTE1_Pay as [HI_SM_OTE1_Pay],
	@HI_SM_OTE2_Pay as [HI_SM_OTE2_Pay],
	@HI_SM_ATE_Threshold as [HI_SM_ATE_Threshold],
	@HI_SM_ATE1_ThresholdMax as [HI_SM_ATE1_ThresholdMax],
	@HI_SM_ATE1_Pay as [HI_SM_ATE1_Pay],
	@HI_SM_ATE2_Pay as [HI_SM_ATE2_Pay]
from
	(--bb
	-- BDM
	select distinct
		i.[Month],
		'BDM' as [Role],
		o.LatestBDMName as [Employee Name],
		case when o.SuperGroupName in ('helloworld','independents') then 'H & I' else 'FC' end as [Agency Category],
		isnull(o.TerritoryManager,'Unknown') as [State Manager Latest],
		i.[Sell Price],
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
	(-- i
	select
		case
			when i.[Agency Category] = 'H & I' then 
				case 
					when i.[Var %] >= @HI_BDM_OTE_Threshold and i.[Var %] <= @HI_BDM_OTE1_ThresholdMax then @HI_BDM_OTE1_Pay
					when i.[Var %] > @HI_BDM_OTE1_ThresholdMax then @HI_BDM_OTE2_Pay
					else 0
				end
			when i.[Agency Category] = 'FC' then 
				case 
					when i.[Var %] >= @FC_BDM_OTE_Threshold and i.[Var %] <= @FC_BDM_OTE1_ThresholdMax then @FC_BDM_OTE1_Pay
					when i.[Var %] > @FC_BDM_OTE1_ThresholdMax then @FC_BDM_OTE2_Pay
					else 0
				end
		end as [OTE Amount],
		case
			when i.[Agency Category] = 'H & I' then
				case 
					when i.[Var %] >= @HI_BDM_ATE_Threshold and i.[Var %] <= @HI_BDM_ATE1_ThresholdMax then i.[Var $] * @HI_BDM_ATE1_Pay
					when i.[Var %] > @HI_BDM_ATE1_ThresholdMax then i.[Var $] * @HI_BDM_ATE2_Pay
					else 0
				end
			when i.[Agency Category] = 'FC' then 
				case 
					when i.[Var % for FC ATE] >= @FC_BDM_ATE_Threshold and i.[Var % for FC ATE] <= @FC_BDM_ATE1_ThresholdMax then i.[Var $ for FC ATE] * @FC_BDM_ATE1_Pay
					when i.[Var % for FC ATE] > @FC_BDM_ATE1_ThresholdMax then i.[Var $ for FC ATE] * @FC_BDM_ATE2_Pay
					else 0
				end
		end as [ATE Amount],
		i.*
	from 
		--#temp_inc_new i
		(-- i
		select
			i.*,
			case 
				when i.[Agency Category] = 'H & I' then i.[Sell Price] - (i.[Target] * @HI_BDM_ATE_Threshold)
				when i.[Agency Category] = 'FC' then i.[Sell Price] - (i.[Target] * @FC_BDM_ATE_Threshold)
			end as [Var $],
			case 
				when i.[Agency Category] = 'H & I' then (i.[Sell Price] - (i.[Target] * @HI_BDM_ATE_Threshold)) / nullif(i.[Target],0)  + 1
				when i.[Agency Category] = 'FC' then (i.[Sell Price] - (i.[Target] * @FC_BDM_ATE_Threshold)) / nullif(i.[Target],0)  + 1
			end as [Var %],
			case 
				when i.[Agency Category] = 'H & I' then 0
				when i.[Agency Category] = 'FC' then i.[Sell Price for FC ATE] - (i.[Target for FC ATE] * @FC_BDM_ATE_Threshold)
			end as [Var $ for FC ATE],
			case 
				when i.[Agency Category] = 'H & I' then 0
				when i.[Agency Category] = 'FC' then (i.[Sell Price for FC ATE] - (i.[Target for FC ATE] * @FC_BDM_ATE_Threshold)) / nullif(i.[Target for FC ATE],0)  + 1
			end as [Var % for FC ATE]
		from #temp_inc_new i

		)as i
	where
		i.[BDM Latest] = o.LatestBDMName and
		i.[Agency Category] = case when o.SuperGroupName in ('helloworld','independents') then 'H & I' else 'FC' end
	) as i
	where
		o.Country = @Country and
		o.SuperGroupName in ('helloworld','independents','Flight Centre') and
		o.TradingStatus in ('Prospect','Stocked') -- Exclude currently stopped outlet?
		and i.[Month] is not null

	Union all

	-- State Manager
	select
		aa.[Month],
		aa.[Role],
		aa.[Employee Name],
		aa.[Agency Category],
		aa.[State Manager Latest],
		aa.[Sell Price],
		aa.[Target],
		aa.[Var $],
		aa.[Var %],
		case
			when aa.[Agency Category] = 'H & I' then 
				case 
					when aa.[Var %] >= @HI_SM_OTE_Threshold and aa.[Var %] <= @HI_SM_OTE1_ThresholdMax then @HI_SM_OTE1_Pay
					when aa.[Var %] > @HI_SM_OTE1_ThresholdMax then @HI_SM_OTE2_Pay
					else 0
				end
			when aa.[Agency Category] = 'FC' then 
				case 
					when aa.[Var %] >= @FC_SM_OTE_Threshold and aa.[Var %] <= @FC_SM_OTE1_ThresholdMax then @FC_SM_OTE1_Pay
					when aa.[Var %] > @FC_SM_OTE1_ThresholdMax then @FC_SM_OTE2_Pay
					else 0
				end
		end as [OTE Amount],
		case
			when aa.[Agency Category] = 'H & I' then
				case 
					when aa.[Var %] >= @HI_SM_ATE_Threshold and aa.[Var %] <= @HI_SM_ATE1_ThresholdMax then aa.[Var $] * @HI_SM_ATE1_Pay
					when aa.[Var %] > @HI_SM_ATE1_ThresholdMax then aa.[Var $] * @HI_SM_ATE2_Pay
					else 0
				end
			when aa.[Agency Category] = 'FC' then 
				case 
					when aa.[Var % for FC ATE] >= @FC_SM_ATE_Threshold and aa.[Var % for FC ATE] <= @FC_SM_ATE1_ThresholdMax then aa.[Var $ for FC ATE] * @FC_SM_ATE1_Pay
					when aa.[Var % for FC ATE] > @FC_SM_ATE1_ThresholdMax then aa.[Var $ for FC ATE] * @FC_SM_ATE2_Pay
					else 0
				end
		end as [ATE Amount],
		aa.[Sell Price for FC ATE],
		aa.[Target for FC ATE],
		aa.[Var $ for FC ATE],
		aa.[Var % for FC ATE]
	from
	(--aa
	select
		i.[Month],
		'State Manager' as [Role],
		isnull(o.TerritoryManager,'Unknown') as [Employee Name],
		i.[Agency Category],
		isnull(o.TerritoryManager,'Unknown') as [State Manager Latest],
		sum(i.[Sell Price]) as [Sell Price],
		sum(i.[Target]) as [Target],
		sum(i.[Sell Price for FC ATE]) as [Sell Price for FC ATE],
		sum(i.[Target for FC ATE]) as [Target for FC ATE],
		case 
			when i.[Agency Category] = 'H & I' then sum(i.[Sell Price]) - (sum(i.[Target]) * @HI_SM_ATE_Threshold)
			when i.[Agency Category] = 'FC' then sum(i.[Sell Price]) - (sum(i.[Target]) * @FC_SM_ATE_Threshold)
		end as [Var $],
		case 
			when i.[Agency Category] = 'H & I' then (sum(i.[Sell Price]) - (sum(i.[Target]) * @HI_SM_ATE_Threshold)) / nullif(sum(i.[Target]),0)  + 1
			when i.[Agency Category] = 'FC' then (sum(i.[Sell Price]) - (sum(i.[Target]) * @FC_SM_ATE_Threshold)) / nullif(sum(i.[Target]),0)  + 1
		end as [Var %],
		case 
			when i.[Agency Category] = 'H & I' then 0
			when i.[Agency Category] = 'FC' then sum(i.[Sell Price for FC ATE]) - (sum(i.[Target for FC ATE]) * @FC_SM_ATE_Threshold)
		end as [Var $ for FC ATE],
		case 
			when i.[Agency Category] = 'H & I' then 0
			when i.[Agency Category] = 'FC' then (sum(i.[Sell Price for FC ATE]) - (sum(i.[Target for FC ATE]) * @FC_SM_ATE_Threshold)) / nullif(sum(i.[Target for FC ATE]),0)  + 1
		end as [Var % for FC ATE]
	from 
		#temp_inc_new i
	left join (select distinct o.LatestBDMName, o.TerritoryManager from [db-au-star].dbo.dimOutlet o) as o on o.LatestBDMName = i.[BDM Latest]
	group by
		i.[Month],
		i.[Agency Category],
		o.TerritoryManager
	)as aa
)as bb
where
	(bb.[Agency Category] = @Agency or isnull(@Agency,'All') = 'All') 
	and	((bb.[Employee Name] = @BDMName and bb.[Role] = 'BDM') or isnull(@BDMName,'All') = 'All') 
	and	(bb.[State Manager Latest] = @StateManagerName or isnull(@StateManagerName,'All') = 'All')

End
GO
