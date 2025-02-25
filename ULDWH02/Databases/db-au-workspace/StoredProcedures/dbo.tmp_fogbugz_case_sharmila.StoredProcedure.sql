USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_fogbugz_case_sharmila]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_fogbugz_case_sharmila]
as

SET NOCOUNT ON


select distinct 
	b.ixbug as CaseNo,
	p.sFullname as Assignee,
	b.stitle as CaseTitle,
	b.dtopened as DateOpened,
	b.dtDue as DateDue,
	b.dtResolved as DateResolved,
	b.dtClosed as DateClosed,
	case when b.dtDue is null or convert(varchar(10),b.dtDue,120) = convert(varchar(10),b.dtOpened,120) then 'N/A'
		 when convert(varchar(10),b.dtDue,120) < convert(varchar(10),b.dtResolved,120) then 'Overdue'
		 when convert(varchar(10),b.dtDue,120) >= convert(varchar(10),b.dtResolved,120) then 'On Time'
		 when b.dtResolved is null and convert(varchar(10),b.dtDue,120) <= convert(varchar(10),getdate(),120) then 'Overdue'
		 when b.dtResolved is null and convert(varchar(10),b.dtDue,120) >= convert(varchar(10),getdate(),120) then 'Pending'
		 else 'Unknown'
    end as SLA,
    (select sum(isWeekDay) from [db-au-cmdwh].dbo.Calendar where [Date] between b.dtDue and b.dtResolved) as WorkDay,
    (select sum(isWeekEnd) from [db-au-cmdwh].dbo.Calendar where [Date] between b.dtDue and b.dtResolved) as WorkEnd,
    (select sum(isHoliday) from [db-au-cmdwh].dbo.Calendar where [Date] between b.dtDue and b.dtResolved) as Holiday    
from
	wills.fogbugz.dbo.bugevent be
	inner join wills.fogbugz.dbo.bug b on be.ixbug = b.ixbug
	inner join wills.fogbugz.dbo.person p on be.ixPerson = p.ixperson 
 where 
	(be.sVerb like 'resolv%' or be.sVerb like 'closed%') and 
	p.sFullname like 'Sharmila%'
GO
