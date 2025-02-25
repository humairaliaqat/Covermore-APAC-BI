USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[usrFindRunningQueries]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usrFindRunningQueries]
as

SELECT
  CN.session_id  AS SPID,
  ST.text        AS SqlStatementText
FROM
  sys.dm_exec_connections AS CN
CROSS APPLY
  sys.dm_exec_sql_text(CN.most_recent_sql_handle) AS ST
ORDER BY
  CN.session_id
GO
