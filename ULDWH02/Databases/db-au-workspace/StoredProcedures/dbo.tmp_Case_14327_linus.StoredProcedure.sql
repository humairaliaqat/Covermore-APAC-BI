USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_Case_14327_linus]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[tmp_Case_14327_linus]	@ReportingPeriod varchar(30),	--values 'last month', 'Year-To-Date'
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON 


/****************************************************************************************************/
-- Name:			[dbo].[tmp_Case14327]
-- Author:			Sharmila Inbaseelan
-- Create date:		20101112
-- Description:		This stored procedure returns the 'NET SALES' achieved by each BDM in each month 
--					for this year and last year with breakdown for each agency group by BDM.
-- Parameters:		@ReportingPeriod = values like 'last month', 'Year-To-Date','User Defined'
--					@StartDate = null,							-- Start date 
--					@EndDate   = null							-- End date 
-- Change History:	
/****************************************************************************************************/
--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @ReportingPeriod = 'last month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @LYrptStartDate datetime
declare @LYrptEndDate datetime


if @ReportingPeriod = 'User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
select @rptStartDate = StartDate, @rptEndDate = EndDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = @ReportingPeriod
  
select @LYrptStartDate =dateadd(year, -1, @rptStartDate),@LYrptEndDate =dateadd(year, -1, @rptEndDate)
  
  select 
	  a.AgencyGroupName,
	  a.BDMName,
	  sum(case when p.CreateDate between @rptStartDate and @rptEndDate then (p.NetPremium) end)TYNETSales,
	  sum(case when p.CreateDate between @LYrptStartDate and @LYrptEndDate then	(p.NetPremium)end)LYNETSales,
	  @rptStartDate as TYStartDate,
	  @rptEndDate as LYEndDate,
	  @LYrptStartDate as LYrptStartDate,
	  @LYrptEndDate as LYrptEndDate
  
  from [db-au-cmdwh].dbo.Agency a
	  join [db-au-cmdwh].dbo.Policy p on p.CountryKey = a.CountryKey and p.AgencyKey = a.AgencyKey
  
  where 
	  p.CountryKey = 'NZ' and
	  (p.CreateDate between @rptStartDate and @rptEndDate or p.CreateDate between @LYrptStartDate and @LYrptEndDate)
		 
 group by
	  a.AgencyGroupName,
	  a.BDMName
GO
