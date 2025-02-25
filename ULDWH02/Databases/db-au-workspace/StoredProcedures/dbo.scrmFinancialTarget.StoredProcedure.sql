USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[scrmFinancialTarget]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[scrmFinancialTarget]	@CountryCode varchar(2),
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
select @CountryCode = 'AU', @DateRange = 'Last 12 Months', @StartDate = null, @EndDate = null
*/

--variables
declare @rptStartDate datetime
declare @rptEndDate datetime
declare @SQL varchar(8000)

if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate, @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange	



--get Outlet Unique Identifiers
if object_id('[db-au-workspace].dbo.tmp_scrmTarget') is not null drop table [db-au-workspace].dbo.tmp_scrmTarget

select @SQL = 'select * into [db-au-workspace].dbo.tmp_scrmTarget
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


--get financial target
select
	o.CountryKey + '.' + case when o.CompanyKey = 'CM' then 'CMA' else 'TIP' end + '.' + o.AlphaCode as [UniqueIdentifier],
	f.[Date],
	sum(f.SalesTarget) as SalesTarget,
	sum(f.PolicyCount) as PolicyCount,
	oo.CurrencyCode
from
	[db-au-cmdwh].dbo.penOutlet o
	inner join [db-au-workspace].dbo.tmp_scrmTarget oo on 
		o.CountryKey = oo.CountryKey collate database_default and
		o.AlphaCode = oo.AlphaCode collate database_default and
		o.OutletStatus = 'Current'
	inner join
	(
		select
			o.Country,
			o.AlphaCode,
			convert(datetime,convert(varchar(8),d.[Date],120)+'01') as [Date],
			sum(t.SellPriceTarget) as SalesTarget,
			sum(t.PolicyCountBudget) as PolicyCount
		from
			[db-au-star].dbo.v_ic_factTarget t
			inner join [db-au-star].dbo.dimOutlet o on t.OutletSK = o.OutletSK
			inner join [db-au-star].dbo.Dim_Date d on t.DateSK = d.Date_SK
		where
			o.Country = 'AU' and
			t.OutletReference = 'Latest Alpha' and
			d.Date_SK >= convert(varchar(8),@rptStartDate,112) and
			d.Date_SK < convert(varchar(8),dateadd(d,1,@rptEndDate),112) 
		group by
			o.Country,
			o.AlphaCode,
			convert(datetime,convert(varchar(8),d.[Date],120)+'01')
	) f on 
		o.CountryKey = f.Country and 
		o.AlphaCode = f.AlphaCode
group by
	o.CountryKey + '.' + case when o.CompanyKey = 'CM' then 'CMA' else 'TIP' end + '.' + o.AlphaCode,
	f.[Date],
	oo.CurrencyCode
order by 1,2
GO
