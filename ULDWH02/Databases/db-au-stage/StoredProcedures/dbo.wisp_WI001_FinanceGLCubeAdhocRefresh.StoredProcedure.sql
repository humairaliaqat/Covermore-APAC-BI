USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[wisp_WI001_FinanceGLCubeAdhocRefresh]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[wisp_WI001_FinanceGLCubeAdhocRefresh]	@BusinessUnit varchar(200),
															@Scenario varchar(200),
															@paramStartDate varchar(10),
															@paramEndDate varchar(10)
as

/************************************************************************************************************************************
Author:         Linus Tor
Title:			dbo.wisp_WI001_FinanceGLCubeAdhocRefresh
Date:           20171019
Prerequisite:   Finance team sends SNOW ticket request to refresh Finance GL Cube.
                Parameters to be supplied by Finance team in the request:
					*BusinessUnit
					*Scenario
					*StartDate
					*EndDate
Description:    Refresh Finance GL Cube
Parameters:     @BusinessUnit:	use * for all business units, or enter 1 or more business units (separated by comma).
				@Scenario:		use * from all scenarios, or enter 1 or more scenarios (separated by comma).
				@StartDate:		format yyyy-mm-dd (eg. 2016-07-01)
				@EndDate:		format yyyy-mm-dd (eg. 2017-06-30)
Change History:
                20171019 - LT - Procedure created
								
*************************************************************************************************************************************/

--uncomment to debug
/*
declare @BusinessUnit varchar(200)
declare @Scenario varchar(200)
declare @paramStartDate varchar(10)
declare @paramEndDate varchar(10)
select @BusinessUnit = '*', @Scenario = '*', @paramStartDate = '2016-07-01', @paramEndDate = '2017-06-30'
*/

DECLARE @batchid INT, 
		@start DATE, 
		@end DATE, 
		@paramBU VARCHAR(MAX), 
		@paramScenario VARCHAR(MAX)
    

-- start and end of FY
SELECT	@start = MIN(CurFiscalYearStart),
		@end = MAX(CurFiscalYear)
FROM 
	[db-au-cmdwh]..Calendar
WHERE
	[Date] = CONVERT(DATE, GETDATE()) OR 
	(
		DATEPART(mm, GETDATE()) = 7 AND 
		[Date] = CONVERT(date, DATEADD(MONTH, -1, GETDATE()))
    )
	

--specify refresh date range here
EXEC [db-au-stage]..syssp_createbatch
    @SubjectArea = 'SUN GL',
    @StartDate = @paramStartDate,
    @EndDate = @paramEndDate

EXEC [db-au-stage]..syssp_getrunningbatch
    @SubjectArea = 'SUN GL',
    @BatchID = @batchid out,
    @StartDate = @start out,
    @EndDate = @end out

EXEC [db-au-stage]..syssp_genericerrorhandler
    @LogToTable = 1,
    @ErrorCode = '0',
    @BatchID = @batchid,
    @PackageID = '[PARAMETER_BUSINESSUNIT]',
    @LogStatus = @paramBU

EXEC [db-au-stage]..syssp_genericerrorhandler
    @LogToTable = 1,
    @ErrorCode = '0',
    @BatchID = @batchid,
    @PackageID = '[PARAMETER_SCENARIO]',
    @LogStatus = @paramScenario


--call the sql agent and be done with it
--when it's finished we will get email notification
EXEC msdb.dbo.sp_start_job 
    @job_name = N'ETL033_Finance_Data',
    @step_name = N'Stage'
GO
