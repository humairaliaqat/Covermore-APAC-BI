USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCBFirstUWDecision]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vCBFirstUWDecision] as

--20150714_LT - T16701, Added count of all WOP statuses for each case in reporting period

select 
    cc.CaseKey,
    case
        when cac.LastUWCoverStatus = 'Without Prejudice' then cac.LastUWCoverStatus
        when FirstUWDecision = 'UC' then 'Covered'
        when FirstUWDecision = 'UD' then 'Cover Declined'
        else cac.LastUWCoverStatus
    end UWCoverStatus,
    cac.LastUWCoverStatus,
    convert(datetime, convert(varchar(7), cn.FirstUWDecisionTime, 120) + '-01') StartOfMonth,
    cn.FirstUWDecisionTime,
    datediff(hh, cc.CreateDate, cn.FirstUWDecisionTime) / 24.00 DaysElapsed,
    1 CaseCount,
    FirstDecisionMaker,
	wop.WOPALLCount
from
    cbCase cc
    cross apply
    (
        select top 1 
            cn.UserName FirstDecisionMaker,
            NoteCode FirstUWDecision,
            NoteTime FirstUWDecisionTime
        from
            cbNote cn
        where
            cn.CaseKey = cc.CaseKey and
            cn.NoteCode in ('UC', 'UD')
        order by
            cn.NoteTime
    ) cn
    cross apply
    (
        select top 1
            cac.UWCoverStatus LastUWCoverStatus
        from    
            cbAuditCase cac
        where
            cac.CaseKey = cc.CaseKey and
            cac.isUWCoverChanged = 1 and
            cac.UWCoverStatus <> 'ACCOUNTS' and
            cac.AuditDateTime < dateadd(month, 1, convert(datetime, convert(varchar(7), cn.FirstUWDecisionTime, 120) + '-01'))
        order by
            cac.AuditDateTime desc
    ) cac
	outer apply					--count all WOP statuses for each case in reporting period
	(
        select
            count(distinct CaseNo) as WOPALLCount
        from    
            cbAuditCase cac
        where
            cac.CaseKey = cc.CaseKey and
            cac.isUWCoverChanged = 1 and
            cac.UWCoverStatus <> 'ACCOUNTS' and
            --cac.AuditDateTime < dateadd(month, 1, convert(datetime, convert(varchar(7), cn.FirstUWDecisionTime, 120) + '-01')) and
			cac.UWCoverStatus = 'Without Prejudice'
	) wop

GO
