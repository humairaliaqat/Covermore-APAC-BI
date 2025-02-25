USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_etl_event_file]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE procedure [dbo].[etlsp_cmdwh_etl_event_file]    @Operation varchar(20),  
                                                    @ETLProcess varchar(30)  
as  
  
SET NOCOUNT ON  
  
  
/****************************************************************************************************/  
--    Name:    dbo.etlsp_cmdwh_etl_event_file  
--    Author:   Linus Tor  
--    Date Created:  20110627  
--    Description:  This stored procedure deletes and create empty text files for BusinessObjects  
--      file events  
--    Parameters:       @Operation: value is 'Delete', 'Create', 'Rename'  
--                     @ETLProcess: Value is 'Policy', 'Claims', 'e5', 'Corporate', 'FogBugz', 'Underwriter', 'TIAS'  
--  
--    Change History:    20110627 - LT - Created  
--       20190801 - RS - Added Cisco Calls  
--  
/****************************************************************************************************/  
  
--uncomment to debug  
/*  
declare @Operation varchar(20)  
declare @ETLProcess varchar(30)  
select @Operation = 'create', @ETLProcess = 'Policy'  
*/  
  
  
declare @sql varchar(8000)  
declare @Cmd varchar(200)  
declare @FilePath varchar(100)  
declare @Filename varchar(100)  
  
select @FilePath = '\\ulbi02\Events\' 
--select @FilePath = '\\SYDSAPPRDAPP01\Events\' 
  
if @ETLProcess = 'Policy' select @Filename = 'GO_Policy.txt'  
else if @ETLProcess = 'Claims' select @Filename = 'GO_Claims.txt'  
else if @ETLProcess = 'e5' select @Filename = 'GO_e5.txt'  
else if @ETLProcess = 'Corporate' select @Filename = 'GO_Corporate.txt'  
else if @ETLProcess = 'FogBugz' select @Filename = 'GO_Fogbugz.txt'  
else if @ETLProcess = 'Underwriter' select @Filename = 'GO_Underwriter.txt'  
else if @ETLProcess = 'TIAS' select @Filename = 'GO_TIAS.txt'  
else if @ETLProcess = 'Penguin' select @Filename = 'GO_Penguin.txt'  
else if @ETLProcess = 'PenguinUK' select @Filename = 'GO_PenguinUK.txt'  
else if @ETLProcess = 'EMC' select @Filename = 'GO_EMC.txt'  
else if @ETLProcess = 'EMCUK' select @Filename = 'GO_EMCUK.txt'  
else if @ETLProcess = 'Carebase' select @Filename = 'GO_Carebase.txt'  
else if @ETLProcess = 'PenguinDataLoader' select @Filename = 'GO_PenguinDataLoader.txt'  
else if @ETLProcess = 'PenguinDataLoaderUK' select @Filename = 'GO_PenguinDataLoaderUK.txt'  
else if @ETLProcess = 'PenguinDataLoaderUS' select @Filename = 'GO_PenguinDataLoaderUS.txt'  
else if @ETLProcess = 'PenguinUS' select @Filename = 'GO_PenguinUS.txt'  
else if @ETLProcess = 'CiscoCalls' select @Filename = 'GO_Calls.txt'  
  
if @Operation = 'Delete' select @Cmd = 'del /q /f ' + @FilePath + @Filename  
else if @Operation = 'Create' select @Cmd = 'copy /y NUL ' + @FilePath + @Filename + ' > NUL'  
  
--build the full file operation command string  
select @sql = '"' + @cmd + '"'  
  
--execute file operation  
exec master..xp_cmdshell @sql  
  
  
  
GO
