USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_kiteworks_RPT1072_Upload]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rawsp_kiteworks_RPT1072_Upload]
as

set nocount on


/****************************************************************************************************/
--  Name:           dbo.rawsp_kiteworks_RPT1072_Upload
--  Author:         Linus Tor
--  Date Created:   20190729
--  Prequisities:	Kiteworks automation agent has been setup and configured on ULDWH02\e$\kaa
--					RPT1072 task upload file has been configured and tested
--
--  Description:    This stored procedure executes kiteworks batch file, and uploads RPT1072 report files
--					NOTE: RPT1072 and name of task file were deliberately hardcoded to prevent accidental mistake 
--						  (ie no files upload to wrong the recipients/client).
--
--  Change History: 20190729 - LT - Created.
--
/****************************************************************************************************/

declare @SQL varchar(8000)

select @SQL = 'e:\kaa\_tasks\CoverMore\RPT1072\RPT1072_UK_Customer_Data_Report.bat'

if object_id('tempdb..#output') is not null drop table #output

create table #output
(
	[Output] varchar(8000) null
)

insert #output
exec xp_cmdshell @SQL

--return output for Crystal Reports
select *
from #output
GO
