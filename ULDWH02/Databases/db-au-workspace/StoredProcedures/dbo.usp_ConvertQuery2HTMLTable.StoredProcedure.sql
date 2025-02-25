USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[usp_ConvertQuery2HTMLTable]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ConvertQuery2HTMLTable]
 @SQLQuery NVARCHAR(3000) -- the SQL query text to execute. i.e. 'SELECT Column1 FROM dbo.view'
AS
/* =============================================
returns the @SQLQuery as an HTML table with header
============================================= */
BEGIN
 SET NOCOUNT ON
 DECLARE @headerlist NVARCHAR (1000) = ''
 DECLARE @columnslist NVARCHAR (1000) = ''
 DECLARE @restOfQuery NVARCHAR (2000) = ''
 DECLARE @DynTSQL NVARCHAR (3000)
 DECLARE @FROMPOS INT
 SELECT -- quote the header names
  @headerlist += 'ISNULL (''' + NAME + ''',' + '''' + ' ' + '''' + ')' + ','
 FROM
  sys.dm_exec_describe_first_result_set(@SQLQuery, NULL, 0)

 SELECT -- bracket NAME if input arg has [colum name] with spaces
  @columnslist += 'ISNULL ([' + NAME + '],' + '''' + ' ' + '''' + ')' + ','
 FROM
  sys.dm_exec_describe_first_result_set(@SQLQuery, NULL, 0)
 SET @headerlist = LEFT(@headerlist, LEN (@headerlist) - 1) -- trim the last comma from the list
 SET @columnslist = LEFT(@columnslist, LEN (@columnslist) - 1) -- trim the last comma from the list
 SET @FROMPOS = CHARINDEX ('FROM', @SQLQuery, 1)
 SET @restOfQuery = SUBSTRING(@SQLQuery, @FROMPOS, LEN(@SQLQuery) - @FROMPOS + 1)
 SET @headerlist = Replace (@headerlist, '),', ') as th,')
 SET @headerlist += ' as th'
 SET @columnslist = Replace (@columnslist, '),', ') as td,')
 SET @columnslist += ' as td'
 SET @DynTSQL = CONCAT (
 'SELECT CONVERT(NVARCHAR(MAX), (SELECT   
  (SELECT ' 
   ,@headerlist
   , ' '
   ,' FOR XML RAW(''tr''), ELEMENTS, TYPE) AS ''thead'','
   ,' ( SELECT '
   ,  @columnslist
     ,' '
     ,@restOfQuery
    ,' FOR XML RAW (''tr''), ELEMENTS, TYPE) AS ''tbody''',
    ' FOR XML PATH (''''), ROOT (''table'')))'
   )
 EXECUTE (@DynTSQL)
END
GO
