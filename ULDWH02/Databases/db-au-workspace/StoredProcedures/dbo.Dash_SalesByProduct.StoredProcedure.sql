USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Dash_SalesByProduct]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Dash_SalesByProduct]
	@DateRange varchar(50),
	@StartDate date,
	@EndDate date
as 
begin
/****************************************************************************************************/
--  Name:           CBA - Dashboard - Sales by Product
--  Author:         Saurabh Date
--  Date Created:   20180822
--  Description:    Data by day for Policies  
--
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20180822 - SD - Created 
--                  
/****************************************************************************************************/
	--DEBUG -- Uncomment to Debug
	
	--DECLARE 	
	--	@DateRange varchar(50) = 'Yesterday',
	--	@StartDate date = null,
	--	@EndDate date = null


	SET NOCOUNT ON; 

	Declare 
		@Start date,
		@End date

	
	--get reporting dates
	if @DateRange = '_User Defined'
		select 
			@Start = @StartDate,
			@End = @EndDate
	else
		select 
			@Start = R.StartDate, 
			@End = R.EndDate
		from 
			[uldwh02].[db-au-cmdwh].dbo.vDateRange R
		where 
			R.DateRange = @DateRange
	

	if object_id('tempdb..#Periods') is not null
		drop table #Periods

	;with DatePeriods 
	 as (
			select 
				'Current Period' as PeriodText, 
				C.Date
			from 
				[ULDWH02].[db-au-cmdwh].dbo.Calendar C
			where 
				C.Date between @Start and @End
			union all
			select 
				'Last Year at Current Period' as PeriodText, 
				C.Date
			from 
				[ULDWH02].[db-au-cmdwh].dbo.Calendar C
			where 
				C.Date between DateAdd(year, -1, @Start) and DateAdd(year, -1, @End)
		 )

	select 
		*
	into 
		#Periods
	from 
		dbo.UDF_ReportingPeriods(@Start, @End, DEFAULT)

	--select * from #Periods

	if object_id('tempdb..#Results') is not null
		drop table #Results

	select	
		C.PeriodText,
		C.Date,
		C.PeriodStartDate,
		C.PeriodEndDate,
		C.PeriodDateNum,
		po.SuperGroupName,
		po.GroupCode,
		po.GroupName,
		po.Subgroupcode,
		Case
			When po.SubGroupName = 'Retail' then 'Activated'
			When po.SubGroupName = 'SalesForce' then 'Comprehensive'
			When po.SubGroupName = 'Websales' then 'Essential'
			When po.SubGroupName = 'Staff' then 'Domestic'
			Else po.SubGroupName
		End SaleType,
		po.AlphaCode,
		po.OutletName, 
		pp.ProductCode,
		Case
			When pp.ProductDisplayName = 'Comprehensive' then 'Gold'
			When pp.ProductDisplayName = 'Medical Only' then 'Platinum'
			Else pp.ProductDisplayName
		End [ProductName],
		Case
			When pp.TripType = 'Annual Multi Trip' then 'Family'
			When pp.TripType = 'Single Trip' then 'Single'
			Else pp.TripType
		End [TravelGroup],
		sum(isnull(pts.BasePolicyCount,0)) [PolicyCount],
		sum(isnull(pts.GrossPremium,0)) [SellPrice],
		(sum(isnull(pts.Commission,0)) + sum(isnull(pts.GrossAdminFee,0))) [Commission],
		(sum(isnull(pts.GrossPremium,0)) - sum(isnull(pts.Commission,0)) - sum(isnull(pts.GrossAdminFee,0))) CostToCBA
	INTO 
		#Results
	from 
		[db-au-cba].dbo.penOutlet po
		inner join [db-au-cba].dbo.penPolicy pp
			on pp.OutletAlphakey = pp.OutletAlphaKey
		inner join [db-au-cba].dbo.penPolicyTransSummary pts
			on pts.PolicyKey = pp.PolicyKey
				and pts.OutletAlphaKey = po.OutletAlphaKey
		right outer join #Periods c
			on pts.PostingDate between c.PeriodStartDate and c.PeriodEndDate
	where 
		po.GroupCode = 'MB'
		and po.OutletStatus = 'Current'
	Group By
		C.PeriodText,
		C.Date,
		C.PeriodStartDate,
		C.PeriodEndDate,
		C.PeriodDateNum,
		po.SuperGroupName,
		po.GroupCode,
		po.GroupName,
		po.Subgroupcode,
		Case
			When po.SubGroupName = 'Retail' then 'Activated'
			When po.SubGroupName = 'SalesForce' then 'Comprehensive'
			When po.SubGroupName = 'Websales' then 'Essential'
			When po.SubGroupName = 'Staff' then 'Domestic'
			Else po.SubGroupName
		End,
		po.AlphaCode,
		po.OutletName, 
		pp.ProductCode,
		Case
			When pp.ProductDisplayName = 'Comprehensive' then 'Gold'
			When pp.ProductDisplayName = 'Medical Only' then 'Platinum'
			Else pp.ProductDisplayName
		End,
		Case
			When pp.TripType = 'Annual Multi Trip' then 'Family'
			When pp.TripType = 'Single Trip' then 'Single'
			Else pp.TripType
		End


	if object_id('tempdb..#SummaryResults') is not null
		drop table #SummaryResults

	select 
		'Summary' as DataType,
		PeriodText,
		PeriodStartDate,
		PeriodEndDate,
		SuperGroupName,
		GroupCode,
		GroupName,
		Subgroupcode,
		SaleType,
		AlphaCode,
		OutletName, 
		ProductCode,
		ProductName,
		TravelGroup,
		sum(PolicyCount) [PolicyCount],
		sum(SellPrice) [SellPrice],
		sum(Commission) [Commission],
		sum(CostToCBA) [CostToCBA]
	INTO 
		#SummaryResults
	from 
		#Results
	GROUP BY
		PeriodText,
		PeriodStartDate,
		PeriodEndDate,
		SuperGroupName,
		GroupCode,
		GroupName,
		Subgroupcode,
		SaleType,
		AlphaCode,
		OutletName, 
		ProductCode,
		ProductName,
		TravelGroup



	insert into 
		#SummaryResults
	select 
		'Summary' DataType,
		'Current Period Variance' as PeriodText,
		null,
		null,
		R.SuperGroupName,
		R.GroupCode,
		R.GroupName,
		R.Subgroupcode,
		R.SaleType,
		R.AlphaCode,
		R.OutletName, 
		R.ProductCode,
		R.ProductName, 
		R.TravelGroup,
		sum(R.PolicyCount) - sum(R2.PolicyCount) [PolicyCount],
		sum(R.SellPrice) - sum(R2.SellPrice) [SellPrice],
		sum(R.Commission) - sum(R2.Commission) [Commission],
		sum(R.CostToCBA) - sum(R2.CostToCBA) [CostToCBA]
	from 
		#Results R
		LEFT JOIN #Results R2 
			on R.SuperGroupName = R2.SuperGroupName
				and R.GroupCode = R2.GroupCode
				and R.GroupName = R2.GroupName
				and R.Subgroupcode = R2.Subgroupcode
				and R.SaleType = R2.SaleType
				and R.AlphaCode = R2.AlphaCode
				and R.OutletName = R2.OutletName
				and R.ProductCode = R2.ProductCode
				and R.ProductName = R2.ProductName
				and R.TravelGroup = R2.TravelGroup
	where 
		R.PeriodText = 'Current Period'
		AND R2.PeriodText = 'Last Year at Current Period'
	GROUP BY 
		R.PeriodText, 
		R.SuperGroupName,
		R.GroupCode,
		R.GroupName,
		R.Subgroupcode,
		R.SaleType,
		R.AlphaCode,
		R.OutletName, 
		R.ProductCode,
		R.ProductName,
		R.TravelGroup

	select 
		* 
	from 
		#SummaryResults

End
GO
