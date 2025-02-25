USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_UKCustomerDataAll]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[tmp_rptsp_UKCustomerDataAll] @DateRange varchar(30),
												 @StartDate datetime,
											     @EndDate datetime
as

SET NOCOUNT ON


--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = '_User Defined', @StartDate = '2019-01-01', @EndDate = '2019-02-28'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

/* get reporting dates */
if @DateRange = '_User Defined'
	select  @rptStartDate = @StartDate,
		@rptEndDate = @EndDate
else
	select	@rptStartDate = StartDate, 
		@rptEndDate = EndDate
	from	[db-au-cmdwh].dbo.vDateRange
	where	DateRange = @DateRange;

if object_id('tempdb..#policy') is not null drop table #policy
select distinct
	p.PolicyKey
into #policy
from
	[db-au-cmdwh].dbo.penPolicy p
	inner join [db-au-cmdwh].dbo.penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
where
	p.CountryKey= 'UK' and
	p.StatusDescription = 'Active' and
	p.IssueDate >= @rptStartDate and
	p.IssueDate < dateadd(d,1,@rptEndDate)


select
	p.PolicyNumber,
	p.IssueDate,
	ptr.PolicyTravellerID,
	ptr.FirstName + ' ' + ptr.LastName as CustomerName,
	ptr.isPrimary,
	ptr.AddressLine1 + ' ' + ptr.AddressLine2 + ' ' + ptr.Suburb as CustomerAddress,
	case when ptr.isAdult = 1 then 1 else 0 end as NumberOfAdults,
	case when ptr.isAdult = 0 then 1 else 0 end as NumberOfChildren,
	ptr.Age as CustomerAge,
	p.TripDuration as TravelDuration,
	p.TripStart as DepartureDate,
	p.TripEnd as ReturnDate,
	p.AreaName as AreaOfTravel,
	p.PrimaryCountry as CountryOfTravel,
	p.Excess as Excess,
	emc.EMCScore,
	ad.AddOnGroup,
	@rptStartDate as StartDate,
	@rptEndDate as EndDate
from
	[db-au-cmdwh].dbo.penPolicy p
	inner join [db-au-cmdwh].dbo.penPolicyTraveller ptr on p.PolicyKey = ptr.PolicyKey
	outer apply
	(
		select
			sum(e.MedicalRisk) as EMCScore
		from
			[db-au-cmdwh].dbo.penPolicyTransaction ptrans 
			inner join [db-au-cmdwh].dbo.penPolicyTravellerTransaction ptt on ptrans.PolicyTransactionKey = ptt.PolicyTransactionKey
			inner join [db-au-cmdwh].dbo.penPolicyEMC pe on ptt.PolicyTravellerTransactionKey = pe.PolicyTravellerTransactionKey
			inner join [db-au-cmdwh].dbo.penPolicyTraveller ptrav on ptt.PolicyTravellerKey = ptrav.PolicyTravellerKey
			inner join [db-au-cmdwh].dbo.emcApplications e on pe.EMCApplicationKey = e.ApplicationKey
		where
			ptrans.PolicyKey = p.PolicyKey and
			ptrav.PolicyTravellerKey = ptr.PolicyTravellerKey
	) emc
	outer apply
	(
		select a.AddonGroup
		from 
			[db-au-cmdwh].dbo.penPolicyTransAddOn a
			inner join [db-au-cmdwh].dbo.penPolicyTransSummary pts on a.PolicyTransactionKey = pts.PolicyTransactionKey
		where
			pts.PolicyKey = p.PolicyKey
	) ad
where
	--p.PolicyKey = 'UK-CM11-2195663'
	p.PolicyKey in (select PolicyKey from #policy)
order by
	p.PolicyKey,
	ptr.PolicyTravellerID


GO
