USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0996]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--exec [rptsp_rpt0996] 'AU','Delta','_User Defined','2021-02-15 00:00:00.000','2021-02-15 11:59:00.000',''


CREATE procedure [dbo].[rptsp_rpt0996] @CountryCode varchar(3),
									   @LoadType varchar(50),
									   @DateRange varchar(30),
									   @StartDate datetime,
									   @EndDate datetime,
									   @UniqueIdentifier varchar(50)
as	

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0996
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns financial summary by account by date by Country. 
--					The financial summary list is for uploading to SugarCRM.
--  Parameters:     @CountryCode:	Required. Valid country code (AU, NZ, MY, SG, US, UK etc...)
--					@LoadType:		Required. Valid values (Full, Delta, Test Full, Test Delta)
--									If value is Full, the output is all accounts in the reporting period
--									If value is Delta, the output is all new sales the previous day
--									If value is Test Full, the output is all test accounts and respective sales.
--									If value is Test Delta, the output is the account and sales that is passed in @UniqueIdentifier parameter.
--					@DateRange:		Required. Standard date range or _User Defined. Default value 'Last Hour'
--					@StartDate:		Optional. Only enter if DateRange = _User Defined. Format: yyyy-mm-dd hh:mm:ss (eg. 2018-01-01 10:59:00)
--					@EndDate:		Optional. Only enter if DateRange = _User Defined. Format: yyyy-mm-dd hh:mm:ss (eg. 2018-01-01 11:59:00)
--					@UniqueIdentifier: Optional. Valid UniqueIdentifier value. Eg. 'AU.CMA.66A61V'
--  
--  Change History: 20180515 - LT - Created
--                  20180621 - LT - added isSynced is null to all WHERE clauses
/****************************************************************************************************/

--uncomment to debug
/*
declare @CountryCode varchar(3), @LoadType varchar(50), @DateRange varchar(30), @StartDate datetime, @EndDate datetime, @UniqueIdentifier varchar(50)
select @CountryCode = 'AU', @LoadType = 'Test Delta', @DateRange = 'Yesterday', @StartDate = null, @EndDate = null, @UniqueIdentifier =  'AU.CMA.FLN0025'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

/* get reporting dates */
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


if @LoadType = 'Full'									--get all accounts, and respective sales aggregated by month
begin
	select
		a.[UniqueIdentifier],
		f.[Month],
		f.PolicyCount,
		f.QuoteCount,
		f.GrossSales,
		f.CurrencyCode,
		f.Commission
	from
		(
			select distinct [UniqueIdentifier]
			from [db-au-ods].dbo.scrmAccount a 
		) a
		outer apply
		(
			select
				convert(varchar(8),[Date],120)+'01' as [Month],
				sum(PolicyCount) as PolicyCount,
				sum(QuoteCount) as QuoteCount,
				sum(GrossSales) as GrossSales,
				CurrencyCode,
				sum(Commission) as Commission,
				isSynced
			from
				[db-au-ods].dbo.scrmFinancialSummary 
			where
				[UniqueIdentifier] = a.[UniqueIdentifier] and
				--[Date] >= '2015-07-01'								--oldest transaction
				[Date] >= '2016-01-01'								--modified by Ratnesh based on request made by Loaded team on 27-jun
			group by
				convert(varchar(8),[Date],120)+'01',
				CurrencyCode,
				isSynced
		) f
		where
			f.isSynced is null and
			f.Month is not null--to filter out all the  null records.
	order by 1,2
end
else if @LoadType = 'Delta'
begin
	select
		a.[UniqueIdentifier],
		f.[Month],
		f.PolicyCount,
		f.QuoteCount,
		f.GrossSales,
		f.CurrencyCode,
		f.Commission
	from
		[db-au-workspace].dbo.scrmAccount_UAT a
		outer apply
		(
			select
				convert(varchar(8),[Date],120)+'01' as [Month],
				sum(PolicyCount) as PolicyCount,
				sum(QuoteCount) as QuoteCount,
				sum(GrossSales) as GrossSales,
				CurrencyCode,
				sum(Commission) as Commission,
				isSynced
			from
				[db-au-workspace].dbo.scrmFinancialSummary_UAT
			where
				[UniqueIdentifier] = a.[UniqueIdentifier] and
				[Date] >= @rptStartDate and
				[Date] < dateadd(d,1,@rptEndDate)
			group by
				convert(varchar(8),[Date],120)+'01',
				CurrencyCode,
				isSynced
		) f
	where
		(f.PolicyCount <> 0 or
		f.QuoteCount <> 0)				--added to reurn records with non zero count only
		and f.Month is not null			--to filter out all the  null records.
		and f.isSynced is null
	order by 1,2
end
else if @LoadType = 'Test Full'
begin
	select
		a.[UniqueIdentifier],
		f.[Month],
		f.PolicyCount,
		f.QuoteCount,
		f.GrossSales,
		f.CurrencyCode,
		f.Commission		
	from
		[db-au-ods].dbo.scrmTestAccount a
		outer apply
		(
			select
				convert(varchar(8),[Date],120)+'01' as [Month],
				sum(PolicyCount) as PolicyCount,
				sum(QuoteCount) as QuoteCount,
				sum(GrossSales) as GrossSales,
				CurrencyCode,
				sum(Commission) as Commission,
				isSynced
			from
				[db-au-ods].dbo.scrmFinancialSummary 
			where
				[UniqueIdentifier] = a.[UniqueIdentifier] and
				--[Date] >= '2015-07-01'
				[Date] >= '2016-01-01' --modified by Ratnesh based on request from loaded team on 27-jun
			group by
				convert(varchar(8),[Date],120)+'01',
				CurrencyCode,
				isSynced
		) f
		where 
			f.isSynced is null and
			f.Month is not null				--to filter out all the  null records.
			and 
			(
				f.PolicyCount <> 0 or
				f.QuoteCount <> 0
			)								--added to reurn records with non zero count only
	order by 1,2
end
else if @LoadType = 'Test Delta'
begin
	select
		a.[UniqueIdentifier],
		f.[Month],
		f.PolicyCount,
		f.QuoteCount,
		f.GrossSales,
		f.CurrencyCode,
		f.Commission
	from
		[db-au-ods].dbo.scrmAccount a
		outer apply
		(
			select
				convert(varchar(8),[Date],120)+'01' as [Month],
				sum(PolicyCount) as PolicyCount,
				sum(QuoteCount) as QuoteCount,
				sum(GrossSales) as GrossSales,
				CurrencyCode,
				sum(Commission) as Commission,
				isSynced
			from
				[db-au-ods].dbo.scrmFinancialSummary 
			where
				[UniqueIdentifier] = a.[UniqueIdentifier] and
				[Date] >= @rptStartDate and
				[Date] < dateadd(d,1,@rptEndDate)
			group by
				convert(varchar(8),[Date],120)+'01',
				CurrencyCode,
				isSynced
		) f
	where
		a.[UniqueIdentifier] = @UniqueIdentifier
		and f.isSynced is null 
		and f.Month is not null						--to filter out all the  null records.
		and 
		(
			f.PolicyCount <> 0 or
			f.QuoteCount <> 0
		)											--added to reurn records with non zero count only
	order by 1,2
end





GO
