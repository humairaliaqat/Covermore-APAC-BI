USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_kiteworks_ETI_Upload]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rawsp_kiteworks_ETI_Upload]
as

set nocount on


/****************************************************************************************************/
--  Name:           dbo.rawsp_kiteworks_ETI_Upload
--  Author:         Linus Tor
--  Date Created:   20190211
--  Prequisities:	Kiteworks automation agent has been setup and configured on ULDWH02\e$\kaa
--					ETI task upload file has been configured and tested
--
--  Description:    This stored procedure executes kiteworks batch file, and uploads ETI report files
--					NOTE: ETI and name of task file were deliberately hardcoded to prevent accidental mistake 
--						  (ie no files upload to wrong the recipients/client).
--
--  Change History: 20190211 - LT - Created.
--
/****************************************************************************************************/

declare @SQL varchar(8000)

select @SQL = 'e:\kaa\_tasks\eti\eti_upload.bat'

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
