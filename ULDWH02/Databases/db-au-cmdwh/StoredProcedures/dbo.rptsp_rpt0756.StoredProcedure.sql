USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0756]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0756]
	@Country nvarchar(5),
    @ReportingPeriod varchar(30),
    @StartDate date,
    @EndDate date,
	@MinPayment int
as 


/****************************************************************************************************/
--  Name:          rptsp_rpt0756
--  Author:        Peter Zhuo
--  Date Created:  20160322
--  Description:   This stored procedure shows claims payment for Customer Care cases that are initially denied but then overturned at IDR 
--				   level if the decision is disputed.
--
--
--                 20160322, PZ, T23113, stored procedure created

/****************************************************************************************************/


--uncomment to debug
--declare
--	@Country nvarchar(5),
--	@MinPayment int,
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date
--select
--	@Country = 'AU',
--	@MinPayment = 15000,

--    @ReportingPeriod = 'Current Fiscal Year',
--    @StartDate = null,
--    @EndDate = null

--------------------------------------------------------------

set nocount on

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


--------------------------------------------------------------

select
@rptStartDate as [Report Start Date],
@rptEndDate as [Report End Date],
c.CountryKey as [Country],
w.ClaimNumber,
w.Reference as [e5 Reference],
e.CaseID as [Customer/C #],
e.EventDesc as [Claim Description],
c.CreateDate as [Claim Registration Date],
w.CreationDate as [IDR Registration Date],
decl.[Initial Declined Count], -- include the declined count in the report but don't use it as a filter because complaints don't have to be declined to be escalated to IDR
idro.IDROutcome,
pp.[Payment post IDR],
ep.[Total Estimate],
ep.[Total Paid],
isnull(ep.[Total Estimate],0) + isnull(ep.[Total Paid],0) as [Total Claim Value]
from e5work w
inner join clmClaim c on w.ClaimKey = c.ClaimKey
inner join clmEvent e on e.ClaimKey = c.ClaimKey
outer apply
	(
	select
		sum(oac.[Declined Count]) as [Initial Declined Count]
	from vClaimPortfolio oac
	where
		oac.ClaimKey = w.ClaimKey
	) as decl
outer apply
    (-- idro
        select top 1
            wi.Name as IDROutcome
        from e5WorkActivity oawa
        inner join e5WorkActivityProperties oawap on oawap.Work_ID = oawa.Work_ID and oawap.WorkActivity_ID = oawa.ID
        inner join e5WorkItems wi on wi.ID = oawap.PropertyValue
        where
            oawa.Work_ID = w.Work_ID 
			and oawa.CategoryActivityName = 'IDR Outcome'
        order by
            oawa.CompletionDate desc
    ) as idro
outer apply
	(-- pp
	select
		sum(oap.PaymentAmount) as [Payment post IDR]
	from clmPayment oap
	where
		oap.ClaimKey = w.ClaimKey
		and oap.PaymentStatus = 'PAID'
		and oap.ModifiedDate >= w.CreationDate
	) as pp
outer apply
	(
	select
		sum(oas.EstimateValue) as [Total Estimate],
		sum(pp.[PaymentAmount]) as [Total Paid]
	from clmSection oas
		outer apply
			(
			select
				oap.PaymentAmount
			from clmpayment oap 
			where
				oap.ClaimKey = oas.ClaimKey
				and oap.SectionKey = oas.SectionKey
				and oap.PaymentStatus = 'PAID'
				and oap.isDeleted = 0
			)as pp
	where
		oas.ClaimKey = w.ClaimKey
		and oas.isDeleted = 0
	)as ep
where
	w.Country = @Country
	and w.GroupType = 'IDR'
	and (w.CreationDate >=  @rptStartDate and w.CreationDate < dateadd(day,1,@rptEndDate))
	and (e.CaseID <> '' and e.CaseID <> '0' and e.CaseID is not null) -- Customer Care cases related
	and w.ClaimKey is not null
	and idro.IDROutcome not in ('Upheld') -- IDR outcome could be overturned or Partially Maintained
	and pp.[Payment post IDR] >= @MinPayment




GO
