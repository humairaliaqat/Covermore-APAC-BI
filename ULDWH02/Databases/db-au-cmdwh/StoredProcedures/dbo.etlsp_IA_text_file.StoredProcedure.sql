USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_IA_text_file]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[etlsp_IA_text_file]    
as    
    
Begin 
declare @Path varchar(2000)
declare @ExtZip varchar(4)      
declare @ExtTxt varchar(4) 
--declare @start date = N'2023-07-13'
select @ExtTxt = '.txt'  
select @Path = '\\ulwibs01.aust.dmz.local\sftpshares\IA\'
declare @dt varchar(20)
declare @Query varchar(8000)      
declare @SQL varchar(8000)
declare @FileName varchar(200) 
select @Query = 'select 1'	
select @FileName = 'ial_transfer_complete'          
select @SQL = ' bcp "' + @Query + '" queryout "' + @Path + @FileName + @ExtTxt + '"' + ' -S localhost -T -w'    
print(@SQL)   
exec xp_cmdshell @SQL 
END

GO
