USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1064]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************/
--  Name			:	rptsp_rpt1064
--  Description		:	Claims Call Daily Stats Report
--  Author			:	Yi Yang
--  Date Created	:	20190416
--  Parameters		:	
--  Change History	:	
/****************************************************************************************************/

CREATE PROCEDURE [dbo].[rptsp_rpt1064]
AS

begin
    set nocount on


---- uncomments to debug
DECLARE @ReportingPeriod VARCHAR(30)
, @StartDate DATETIME
, @EndDate DATETIME
SELECT @ReportingPeriod =  '_User Defined'
, @StartDate = dateadd(day, 1, EOMONTH(DATEADD(day, -1, convert(date, GETDATE())), -2))		 
, @EndDate = dateadd(day, -1, convert(date, GETDATE()))									 
-- uncomments to debug


if object_id('tempdb..#temp_calls') is not null
        drop table #temp_calls

-----------------------------------------------------
select 
	*
into 
	#temp_calls
from (

-- Inbound Calls via CSQ 
	select 
		'Inbound CSQ' as CallType,
		c.CallDate,
		c.CSQname, 
		c.AgentName, 
		c.DialedNumber, 
		c.DestinationAgent, 
		c.OriginatorExt, 
		c.SessionID,
		c.QueueHandled
	from 
		vtelephonydata as c
	where 

		c.CSQName <> 'Unknown' and
		c.AgentName in (select TeamMember from usrLDAPTeam where isActive = 1) and
	 	convert(date, c.CallStartDateTime) between @StartDate and @EndDate

	union
	-- Inbound Calls direct
	select 
		'Inbound Direct' as CallType,
		c.CallDate,
		c.CSQname, 
		ag.AgentName,
		c.DialedNumber, 
		c.DestinationAgent, 
		c.OriginatorExt, 
		c.SessionID,
		c.QueueHandled
	from 
		vtelephonydata as c
		left join cisAgent as ag on (c.DialedNumber = ag.Extension)
	where 

		ag.AgentName in (select TeamMember from usrLDAPTeam where isActive = 1) and
		convert(date, c.CallStartDateTime) between @StartDate and @EndDate

	union
	-- Outbound calls from extension 
	select 	
		'Outbound' as CallType,
		c.CallDate,
		c.CSQname, 
		ag.AgentName,
		c.DialedNumber, 
		c.DestinationAgent, 
		c.OriginatorExt, 
		c.SessionID,
		c.QueueHandled
	from 
		vtelephonydata as c
		left join cisAgent as ag on (c.OriginatorExt = ag.Extension)
	where 

		ag.AgentName in (select TeamMember from usrLDAPTeam where isActive = 1) 
		and c.ContactType = 'Outgoing'
		and convert(date, c.CallStartDateTime) between @StartDate and @EndDate

	) a

;WITH Call_cte AS (
	select 
		CallDate,
		AgentName,
		count(distinct case when CallType = 'Inbound CSQ' then SessionID else null end) as InboundCSQ, 
		count(distinct case when CallType = 'Inbound CSQ' and QueueHandled = '1' then SessionID else null end) as InboundCSQAnswered, 
		count(distinct case when CallType = 'Inbound Direct' then SessionID else null end) as InboundDirect, 
		count(distinct case when CallType = 'Inbound Direct' and QueueHandled = '1' then SessionID else null end) as InboundDirectAnswered, 
		count(distinct case when CallType = 'Outbound' then SessionID else null end) as Outbound
	from #temp_calls
	Group by
		CallDate,
		AgentName
	),

State_cte as (
-- Get Ready, Lunch/Break, and Not Ready RNA
	select 
		AgentName, 
		convert(date, EventDateTime) as CallDate,
		sum(case when ReasonCode in ('6', '7') then EventDuration else 0 end) as TotalBreakLunchDuration,
		sum(case when EventType = '3' then EventDuration else 0 end) as TotalReadyDuration,
		sum(case when EventType = '5' then EventDuration else 0 end) as TotalTalkDuration,
		--count(case when ReasonCode in ('32763') then EventDuration else 0 end) as CountNotReadyRNA,
		sum(case when ReasonCode in ('32763') then EventDuration else 0 end) as TotalNotReadyRNADuration
	from 
		cisAgentState as ast
		join cisAgent as ag on (ast.AgentKey = ag.AgentKey)
	where 
		convert(date, ast.EventDateTime) between @StartDate and @EndDate
		and ag.AgentName in (select TeamMember from usrLDAPTeam where isActive = 1)
	group by
		AgentName, 
		convert(date, ast.EventDateTime)
	)
-- Generate report columns 
select
	ag.TeamMember as AgentName,
	c.CallDate,
	isnull(c.InboundCSQ, 0) as InboundCSQ,
	isnull(c.InboundCSQAnswered, 0) as InboundCSQAnswered,
	isnull(c.InboundDirect, 0) as InboundDirect,
	isnull(c.InboundDirectAnswered, 0) as InboundDirectAnswered,
	isnull(c.Outbound, 0) as Outbound,
	--left(CONVERT(varchar, DATEADD(ms, s.TotalBreakLunchDuration * 1000, 0), 114), 8) as TotalBreakLunch,
	--left(CONVERT(varchar, DATEADD(ms, s.TotalReadyDuration * 1000, 0), 114), 8) as TotalReady,
	--left(CONVERT(varchar, DATEADD(ms, s.TotalTalkDuration * 1000, 0), 114), 8) as TotalTalk,
	--left(CONVERT(varchar, DATEADD(ms, s.TotalNotReadyRNADuration * 1000, 0), 114), 8) as TotalNotReadyRNA,
	s.TotalBreakLunchDuration,
	s.TotalReadyDuration,
	s.TotalTalkDuration,
	s.TotalNotReadyRNADuration

FROM 
	usrLDAPTeam as ag
	left join Call_cte as c on (ag.TeamMember = c.AgentName)
	left join State_cte as s ON (c.AgentName = s.AgentName and c.CallDate = s.CallDate)
where 
	c.CallDate is not null
	and ag.isActive = 1
order by ag.TeamMember
------------------------ 

-- Reason Code 6, 7 are "Break" and "Lunch"
--select top 100 
--* 
--from 
--	cisAgentState as ast
--	join cisAgent as ag on (ast.AgentKey = ag.AgentKey)
--where 
--	convert(date, ast.EventDateTime) between @StartDate and @EndDate
--	and ag.AgentName = 'Blake Thomas'
--	and ast.ReasonCode in ( '6', '7')

---- Eventtype = 3 is Ready
--select top 100 
--* 
--from 
--	cisAgentState as ast
--	join cisAgent as ag on (ast.AgentKey = ag.AgentKey)
--where 
--	convert(date, ast.EventDateTime) between @StartDate and @EndDate
--	and ag.AgentName = 'Blake Thomas'
--	and EventType = '3'

---- Eventtype = 5 is Talking Time
--select top 100 
--* 
--from 
--	cisAgentState as ast
--	join cisAgent as ag on (ast.AgentKey = ag.AgentKey)
--where 
--	convert(date, ast.EventDateTime) between @StartDate and @EndDate
--	and ag.AgentName = 'Blake Thomas'
--	and EventType = '5'


---- Reason Code 32763 is "Not Ready - RNA"
--select top 100 
--* 
--from 
--	cisAgentState as ast
--	join cisAgent as ag on (ast.AgentKey = ag.AgentKey)
--where 
--	convert(date, ast.EventDateTime) between @StartDate and @EndDate
--	and ag.AgentName = 'Luke Stevenson'
--	and ast.ReasonCode in ( '32763')


--select * from #temp_calls


end
GO
