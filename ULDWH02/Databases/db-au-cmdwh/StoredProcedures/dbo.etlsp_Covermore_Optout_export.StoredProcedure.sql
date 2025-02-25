USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_Covermore_Optout_export]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[etlsp_Covermore_Optout_export]      
as      
      
Begin 
declare @subject_line varchar(8000)
declare @file_name varchar(2000)
declare @profile_name varchar(2000)
declare @recipients varchar(2000)
declare @file_attachments varchar(2000)
declare @fullfile_name varchar(2000)
declare @start as varchar(10)
declare @myDate date
set @myDate = getdate() -1
set @start =  cast(@myDate as varchar(10))
--select @start
set @file_name = '\\ulwibs01\SFTPShares\Medallia\Inbound\Optout\Covermore_optout_export-Daily-'
set @fullfile_name = @file_name + cast(@start as nvarchar(20)) +'.csv'
--select @fullfile_name
set @subject_line = 'Medallia Optout Report - ' + @start
exec msdb..sp_send_dbmail     
                @profile_name='covermorereport', 
				@recipients ='anand.hubli@covermore.com;sam.smith@covermore.com;Steven.Webster@covermore.com;Nitish.Walecha@covermore.com;Abhilash.Yelmelwar@covermore.com;Kota.Kumar@covermore.com',
                @subject=@subject_line,    
                @body='Please find attached Daily Medallia Optout report',  
                @file_attachments = @fullfile_name
end

GO
