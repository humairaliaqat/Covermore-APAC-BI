USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0979]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[rptsp_rpt0979]   
	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           rptsp_rpt0979
--  Author:         Saurabh Date
--  Date Created:   20180312
--  Description:    This stored procedure returns Medibank Customers with 2 or more single trip policies in last 12 months, but no AMT policies
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--   
--  Change History: 20180312 - SD - Created
--                  20180328 - SD - Modified the query to exclude previously contacted customers
/****************************************************************************************************/

--DECLARE
--	@DateRange varchar(30),
--	@StartDate varchar(10),
--	@EndDate varchar(10)
--SET @DateRange = 'Last 12 Months'

declare @rptStartDate date
declare @rptEndDate date


--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from vDateRange
	where DateRange = @DateRange

IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp	
select distinct
	upper(b.Customer) [Customer],
	b.DOB,
	upper(b.Customer) + '-' + convert(varchar, b.DOB, 120) [CustomerDOB]
Into
	#temp
From
	(select
		a.Customer,
		a.DOB,
		a.homephone,
		a.workphone,
		a.mobilephone,
		a.emailaddress,
		sum(Case when a.TripType = 'Single Trip' then 1 Else 0 End) [SingleTripPolicyCount],
		sum(Case when a.TripType = 'Annual Multi Trip' then 1 Else 0 End) [AMTPolicyCount],
		SUM(1) [PolicyCount],
		SUM(a.GrossPremium) [GrossPremium]
	From
		(select 
			pt.FirstName + ' ' + pt.LastName as Customer,
			pt.DOB,
			homephone.homephone,
			workphone.workphone,
			mobilephone.mobilephone,
			emailaddress.emailaddress,
			p.PolicyKey, 
			p.IssueDate,
			p.TripType,
			p.TripStart,
			p.TripEnd,
			pts.GrossPremium,
			om.OptFurtherContact,
			om.MarketingConsent		   
		from
				penPolicy p with(nolock)
				inner join penOutlet o with(nolock) on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
				inner join penPolicyTraveller pt with(nolock)
				on p.PolicyKey = pt.PolicyKey 
					and pt.Isprimary = 1 
					and pt.CountryKey = 'AU'
				outer apply
				(--This is to caluclate Gross Premium of the customer in the selected period
						select sum(GrossPremium) as GrossPremium
						from penPolicyTransSummary with(nolock)
						where PolicyKey = p.PolicyKey
				) pts
				Outer apply
			(--This is to check whether customer has opted for further contact and marketing consent in latest policy purchase
				select
					top 1
					pt2.OptFurtherContact,
					pt2.MarketingConsent
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1
				Order by
					pt2.PolicyTravellerID Desc
			)  om
			Outer apply
			(--This is to find latest non empty Home Phone number of the customer
				select
					top 1
					pt2.homephone
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1 and
					pt2.HomePhone is not null and pt2.HomePhone <> ''
				Order by
					pt2.PolicyTravellerID Desc
			) homephone
			Outer apply
			(--This is to find latest non empty work phone number of the customer
				select
					top 1
					pt2.Workphone
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1 and
					pt2.WorkPhone is not null and pt2.WorkPhone <> ''
				Order by
					pt2.PolicyTravellerID Desc
			) workphone
			Outer apply
			(--This is to find latest non empty Mobile Phone number of the customer
				select
					top 1
					pt2.mobilephone
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1 and
					pt2.MobilePhone is not null and pt2.MobilePhone <> ''
				Order by
					pt2.PolicyTravellerID Desc
			) mobilephone
			Outer apply
			(--This is to find latest non empty Email Address of the customer
				select
					top 1
					pt2.emailaddress
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1 and
					pt2.EmailAddress is not null and pt2.EmailAddress <> ''
				Order by
					pt2.PolicyTravellerID Desc
			) emailaddress
		where
				p.IssueDate >= @rptStartDate
				AND
				p.IssueDate < Dateadd(Day, 1, @rptEndDate)
				AND
				om.OptFurtherContact = 1
				AND
				om.MarketingConsent = 1
				AND
				p.StatusDescription = 'Active'
				AND
				o.CountryKey  =  'AU'
				AND
				o.GroupName = 'Medibank'
		) a
	Group BY
		a.Customer,
		a.DOB,
		a.homephone,
		a.workphone,
		a.mobilephone,
		a.emailaddress
	Having
		sum(Case when a.TripType = 'Single Trip' then 1 Else 0 End) >= 2
		and sum(Case when a.TripType = 'Annual Multi Trip' then 1 Else 0 End) = 0
	) b
	inner join penPolicyTraveller pt with(nolock)
		on (pt.FirstName + ' ' + pt.LastName) = b.Customer
			and pt.DOB = b.DOB
			and pt.Isprimary = 1 
			and pt.CountryKey = 'AU'
	inner join penPolicy p with(nolock)
		on p.PolicyKey = pt.policykey
	inner join penOutlet o with(nolock) 
		on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	outer apply
	(--This is to caluclate Gross Premium of the customer in the selected period
			select sum(GrossPremium) as GrossPremium
			from penPolicyTransSummary with(nolock)
			where PolicyKey = p.PolicyKey
	) pts
where
	p.IssueDate >= @rptStartDate
	AND
	p.IssueDate < Dateadd(Day, 1, @rptEndDate)
	AND
	p.StatusDescription = 'Active'
	AND
	o.CountryKey  =  'AU'
	AND
	o.GroupName = 'Medibank'
	and (upper(b.Customer) + '-' + convert(varchar, b.DOB, 120)) not in (Select CustomerDOB from [db-au-workspace].[dbo].[rpt0979_Customer])



select
	b.Customer,
	b.DOB,
	b.homephone,
	b.workphone,
	b.mobilephone,
	b.emailaddress,
	p.PolicyNumber,
	p.IssueDate,
	p.TripType,
	p.TripStart,
	p.TripEnd,
	pts.GrossPremium,
	o.Groupname,
	o.AlphaCode,
	o.OutletName,
	[PolicyCount],
	b.[GrossPremium] [Total Gross Premium],
	@rptStartDate [Start Date],
	@rptEndDate [End Date]
From
	(select
		a.Customer,
		a.DOB,
		a.homephone,
		a.workphone,
		a.mobilephone,
		a.emailaddress,
		sum(Case when a.TripType = 'Single Trip' then 1 Else 0 End) [SingleTripPolicyCount],
		sum(Case when a.TripType = 'Annual Multi Trip' then 1 Else 0 End) [AMTPolicyCount],
		SUM(1) [PolicyCount],
		SUM(a.GrossPremium) [GrossPremium]
	From
		(select 
			pt.FirstName + ' ' + pt.LastName as Customer,
			pt.DOB,
			homephone.homephone,
			workphone.workphone,
			mobilephone.mobilephone,
			emailaddress.emailaddress,
			p.PolicyKey, 
			p.IssueDate,
			p.TripType,
			p.TripStart,
			p.TripEnd,
			pts.GrossPremium,
			om.OptFurtherContact,
			om.MarketingConsent		   
		from
				penPolicy p with(nolock)
				inner join penOutlet o with(nolock) on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
				inner join penPolicyTraveller pt with(nolock)
				on p.PolicyKey = pt.PolicyKey 
					and pt.Isprimary = 1 
					and pt.CountryKey = 'AU'
				outer apply
				(--This is to caluclate Gross Premium of the customer in the selected period
						select sum(GrossPremium) as GrossPremium
						from penPolicyTransSummary with(nolock)
						where PolicyKey = p.PolicyKey
				) pts
				Outer apply
			(--This is to check whether customer has opted for further contact and marketing consent in latest policy purchase
				select
					top 1
					pt2.OptFurtherContact,
					pt2.MarketingConsent
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1
				Order by
					pt2.PolicyTravellerID Desc
			)  om
			Outer apply
			(--This is to find latest non empty Home Phone number of the customer
				select
					top 1
					pt2.homephone
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1 and
					pt2.HomePhone is not null and pt2.HomePhone <> ''
				Order by
					pt2.PolicyTravellerID Desc
			) homephone
			Outer apply
			(--This is to find latest non empty work phone number of the customer
				select
					top 1
					pt2.Workphone
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1 and
					pt2.WorkPhone is not null and pt2.WorkPhone <> ''
				Order by
					pt2.PolicyTravellerID Desc
			) workphone
			Outer apply
			(--This is to find latest non empty Mobile Phone number of the customer
				select
					top 1
					pt2.mobilephone
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1 and
					pt2.MobilePhone is not null and pt2.MobilePhone <> ''
				Order by
					pt2.PolicyTravellerID Desc
			) mobilephone
			Outer apply
			(--This is to find latest non empty Email Address of the customer
				select
					top 1
					pt2.emailaddress
				From
					penPolicyTraveller pt2 with(nolock)
				Where
					pt2.FirstName  = pt.FirstName
					and pt2.LastName  = pt.LastName
					and pt2.DOB = pt.DOB
					and pt2.Isprimary = 1 and
					pt2.EmailAddress is not null and pt2.EmailAddress <> ''
				Order by
					pt2.PolicyTravellerID Desc
			) emailaddress
		where
				p.IssueDate >= @rptStartDate
				AND
				p.IssueDate < Dateadd(Day, 1, @rptEndDate)
				AND
				om.OptFurtherContact = 1
				AND
				om.MarketingConsent = 1
				AND
				p.StatusDescription = 'Active'
				AND
				o.CountryKey  =  'AU'
				AND
				o.GroupName = 'Medibank'
		) a
	Group BY
		a.Customer,
		a.DOB,
		a.homephone,
		a.workphone,
		a.mobilephone,
		a.emailaddress
	Having
		sum(Case when a.TripType = 'Single Trip' then 1 Else 0 End) >= 2
		and sum(Case when a.TripType = 'Annual Multi Trip' then 1 Else 0 End) = 0
	) b
	inner join penPolicyTraveller pt with(nolock)
		on (pt.FirstName + ' ' + pt.LastName) = b.Customer
			and pt.DOB = b.DOB
			and pt.Isprimary = 1 
			and pt.CountryKey = 'AU'
	inner join penPolicy p with(nolock)
		on p.PolicyKey = pt.policykey
	inner join penOutlet o with(nolock) 
		on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	outer apply
	(--This is to caluclate Gross Premium of the customer in the selected period
			select sum(GrossPremium) as GrossPremium
			from penPolicyTransSummary with(nolock)
			where PolicyKey = p.PolicyKey
	) pts
where
	p.IssueDate >= @rptStartDate
	AND
	p.IssueDate < Dateadd(Day, 1, @rptEndDate)
	AND
	p.StatusDescription = 'Active'
	AND
	o.CountryKey  =  'AU'
	AND
	o.GroupName = 'Medibank'
	and (b.Customer + '-' + convert(varchar, b.DOB, 120)) not in (Select CustomerDOB from [db-au-workspace].[dbo].[rpt0979_Customer])
Order by
	Customer,
	IssueDate

Insert Into [db-au-workspace].[dbo].[rpt0979_Customer]
select
	*
From
	#temp
GO
