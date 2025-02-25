USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0880g]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- MDM Log Table Count
CREATE PROCEDURE [dbo].[rptsp_rpt0880g]
AS
/****************************************************************************************************/
--  Name:           rptsp_rpt0880g
--  Author:         Ryan Lee
--  Date Created:   20170815
--  Description:    Used by RPT0880 for MDM Data-In Monitoring - MDM Log
--  Parameters:     N/A
/****************************************************************************************************/
select RowIDCount, TableName
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select count(1) as RowIDCount, ''C_REPOS_AUDIT'' as TableName from [MDM_Distributor]..C_REPOS_AUDIT with (nolock)
union
select count(1), ''C_REPOS_MQ_DATA_CHANGE'' from [MDM_Distributor]..C_REPOS_MQ_DATA_CHANGE with (nolock)
union
select count(1), ''C_REPOS_JOB_METRIC'' from [MDM_Distributor]..C_REPOS_JOB_METRIC with (nolock)
union
select count(1), ''C_REPOS_MET_VALID_MSG'' from [MDM_Distributor]..C_REPOS_MET_VALID_MSG with (nolock)
union
select count(1), ''C_REPOS_TASK_ASSIGNMENT_HIST'' from [MDM_Distributor]..C_REPOS_TASK_ASSIGNMENT_HIST with (nolock)
union
select count(1), ''C_REPOS_JOB_CONTROL'' from [MDM_Distributor]..C_REPOS_JOB_CONTROL with (nolock)
union
select count(1), ''C_REPOS_JOB_GROUP_CONTROL'' from [MDM_Distributor]..C_REPOS_JOB_GROUP_CONTROL with (nolock)
union
select count(1), ''C_REPOS_MET_VALID_RESULT'' from [MDM_Distributor]..C_REPOS_MET_VALID_RESULT with (nolock)
union
select count(1), ''C_REPOS_APPLIED_LOCK'' from [MDM_Distributor]..C_REPOS_APPLIED_LOCK with (nolock)
union
select count(1), ''C_PARTY_PRODUCT_TXN'' from [MDM_Distributor]..C_PARTY_PRODUCT_TXN with (nolock)
union
select count(1), ''C_PARTY_IDENTIFIER'' from [MDM_Distributor]..C_PARTY_IDENTIFIER with (nolock)
union
select count(1), ''C_PARTY'' from [MDM_Distributor]..C_PARTY with (nolock)
')


GO
