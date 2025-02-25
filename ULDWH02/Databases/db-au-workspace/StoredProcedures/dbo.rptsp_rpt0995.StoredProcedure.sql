USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0995]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[rptsp_rpt0995] @CountryCode varchar(3),
									  @LoadType varchar(50),
									  @DateRange varchar(30),
									  @StartDate datetime,
									  @EndDate datetime,
									  @UniqueIdentifier varchar(50)
as	

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0995
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns consultant list by Country. The list is for uploading to
--					SugarCRM.
--  Parameters:     @CountryCode:	Required. Valid country code (AU, NZ, MY, SG, US, UK etc...)
--					@LoadType:		Required. Valid values (Full, Delta, Test Full, Test Delta)
--									If value is Full, the output is all consultants.
--									If value is Delta, the output is all new/amended consultants. 
--									If value is Test Full, the output is all test consultants.
--									If value is Test Delta, the output is the account that is passed in @UniqueIdentifier parameter.
--					@DateRange:		Required. Standard date range or _User Defined. Default value 'Last Hour'
--					@StartDate:		Optional. Only enter if DateRange = _User Defined. Format: yyyy-mm-dd hh:mm:ss (eg. 2018-01-01 10:59:00)
--					@EndDate:		Optional. Only enter if DateRange = _User Defined. Format: yyyy-mm-dd hh:mm:ss (eg. 2018-01-01 11:59:00)
--					@UniqueIdentifier: Optional. Valid UniqueIdentifier value. Eg. 'AU.CMA.66A61V.FionaGilbert'
--  
--  Change History: 20180515 - LT - Created
--					20180529 - LT - Exclude Inactive status consultants
--                  20180530 - RS - Exclude Inactive status consultants for Full load only and included for Delta load. Fixed window period also for delta load.
--					20180621 - LT - Added isSynced is null to all where clauses
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @CountryCode varchar(3), @LoadType varchar(50), @DateRange varchar(30), @StartDate datetime, @EndDate datetime, @UniqueIdentifier varchar(50)
select @CountryCode = 'AU', @LoadType = 'Test Full', @DateRange = 'Last Hour', @StartDate = null, @EndDate = null, @UniqueIdentifier =  'AU.CMA.66A61V.FionaGilbert'
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


if @LoadType = 'Full'
begin
	select
		[UniqueIdentifier],
		[Name],
		FirstName,
		LastName,
		UserName,
		UserType,
		[OutletUniqueIdentifier],
		[Status],		
		[InactiveStatusDate],
		Email,
		DateOfBirth
	from 
		[db-au-ods].dbo.scrmConsultant
	where
		[Status] = 'Active' and
		isSynced is null
	order by 1,2
end
else if @LoadType = 'Delta'
begin
	select
		[UniqueIdentifier],
		[Name],
		FirstName,
		LastName,
		UserName,
		UserType,
		[OutletUniqueIdentifier],
		[Status],		
		[InactiveStatusDate],
		Email,
		DateOfBirth
	from 
		[db-au-workspace].dbo.scrmConsultant_UAT a
	where
		( 
			(
				a.LoadDate >= @rptStartDate and				
				a.LoadDate <= @rptEndDate
			) or
			(
				a.UpdateDate >= @rptStartDate and				
				a.UpdateDate <= @rptEndDate
			)
		)  and
		isSynced is null
	order by 1,2
end
else if @LoadType = 'Test Full'
begin
	select 
		[UniqueIdentifier],
		[Name],
		FirstName,
		LastName,
		UserName,
		UserType,
		[OutletUniqueIdentifier],
		[Status],		
		[InactiveStatusDate],
		Email,
		DateOfBirth
	from
	(
		select
			row_number() over (partition by [OutletUniqueIdentifier] order by [OutletUniqueIdentifier], [UniqueIdentifier]) as RowID,
			[UniqueIdentifier],
			[Name],
			FirstName,
			LastName,
			UserName,
			UserType,
			[OutletUniqueIdentifier],
			[Status],		
			[InactiveStatusDate],
			Email,
			DateOfBirth
		from 
			[db-au-ods].dbo.scrmConsultant a
		where 
			a.[Status] = 'Active' and
			a.[OutletUniqueIdentifier] in (select [UniqueIdentifier] from [db-au-ods].dbo.scrmTestAccount) and
			isSynced is null
	) b
	where b.RowID <= 5
	order by [OutletUniqueIdentifier], [UniqueIdentifier]
end
else if @LoadType = 'Test Delta'
begin
	select
		[UniqueIdentifier],
		[Name],
		FirstName,
		LastName,
		UserName,
		UserType,
		[OutletUniqueIdentifier],
		[Status],		
		[InactiveStatusDate],
		Email,
		DateOfBirth
	from 
		[db-au-ods].dbo.scrmConsultant a
	where 
		a.[UniqueIdentifier] = @UniqueIdentifier and
		isSynced is null
end


GO
