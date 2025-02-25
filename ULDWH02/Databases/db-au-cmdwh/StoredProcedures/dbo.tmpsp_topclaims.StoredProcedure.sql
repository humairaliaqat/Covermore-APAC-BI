USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[tmpsp_topclaims]    Script Date: 24/02/2025 12:39:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmpsp_topclaims]	@Country varchar(2),
											@ReportingPeriod varchar(30),
											@TopAmt int
as
SET NOCOUNT ON 


--Uncomment to debug
/*testing
declare @Country varchar(2)
declare @ReportingPeriod varchar(30)
declare @TopAmt int
select @Country = 'AU', @TopAmt = 25000, @ReportingPeriod = 'Last Month'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @SQL varchar(8000)

--get reporting parameters 
select @rptStartDate = StartDate, @rptEndDate = EndDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = @ReportingPeriod

--top amount defaults to $25000 if null
if @TopAmt is null or @TopAmt = 0
	select @TopAmt = 25000

SELECT
  clmClaimSummary.EventCountryName,
  sum(clmClaimSummary.ClaimValue) as ClaimValue,
  count(distinct clmClaimSummary.ClaimKey) as ClaimCount
FROM
  vDateRange INNER JOIN Calendar ON (Calendar.Date between vDateRange.StartDate and vDateRange.EndDate)
   INNER JOIN clmClaimSummary ON (Calendar.Date = clmClaimSummary.ReceivedDate)
  
WHERE
  vDateRange.DateRange  =  @ReportingPeriod and 
  clmClaimSummary.EventCountryName <> 'Australia' and
  clmClaimSummary.EventCountryName is not null
GROUP BY
  clmClaimSummary.EventCountryName
HAVING sum(clmClaimSummary.ClaimValue) > @TopAmt
ORDER BY 2 desc


GO
