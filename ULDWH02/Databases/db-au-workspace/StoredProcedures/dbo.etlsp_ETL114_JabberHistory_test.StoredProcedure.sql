USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL114_JabberHistory_test]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[etlsp_ETL114_JabberHistory_test] @Server varchar(50),
												@DateRange varchar(30),
												@StartDate varchar(10),
												@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.etlsp_ETL114_JabberHistory
--	Author:			Linus Tor
--	Date Created:	20190218
--	Description:	This stored procedure imports jabber history and stores it in db-au-cmdwh
--
--	Parameters:		@Server:	linked server name ( JABBERUL or JABBERBH)
--					@DateRange: default date range or '_User Defined'
--					@StartDate: if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--					@EndDate:	if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--	
--	Change History:	20190218 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @Server varchar(50)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @Server = 'JABBERUL', @DateRange = '_User Defined', @StartDate = '2019-01-01', @EndDate = '2019-01-31'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @SQL nvarchar(max)


/* get reporting dates */
if @DateRange = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @DateRange
  

if object_id('[db-au-workspace].dbo.usrJabberHistory_test') is null
begin
	create table [db-au-workspace].dbo.usrJabberHistory_test
	(
		BIRowID bigint identity(1,1) not null,
		ToJID nvarchar(200) not null,
		FromJID nvarchar(200) not null,
		SentDate datetime not null,
		SentDateUTC datetime not null,
		[Subject] nvarchar(128) null,
		ThreadID nvarchar(128) null,
		MessageType nvarchar(1) not null,
		Direction nvarchar(1) not null,
		BodyLength int not null,
		MessageLength int not null,
		BodyString nvarchar(2000) null,
		MessageString nvarchar(1000) null,
		BodyText nvarchar(2000) null,
		MessageText nvarchar(1000) null,
		HistoryFlag nvarchar(1) not null
	)
    create clustered index idx_usrJabberHistory_BIRowID on [db-au-workspace].dbo.usrJabberHistory_test(BIRowID)
    create nonclustered index idx_usrJabberHistory_ThreadID on [db-au-workspace].dbo.usrJabberHistory_test(ThreadID) include(SentDate, ToJID, FromJID)
end


select @SQL = 'if object_id(''[db-au-workspace].dbo.tmp_jabber_test'') is not null drop table [db-au-workspace].dbo.tmp_jabber_test
				select left(to_jid,200) to_jid, left(from_jid,200) from_jid, sent_date,
					left(subject,128) subject, left(thread_ID,128) thread_ID, left(msg_type,1) msg_type,
					left(direction,1) direction, body_len, message_len, left(body_string,2000) body_string, left(message_string,1000) message_string,
					left(body_text,2000) body_text, left(message_text,1000) message_text, left(history_flag,1) history_flag
				into [db-au-workspace].dbo.tmp_jabber_test
				from openquery(' + @Server + ',''
					select	left(to_jid,200) as to_jid,	left(from_jid,200) as from_jid,
						sent_date, left(subject,128) as subject, left(thread_id,128) as thread_id, left(msg_type,1) as msg_type, left(direction,1) as direction,  
						body_len, message_len, left(body_string,2000) as body_string,
						left(message_string,1000) as message_string, left(cast(body_text as varchar(2000)),2000) as body_text,
						left(cast(message_text as varchar(1000)),1000) as message_text,	left(history_flag,1) as history_flag 
					from jm
					where sent_date >= ''''' + convert(varchar(10),@rptStartDate,120) + ''''' and
						sent_date < ''''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + '''''
				'')'

execute(@SQL)

--delete records if exists
delete [db-au-workspace].dbo.usrJabberHistory_test
where
	SentDate >= @rptStartDate and
	SentDate < dateadd(d,1,@rptEndDate)

insert [db-au-workspace].dbo.usrJabberHistory_test
select
	[to_jid] as ToJID,
	[from_jid] as FromJID,
	[db-au-cmdwh].[dbo].[xfn_ConvertUTCtoLocal]([sent_date],'AUS Eastern Standard Time') as SentDate,
	[sent_date] as SentDateUTC,
	[subject] as [Subject],
	[thread_ID] as ThreadID,
	[msg_type] as MessageType,
	[direction] as Direction,
	[body_len] as BodyLength,
	[message_len] as MessageLength,
	[body_string] as BodyString,
	[message_string] as MessageString,
	[body_text] as BodyText,
	[message_text] as MessageText,
	[history_flag] as HistoryFlag
from
	[db-au-workspace].dbo.tmp_jabber_test


GO
