USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_kiteworks_RPT1079_Upload]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[rawsp_kiteworks_RPT1079_Upload]
as

set nocount on


/****************************************************************************************************/
--  Name:           dbo.rawsp_kiteworks_RPT1079_Upload
--  Author:         Asad
--  Date Created:   20191022
--  Prequisities:	Kiteworks automation agent has been setup and configured on ULDWH02\e$\kaa
--					RPT1091 task upload file has been configured and tested
--
--  Description:    This stored procedure executes kiteworks batch file, and uploads RPT1091 report file
--					NOTE: RPT1091 and name of task file were deliberately hardcoded to prevent accidental mistake 
--						  (ie no files upload to wrong the recipients/client).
--
--  Change History: 20191022 - LT - Created.
--
/****************************************************************************************************/

declare @SQL varchar(8000)

select @SQL = 'e:\kaa\_tasks\CoverMore\RPT1079\RPT1079_-_Travel_Partners_Statement_with_Customer_Details.bat'

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
