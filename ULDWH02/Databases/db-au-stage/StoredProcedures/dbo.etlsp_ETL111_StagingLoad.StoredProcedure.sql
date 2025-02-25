USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL111_StagingLoad]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--CREATE
CREATE
PROCEDURE [dbo].[etlsp_ETL111_StagingLoad]
AS

  --SET NOCOUNT ON


  /****************************************************************************************************/
  --  Name:           etlsp_ETL111_StagingLoad
  --  Author:         Linus Tor
  --  Date Created:   20190703
  --  Description:    This stored procedure loads data from qualrics data feeds to staging tables.
  --  Parameters:     
  --  
  --  Change History: 20190201 - LT - Initial SSIS job was Created
  --                  20190704 - RS - Converted SSIS job to sql proc.
  --
  /****************************************************************************************************/

  --uncomment to debug
  /*
  */

  DECLARE @filename varchar(256)
  DECLARE @filecount int
  DECLARE @sql nvarchar(4000)
  DECLARE @AUDRate decimal(25, 10)
  DECLARE @NZDRate decimal(25, 10)
  DECLARE @FXDate date
  DECLARE @tmpString varchar(100)

  BEGIN

    IF OBJECT_ID('[db-au-stage].dbo.etl_QualtricsFeedAU') IS NULL
    BEGIN

      CREATE TABLE [etl_QualtricsFeedAU] (
        [Selection Date] varchar(50),
        [First Name] varchar(100),
        [Last Name] varchar(100),
        [Email] varchar(255),
        [ID Number] varchar(50),
        [Company] varchar(100),
        [Division] varchar(100),
        [Department] varchar(100),
        [Reports To Position Title] varchar(100),
        [Gender] varchar(50),
        [Personnel Type Desc] varchar(100),
        [Employment Type Desc] varchar(100),
        [Location] varchar(100),
        [Country] varchar(100),
        [Hire Date] varchar(50)
      )
    END
    ELSE
      TRUNCATE TABLE etl_QualtricsFeedAU


    IF OBJECT_ID('[db-au-stage].dbo.etl_QualtricsFeedNZ') IS NULL
    BEGIN

      CREATE TABLE [etl_QualtricsFeedNZ] (
        [Selection Date] varchar(50),
        [First Name] varchar(100),
        [Last Name] varchar(100),
        [Email] varchar(255),
        [ID Number] varchar(50),
        [Company] varchar(100),
        [Division] varchar(100),
        [Department] varchar(100),
        [Reports To Position Title] varchar(100),
        [Gender] varchar(50),
        [Personnel Type Desc] varchar(100),
        [Employment Type Desc] varchar(100),
        [Location] varchar(100),
        [Country] varchar(100),
        [Hire Date] varchar(50)
      )
    END
    ELSE
      TRUNCATE TABLE etl_QualtricsFeedNZ


    SET @sql = 'bulk insert etl_QualtricsFeedAU
from ''\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\QUALTRIX FEED\QUALTRIXFEEDAU.csv''
with
(
	FIRSTROW = 2,
	FIELDTERMINATOR = '',''
)'

    --print(@sql)
    PRINT ('Loading table etl_QualtricsFeedAU')
    EXEC (@sql)

    UPDATE etl_QualtricsFeedAU
    SET [Selection Date] = REPLACE([Selection Date], '"', ''),
        [First Name] = REPLACE([First Name], '"', ''),
        [Last Name] = REPLACE([Last Name], '"', ''),
        [Email] = REPLACE([Email], '"', ''),
        [ID Number] = REPLACE([ID Number], '"', ''),
        [Company] = REPLACE([Company], '"', ''),
        [Division] = REPLACE([Division], '"', ''),
        [Department] = REPLACE([Department], '"', ''),
        [Reports To Position Title] = REPLACE([Reports To Position Title], '"', ''),
        [Gender] = REPLACE([Gender], '"', ''),
        [Personnel Type Desc] = REPLACE([Personnel Type Desc], '"', ''),
        [Employment Type Desc] = REPLACE([Employment Type Desc], '"', ''),
        [Location] = REPLACE([Location], '"', ''),
        [Country] = REPLACE([Country], '"', ''),
        [Hire Date] = REPLACE(REPLACE(REPLACE([Hire Date], '"', ''), ',', ''), 'AUSTRALIA', '')

    --select * from etl_QualtricsFeedAU


    SET @sql = 'bulk insert etl_QualtricsFeedNZ
from ''\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\QUALTRIX FEED\QUALTRIXFEEDNZ.csv''
with
(
	FIRSTROW = 2,
	FIELDTERMINATOR = '',''
)'

    --print(@sql)
    PRINT ('Loading table etl_QualtricsFeedNZ')
    EXEC (@sql)

    UPDATE etl_QualtricsFeedNZ
    SET [Selection Date] = REPLACE([Selection Date], '"', ''),
        [First Name] = REPLACE([First Name], '"', ''),
        [Last Name] = REPLACE([Last Name], '"', ''),
        [Email] = REPLACE([Email], '"', ''),
        [ID Number] = REPLACE([ID Number], '"', ''),
        [Company] = REPLACE([Company], '"', ''),
        [Division] = REPLACE([Division], '"', ''),
        [Department] = REPLACE([Department], '"', ''),
        [Reports To Position Title] = REPLACE([Reports To Position Title], '"', ''),
        [Gender] = REPLACE([Gender], '"', ''),
        [Personnel Type Desc] = REPLACE([Personnel Type Desc], '"', ''),
        [Employment Type Desc] = REPLACE([Employment Type Desc], '"', ''),
        [Location] = REPLACE([Location], '"', ''),
        [Country] = REPLACE([Country], '"', ''),
        [Hire Date] = REPLACE(REPLACE(REPLACE([Hire Date], '"', ''), ',', ''), 'AUSTRALIA', '')

    --select * from etl_QualtricsFeedAU

    --archive processed files
    DECLARE @Command varchar(8000)

    --move files to archive
    SELECT
      @Command = 'move "\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\QUALTRIX FEED\QUALTRIXFEEDAU.csv" "e:\etl\data\preceda\archive\QUALTRIXFEEDAU_' + CONVERT(varchar(10), GETDATE(), 112) + '.csv"'
    EXECUTE xp_cmdshell @Command

    SELECT
      @Command = 'move "\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\QUALTRIX FEED\QUALTRIXFEEDNZ.csv" "e:\etl\data\preceda\archive\QUALTRIXFEEDNZ_' + CONVERT(varchar(10), GETDATE(), 112) + '.csv"'
    EXECUTE xp_cmdshell @Command

  --delete files from Payroll folder
  --select @Command = 'del "\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\QUALTRIX FEED\QUALTRIXFEEDAU.csv"'
  --execute xp_cmdshell @Command

  --select @Command = 'del "\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\QUALTRIX FEED\QUALTRIXFEEDNZ.csv"'
  --execute xp_cmdshell @Command


  END;
GO
