USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_main_ANG_DAILY_FILES]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE Procedure [dbo].[etlsp_main_ANG_DAILY_FILES]    
as    
    
Begin    
declare @QueryCL varchar(8000)      
    
declare @SQL varchar(8000)      
declare @Path varchar(1000)      
declare @FileNameCL varchar(200)      
      
declare @ExtZip varchar(4)      
declare @ExtTxt varchar(4) 
declare @start date = getdate()

select @QueryCL = 'EXEC	[db-au-cmdwh].[dbo].[ClaimData_Proc] @StartDate = @start GO'	
select @Path = 'E:\ETL\'      
select @FilenameCL = 'Claims_data'    
select @ExtTxt = '.csv'           
select @SQL = ' bcp "' + @QueryCL + '" queryout "' + @Path + @FileNameCL + @ExtTxt + '"' + ' -S localhost -T -w'    
print(@SQL)   
exec xp_cmdshell @SQL    
  
exec msdb..sp_send_dbmail     
                @profile_name='covermorereport',    
				@recipients='surya.bathula@covermore.com',   
                @subject='Claims data File',    
                @body='',   
                @file_attachments = 'E:\ETL\Claims_data.csv';        
End  
  
GO
