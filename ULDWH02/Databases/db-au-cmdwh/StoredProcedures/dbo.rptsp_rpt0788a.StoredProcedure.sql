USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0788a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0788a] 
@DashboardMonth varchar(30),
@StartDate date,
@EndDate date

as

Begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0788a
--  Author:         Peter Zhuo
--  Date Created:   20160706
--  Description:    This stored procedure provides a few key claim metrics drilled down to benefit category level.
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  
--  Change History: 
--                  20160706	-	PZ	-	Created
--
/****************************************************************************************************/

set nocount on

--Uncomment to debug
--declare
--    @DashboardMonth varchar(30),
--    @StartDate date,
--    @EndDate date

--select
--    @DashboardMonth = 'Last June',
--    @StartDate = '2016-05-01',
--    @EndDate = '2016-05-04'



declare
    @rptStartDate datetime,
    @rptEndDate datetime,
    @rptStartDate_LY datetime,
    @rptEndDate_LY datetime

--get reporting dates
    if @DashboardMonth = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate,
			@rptStartDate_LY = dateadd(year,-1,@rptStartDate),
			@rptEndDate_LY = dateadd(year,-1,@rptEndDate)
    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate,
			@rptStartDate_LY = dateadd(year,-1,@rptStartDate),
			@rptEndDate_LY = dateadd(day,-1,dateadd(year,-1,dateadd(month,1,(DATEADD(month, DATEDIFF(month, 0, @rptEndDate), 0))))) -- This is to handle leap year correctly. 
																												   -- The assumption is if a preset period is selected, the user wants to compare whole month this year vs last year. For leap year this comparison would mean 29days vs 28days.
																												   -- If a custom period (_User Defined) is selected, the user wants to compare the exact same period this year vs last year.
        from
            vDateRange
        where
            DateRange = @DashboardMonth

--select @rptStartDate
--select @rptEndDate

--select @rptStartDate_LY
--select @rptEndDate_LY
----------------------------------------------------------


IF OBJECT_ID('tempdb..#temp_a') IS NOT NULL DROP TABLE #temp_a
select
	vb.OperationalBenefitGroup,
	sum(c.PaymentDelta) as [Paid]
into #temp_a
from 
	vclmClaimSectionIncurred c
left join clmSection s on s.SectionKey = c.SectionKey
left join vclmBenefitCategory vb on vb.BenefitSectionKey = s.BenefitSectionKey
where
	s.CountryKey = 'AU' and
	c.IncurredDate >= @rptStartDate and c.IncurredDate < dateadd(day, 1, @rptEndDate)
group by
	vb.OperationalBenefitGroup


IF OBJECT_ID('tempdb..#temp_a_LY') IS NOT NULL DROP TABLE #temp_a_LY
select
	vb.OperationalBenefitGroup,
	sum(c.PaymentDelta) as [Paid]
into #temp_a_LY
from 
	vclmClaimSectionIncurred c
left join clmSection s on s.SectionKey = c.SectionKey
left join vclmBenefitCategory vb on vb.BenefitSectionKey = s.BenefitSectionKey
where
	s.CountryKey = 'AU' and
	c.IncurredDate >= @rptStartDate_LY and c.IncurredDate < dateadd(day, 1, @rptEndDate_LY)
group by
	vb.OperationalBenefitGroup

	
select
	aa.OperationalBenefitGroup,
	a.Paid,
	aa.[Estimates Balance],
	a.Paid + aa.[Estimates Balance] as [Total Incurred Balance],
	aa.[Estimates Balance LY],
	a_LY.Paid as [Paid LY],
	a_LY.Paid + aa.[Estimates Balance LY] as [Total Incurred Balance LY],
	@DashboardMonth as [ReportingPeriod],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate]
from
	(--aa
	select distinct
		mvb.OperationalBenefitGroup,
		est.[Estimates Balance],
		est_LY.[Estimates Balance] as [Estimates Balance LY]
	from 
		vclmBenefitCategory mvb
	outer apply
		(-- est
		select
			sum(c.EstimateMovement) as [Estimates Balance]
		from 
			clmClaimEstimateMovement c
		left join clmSection s on s.SectionKey = c.SectionKey
		left join vclmBenefitCategory vb on vb.BenefitSectionKey = s.BenefitSectionKey
		where
			c.ClaimKey like 'AU%' and
			c.[EstimateDate] < dateadd(day, 1, @rptEndDate) and
			vb.OperationalBenefitGroup = mvb.OperationalBenefitGroup
		) as est
	outer apply
		(-- est_LY
		select
			sum(c.EstimateMovement) as [Estimates Balance]
		from 
			clmClaimEstimateMovement c
		left join clmSection s on s.SectionKey = c.SectionKey
		left join vclmBenefitCategory vb on vb.BenefitSectionKey = s.BenefitSectionKey
		where
			c.ClaimKey like 'AU%' and
			c.[EstimateDate] < dateadd(day, 1, @rptEndDate_LY) and
			vb.OperationalBenefitGroup = mvb.OperationalBenefitGroup
		) as est_LY
	)as aa
left join #temp_a a on a.OperationalBenefitGroup = aa.OperationalBenefitGroup
left join #temp_a_LY a_LY on a_LY.OperationalBenefitGroup = aa.OperationalBenefitGroup

End
GO
