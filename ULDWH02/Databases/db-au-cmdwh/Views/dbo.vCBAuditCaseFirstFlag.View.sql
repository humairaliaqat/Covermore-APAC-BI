USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCBAuditCaseFirstFlag]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vCBAuditCaseFirstFlag] 
as
select 
    CaseKey,
    FirstClosedID,
    FirstReopenedID
from
    cbCase cc
    outer apply
    (
        select
            min(BIRowID) FirstClosedID
        from
            cbAuditCase acc
        where
            acc.CaseKey = cc.CaseKey and
            isClosed = 1
    ) fc
    outer apply
    (
        select
            min(BIRowID) FirstReopenedID
        from
            cbAuditCase acc
        where
            acc.CaseKey = cc.CaseKey and
            isReopened = 1
    ) fr
GO
