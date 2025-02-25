USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0758]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0758]	@DateRange varchar(30),
					@StartDate datetime = null,
					@EndDate datetime = null
as

SET NOCOUNT ON



/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0758
--  Author:         Saurabh Date
--  Date Created:   20160329
--  Description:    This stored procedure returns Medical Case deails
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20160329 - SD - Created
--					20160524 - SD - Changed OpenDate to OpenTime, and also changed variables to support datetime comparison
--					20160525 - SD - Addition of Date Range conditions to incorporate date time selection of 'Yesterday 8AM till midnight' and 'Today midnight to 8 AM'
--					20160607 - SD - Addition of two new columns, Customer country and customer location
--					20160616 - SD - Addition of new column, Customer Name
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @DateRange = 'Yesterday 8AM till midnight', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

/* get reporting dates */
If @DateRange = 'Yesterday 8AM till midnight'
	select @rptStartDate = DATEADD(hour,8,(DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0) - 1)),
		@rptEndDate = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0)
else if @DateRange = 'Today midnight to 8 AM'
	select @rptStartDate = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0),
		@rptEndDate = DATEADD(hour,8,DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0))
else if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		@rptEndDate = @EndDate
else
	select	@rptStartDate = StartDate, 
		@rptEndDate = EndDate
	from	[db-au-cmdwh].dbo.vDateRange
	where	DateRange = @DateRange;


SELECT 
	Distinct
 	cc.CaseNo [Case Number],
	cc.OpenTime [Case Open Date],
	cc.CountryKey [Country],
	(cc.FirstName + ' ' + cc.SurName) [Customer Name],
	cc.Location [Customer Location],
	cc.Country [Customer Country],
	cc.RiskLevel [Case Risk Level],
	cc.IncidentType [Incident Type],
	cc.TotalEstimate [Estimate],
	cn.NoteType [Note Type],
	cn.CreateDate [Note Create Date],
	'Yes' [NA Note Assessed],
	@rptStartDate [Start Date],
	@rptEndDate [End Date]
FROM
  	cbCase cc INNER JOIN cbNote cn 
		ON cn.CaseKey=cc.CaseKey
WHERE
   	cn.NoteType  = 'NURSING ASSESSMENT'
   	AND
   	cc.OpenTime between  @rptStartDate and @rptEndDate
   	AND
   	cc.IsDeleted = 0
   	AND
   	cc.Protocol='Medical'

UNION

SELECT 
	Distinct
  	cc.CaseNo [Case Number],
  	cc.OpenTime [Case Open Date],
  	cc.CountryKey [Country],
	(cc.FirstName + ' ' + cc.SurName) [Customer Name],
	cc.Location [Customer Location],
	cc.Country [Customer Country],
  	cc.RiskLevel [Case Risk Level],
  	cc.IncidentType [Incident Type],
  	cc.TotalEstimate [Estimate],
  	cn.NoteType [Note Type],
  	cn.CreateDate [Note Create Date],
  	Case 
		when NA.NAValue > 0 then 'Yes'
		Else 'No'
	End [NA Note Assessed],
	@rptStartDate [Start Date],
	@rptEndDate [End Date]
FROM
	cbCase cc INNER JOIN cbNote cn 
		ON cn.CaseKey = cc.CaseKey
	Outer Apply
   (
		select
			Sum(Case
				when cn2.NoteType = 'NURSING ASSESSMENT' then 1
				else 0
			end) [NAValue]
		from
			cbNote cn2
		where
			cn2.CaseKey = cn.CaseKey
	) NA
WHERE
	cn.NoteType in ( 'MEDICAL OFFICER', 'M/C NOTE' )
	AND
	cc.OpenTime between  @rptStartDate and @rptEndDate
	AND
	cc.IsDeleted = 0
	AND
	cc.Protocol = 'Medical'

UNION

SELECT 
	Distinct
	cc.CaseNo [Case Number],
	cc.OpenTime [Case Open Date],
	cc.CountryKey [Country],
	(cc.FirstName + ' ' + cc.SurName) [Customer Name],
	cc.Location [Customer Location],
	cc.Country [Customer Country],
	cc.RiskLevel [Case Risk Level],
	cc.IncidentType [Incident Type],
	cc.TotalEstimate [Estimate],
	NULL [Note Type],
	NULL [Note Create Date],
	'No' [NA Note Assessed],
	@rptStartDate [Start Date],
	@rptEndDate [End Date]
FROM
	cbCase cc INNER JOIN cbNote cn 
		ON cn.CaseKey=cc.CaseKey
	Outer Apply
	(
		select
		Sum(Case
				when cn2.NoteType='NURSING ASSESSMENT' then 1
				else 0
			end) [NAValue],
		Sum(Case
				when cn2.NoteType in ( 'MEDICAL OFFICER', 'M/C NOTE' ) then 1
				else 0
			end) [Value]
		from
			cbNote cn2
		where
			cn2.CaseKey=cn.CaseKey
	) NA
WHERE
	cn.NoteType not in ( 'NURSING ASSESSMENT', 'MEDICAL OFFICER', 'M/C NOTE' )
	AND
	cc.OpenTime between  @rptStartDate and @rptEndDate
	AND
	cc.IsDeleted = 0
	AND
	cc.Protocol = 'Medical'
	AND
	NA.NAValue = 0
	AND
	NA.Value = 0
GO
