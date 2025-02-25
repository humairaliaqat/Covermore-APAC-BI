USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0998]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[rptsp_rpt0998] @CountryCode varchar(3),
									   @LoadType varchar(50),
									   @DateRange varchar(30),
									   @StartDate datetime,
									   @EndDate datetime,
									   @UniqueIdentifier varchar(50)
as	

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0998
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns strike rate data. The strike rate data is for uploading to SugarCRM.
--  Parameters:     @CountryCode:	Required. Valid country code (AU, NZ, MY, SG, US, UK etc...)
--					@LoadType:		Required. Valid values (Full, Delta, Test Full, Test Delta)
--									If value is Full, the output is all accounts in the reporting period
--									If value is Delta, the output is all new sales the previous day
--									If value is Test Full, the output is all test accounts and respective sales.
--									If value is Test Delta, the output is the account and sales that is passed in @UniqueIdentifier parameter.
--					@DateRange:		Required. Standard date range or _User Defined. Default value 'Last Month'
--					@StartDate:		Optional. Only enter if DateRange = _User Defined. Format: yyyy-mm-dd hh:mm:ss (eg. 2018-01-01 10:59:00)
--					@EndDate:		Optional. Only enter if DateRange = _User Defined. Format: yyyy-mm-dd hh:mm:ss (eg. 2018-01-01 11:59:00)
--					@UniqueIdentifier: Optional. Valid UniqueIdentifier value. Eg. 'AU.CMA.66A61V'
--  
--  Change History: 20180515 - LT - Created
--					20180621 - LT - added isSynced is null to all WHERE clauses
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @CountryCode varchar(3), @LoadType varchar(50), @DateRange varchar(30), @StartDate datetime, @EndDate datetime, @UniqueIdentifier varchar(50)
select @CountryCode = 'AU', @LoadType = 'Delta', @DateRange = 'Last Month', @StartDate = null, @EndDate = null, @UniqueIdentifier =  'AU.CMA.FLN0025'
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
		a.[Month],
		a.StrikeRate
	from
		[db-au-ods].dbo.scrmStrikeRate a
	where
		a.isSynced is null and
		[Month] >= '2016-01-01'								--modified by Ratnesh based on request made by Loaded team on 27-jun
end
else if @LoadType = 'Delta'
begin
	select
		a.[UniqueIdentifier],
		a.[Month],
		a.StrikeRate
	from
		[db-au-ods].dbo.scrmStrikeRate a
	where
		a.[Month] >= @rptStartDate and
		a.[Month] < @rptEndDate and
		a.isSynced is null
end
else if @LoadType = 'Test Full'
begin
	select
		a.[UniqueIdentifier],
		c.[Month],
		c.StrikeRate
	from
		[db-au-ods].dbo.scrmTestAccount a
		outer apply
		(
			select 
				[UniqueIdentifier],
				[Month],
				StrikeRate,
				isSynced
			from
				[db-au-ods].dbo.scrmStrikeRate 	
			where
				[UniqueIdentifier] = a.[UniqueIdentifier]
		) c
	where
		c.isSynced is null and
		[Month] >= '2016-01-01'								--modified by Ratnesh based on request made by Loaded team on 27-jun
	order by 1,2,3
end
else if @LoadType = 'Test Delta'
begin
	select
		a.[UniqueIdentifier],
		a.[Month],
		a.StrikeRate
	from
		[db-au-ods].dbo.scrmStrikeRate a	
	where
		[UniqueIdentifier] = @UniqueIdentifier and
		a.isSynced is null
end






GO
