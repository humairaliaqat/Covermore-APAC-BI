USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0813]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0813]	
									@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime
as
begin

    SET NOCOUNT ON


    /****************************************************************************************************/
    --  Name:           dbo.rptsp_rpt0813
    --  Author:         Saurabh Date
    --  Date Created:   20171017
    --  Description:    Returns IAG Traveller extract details
    --					
    --  Parameters:     
    --                  @DateRange: required. valid date range or _User Defined
    --                  @StartDate: optional. required if date range = _User Defined
    --                  @EndDate: optional. required if date range = _User Defined
    --                  
    --  Change History: 
    --                  20171017 - SD - Created

    /****************************************************************************************************/


    --uncomment to debug
    /*
    declare @DateRange varchar(30)
    declare @StartDate datetime
    declare @EndDate datetime
    select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
    */


     /* get reporting dates */
    if @DateRange <> '_User Defined'
        select 
            @StartDate = StartDate, 
            @EndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @DateRange

--Fetch policy count for all IAG NZ customers
IF OBJECT_ID('tempdb..#policycount') IS NOT NULL DROP TABLE #policycount
select 
	(pt2.FirstName + ' ' + pt2.LastName) CustomerName,
	pt2.DOB,
	count(pp2.PolicyKey) AllPolicyCount
Into
	#policycount
from
	[db-au-cmdwh].dbo.penPolicy pp2 with(nolock)
	inner join [db-au-cmdwh].dbo.penPolicyTraveller pt2 with(nolock) on
		pp2.PolicyKey = pt2.PolicyKey
	inner join [db-au-cmdwh].dbo.penOutlet po2 with(nolock) on
		pp2.OutletAlphaKey = po2.OutletAlphaKey and po2.OutletStatus = 'Current'
Where
	po2.CountryKey = 'NZ' and
	po2.SuperGroupName = 'IAG NZ' and
	pp2.StatusDescription = 'Active'
Group BY
	(pt2.FirstName + ' ' + pt2.LastName),
	pt2.DOB


--Fetch Channel wise policy count for all IAG NZ customers
IF OBJECT_ID('tempdb..#channelpolicycount') IS NOT NULL DROP TABLE #channelpolicycount
select 
	(pt2.FirstName + ' ' + pt2.LastName) CustomerName,
	pt2.DOB,
	po2.Channel,
	count(pp2.PolicyKey) ChannelPolicyCount
Into
	#channelpolicycount
from
	[db-au-cmdwh].dbo.penPolicy pp2 with(nolock)
	inner join [db-au-cmdwh].dbo.penPolicyTraveller pt2 with(nolock) on
		pp2.PolicyKey = pt2.PolicyKey
	inner join [db-au-cmdwh].dbo.penOutlet po2 with(nolock) on
		pp2.OutletAlphaKey = po2.OutletAlphaKey and po2.OutletStatus = 'Current'
Where
	po2.CountryKey = 'NZ' and
	po2.SuperGroupName = 'IAG NZ' and
	pp2.StatusDescription = 'Active'
Group BY
	(pt2.FirstName + ' ' + pt2.LastName),
	pt2.DOB,
	po2.Channel

--Fetch Destination wise counts for all IAG NZ Customers
IF OBJECT_ID('tempdb..#destinationgroup') IS NOT NULL DROP TABLE #destinationgroup
select 
	(pt.FirstName + ' ' + pt.LastName) CustomerName,
	pt.DOB,
	sum(1) AllCount,
	sum
	(
		case
			when p.CountryKey = 'AU' and p.PrimaryCountry = 'Australia' then 1
			when p.CountryKey = 'NZ' and p.PrimaryCountry = 'New Zealand' then 1
			else 0
		end 
	) LocalCount,
	sum
	(
		case
			when p.PrimaryCountry like '%cruise%' then 1
			when isnull(pta.CruisePremium, 0) > 0 then 1
			else 0
		end 
	) CruiseCount,
	count
	(
		distinct
		case
			when p.CountryKey = 'AU' and p.PrimaryCountry = 'Australia' then null
			when p.CountryKey = 'NZ' and p.PrimaryCountry = 'New Zealand' then null
			else p.PrimaryCountry
		end 
	) DestinationCount,
	sum
	(
		case
			when co.Continent = 'Africa' then 1
			else 0
		end
	) AfricaCount,
	sum
	(
		case
			when co.Continent = 'Asia' then 1
			else 0
		end
	) AsiaCount,
	sum
	(
		case
			when co.Continent = 'Europe' then 1
			else 0
		end
	) EuropeCount,
	sum
	(
		case
			when co.Continent = 'Oceania' then 1
			when co.Continent = 'Antarctica' then 1
			else 0
		end
	) OceaniaCount,
	sum
	(
		case
			when co.Continent = 'North America' then 1
			when co.Continent = 'South America' then 1
			else 0
		end
	) AmericaCount
Into
	#destinationgroup
from
	[db-au-cmdwh].dbo.penPolicy p with(nolock)
	inner join [db-au-cmdwh].dbo.penPolicyTraveller pt with(nolock) on
		pt.PolicyKey = p.PolicyKey
	inner join penOutlet po4 with(nolock) on
		po4.OutletAlphaKey = p.OutletAlphaKey and po4.OutletStatus = 'Current'
	outer apply
	(
		select top 1 
			dd.Continent
		from
			[db-au-star].dbo.dimPolicy dp with(nolock)
			inner join [db-au-star].dbo.factPolicyTransaction fpt with(nolock) on
				fpt.PolicySK = dp.PolicySK
			inner join [db-au-star].dbo.dimDestination dd with(nolock) on
				dd.DestinationSK = fpt.DestinationSK
		where
			dp.PolicyKey = p.PolicyKey
	) co
	outer apply
	(
		select
			sum(pta.GrossPremium) CruisePremium
		from
			[db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
			inner join [db-au-cmdwh].dbo.penPolicyTransAddOn pta with(nolock) on
				pta.PolicyTransactionKey = pt.PolicyTransactionKey
		where
			pt.PolicyKey = p.PolicyKey and
			pta.AddOnGroup = 'Cruise'
	) pta
where
	p.StatusDescription = 'Active' and
	po4.CountryKey = 'NZ' and
	po4.SuperGroupName = 'IAG NZ'
Group By
	(pt.FirstName + ' ' + pt.LastName),
	pt.DOB


--Fetch product preference related metrics for all IAG NZ Customers
IF OBJECT_ID('tempdb..#productpreference') IS NOT NULL DROP TABLE #productpreference
select 
	(pt.FirstName + ' ' + pt.LastName) CustomerName,
	pt.DOB,
	sum(1) AllPolicyCount,
	sum(isnull(PromoCount, 0)) PromoCount,
	sum(isnull(ValueCount, 0)) ValueCount,
	sum(isnull(BusinessCount, 0)) BusinessCount,
	sum(isnull(PremiumCount, 0)) PremiumCount
Into
	#productpreference
from
	[db-au-cmdwh].dbo.penPolicy p with(nolock)
	inner join [db-au-cmdwh].dbo.penPolicyTraveller pt with(nolock) on
		pt.PolicyKey = p.PolicyKey
	inner join penOutlet po5 with(nolock) on
		po5.OutletAlphaKey = p.OutletAlphaKey and po5.OutletStatus = 'Current'
	outer apply
	(
		select top 1 
			1 PromoCount
		from
			[db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
		where
			pt.PolicyKey = p.PolicyKey and
			(
				pt.isPriceBeat = 1 or
				pt.isExpo = 1 or
				pt.GrossPremium < pt.UnAdjGrossPremium or
				exists
				(
					select
						null
					from
						[db-au-cmdwh].dbo.penPolicyTransactionPromo ptp with(nolock)
					where
						ptp.PolicyTransactionKey = pt.PolicyTransactionKey and
						ptp.IsApplied = 1
				)
			)
	) pp
	outer apply
	(
		select top 1 
			case 
				when dpr.ProductClassification = 'Value' then 1 
				else 0 
			end ValueCount,
			case 
				when dpr.ProductClassification = 'Business' then 1 
				when dpr.ProductClassification = 'Corporate' then 1
				else 0 
			end BusinessCount,
			case 
				when dpr.ProductClassification = 'Comprehensive' then 1 
				else 0 
			end PremiumCount,
			case 
				when dpr.ProductClassification = 'Value' then 0
				when dpr.ProductClassification = 'Business' then 0
				when dpr.ProductClassification = 'Corporate' then 0
				when dpr.ProductClassification = 'Comprehensive' then 0
				else 1
			end AverageJoeCount
		from
			[db-au-star].dbo.dimPolicy dp with(nolock)
			inner join [db-au-star].dbo.factPolicyTransaction fpt with(nolock) on
				fpt.PolicySK = dp.PolicySK
			inner join [db-au-star].dbo.dimProduct dpr with(nolock) on
				dpr.ProductSK = fpt.ProductSK
		where
			dp.PolicyKey = p.PolicyKey and
			dpr.ProductClassification = 'Value'
	) pv
where
	p.StatusDescription = 'Active' and
	po5.CountryKey = 'NZ' and
	po5.SuperGroupName = 'IAG NZ'
Group By
	(pt.FirstName + ' ' + pt.LastName),
	pt.DOB


--Fetch Travel group related metrics for all IAG NZ Customers
IF OBJECT_ID('tempdb..#travelgroup') IS NOT NULL DROP TABLE #travelgroup
select
	(pt.FirstName + ' ' + pt.LastName) CustomerName,
	pt.DOB,
	sum(1) AllCount,
	sum
	(
		case
			when 
				isnull(TravellersCount, 0) > 1 and
				isnull(TravellersCount, 0) = isnull(AdultsCount, 0) 
			then 1
			else 0
		end
	) FamilyCount,
	sum
	(
		case
			when 
				isnull(TravellersCount, 0) > 1 and
				isnull(AdultsCount, 0) > 0 and
				isnull(ChildrenCount, 0) > 0
			then 1
			else 0
		end
	) FamilyKidsCount,
	sum
	(
		case
			when 
				isnull(TravellersCount, 0) = 2 and
				isnull(TravellersCount, 0) = isnull(AdultsCount, 0) 
			then 1
			else 0
		end
	) CoupleCount,
	sum
	(
		case
			when 
				isnull(TravellersCount, 0) = 1 and
				isnull(TravellersCount, 0) = isnull(AdultsCount, 0) 
			then 1
			else 0
		end
	) SingleCount,
	sum
	(
		case
			when isnull(TravellersCount, 0) >= 10 then 1
			else 0
		end
	) GroupCount
Into
	#travelgroup
from
	[db-au-cmdwh].dbo.penPolicyTransSummary p with(nolock)
	inner join [db-au-cmdwh].dbo.penPolicyTraveller pt with(nolock) on
		pt.PolicyKey = p.PolicyKey
	inner join penOutlet po with(nolock) on
		po.OutletAlphaKey = p.OutletAlphaKey and po.OutletStatus = 'Current'
where
	p.TransactionType = 'Base' and 
	p.TransactionStatus = 'Active' and
	po.CountryKey = 'NZ' and
	po.SuperGroupName = 'IAG NZ'
Group By
	(pt.FirstName + ' ' + pt.LastName),
	pt.DOB

--Fetch Travel Pattern related metrics for all IAG NZ Customers
IF OBJECT_ID('tempdb..#travelpattern') IS NOT NULL DROP TABLE #travelpattern
select
	(pt.FirstName + ' ' + pt.LastName) CustomerName,
	pt.DOB,
	sum(1) AllCount,
	sum
	(
		case
			when datediff(day, p.IssueDate, p.TripStart) >= 214 then 1 --Pricing group 5, 6+ months
			else 0
		end 
	) LongLeadTimeCount
Into
	#travelpattern
from
	[db-au-cmdwh].dbo.penPolicy p with(nolock)
	inner join [db-au-cmdwh].dbo.penPolicyTraveller pt with(nolock) on
		pt.PolicyKey = p.PolicyKey
	inner join penOutlet po with(nolock) on
		po.OutletAlphaKey = p.OutletAlphaKey and po.OutletStatus = 'Current'
where
	p.StatusDescription = 'Active' and
	po.CountryKey = 'NZ' and
	po.SuperGroupName = 'IAG NZ'
Group By
	(pt.FirstName + ' ' + pt.LastName),
	pt.DOB


--Fetch RiskProfile for all IAG NZ Customers
IF OBJECT_ID('tempdb..#riskprofile') IS NOT NULL DROP TABLE #riskprofile
select 
	distinct
	(pt.FirstName + ' ' + pt.LastName) CustomerName,
	pt.DOB,
    case
        when isnull(BlockScore, 0) > 0 then 'Blocked'
        when ec.ClaimScore >= 3000 then 'Very high risk'
        when ec.ClaimScore >= 500 then 'High risk'
        when ec.ClaimScore >= 10 then 'Medium risk'
        when ec.PrimaryScore >= 5000 then 'Very high risk'
        when ec.SecondaryScore >= 6000 then 'Very high risk by association'
        when ec.PrimaryScore >= 3000 then 'High risk'
        when ec.SecondaryScore >= 4000 then 'High risk by association'
        when ec.PrimaryScore > 1500 then 'Medium risk'
        when ec.SecondaryScore > 2000 then 'Medium risk by association'
        else 'Low risk'
    end ClaimRiskProfile
Into
	#riskprofile
from
    [db-au-cmdwh].dbo.penPolicy p with(nolock)
	inner join [db-au-cmdwh].dbo.penPolicyTraveller pt with(nolock) on
		pt.PolicyKey = p.PolicyKey
	inner join penOutlet po with(nolock) on
		po.OutletAlphaKey = p.OutletAlphaKey and po.OutletStatus = 'Current'
	Outer apply
	(
		select
			e.CustomerName,
			e.DOB,
			Sum(ClaimScore) ClaimScore,
			Sum(PrimaryScore) PrimaryScore,
			Sum(SecondaryScore) SecondaryScore
		From 
			entCustomer e
		Where
			e.CustomerName = (pt.FirstName + ' ' + pt.LastName) and
			e.DOB = pt.DOB
		Group By
			e.CustomerName,
			e.DOB
	) ec
    outer apply
    (
        select top 1 
            9001 BlockScore,
            1 BlockFlag
        from
            [db-au-cmdwh]..entBlacklist bl
        where
            bl.SurName = pt.LastName and
			bl.Given = pt.FirstName and
			bl.DOB = pt.DOB
    ) bl
where
	p.StatusDescription = 'Active' and
	po.CountryKey = 'NZ' and
	po.SuperGroupName = 'IAG NZ'


--Fetch Brand Affiliation related metrics for all IAG NZ Customers
IF OBJECT_ID('tempdb..#brandaffiliation') IS NOT NULL DROP TABLE #brandaffiliation
select 
	(pt.FirstName + ' ' + pt.Lastname) CustomerName,
	pt.DOB,
    sum(1) AllCount,
    sum
    (
        case
            when o.SuperGroupName = 'IAG NZ' then 1
            else 0
        end 
    ) IAGCount,
    count(distinct o.SuperGroupName) BrandCount
Into
	#brandaffiliation
from
    [db-au-cmdwh].dbo.penPolicy p with(nolock)
		inner join [db-au-cmdwh].dbo.penPolicyTraveller pt with(nolock) on
			pt.PolicyKey = p.PolicyKey
		inner join penOutlet o with(nolock) on
			o.OutletAlphaKey = p.OutletAlphaKey and o.OutletStatus = 'Current'
where
    p.StatusDescription = 'Active' and
	o.CountryKey = 'NZ'
Group By
	(pt.FirstName + ' ' + pt.Lastname),
	pt.DOB
Having
	sum
    (
        case
            when o.SuperGroupName = 'IAG NZ' then 1
            else 0
        end 
    ) > 0


--Fetch details of all IAG NZ Customer
IF OBJECT_ID('tempdb..#customer') IS NOT NULL DROP TABLE #customer
select 
	ppt.PolicyTravellerId [InternalID],
	ppt.FirstName + ' ' + ppt.LastName [CustomerName],
	ppt.DOB,
	ppt.EmailAddress Email,
	o.Groupname [Group],
	p.ProductCode [Product],
	p.PrimaryCountry [Destination],
	case
		when p.TripDuration <= 7 then 'up to 1 week'
		when p.TripDuration <= 14 then 'up to 2 weeks'
		when p.TripDuration <= 30 then 'up to 1 month'
		when p.TripDuration <= 60 then 'up to 2 months'
		when p.TripDuration <= 90 then 'up to 3 months'
		when p.TripDuration <= 180 then 'up to 6 months'
		else 'up to 1 year'
    end TripDuration,
	@StartDate [Start Date],
	@EndDate [End Date]
Into
	#customer
from 
	penpolicyTraveller ppt with(nolock)
	inner join penPolicy p with(nolock) on
		ppt.PolicyKey = p.PolicyKey
	inner join penOutlet o with(nolock) on
		p.OutletAlphaKey = o. OutletAlphaKey
	inner join penPolicyTransSummary pt with(nolock) on
		pt.PolicyKey = p.PolicyKey
where
	o.CountryKey = 'NZ' and
	o.SuperGroupname = 'IAG NZ' and
	pt.TransactionStatus = 'Active' and
	pt.TransactionType = 'Base' and
	o.OutletStatus = 'Current' and
	p.StatusDescription = 'Active' and
	convert(date, pt.PostingDate) between convert(date, @StartDate) and convert(date, @EndDate)


--Final query providing desired details of IAG NZ Customers
select
	cust.InternalID,
	cust.CustomerName,
	cust.DOB,
	cust.Email,
	cust.[Group],
	cust.Product,
	cust.Destination,
	cust.TripDuration,
	p.AllPolicyCount PolicyCount,
	case
		when tp.AllCount <= 1 then 'One-off traveller'
		when tp.AllCount >= 4 and tp.LongLeadTimeCount * 1.00 / tp.AllCount >= 0.6 then 'Planner'
		when tp.AllCount >= 4 then 'Frequent traveller'
		else 'Repeat traveller'
	end TravelPattern,
	Case
		When cp.ChannelPolicyCount * 1.00 / p.AllPolicyCount > 0.75 then cp.Channel
		Else 'Mixed'
	End ChannelPreference,
	case
		when d.AllCount <> 0 and d.LocalCount * 1.00 / d.AllCount >= 0.90 then 'Local traveller'
		when d.AllCount <> 0 and d.CruiseCount * 1.00 / d.AllCount >= 0.90 then 'Cruiser'
		when d.AllCount > 0 and d.DestinationCount = 1 and d.LocalCount * 1.00 / d.AllCount <= 0.25 and d.LocalCount * 1.00 / d.AllCount > 0 then 'Going home'
		when d.AllCount > 0 and d.AfricaCount * 1.00 / d.AllCount >= 0.75 then 'Africa'
		when d.AllCount > 0 and d.AsiaCount * 1.00 / d.AllCount >= 0.75 then 'Asia'
		when d.AllCount > 0 and d.EuropeCount * 1.00 / d.AllCount >= 0.75 then 'Europe'
		when d.AllCount > 0 and d.OceaniaCount * 1.00 / d.AllCount >= 0.75 then 'Oceania'
		when d.AllCount > 0 and d.AmericaCount * 1.00 / d.AllCount >= 0.75 then 'America'
		when 
			(
				(
					case when d.AfricaCount > 0 then 1 else 0 end +
					case when d.AsiaCount > 0 then 1 else 0 end +
					case when d.EuropeCount > 0 then 1 else 0 end +
					case when d.OceaniaCount > 0 then 1 else 0 end +
					case when d.AmericaCount > 0 then 1 else 0 end
				) >= 4 or
				d.DestinationCount >= 7
			) and
			d.LocalCount * 1.00 / d.AllCount <= 0.25 and d.LocalCount * 1.00 / d.AllCount > 0 then 'World Explorer'
		else 'Mix'
	end DestinationGroup,
	case
		when pp.AllPolicyCount <> 0 and pp.BusinessCount * 1.00  / pp.AllPolicyCount >= 0.5 then 'Business'
		when pp.AllPolicyCount <> 0 and pp.PromoCount * 1.00  / pp.AllPolicyCount >= 0.5 then 'Bargain lover'
		when pp.AllPolicyCount <> 0 and pp.ValueCount * 1.00  / pp.AllPolicyCount >= 0.5 then 'Value'
		when pp.AllPolicyCount <> 0 and pp.PremiumCount * 1.00  / pp.AllPolicyCount >= 0.5 then 'Premium'
		else 'Basic'
	end ProductPreference,
	case
		when tg.CoupleCount * 1.00 / tg.AllCount >= 0.6 then 'Couple'
		when 
			(
				tg.FamilyCount * 1.00 / tg.AllCount >= 0.6 or
				tg.FamilyKidsCount * 1.00 / tg.AllCount >= 0.6
			) and 
			tg.FamilyKidsCount >= tg.FamilyCount 
		then 'Family with kids'
		when 
			(
				tg.FamilyCount * 1.00 / tg.AllCount >= 0.6 or
				tg.FamilyKidsCount * 1.00 / tg.AllCount >= 0.6
			) 
		then 'Family'
		when tg.singleCount * 1.00 / tg.AllCount >= 0.6 then 'Lone traveller'
		when tg.GroupCount * 1.00 / tg.AllCount >= 0.6 then 'Group'
		else 'Mix'
	end TravelGroup,
	cust.[Start Date],
	cust.[End Date],
	rp.ClaimRiskProfile,
	case 
        when ba.AllCount >= 5 and ba.IAGCount = ba.AllCount then 'Strong brand affiliation'
        when ba.AllCount >= 5 and ba.BrandCount = 2 then 'Alternate affiliation'
        when ba.IAGCount between 2 and 4 then 'Weak affiliation'
        else 'No affiliation'
    end BrandAffiliation
From
	#customer cust
	inner join #policycount p on cust.CustomerName = p.CustomerName and cust.DOB = p.DOB
	inner join #destinationgroup d on cust.CustomerName = d.CustomerName and cust.DOB = d.DOB
	inner join #productpreference pp on cust.CustomerName = pp.CustomerName and cust.DOB = pp.DOB
	inner join #travelpattern tp on cust.CustomerName = tp.CustomerName and cust.DOB = tp.DOB
	inner join #travelgroup tg on cust.CustomerName = tg.CustomerName and cust.DOB = tg.DOB
	inner join #riskprofile rp on cust.CustomerName = rp.CustomerName and cust.DOB = rp.DOB
	inner join #brandaffiliation ba on cust.CustomerName = ba.CustomerName and cust.DOB = ba.DOB
	Outer apply
	(
		select
			top 1
			c.Channel,
			c.ChannelPolicyCount
		From
			#channelpolicycount c
		Where
			c.CustomerName = cust.CustomerName and
			c.DOB = cust.DOB
		Order By
			c.ChannelPolicyCount Desc
	) cp
    

end
GO
