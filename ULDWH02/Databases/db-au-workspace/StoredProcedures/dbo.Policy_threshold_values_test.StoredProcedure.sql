USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Policy_threshold_values_test]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Policy_threshold_values_test]    
AS    
begin    
DECLARE @xml NVARCHAR(MAX)    
 DECLARE @xml_1 NVARCHAR(MAX)    
 DECLARE @body NVARCHAR(MAX)    
IF (select count(*) FROM [db-au-workspace].dbo.tbl_recon_analytics2 where date = '2024-08-15' and IncomingDataCount > UpperThreshold ) = '0'    
 begin     
 SET @xml = N'<html><body><H3>Policy Lower Threshold values</H3>    
 <table border = 1>     
 <tr><th> Date </th>     
 <th> partner </th>     
 <th> LowerThreshold </th>     
 <th> UpperThreshold </th>    
 <th> IncomingDataCount </th></tr>'    
 +CAST((SELECT td = [Date], '',     
 td = [Partner], '',     
 td= [LowerThreshold], '',    
 td = [UpperThreshold], '',    
 td = [IncomingDataCount], ''     
 FROM [db-au-workspace].dbo.tbl_recon_analytics2     
 where date = '2024-08-15'
 and IncomingDataCount < LowerThreshold 
 and Partner not in ('Booking.com Trip Cancellation','Booking.com Flights TI') FOR XML  PATH('tr'), Type ) AS NVARCHAR(MAX)) + N'</table>'    
 set @body = 'There are no upper policy threshold values today'+@xml     
 EXEC msdb.dbo.sp_send_dbmail    
 @profile_name = 'covermorereport',    
 @body = @body,    
 @body_format ='HTML',    
 @recipients = 'surya.bathula@covermore.com;siddhesh.shinde@covermore.com;humaira.liaqat@covermore.com;abhilash.yelmelwar@covermore.com',    
 @subject = 'Policy Threshold values';    
 end    
ELSE if (select count(date) FROM [db-au-workspace].dbo.tbl_recon_analytics2 where date = '2024-08-15' and IncomingDataCount < LowerThreshold )  = '0'    
    begin    
 SET @xml_1 = N'<html><body><H3>Policy Upper Threshold values</H3>    
 <table border = 1>     
 <tr><th> Date </th>     
 <th> partner </th>     
 <th> LowerThreshold </th>     
 <th> UpperThreshold </th>    
 <th> IncomingDataCount </th></tr>'    
 +CAST((SELECT td = [Date], '',     
 td = [Partner], '',     
 td= [LowerThreshold], '',    
 td = [UpperThreshold], '',    
 td = [IncomingDataCount], ''    
 FROM [db-au-workspace].dbo.tbl_recon_analytics2     
 where date = '2024-08-15'
 and IncomingDataCount > UpperThreshold and Partner not in ('Booking.com Trip Cancellation','Booking.com Flights TI') 
 FOR XML  PATH('tr'), Type ) AS NVARCHAR(MAX)) + N'</table>'    
 set @body = 'There are no Lower policy threshold values today'+@xml_1    
 EXEC msdb.dbo.sp_send_dbmail    
 @profile_name = 'covermorereport',    
 @body = @xml_1,    
 @body_format ='HTML',    
 @recipients = 'surya.bathula@covermore.com;siddhesh.shinde@covermore.com;humaira.liaqat@covermore.com;abhilash.yelmelwar@covermore.com',    
 @subject = 'Policy Threshold values';    
 end    
ELSE     
 begin    
 SET @xml = N'<html><body><H3>Policy Lower Threshold values</H3>    
 <table border = 1>     
 <tr><th> Date </th>     
 <th> partner </th>     
 <th> LowerThreshold </th>     
 <th> UpperThreshold </th>    
 <th> IncomingDataCount </th></tr>'    
 +CAST((SELECT td = [Date], '',     
 td = [Partner], '',     
 td= [LowerThreshold], '',    
 td = [UpperThreshold], '',    
 td = [IncomingDataCount], ''     
 FROM [db-au-workspace].dbo.tbl_recon_analytics2     
 where date = '2024-08-15'
 and IncomingDataCount < LowerThreshold 
 and Partner not in ('Booking.com Trip Cancellation','Booking.com Flights TI') 
 FOR XML  PATH('tr'), Type ) AS NVARCHAR(MAX)) + N'</table>'    
 SET @xml_1 = N'<html><body><H3>Policy Upper Threshold values</H3>    
 <table border = 1>     
 <tr><th> Date </th>     
 <th> partner </th>     
 <th> LowerThreshold </th>     
 <th> UpperThreshold </th>    
 <th> IncomingDataCount </th></tr>'    
 +CAST((SELECT td = [Date], '',     
 td = [Partner], '',     
 td= [LowerThreshold], '',    
 td = [UpperThreshold], '',    
 td = [IncomingDataCount], ''    
 FROM [db-au-workspace].dbo.tbl_recon_analytics2     
 where date = '2024-08-15'
 and IncomingDataCount > UpperThreshold 
 and Partner not in ('Booking.com Trip Cancellation','Booking.com Flights TI') 
 FOR XML  PATH('tr'), Type ) AS NVARCHAR(MAX)) + N'</table>'    
     
 set @body = @xml_1+@xml     
 EXEC msdb.dbo.sp_send_dbmail    
 @profile_name = 'covermorereport',     
 @body = @body,    
 @body_format ='HTML',    
 @recipients = 'surya.bathula@covermore.com;siddhesh.shinde@covermore.com;humaira.liaqat@covermore.com;abhilash.yelmelwar@covermore.com',    
 @subject = 'Policy Threshold values';    
 end    
end 
GO
