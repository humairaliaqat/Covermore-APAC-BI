USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1070]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************/
--  Name			:	rptsp_rpt1070
--  Description		:	Call Centre Performance by Client   
--  Author			:	Mercede
--  Date Created	:	20190606
--  Parameters		:	@DateRange, @StartDate, @EndDate
--  Change History	:	20191007 - ME - Made the SP Generic. Not specific to Paul Johnson MY report rules.
--						20191008 - ME - Made the SP Multivariable
/****************************************************************************************************/

CREATE PROCEDURE [dbo].[rptsp_rpt1070]
						@DateRange varchar(30),
						@StartDate varchar(10),
						@EndDate varchar(10),
						@ApplicationName NVARCHAR(MAX),
						@Group NVARCHAR(MAX),
						@Team NVARCHAR(MAX),
						@QueueTimeThreshold INT
AS

BEGIN

	---- uncomments to debug

	--DECLARE @DateRange VARCHAR(30)
	--	   ,@StartDate DATETIME
	--	   ,@EndDate DATETIME
	--	   ,@ApplicationName NVARCHAR(MAX)
	--	   ,@Group NVARCHAR(MAX)
	--	   ,@Team NVARCHAR(MAX)
	--SELECT @DateRange =  '_User Defined'
	--	  ,@StartDate = DATEADD(day, 1, EOMONTH(DATEADD(day, -1, CONVERT(date, GETDATE())), -4))		
	--	  ,@EndDate = DATEADD(day, -1, CONVERT(date, GETDATE()))	
	--	  ,@ApplicationName = 'MYMedicalAssistance'
	--	  ,@Group = 'All'		
	--	  ,@Team = 'All'					
		  	
	-- uncomments to debug
 

	--get reporting dates
	DECLARE @rptStartDate DATETIME
		   ,@rptEndDate DATETIME

	IF @DateRange = '_User Defined'
		SELECT @rptStartDate = @StartDate
			  ,@rptEndDate = @EndDate
	ELSE
		SELECT @rptStartDate = StartDate
			  ,@rptEndDate = EndDate
		FROM [db-au-cmdwh].dbo.vDateRange
		where DateRange = @DateRange

	--conditions
	IF OBJECT_ID('tempdb..#Applications') IS NOT NULL DROP TABLE #Applications
	SELECT item	AS ApplicationName 
	INTO #Applications
	FROM [db-au-cmdwh].[dbo].[fn_DelimitedSplit8K](@ApplicationName,';')

	IF OBJECT_ID('tempdb..#Groups') IS NOT NULL DROP TABLE #Groups
	SELECT item	AS [Group]
	INTO #Groups
	FROM [db-au-cmdwh].[dbo].[fn_DelimitedSplit8K](@Group,';')

	IF OBJECT_ID('tempdb..#Teams') IS NOT NULL DROP TABLE #Teams
	SELECT item	AS Team 
	INTO #Teams
	FROM [db-au-cmdwh].[dbo].[fn_DelimitedSplit8K](@Team,';')

	--get report data
	SELECT	@rptStartDate	AS ReportingStartDate,
			@rptEndDate	AS ReportingEndDate,
			@QueueTimeThreshold	AS QueueTimeThreshold,
			c.ApplicationName,
			m.[Group],
			c.SessionKey,
			c.SessionID,
			c.ContactType,
			c.GatewayNumber,	
			c.CSQName,		
			c.Agent,
			c.Team,
			c.CallStartDateTime,		
			c.QueueTime,	
			c.QueueHandled,
			c.QueueAbandoned,	
			c.TalkTime,
			c.HoldTime,	
			c.WorkTime,
			c.RingTime,
			c.MetServiceLevel
	  FROM [db-au-cmdwh].[dbo].[cisCalls] c
	  INNER JOIN [db-au-workspace].[dbo].[cisCallsPartnerMapping] m
		ON c.GatewayNumber = m.GatewayNumber
	  WHERE c.CallStartDateTime >= @rptStartDate
		AND c.CallStartDateTime < DATEADD(day, 1, @rptEndDate)	
		AND (@ApplicationName = 'All'
				OR EXISTS (SELECT 1 FROM #Applications a WHERE a.ApplicationName = c.ApplicationName) )
		AND (@Group = 'All'
				OR EXISTS (SELECT 1 FROM #Groups g WHERE g.[Group] = m.[Group]) )
		AND (@Team = 'All'
				OR EXISTS (SELECT 1 FROM #Teams t WHERE t.Team = c.Team) )

	
END
GO
