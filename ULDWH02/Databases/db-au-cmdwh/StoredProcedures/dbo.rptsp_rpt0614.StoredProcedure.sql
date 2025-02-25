USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0614]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0614]
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0614
--	Author:			Linus Tor
--	Date Created:	20150203
--	Description:	This stored procedure shows any IAG NZ Flybuy job errors
--					
--
--	Change History:	20150203 - LT - Created
--
/****************************************************************************************************/


if object_id('tempdb..#Output') is not null drop table #Output
select
	a.DataID,
	a.JobCode,
	a.JobName,
	a.CreateDateTime,
	a.ErrorDescription
into #Output	
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'
	select distinct
		dq.DataID,
		j.JobCode,
		j.JobName,
		AU_PenguinSharp_Active.dbo.UtcToLocalTimeZone(dq.CreateDateTime,''AUS Eastern Standard Time'') as CreateDateTime,
		je.Description as ErrorDescription		
	from 
		AU_PenguinJob.dbo.tblDataQueue dq
		inner join AU_PenguinJob.dbo.tblJob j on dq.JobID = j.JobID	
		inner join AU_PenguinJob.dbo.tblJobError je on je.DataID = dq.DataID and je.JobID = dq.JobID
	where
		dq.JobID = 157 and
		dq.[Status] <> ''DONE''
') a

if (select count(*) from #Output) <> 0
begin
	select
		convert(int,DataID) as DataID,
		convert(varchar(50),JobCode) as JobCode,
		convert(varchar(100),JobName) as JobName,
		convert(datetime,CreateDateTime) as CreateDateTime,
		convert(text,ErrorDescription) as ErorDescription
	from #Output
end
else
begin	
	select
		convert(int,null) as DataID,
		convert(varchar(50),null) as JobCode,
		convert(varchar(100),null) as JobName,
		convert(datetime,null) as CreateDateTime,
		convert(text,null) as ErorDescription	
end		

drop table #Output

GO
