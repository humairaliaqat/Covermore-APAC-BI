USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0880f]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[rptsp_rpt0880f]
AS
/****************************************************************************************************/
--  Name:           rptsp_rpt0880f
--  Author:         Ryan Lee
--  Date Created:   20170815
--  Description:    Used by RPT0880 for MDM Data-In Monitoring - MDM Identifier
--  Parameters:     N/A
/****************************************************************************************************/
select LAST_ROWID_SYSTEM
, IDNTIFR_TYP
, IDNTIFR_SUB_TYP
, PartyStatus
, CONSOLIDATION_IND
, CreateDateGroup
, RowIDCount
, IdentifierIDCount
, PartyIDCount
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select midt.LAST_ROWID_SYSTEM
, midt.IDNTIFR_TYP
, midt.IDNTIFR_SUB_TYP
, mp.STATUS as PartyStatus
, mp.CONSOLIDATION_IND
, case when datediff(HOUR, midt.CREATE_DATE, getdate()) <= 0 then ''A: This Hour''
	when datediff(DAY, midt.CREATE_DATE, getdate()) <= 0 then ''B: Today''
	when datediff(WEEK, midt.CREATE_DATE, getdate()) <= 0 then ''C: This Week''
	when datediff(MONTH, midt.CREATE_DATE, getdate()) <= 0 then ''D: This Month''
	when datediff(YEAR, midt.CREATE_DATE, getdate()) <= 0 then ''E: This Year''
	when datediff(YEAR, midt.CREATE_DATE, getdate()) <= 1 then ''F: Last Year''
	else ''G: Other'' end as CreateDateGroup
, count(1) as RowIDCount
, count(distinct midt.IDNTIFR_VAL) as IdentifierIDCount
, count(distinct midt.PRTY_FK) as PartyIDCount
from [MDM_Distributor]..C_PARTY_IDENTIFIER midt with (nolock)
left join [MDM_Distributor]..C_PARTY mp with (nolock) on mp.ROWID_OBJECT = midt.PRTY_FK
group by midt.LAST_ROWID_SYSTEM
, midt.IDNTIFR_TYP
, midt.IDNTIFR_SUB_TYP
, mp.STATUS
, mp.CONSOLIDATION_IND
, case when datediff(HOUR, midt.CREATE_DATE, getdate()) <= 0 then ''A: This Hour''
	when datediff(DAY, midt.CREATE_DATE, getdate()) <= 0 then ''B: Today''
	when datediff(WEEK, midt.CREATE_DATE, getdate()) <= 0 then ''C: This Week''
	when datediff(MONTH, midt.CREATE_DATE, getdate()) <= 0 then ''D: This Month''
	when datediff(YEAR, midt.CREATE_DATE, getdate()) <= 0 then ''E: This Year''
	when datediff(YEAR, midt.CREATE_DATE, getdate()) <= 1 then ''F: Last Year''
	else ''G: Other'' end')


GO
