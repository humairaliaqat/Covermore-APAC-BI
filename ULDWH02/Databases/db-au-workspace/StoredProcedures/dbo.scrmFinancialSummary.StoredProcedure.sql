USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[scrmFinancialSummary]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[scrmFinancialSummary]	@CountryCode varchar(2),
											@DateRange varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON



--uncomment to debug
/*
declare @CountryCode varchar(2)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @CountryCode = 'AU', @DateRange = 'Month-To-Date', @StartDate = null, @EndDate = null
*/

--variables
declare @rptStartDate datetime
declare @rptEndDate datetime
declare @rptYesterday datetime
declare @SQL varchar(8000)

if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate, @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange	

select @rptYesterday = StartDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = 'Yesterday'


--get Outlet Unique Identifiers
if object_id('[db-au-workspace].dbo.tmp_scrmOutlet') is not null drop table [db-au-workspace].dbo.tmp_scrmOutlet

select @SQL = 'select * into [db-au-workspace].dbo.tmp_scrmOutlet
			  from openquery(ULSQLAGR03, ''
				select
					td.CountryCode as CountryKey,
					to1.AlphaCode,
					td.CurrencyCode
				from
					[AU_PenguinSharp_Active].dbo.tblOutlet to1
					inner join [AU_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
					inner join [AU_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
				where	
					TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
					TC.CompanyName = ''''Covermore'''''

if @CountryCode = 'AU'
	select @SQL = @SQL + ' union all
						select
							td.CountryCode as CountryKey,
							to1.AlphaCode,
							td.CurrencyCode
						from
							[AU_TIP_PenguinSharp_Active].dbo.tblOutlet to1
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblSubGroup sg on to1.SubGroupID = sg.ID
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblGroup tg on sg.GroupID = tg.ID
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
						where	
							TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
							TC.CompanyName = ''''TIP'''' and
							tg.[Name] not in (''''AANT'''',''''Adventure World'''',''''NRMA'''',''''RAA'''',''''RAC'''',''''RACQ'''',''''RACT'''',''''RACV'''')
						'') a'
else
	select @SQL = @SQL + ' '') a'

execute(@SQL)


--get financial summary
if object_id('tempdb..#Sales') is not null drop table #Sales
select
	o.CountryKey + '.' + case when o.CompanyKey = 'CM' then 'CMA' else 'TIP' end + '.' + o.AlphaCode as [UniqueIdentifier],
	f.[Month],
	f.TransactionDate,
	sum(f.PolicyCount) as PolicyCount,
	sum(f.QuoteCount) as QuoteCount,
	sum(f.GrossSales) as GrossSales,
	oo.CurrencyCode,
	sum(f.Commission) as Commission	
into #Sales
from
	[db-au-cmdwh].dbo.penOutlet o
	inner join [db-au-workspace].dbo.tmp_scrmOutlet oo on 
		o.CountryKey = oo.CountryKey collate database_default and
		o.AlphaCode = oo.AlphaCode collate database_default and
		o.OutletStatus = 'Current'
	outer apply
	(
		select
			convert(datetime,convert(varchar(8),pt.PostingDate,120)+'01') as [Month],
			pt.PostingDate as TransactionDate,
			sum(pt.NewPolicyCount) as PolicyCount,
			sum(pt.GrossPremium) as GrossSales,
			sum(pt.Commission + pt.GrossAdminFee) as Commission,
			0 as QuoteCount
		from
			[db-au-cmdwh].dbo.penPolicy p
			inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt on p.PolicyKey = pt.PolicyKey
		where
			p.OutletAlphaKey = o.OutletAlphaKey and
			pt.PostingDate >= @rptStartDate and
			pt.PostingDate < @rptEndDate
		group by
			convert(datetime,convert(varchar(8),pt.PostingDate,120)+'01'),
			pt.PostingDate

		union all

		select
			convert(datetime,convert(varchar(8),d.[Date],120)+'01') as [Month],
			d.[Date] as TransactionDate,
			0 as PolicyCount,
			0 as GrossSales,
			0 as Commission,
			sum(q.QuoteCount) as QuoteCount
		from
			[db-au-star].dbo.vfactQuoteSummary q
			inner join [db-au-star].dbo.dimOutlet do on q.OutletSK = do.OutletSK
			inner join [db-au-star].dbo.Dim_Date d on q.DateSK = d.Date_SK			
		where			
			do.OutletAlphaKey = o.OutletAlphaKey and
			d.[Date] >= @rptStartDate and
			d.[Date] <= @rptEndDate
		group by
			convert(datetime,convert(varchar(8),d.[Date],120)+'01'),
			d.[Date]
	) f
group by
	o.CountryKey + '.' + case when o.CompanyKey = 'CM' then 'CMA' else 'TIP' end + '.' + o.AlphaCode,
	f.[Month],
	f.TransactionDate,
	oo.CurrencyCode


select
	s.[UniqueIdentifier],
	s.[Month],
	sum(s.PolicyCount) as PolicyCount,
	sum(s.QuoteCount) as QuoteCount,
	sum(s.GrossSales) as GrossSales,
	s.CurrencyCode,
	sum(s.Commission) as Commission
from 
	#Sales s
	inner join				--only include outlets that had at least 1 quote the previous day
	(
		select [UniqueIdentifier], sum(isnull(QuoteCount,0)) as QuoteCount, sum(isNull(PolicyCount,0)) as PolicyCount
		from #Sales
		where
			TransactionDate >= @rptYesterday and
			TransactionDate < dateadd(d,1,@rptYesterday)
		group by
			[UniqueIdentifier]
		having 
			(
				case when sum(isnull(QuoteCount,0)) = 0 and sum(isnull(PolicyCount,0)) > 0 then 0
					 when sum(isnull(QuoteCount,0)) = 0 and sum(isnull(PolicyCount,0)) = 0 then 0
					 else 1
				end
			) = 1
	) hasSales on s.[UniqueIdentifier] = hasSales.[UniqueIdentifier]
group by
	s.[UniqueIdentifier],
	s.[Month],
	s.CurrencyCode
order by 1,2
GO
