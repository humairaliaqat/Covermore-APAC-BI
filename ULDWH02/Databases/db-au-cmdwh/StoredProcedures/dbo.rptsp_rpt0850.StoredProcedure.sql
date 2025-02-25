USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0850]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0850]  @DateRange varchar(30),
									   @StartDate datetime,
									   @EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/  
--  Name:           dbo.rptsp_rpt0850
--  Author:         Linus Tor 
--  Date Created:   20170404
--  Description:    This stored procedure returns primary traveller list with active policies issued in the
--					reporting period.
--  Parameters:     @DateRange: Value is valid date range  
--                  @StartDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01  
--                  @EndDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01  
--     
--  Change History: 20170404 - LT - Created  
--  
/****************************************************************************************************/ 

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare	@rptEndDate datetime
declare @rptMonthStart datetime

--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate, @rptEndDate = @EndDate
else
	select 
		@rptStartDate = StartDate, 
		@rptEndDate = EndDate
	from 
		vDateRange
	where 
		DateRange = @DateRange


if object_id('tempdb..##output') is not null drop table ##output

create table ##output
(
	First_Name varchar(100) null,
	Last_Name varchar(100) null,
	DOB varchar(50) null,
	Age varchar(50) null,
	Departure_Date varchar(50) null,
	Return_Date varchar(50) null
)

--insert header
insert ##output values('First_Name','Last_Name','DOB','Age','Departure_Date','Return_Date')

insert ##output
select distinct
  ptr.FirstName,
  ptr.LastName,
  convert(varchar(20),ptr.DOB,120) as DOB,
  ptr.Age,
  convert(varchar(20),p.TripStart,120) as Departure_Date,
  convert(varchar(20),p.TripEnd,120) as Return_Date
from
  penPolicyTraveller ptr
  inner join penPolicy p ON p.PolicyKey = ptr.PolicyKey
  inner join penPolicyTransSummary pts on pts.PolicyKey = p.PolicyKey
  inner join penOutlet o on pts.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
   o.CountryKey  =  'NZ' and
   o.SuperGroupName  =  'Westpac NZ' and   
   pts.PostingDate >= @rptStartDate and
   pts.PostingDate <= @rptEndDate and
   ptr.isPrimary  =  1 and
   p.StatusDescription = 'Active'



declare @SQL varchar(8000)
declare @Filename varchar(200)
declare @Path varchar(200)
declare @recipientText varchar(200)
declare @cctext varchar(200)
declare @SubjectText varchar(200)
declare @FileAttachmentText varchar(500)

select @Filename = 'rpt0850_Westpac_NZ_Traveller_File_' + convert(varchar(8),getdate(),112),
	   @Path = 'e:\ETL\Data\'


----export to csv file
select @SQL = 'bcp ##output out ' + @Path + @Filename + '.csv -c -t "," -T -S ULDWH02'
exec master..xp_cmdshell @SQL

--zip file
select @SQL = '"c:\program files\7-zip\7z.exe" a -p%WestpacTravel$365 ' + @Path + @Filename + '.zip ' + @Path + @Filename + '.csv'
execute master..xp_cmdshell @SQL


--email file
select @recipienttext = 'Insight_Driven_Marketing@westpac.co.nz'
select @cctext = 'karl.dixon@covermore.com'


select @SubjectText = 're: ' + @Filename
select @FileAttachmentText = 'E:\\ETL\Data\' + @Filename + '.zip'

EXEC msdb.dbo.sp_send_dbmail @profile_name='covermorereport',
							 @recipients=@RecipientText,
							 @copy_recipients=@cctext,
							 @subject= @SubjectText,
							 @body='Please find attached Westpac NZ Traveller data file.',
							 @file_attachments=@FileAttachmentText


select 'hello world' as Greeting

drop table ##output
GO
