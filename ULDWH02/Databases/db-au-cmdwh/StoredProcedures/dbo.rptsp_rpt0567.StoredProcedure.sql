USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0567]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0567]	
    @Group varchar(100),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0567 - AMT Expiry Report
--  Author:         Linus Tor
--  Date Created:   20140716
--  Description:    This stored procedure returns AMT policies that are about to expire
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--					@Group: Value is valid Group
--   
--  Change History: 20140716 - LT - Created
--					20160629 - SD - INC0011873 - Included "Medibank" supergroup, as requested by Kate Keogh
--					20161011 - LT - Added FCArea column to result output
--					20171010 - LT - Added VA Staff AMT group
--					20171109 - SD - INC0049243 - Included "Helloworld" and "Flight Centre All Alpha" group
--					20180228 - LT - Added agent email column to result
--                  20180913 - LL - REQ-369 split AP & CM
/****************************************************************************************************/

--uncomment to debug
--declare @Group varchar(100)
--declare @ReportingPeriod varchar(30)
--declare @StartDate varchar(10)
--declare @EndDate varchar(10)
--select @Group = 'Covermore', @ReportingPeriod = '_User Defined', @StartDate = '20180901', @EndDate = '20181231'


declare @rptStartDate datetime  
declare @rptEndDate datetime  

/* get reporting dates */  
if @ReportingPeriod = '_User Defined'  
    select 
		@rptStartDate = @StartDate, 
		@rptEndDate = @EndDate  
else  
    select 
		@rptStartDate = StartDate, 
		@rptEndDate = EndDate  
    from 
		[db-au-cmdwh].dbo.vDateRange  
    where 
		DateRange = @ReportingPeriod 

if object_id('tempdb..#rpt0567_alpha') is not null drop table #rpt0567_alpha

/* get alphas */
create table #rpt0567_alpha 
(
	OutletAlphaKey varchar(50) null
)

if @Group = 'Flight Centre'
	insert 
		#rpt0567_alpha
	select 
		OutletAlphaKey
	from 
		penOutlet
	where 
		CountryKey = 'AU' 
		and 
		GroupCode = 'FL' 
		and 
		SubGroupCode in ('FL','WE') 
		and 
		OutletStatus = 'Current'
--20180913 - LL - REQ-369 split AP & CM
--else if @Group = 'Covermore'
--	insert 
--		#rpt0567_alpha
--	select 
--		OutletAlphaKey
--	from 
--		penOutlet
--	where 
--		CountryKey = 'AU' 
--		and 
--		OutletStatus = 'Current' 
--		and 
--		AlphaCode in ('CMFL000','CMN0100','APN0003','APN0002','APN0001')		--CM customer service alphas
else if @Group = 'Covermore'
	insert 
		#rpt0567_alpha
	select 
		OutletAlphaKey
	from 
		penOutlet
	where 
		CountryKey = 'AU' 
		and 
		OutletStatus = 'Current' 
		and 
		AlphaCode in ('CMFL000','CMN0100')		--CM customer service alphas
else if @Group = 'Auspost'
	insert 
		#rpt0567_alpha
	select 
		OutletAlphaKey
	from 
		penOutlet
	where 
		CountryKey = 'AU' 
		and 
		OutletStatus = 'Current' 
		and 
		AlphaCode in ('APN0003','APN0002','APN0001')		--AP customer service alphas

else if @Group = 'VA Staff'
	insert 
		#rpt0567_alpha
	select 
		OutletAlphaKey
	from 
		penOutlet
	where 
		CountryKey = 'AU' 
		and 
		OutletStatus = 'Current' 
		and 
		AlphaCode in ('VAA0003')		--Virgin Australia staff
else if @Group = 'Medibank'
	insert 
		#rpt0567_alpha
	select 
		OutletAlphaKey
	from 
		penOutlet
	where 
		CountryKey = 'AU' 
		and 
		SuperGroupName = 'Medibank' 
		and 
		OutletStatus = 'Current'
else if @Group = 'Helloworld'
	insert 
		#rpt0567_alpha
	select 
		OutletAlphaKey
	from 
		penOutlet
	where 
		OutletStatus = 'Current' 
		and
		CountryKey = 'AU' 
		and
		(
			SuperGroupname = 'Stella' or 
			GroupName = 'Traveller''s Choice'
		) 
		and
		OutletAlphaKey not in (
								select 
									OutletAlphaKey							--exclude TRIPS migrated outlets
								from 
									penOutlet
								where
									CountryKey = 'AU' 
									and
									(
										SuperGroupname = 'Stella' or 
										GroupName = 'Traveller''s Choice'
									) 
									and
									OutletStatus = 'Current' and
									ISNUMERIC(REPLACE(LatestOutletKey, 'AU-CM7-', '')) = 0
								)
Else if @Group = 'Flight Centre All Alpha'
		insert 
			#rpt0567_alpha
		select 
			OutletAlphaKey
		from 
			penOutlet
		where 
			CountryKey = 'AU' 
			and 
			GroupCode = 'FL'
			and 
			OutletStatus = 'Current'
else if @Group = 'IAL'
		insert #rpt0567_alpha
		select OutletAlphaKey
		from penOutlet
		where CountryKey = 'AU' and SuperGroupName = 'IAL' and OutletStatus = 'Current'
else if @Group = 'NRMA'
		insert #rpt0567_alpha
		select OutletAlphaKey
		from penOutlet
		where CountryKey = 'AU' and AlphaCode in ('NIN0001','SES0001','SOW0001') and OutletStatus = 'Current' 


if object_id('tempdb..#rpt0567') is not null drop table #rpt0567

create table #rpt0567
(
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[FCArea] [nvarchar](50) NULL,
	[PolicyNumber] [bigint] NULL,
	[IssueDate] [date] NULL,
	[PolicyValue] [money] NULL,
	[PolicyStart] [date] NULL,
	[PolicyEnd] [date] NULL,
	[ProductName] [nvarchar](50) NULL,
	[TripType] [nvarchar](50) NULL,
	[CustTitle] [nvarchar](50) NULL,
	[CustName] [nvarchar](201) NULL,
	[DOB] [date] NULL,
	[Age] [int] NULL,
	[CustAddress] [nvarchar](201) NULL,
	[CustSuburb] [nvarchar](50) NULL,
	[CustState] [nvarchar](100) NULL,
	[CustPostcode] [nvarchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[hasRenewed] [varchar](1) NULL,
	[rptStartDate] [datetime] NULL,
	[rptEndDate] [datetime] NULL,
	[AgentEmail] [varchar](255) NULL,
	[CustomerID] [bigint] null,
	[NextAMTPolicy] [bigint] null
)

insert #rpt0567
select
	o.AlphaCode,
	o.OutletName,
	o.FCArea,
	p.PolicyNumber,
	convert(date,p.IssueDate) as IssueDate,	
	sum(pts.GrossPremium) as PolicyValue,	
	convert(date,p.PolicyStart) as PolicyStart,
	convert(date,p.PolicyEnd) as PolicyEnd,
	p.ProductDisplayName as ProductName,
	p.TripType,
	pt.Title as CustTitle,
	ltrim(rtrim(pt.FirstName)) + ' ' + ltrim(rtrim(pt.LastName)) as CustName,
	convert(date,pt.DOB) as DOB,
	pt.Age,
	ltrim(rtrim(pt.AddressLine1)) + ' ' + ltrim(rtrim(pt.AddressLine2)) as CustAddress,
	pt.Suburb as CustSuburb,
	pt.[State] as CustState,
	pt.Postcode as CustPostcode,
	pt.WorkPhone,
	pt.MobilePhone,
	pt.EmailAddress,
	case when q.PreviousPolicyNumber is null then 'N' else 'Y' end as hasRenewed,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate,
	agent.AgentEmail,
	ep.CustomerID,
	nextp.PolicyNumber
from
	penPolicy p
	join penOutlet o on
		p.OutletAlphaKey = o.OutletAlphaKey and
		o.OutletStatus = 'Current'		
	join penPolicyTraveller pt on
		p.PolicyKey = pt.PolicyKey
	LEFT JOIN entPolicy ep on p.PolicyKey = ep.PolicyKey AND pt.PolicyTravellerKey = ep.Reference
	outer apply
	(
		select sum(GrossPremium) as GrossPremium
		from penPolicyTransSummary 
		where PolicyKey = p.PolicyKey
	) pts
	outer apply
	(
		select top 1 q.PreviousPolicyNumber
		from [db-au-cmdwh].dbo.penQuote q
		where q.PolicyKey = p.PolicyKey
	) q
	outer apply
	(
		select top 1 Email as AgentEmail
		from 
			penPolicyTransSummary ps 
			inner join penUser u on ps.UserKey = u.UserKey and u.UserStatus = 'Current'
		where
			ps.PolicyKey = p.PolicyKey and
			ps.TransactionType = 'Base' 
	) agent
	outer apply
	(
		select top 1 isAgentSpecial
		from penPolicyTransSummary
		where PolicyKey = p.PolicyKey and TransactionType = 'Base'
	) ptsum
	outer apply (
		select TOP 1 pp.PolicyNumber, pp.PolicyStart, pp.PolicyEnd, pp.TripType, pp.PreviousPolicyNumber
		from penPolicy pp
		join entPolicy epp on pp.PolicyKey = epp.PolicyKey
		where epp.CustomerID = ep.CustomerID
		AND pp.PolicyStart >= DateAdd(day,-7,p.PolicyEnd)
		and pp.StatusDescription = 'Active' 
		and pp.TripType = 'Annual Multi Trip'
		ORDER BY TripStart ASC
	) nextp
where
	p.CountryKey = 'AU' and	
	o.OutletAlphaKey in (select OutletAlphaKey from #rpt0567_alpha) and
	p.StatusDescription = 'Active' and
	p.TripType = 'Annual Multi Trip' and
	pt.isPrimary = 1 and
	pt.isAdult = 1 and	
 	ptsum.isAgentSpecial = 0 and
	p.PolicyEnd >= convert(varchar(10),@rptStartDate,120) and 
	p.PolicyEnd <  convert(varchar(10),dateadd(day, 1, @rptEndDate),120)
group by
	o.AlphaCode,
	o.OutletName,
	o.FCArea,
	p.PolicyNumber,
	convert(date,p.IssueDate),	
	convert(date,p.PolicyStart),
	convert(date,p.PolicyEnd),
	p.ProductDisplayName,
	p.TripType,
	pt.Title,
	ltrim(rtrim(pt.FirstName)) + ' ' + ltrim(rtrim(pt.LastName)),
	convert(date,pt.DOB),
	pt.Age,
	ltrim(rtrim(pt.AddressLine1)) + ' ' + ltrim(rtrim(pt.AddressLine2)),
	pt.Suburb,
	pt.[State],
	pt.Postcode,
	pt.WorkPhone,
	pt.MobilePhone,
	pt.EmailAddress,
	case when q.PreviousPolicyNumber is null then 'N' else 'Y' end,
	agent.AgentEmail,
	ep.CustomerID,
	nextp.PolicyNumber


if (select count(*) from #rpt0567) = 0
	select 
		convert(nvarchar(20),null) [AlphaCode],
		convert(nvarchar(50),null) [OutletName],
		convert(nvarchar(50),null) [FCArea],
		convert(bigint,null) [PolicyNumber],
		convert(date,null) [IssueDate],
		convert(money,null) [PolicyValue],
		convert(date,null) [PolicyStart],
		convert(date,null) [PolicyEnd],
		convert(nvarchar(50),null) [ProductName],
		convert(nvarchar(50),null) [TripType],
		convert(nvarchar(50),null) [CustTitle],
		convert(nvarchar(201),null) [CustName],
		convert(date,null) [DOB],
		convert(int,null) [Age],
		convert(nvarchar(201),null) [CustAddress],
		convert(nvarchar(50),null) [CustSuburb],
		convert(nvarchar(100),null) [CustState],
		convert(nvarchar(50),null) [CustPostcode],
		convert(nvarchar(50),null) [WorkPhone],
		convert(nvarchar(50),null) [MobilePhone],
		convert(nvarchar(255),null) [EmailAddress],
		convert(varchar(1),null) [hasRenewed],
		@rptStartDate as rptStartDate, 
		@rptEndDate as rptEndDate,
		convert(varchar(255),null) AgentEmail,
		convert(bigint,null) [NextAMTPolicy]
else	
	select
		AlphaCode,
		OutletName,
		FCArea,
		PolicyNumber,
		IssueDate,
		PolicyValue,
		PolicyStart,
		PolicyEnd,
		ProductName,
		TripType,
		CustTitle,
		CustName,
		DOB,
		Age,
		CustAddress,
		CustSuburb,
		CustState,
		CustPostcode,
		WorkPhone,
		MobilePhone,
		EmailAddress,
		hasRenewed,
		rptStartDate,
		rptEndDate,
		AgentEmail,
		NextAMTPolicy
	from 
		#rpt0567
	where NextAMTPolicy IS NULL

drop table #rpt0567
drop table #rpt0567_alpha
GO
