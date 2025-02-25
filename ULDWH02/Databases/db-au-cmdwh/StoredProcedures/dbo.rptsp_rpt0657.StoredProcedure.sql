USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0657]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0657]	@Country varchar(2),
									@IncidentCountry varchar(100),
									@DateRange varchar(30),
									@StartDate varchar(10),
									@EndDate varchar(10),
									@Timezone varchar(100)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           rptsp_rpt0657
--  Author:         Linus Tor
--  Date Created:   20150703
--  Description:    This stored procedure returns assistance case and respective claims and policy info
--
--  Parameters:		@Country: AU, NZ, SG, MY, ID, CN, UK, IN
--					@Incident Country: country where incident happened. Use wildcarld for multiple countries
--									   eg. USA%
--					@DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@Timezone: valid timezone code eg. AUS Eastern Standard Time
--   
--  Change History: 20150703 - LT - Created
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(2)
declare @IncidentCountry varchar(100)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
declare @TimeZone varchar(100)
select @Country = 'AU', @IncidentCountry = 'USA%', @DateRange = 'Last 6 Months', @StartDate = null, @EndDate = null, @TimeZone = 'AUS Eastern Standard Time'
*/								

declare @rptStartDate date
declare @rptEndDate date


--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange


select
	c.CaseNo,
	c.CaseType,
	dbo.xfn_ConvertUTCtoLocal(c.OpenTimeUTC, @TimeZone) as OpenDate,
	c.TotalEstimate,
	c.ClientName,
	c.UWCoverStatus,
	ic.IncidentCountry,
	rc.ResidenceCountry,
	claim.ClaimNo,
	claim.EventDesc,
	claim.SectionCode,
	claim.PaidPayment,
	claim.AgencySuperGroupName,
	convert(datetime,@rptStartDate) as StartDate,
	convert(datetime,@rptEndDate) as EndDate
from
	cbCase c
	outer apply			--get Incident Country
	(
		select top 1 CountryName as IncidentCountry
		from cbAddress
		where AddressType = 'INCIDENT LOCATION' and
			CaseKey = c.CaseKey
	) ic
	outer apply			--get Residential Country
	(
		select top 1 CountryName as ResidenceCountry
		from cbAddress
		where AddressType = 'RESIDENTIAL ADDRESS' and
			CaseKey = c.CaseKey
	) rc
	outer apply
	(
		select
			cc.CaseKey,
			isnull(cl.ClaimKey, ce.ClaimKey) as ClaimKey,
			isnull(cl.ClaimNo, ce.ClaimNo) as ClaimNo,
			isnull(cl.EventDescription, ce.EventDescription) as EventDesc,
			isnull(cl.SectionCode, ce.SectionCode) as SectionCode,
			isnull(cl.PaidPayment, ce.PaidPayment) as PaidPayment,
			isnull(cl.AgencySuperGroupName, ce.AgencySuperGroupName) as AgencySuperGroupName
		from
			cbCase cc
			outer apply
			(					--get claim details via PolicyNo
				select top 1
					cls.ClaimKey,
					cls.ClaimNo,
					cls.EventDescription,
					cls.SectionCode,
					cls.PaidPayment,
					cls.AgencySuperGroupName
				from
					clmClaimSummary cls
				where
					cls.CreateDate >= cc.CreateDate and
					cls.SectionCode = 'MED' and
					convert(varchar, PolicyNo) in
					(
						select 
							rtrim(ltrim(p.PolicyNo))
						from
							cbPolicy p
						where
							p.CaseKey = cc.CaseKey and
							p.PolicyTransactionKey is not null
					)
				order by
					cls.CreateDate desc
			) cl
			outer apply
			(
				select top 1		--get claim details via CustomerCareID
					cls.ClaimKey,
					cls.ClaimNo,
					cls.EventDescription,
					cls.SectionCode,
					cls.PaidPayment,
					cls.AgencySuperGroupName
				from
					clmClaimSummary cls
				where
					isnumeric(cc.CaseNo) = 1 and
					CustomerCareID = cc.CaseNo and
					cls.SectionCode = 'MED'			--medical sections only
				order by
					cls.CreateDate desc
			) ce
		where
			cc.CaseKey = c.CaseKey
	) claim
   inner join
   ( 
		select *,
			   @TimeZone as TimeZonePrompt
		from
			Calendar
	)  CaseOpenCalendar ON 
		c.OpenTimeUTC >= dbo.xfn_ConvertLocaltoUTC(CaseOpenCalendar.Date, @TimeZone) and
		c.OpenTimeUTC <  dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, CaseOpenCalendar.Date), @TimeZone) and
		c.OpenDate >= dateadd(day, -1, CaseOpenCalendar.Date) and		/* force main index */
		c.OpenDate <  dateadd(day, 2, CaseOpenCalendar.Date)
	inner join vDateRange on
		CaseOpenCalendar.Date between vDateRange.StartDate and vDateRange.EndDate
where
	c.CountryKey = @Country and
	ic.IncidentCountry like @IncidentCountry and
	c.UWCoverStatus  =  'Pay and Claim' and
	c.IsDeleted = 0 and
	vDateRange.DateRange = @DateRange
GO
