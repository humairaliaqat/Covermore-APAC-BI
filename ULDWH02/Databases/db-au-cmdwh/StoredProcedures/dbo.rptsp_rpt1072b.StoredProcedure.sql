USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1072b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt1072b]	 @DateRange varchar(30),
									 @StartDate datetime,
									 @EndDate datetime
as

/****************************************************************************************************/
--  Name:				dbo.rptsp_rpt1072b
--  Author:				Linus Tor
--  Date Created:		20190722
--  Description:		Returns UK policy and primary customers only
--					
--  Parameters:     
--						@DateRange: required. valid date range or _User Defined
--						@StartDate: optional. required if date range = _User Defined
--						@EndDate: optional. required if date range = _User Defined
--                  
--  Change History:
--		20190722 - LT - Stored procedure created
--
/****************************************************************************************************/

SET NOCOUNT ON

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
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
	o.SuperGroupName,
	o.GroupName,
	o.SubGroupName,
	o.OutletName as AgencyName,
	o.AlphaCode,
	p.PolicyNumber,
	p.IssueDate,
	p.ProductDisplayName as ProductName,
	p.PlanDisplayName as PlanName,	
	isnull(pr.BasePremiumExclIPT,0) - isnull(pa.EMCPremium,0) - isnull(pa.OtherAddonPremium,0) as BasePremiumExclIPT,
	pa.EMCPremium as EMCPremium,
	pa.OtherAddonPremium as OtherAddonPremium,
	pr.GrossPremiumExclIPT,
	pr.IPT,
	pr.GrossPremiumInclIPT,
	pr.TravellerCount,
	ptr.PolicyTravellerID,
	ptr.FirstName + ' ' + ptr.LastName as CustomerName,
	ptr.isPrimary,
	ptr.Age,
	ptr.AddressLine1 + ' ' + ptr.AddressLine2 + ' ' + ptr.Suburb as CustomerAddress,
	ptr.PostCode as CustomerPostcode,
	pr.NumberOfAdults,
	pr.NumberOfChildren,
	p.TripDuration as TravelDuration,
	p.TripStart as DepartureDate,
	p.TripEnd as ReturnDate,
	p.AreaName as AreaOfTravel,
	p.PrimaryCountry as CountryOfTravel,
	p.Excess as Excess,
	ad.AddOnGroup,
	sum((case when isnull(ad.AddonGroup,'') > '' then 1 else 0 end)) as AddonCount,
	@rptStartDate as StartDate,
	@rptEndDate as EndDate
from
	[db-au-cmdwh].dbo.penPolicy p
	inner join [db-au-cmdwh].dbo.penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	inner join [db-au-cmdwh].dbo.penPolicyTraveller ptr on p.PolicyKey = ptr.PolicyKey
	outer apply													--get EMC premium / addon
	(
		select 
			sum(case when AddonGroup = 'Medical' then pta.GrossPremium else 0 end) as EMCPremium,
			sum(case when AddonGroup <> 'Medical' then pta.GrossPremium else 0 end) as OtherAddonPremium
		from 
			[db-au-cmdwh].dbo.penPolicyTransSummary pts
			inner join [db-au-cmdwh].dbo.penPolicyTransAddon pta on pts.PolicyTransactionKey = pta.PolicyTransactionKey
		where
			pts.PolicyKey = p.PolicyKey
	) pa
	outer apply													--get other metrics
	(
		select			
			(isnull(sum(ppp.[Sell Price (excl GST)]),0)) as BasePremiumExclIPT,
			isnull(sum(ppp.[GST on Sell Price]),0) as IPT,
			isnull(sum(ppp.[Sell Price (excl GST)]),0) as GrossPremiumExclIPT,
			isnull(sum(ppp.[Sell Price]),0) as GrossPremiumInclIPT,
			isnull(sum(pts.TravellersCount),0) as TravellerCount,
			sum(pts.AdultsCount) as NumberOfAdults,
			sum(pts.ChildrenCount) as NumberOfChildren
		from
			[db-au-cmdwh].dbo.penPolicyTransSummary pts
			inner join [db-au-cmdwh].dbo.vPenguinPolicyPremiums ppp on pts.PolicyTransactionKey = ppp.PolicyTransactionKey
		where
			pts.PolicyKey = p.PolicyKey
	) pr	
	outer apply													--get addon group
	(
		select a.AddonGroup
		from 
			[db-au-cmdwh].dbo.penPolicyTransAddOn a
			inner join [db-au-cmdwh].dbo.penPolicyTransSummary pts on a.PolicyTransactionKey = pts.PolicyTransactionKey
		where
			pts.PolicyKey = p.PolicyKey
	) ad
where
	p.PolicyKey in (select PolicyKey from #policy) and
	ptr.isPrimary = 1
group by
	o.SuperGroupName,
	o.GroupName,
	o.SubGroupName,
	o.OutletName,
	o.AlphaCode,
	p.PolicyNumber,
	p.IssueDate,
	p.ProductDisplayName,
	p.PlanDisplayName,	
	pr.BasePremiumExclIPT,
	pa.EMCPremium,
	pa.OtherAddonPremium,
	pr.GrossPremiumExclIPT,
	pr.IPT,
	pr.GrossPremiumInclIPT,
	pr.TravellerCount,
	ptr.PolicyTravellerID,
	ptr.FirstName + ' ' + ptr.LastName,
	ptr.isPrimary,
	ptr.Age,
	ptr.AddressLine1 + ' ' + ptr.AddressLine2 + ' ' + ptr.Suburb,
	ptr.Postcode,
	pr.NumberOfAdults,
	pr.NumberOfChildren,
	p.TripDuration,
	p.TripStart,
	p.TripEnd,
	p.AreaName,
	p.PrimaryCountry,
	p.Excess,
	ad.AddOnGroup
order by
	p.PolicyNumber,
	ptr.PolicyTravellerID


GO
