USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0880e]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[rptsp_rpt0880e]
AS
/****************************************************************************************************/
--  Name:           rptsp_rpt0880e
--  Author:         Ryan Lee
--  Date Created:   20170815
--  Description:    Used by RPT0880 for MDM Data-In Monitoring - MDM Product
--  Parameters:     N/A
/****************************************************************************************************/
select LAST_ROWID_SYSTEM
, PROD_TYP
, PRTY_ROLE
, PartyStatus
, CONSOLIDATION_IND
, CreateDateGroup
, RowIDCount
, ProductIDCount
, PartyIDCount
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select mprd.LAST_ROWID_SYSTEM
, mprd.PROD_TYP
, mprd.PRTY_ROLE
, mp.STATUS as PartyStatus
, mp.CONSOLIDATION_IND
, case when datediff(HOUR, mprd.CREATE_DATE, getdate()) <= 0 then ''A: This Hour''
	when datediff(DAY, mprd.CREATE_DATE, getdate()) <= 0 then ''B: Today''
	when datediff(WEEK, mprd.CREATE_DATE, getdate()) <= 0 then ''C: This Week''
	when datediff(MONTH, mprd.CREATE_DATE, getdate()) <= 0 then ''D: This Month''
	when datediff(YEAR, mprd.CREATE_DATE, getdate()) <= 0 then ''E: This Year''
	when datediff(YEAR, mprd.CREATE_DATE, getdate()) <= 1 then ''F: Last Year''
	else ''G: Other'' end as CreateDateGroup
, count(1) as RowIDCount
, count(distinct mprd.PROD_REF_NO) as ProductIDCount
, count(distinct mprd.PRTY_FK) as PartyIDCount
from [MDM_Distributor]..C_PARTY_PRODUCT_TXN mprd with (nolock)
left join [MDM_Distributor]..C_PARTY mp with (nolock) on mp.ROWID_OBJECT = mprd.PRTY_FK
group by mprd.LAST_ROWID_SYSTEM
, mprd.PROD_TYP
, mprd.PRTY_ROLE
, mp.STATUS
, mp.CONSOLIDATION_IND
, case when datediff(HOUR, mprd.CREATE_DATE, getdate()) <= 0 then ''A: This Hour''
	when datediff(DAY, mprd.CREATE_DATE, getdate()) <= 0 then ''B: Today''
	when datediff(WEEK, mprd.CREATE_DATE, getdate()) <= 0 then ''C: This Week''
	when datediff(MONTH, mprd.CREATE_DATE, getdate()) <= 0 then ''D: This Month''
	when datediff(YEAR, mprd.CREATE_DATE, getdate()) <= 0 then ''E: This Year''
	when datediff(YEAR, mprd.CREATE_DATE, getdate()) <= 1 then ''F: Last Year''
	else ''G: Other'' end')
GO
