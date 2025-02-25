USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1016]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[rptsp_rpt1016]   
	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           rptsp_rpt1016
--  Author:         Saurabh Date
--  Date Created:   20180831
--  Description:    This stored procedure returns policy splitting details
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2018-07-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2018-07-01
--   
--  Change History: 20180831 - SD - Created
--					20190723 - YY - Don't show as policy split when there are multiple addresses 
--									for same lastname and email (REQ-1787)
--
   
/****************************************************************************************************/

--DECLARE
--	@DateRange varchar(30),
--	@StartDate varchar(10),
--	@EndDate varchar(10)
--	SET @DateRange = 'Last Month'

declare @rptStartDate date
declare @rptEndDate date


--get reporting dates
if @DateRange = '_User Defined'
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
		DateRange = @DateRange
	

IF OBJECT_ID('tempdb..#emailandlastname') IS NOT NULL DROP TABLE #emailandlastname

select 
	p.TripStart, 
	p.TripEnd, 
	p.primaryCountry, 
	pt.EmailAddress,
	pt.LastName,
	po.OutletAlphaKey,
	pts.Consultant,
	Count(*) [PolicyCount],
	@rptStartDate [StartDate],
	@rptEndDate [EndDate]
Into
	#emailandlastname
from 
	penPolicy p
	inner join penOutlet po
		On po.OutletAlphaKey = p.OutletAlphaKey
	inner join penPolicyTraveller pt
		On pt.PolicyKey = p.PolicyKey
	Outer apply
	(
		select
			top 1
			(pu.FirstName + ' ' + pu.LastName) Consultant
		From
			penPolicyTransSummary pts
			inner join penUser pu
				on pts.UserKey = pu.UserKey
		Where
			pu.UserStatus = 'Current'
			and pu.ConsultantType = 'External'
			and pts.PolicyKey = p.Policykey
		order by
			pts.PolicyTransactionID
	) pts
Where
	po.OutletStatus = 'Current'
	and po.CountryKey = 'AU'
	and po.GroupCode = 'FL'
	and isPrimary = 1
	and pt.EmailAddress is not null
	and pt.EmailAddress <> ''
	and p.IssueDate >= @rptStartDate and p.IssueDate < DateAdd(Day, 1, @rptEndDate)
	and p.StatusDescription <> 'Cancelled'
	and pts.Consultant is not null
Group By
	p.TripStart, 
	p.TripEnd, 
	p.primaryCountry, 
	pt.EmailAddress,
	pt.LastName,
	(pt.AddressLine1 + ' ' + pt.Suburb),
	po.OutletAlphaKey,
	pts.Consultant
Having 
	Count(*) > 1
Order By
	Count(*) Desc



IF OBJECT_ID('tempdb..#addressandlastname') IS NOT NULL DROP TABLE #addressandlastname

select 
	p.TripStart, 
	p.TripEnd, 
	p.primaryCountry, 
	(pt.AddressLine1 + ' ' + pt.Suburb) Address,
	pt.LastName,
	po.OutletAlphaKey,
	pts.Consultant,
	Count(*) [PolicyCount],
	@rptStartDate [StartDate],
	@rptEndDate [EndDate]
Into
	#addressandlastname
from 
	penPolicy p
	inner join penOutlet po
		On po.OutletAlphaKey = p.OutletAlphaKey
	inner join penPolicyTraveller pt
		On pt.PolicyKey = p.PolicyKey
	Outer apply
	(
		select
			top 1
			(pu.FirstName + ' ' + pu.LastName) Consultant
		From
			penPolicyTransSummary pts
			inner join penUser pu
				on pts.UserKey = pu.UserKey
		Where
			pu.UserStatus = 'Current'
			and pu.ConsultantType = 'External'
			and pts.PolicyKey = p.Policykey
		order by
			pts.PolicyTransactionID
	) pts
Where
	po.OutletStatus = 'Current'
	and po.CountryKey = 'AU'
	and po.GroupCode = 'FL'
	and isPrimary = 1
	and (pt.EmailAddress is null or pt.EmailAddress = '')
	and p.IssueDate >= @rptStartDate and p.IssueDate < DateAdd(Day, 1, @rptEndDate)
	and p.StatusDescription <> 'Cancelled'
	and pts.Consultant is not null
	and (pt.AddressLine1 + ' ' + pt.Suburb) is not null
	and (pt.AddressLine1 + ' ' + pt.Suburb) <> ''
Group By
	p.TripStart, 
	p.TripEnd, 
	p.primaryCountry, 
	(pt.AddressLine1 + ' ' + pt.Suburb),
	pt.LastName,
	po.OutletAlphaKey,
	pts.Consultant
Having 
	Count(*) > 1
order by 
	count(*) Desc



select 
	p.PolicyNumber,
	p.IssueDate,
	p.TripStart,
	p.TripEnd,
	p.PrimaryCountry,
	a.Consultant,
	po.AlphaCode,
	po.OutletName,
	po.FCNation,
	po.FCArea,
	pt.FirstName,
	pt.LastName,
	pt.EmailAddress,
	pt.AddressLine1,
	pt.AddressLine2,
	pt.Suburb,
	pt.State,
	pt.Country,
	StartDate,
	EndDate
From
	penPolicy p
	inner join penOutlet po
		On po.OutletAlphaKey = p.OutletAlphaKey
	inner join penPolicyTraveller pt
		On pt.PolicyKey = p.PolicyKey
	Outer apply
	(
		select
			top 1
			(pu.FirstName + ' ' + pu.LastName) Consultant
		From
			penPolicyTransSummary pts
			inner join penUser pu
				on pts.UserKey = pu.UserKey
		Where
			pu.UserStatus = 'Current'
			and pu.ConsultantType = 'External'
			and pts.PolicyKey = p.Policykey
		order by
			pts.PolicyTransactionID
	) pts
	inner join #addressandlastname a
		on p.TripStart = a.TripStart
			and p.TripEnd = a.TripEnd
			and p.PrimaryCountry = a.PrimaryCountry
			and po.OutletAlphaKey = a.OutletAlphaKey
			and (pt.AddressLine1 + ' ' + pt.Suburb) = a.Address
			and pt.LastName = a.LastName
			and pts.Consultant = a.Consultant
Where
	po.OutletStatus = 'Current'
	and po.CountryKey = 'AU'
	and po.GroupCode = 'FL'
	and isPrimary = 1
	and (pt.EmailAddress is null or pt.EmailAddress = '')
	and p.IssueDate >= @rptStartDate and p.IssueDate < DateAdd(Day, 1, @rptEndDate)
	and p.StatusDescription <> 'Cancelled'
	and pts.Consultant is not null
	and (pt.AddressLine1 + ' ' + pt.Suburb) is not null
	and (pt.AddressLine1 + ' ' + pt.Suburb) <> ''

union

select 
	p.PolicyNumber,
	p.IssueDate,
	p.TripStart,
	p.TripEnd,
	p.PrimaryCountry,
	a.Consultant,
	po.AlphaCode,
	po.OutletName,
	po.FCNation,
	po.FCArea,
	pt.FirstName,
	pt.LastName,
	pt.EmailAddress,
	pt.AddressLine1,
	pt.AddressLine2,
	pt.Suburb,
	pt.State,
	pt.Country,
	StartDate,
	EndDate
From
	penPolicy p
	inner join penOutlet po
		On po.OutletAlphaKey = p.OutletAlphaKey
	inner join penPolicyTraveller pt
		On pt.PolicyKey = p.PolicyKey
	Outer apply
	(
		select
			top 1
			(pu.FirstName + ' ' + pu.LastName) Consultant
		From
			penPolicyTransSummary pts
			inner join penUser pu
				on pts.UserKey = pu.UserKey
		Where
			pu.UserStatus = 'Current'
			and pu.ConsultantType = 'External'
			and pts.PolicyKey = p.Policykey
		order by
			pts.PolicyTransactionID
	) pts
	inner join #emailandlastname a
		on p.TripStart = a.TripStart
			and p.TripEnd = a.TripEnd
			and p.PrimaryCountry = a.PrimaryCountry
			and po.OutletAlphaKey = a.OutletAlphaKey
			and pt.EmailAddress = a.EmailAddress
			and pt.LastName = a.LastName
			and pts.Consultant = a.Consultant
Where
	po.OutletStatus = 'Current'
	and po.CountryKey = 'AU'
	and po.GroupCode = 'FL'
	and isPrimary = 1
	and pt.EmailAddress is not null
	and pt.EmailAddress <> ''
	and p.IssueDate >= @rptStartDate and p.IssueDate < DateAdd(Day, 1, @rptEndDate)
	and p.StatusDescription <> 'Cancelled'
	and pts.Consultant is not null
GO
