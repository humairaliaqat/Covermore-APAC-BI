USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0738]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0738]		@DateRange varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as
begin

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           rptsp_RPT0738
--  Author:         Saurabh Date
--  Date Created:   20160203
--  Description:    This stored procedure returns Cases data per JV.
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20160203 - SD - Created
--					20160215 - SD - Addition of new column 'Customer Location'
--					20161130 - SD - Addition of new columns 'Program Code' and 'Program'
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
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
    o.CountryKey Country,
    jv.JVCode,
    jv.JVDescription,
	cc.ProgramCode,
	cc.Program,
    convert(date, convert(varchar(8), cc.OpenDate, 120) + '01') Period,
	cc.Country [Customer Location],
    cc.CaseType,
    cc.Protocol,
    count(CaseKey) CaseCount,
	@rptStartDate [RPT Start Date],
	@rptEndDate [RPT End Date]
from
    cbCase cc
    cross apply
    (
        select top 1 
            PolicyTransactionKey
        from
            cbPolicy cp
        where
            cp.CaseKey = cc.CaseKey and
            IsMainPolicy = 1
    ) cp
    inner join penPolicyTransSummary pt on
        pt.PolicyTransactionKey = cp.PolicyTransactionKey
    inner join penOutlet o on
        o.OutletAlphaKey = pt.OutletAlphaKey and
        o.OutletStatus = 'Current'
    inner join vpenOutletJV jv on
        jv.OutletKey = o.OutletKey
where
    OpenDate between @rptStartDate and @rptEndDate
group by
    o.CountryKey,
    jv.JVCode,
    jv.JVDescription,
	cc.ProgramCode,
	cc.Program,
    convert(date, convert(varchar(8), cc.OpenDate, 120) + '01'),
	cc.Country,
    cc.CaseType,
    cc.Protocol

end
GO
