USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0823]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[rptsp_rpt0823]	@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime
as

begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0823
--  Author:         Peter Zhuo
--  Date Created:   20161019
--  Description:    This report is used to track sales force activities, agency sell price and calculate 
--					incentive amount for BDM Damian Triffitt
--					
--  Parameters:     
--                  @DateRange: required. valid date range or _User Defined
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--                  
--  Change History: 
--                  20161019 - PZ - Created
               
/****************************************************************************************************/


--Uncomment to debug
--declare
--    @DateRange varchar(30),
--    @StartDate date,
--    @EndDate date
--select
--    @DateRange = 'Current Month',
--    @StartDate = '2016-05-01',
--    @EndDate = '2016-05-04'


declare
    @rptStartDate datetime,
    @rptEndDate datetime,
    @rptStartDate_SPLY datetime,
    @rptEndDate_SPLY datetime

--get reporting dates
    if @DateRange = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate,
            @rptStartDate_SPLY = dateadd(year,-1,@StartDate),
            @rptEndDate_SPLY = dateadd(year,-1,@EndDate)

    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate,
            @rptStartDate_SPLY = dateadd(year,-1,StartDate),
            @rptEndDate_SPLY = dateadd(year,-1,EndDate)
        from
            vDateRange
        where
            DateRange = @DateRange

declare @sdYTD date -- Current YTD Start
declare @edYTD date -- Current YTD End
declare @sdLY date -- Last Fiscal Year Start
declare @edLY date -- Last Fiscal Year End
set @sdYTD = (select c.YTDFiscalStart from Calendar c where c.[date] = cast(GETDATE() as date))
set @edYTD = (select c.CurMonthStart from Calendar c where c.[date] = cast(GETDATE() as date))
set @sdLY = (select c.LYFiscalYearStart from Calendar c where c.[date] = cast(@rptStartDate as date))
set @edLY = (select c.LYFiscalYearEnd from Calendar c where c.[date] = cast(@rptStartDate as date))

/**********************************************************************************/
-- Only these call categories and subcategories are classed as Sales Call agency visit
IF OBJECT_ID('tempdb..#temp_sfvisit') IS NOT NULL DROP TABLE #temp_sfvisit
create table #temp_sfvisit ([CategoryID] int, [CallCategory] nvarchar(100), [CallSubCategory] nvarchar(100))

insert into #temp_sfvisit select 1, 'Activity - AL Meetings', 'Any'
insert into #temp_sfvisit select 1, 'Activity - AM Call', 'Any'
insert into #temp_sfvisit select 1, 'Activity - In-store visit', 'Any'
insert into #temp_sfvisit select 1, 'Activity - Meetings', 'Any'
insert into #temp_sfvisit select 1, 'Activity - One on One', 'Any'
insert into #temp_sfvisit select 1, 'Activity - TL/ATL', 'Any'
insert into #temp_sfvisit select 1, 'Training - AM/PM Session', 'Any'
insert into #temp_sfvisit select 1, 'Training - Cluster Session', 'Any'
insert into #temp_sfvisit select 2, 'Core', 'Agency Visit'
insert into #temp_sfvisit select 2, 'Focus', 'Agency Visit'
insert into #temp_sfvisit select 2, 'Focus', 'One on One'
insert into #temp_sfvisit select 2, 'Growth', 'One on One'
insert into #temp_sfvisit select 2, 'Sales Call', 'Agency Visit'
insert into #temp_sfvisit select 2, 'Sales Call', 'One on One'
insert into #temp_sfvisit select 2, 'X - Head Office Hours (Do Not Use)', 'Group Training'
insert into #temp_sfvisit select 2, 'X - Head Office Hours (Do Not Use)', 'SWOT Meeting'
insert into #temp_sfvisit select 2, 'X - Sales Call (Do Not Use)', 'Agency Visit'
insert into #temp_sfvisit select 2, 'X - Sales Call (Do Not Use)', 'One on One'
insert into #temp_sfvisit select 2, 'X - Sales Call (Do Not Use)', 'Training'
/**********************************************************************************/

select
	o.SuperGroupName,
	o.GroupName,
	o.SubGroupName,
	a.AccountName,
	o.AlphaCode,
	o.OutletName,
	a.TradingStatus as [Outlet Status],
	[db-au-workspace].[dbo].[fn_cleanexcel](SFlc.[Last Call Comment from SF by Damian]) as [Last Call Comment from SF by Damian],
	SFlc.[Last Call Date from SF by Damian],
	SFlv.[Last Date Visited by Damian],
	SFcall.[Number of SF calls logged by Damian],
	isnull(sp.[SellPrice - Chosen Period],0) as [SellPrice - Chosen Period],
	isnull(sp.[SellPrice - SPLY],0) as [SellPrice - SPLY],
	isnull(sp.[SellPrice - Chosen Period],0) - isnull(sp.[SellPrice - SPLY],0) as [TY Sales Above LY],
	(isnull(sp.[SellPrice - Chosen Period],0) - isnull(sp.[SellPrice - SPLY],0)) * 0.01 as [1% of TY Sales Above LY],
	isnull(sp.[SellPrice - YTD],0) as [SellPrice - YTD],
	isnull(sp.[SellPrice - FY16],0) as [SellPrice - FY16]
from [dbo].[sfAccount] a
inner join penoutlet o on o.CountryKey = left(a.AgencyID,2) and o.AlphaCode = a.AlphaCode and o.OutletStatus = 'current'
outer apply
	(-- SFlc
	select top 1
		a_c.CallComment as [Last Call Comment from SF by Damian], -- last non-blank comment from SF
		a_c.CallStartTime as [Last Call Date from SF by Damian]
	from [dbo].[sfAgencyCall] a_c
	where
		a_c.CreatedBy like '%Damian%Triffitt%'
		and isnull(a_c.CallComment,'') <> ''
		and a_c.AccountID = a.AccountID
	order by
		a_c.CallStartTime desc
	) as SFlc
outer apply
	(-- SFlv
	select top 1
		a_c.CallStartTime as [Last Date Visited by Damian]
	from [dbo].[sfAgencyCall] a_c
	inner join (select distinct sfv.CategoryID, sfv.CallCategory, sfv.CallSubCategory from #temp_sfvisit sfv) as sfv 
	on 
		(sfv.CallCategory = a_c.CallCategory and sfv.CategoryID = 1) 
			or 
		(sfv.CallCategory = a_c.CallCategory and sfv.CallSubCategory = a_c.CallSubCategory and sfv.CategoryID = 2)
	where
		a_c.CreatedBy like '%Damian%Triffitt%'
		and a_c.AccountID = a.AccountID
	order by
		a_c.CallStartTime desc
	) as SFlv
outer apply
	(-- SFcall
	select
		count(a_c.CallID) as [Number of SF calls logged by Damian]
	from [dbo].[sfAgencyCall] a_c
	where
		a_c.CreatedBy like '%Damian%Triffitt%'
		and a_c.AccountID = a.AccountID
	) as SFcall
outer apply
	(-- SP
	select
		sum(case when a_pts.PostingDate >= @rptStartDate and a_pts.PostingDate < dateadd(day,1,@rptEndDate) then a_pts.GrossPremium else 0 end) as [SellPrice - Chosen Period],
		sum(case when a_pts.PostingDate >= @rptStartDate_SPLY and a_pts.PostingDate < dateadd(day,1,@rptEndDate_SPLY) then a_pts.GrossPremium else 0 end) as [SellPrice - SPLY],
		sum(case when a_pts.PostingDate >= @sdYTD and a_pts.PostingDate < dateadd(day,1,@edYTD) then a_pts.GrossPremium else 0 end) as [SellPrice - YTD],
		sum(case when a_pts.PostingDate >= @sdLY and a_pts.PostingDate < dateadd(day,1,@edLY) then a_pts.GrossPremium else 0 end) as [SellPrice - FY16]
	from penPolicyTransSummary a_pts
	where
		a_pts.OutletAlphaKey = o.OutletAlphaKey
	) as SP
where
	SFcall.[Number of SF calls logged by Damian] > 0
	and a.AccountName not in ('test')


order by o.AlphaCode

end
GO
