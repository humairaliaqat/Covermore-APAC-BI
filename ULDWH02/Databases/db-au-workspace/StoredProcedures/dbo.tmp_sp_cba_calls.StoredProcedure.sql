USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_sp_cba_calls]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_sp_cba_calls]
as
begin

    declare
        @StartDate datetime,
        @EndDate datetime

	select @StartDate = dateadd(week, -4, getdate())  


    truncate table tmp_cisco_ciscalls
    
    insert into tmp_cisco_ciscalls
    (
        applicationname,
        contacttype,
        sessionid,
        contactdisposition,
        startdatetime, 
        enddatetime, 
        queuetime
    )
    select
        *
    from 
        openquery(
            CISCO,
            '
            select    
                ccdr.applicationname,
                ccdr.contacttype,
                ccdr.sessionid,
                ccdr.contactdisposition,
                nvl(acdr.startdatetime, ccdr.startdatetime) startdatetime, 
                nvl(acdr.enddatetime, ccdr.enddatetime) enddatetime, 
                nvl(cqdr.queuetime, 0) queuetime
            from 
                contactcalldetail ccdr
                inner join contactqueuedetail cqdr on
                    cqdr.sessionid = ccdr.sessionid and 
                    cqdr.sessionseqnum = ccdr.sessionseqnum and
                    cqdr.profileid = ccdr.profileid and
                    cqdr.nodeid = ccdr.nodeid
                inner join agentconnectiondetail acdr on
                    acdr.sessionid = cqdr.sessionid and
                    acdr.sessionseqnum = cqdr.sessionseqnum and
                    acdr.profileid = cqdr.profileid and 
                    acdr.nodeid = cqdr.nodeid and
                    acdr.qindex = cqdr.qindex
            where 
                ccdr.applicationname = ''AUCustomerServiceCBA'' and
                ccdr.startdatetime >= ''2019-10-01 00:00:00.000''
            for read only
            '
        ) t
    where
        startdatetime >= @StartDate


    insert into tmp_cisco_ciscalls
    (
        applicationname,
        contacttype,
        sessionid,
        contactdisposition,
        startdatetime, 
        enddatetime, 
        queuetime
    )
    select
        *
    from 
        openquery(
            CISCO,
            '
            select    
                ccdr.applicationname,
                ccdr.contacttype,
                ccdr.sessionid,
                ccdr.contactdisposition,
                nvl(acdr.startdatetime, ccdr.startdatetime) startdatetime, 
                nvl(acdr.enddatetime, ccdr.enddatetime) enddatetime, 
                nvl(cqdr.queuetime, 0) queuetime
            from 
                contactcalldetail ccdr
                left join contactqueuedetail cqdr on
                    cqdr.sessionid = ccdr.sessionid and 
                    cqdr.sessionseqnum = ccdr.sessionseqnum and
                    cqdr.profileid = ccdr.profileid and
                    cqdr.nodeid = ccdr.nodeid
                left join agentconnectiondetail acdr on
                    acdr.sessionid = cqdr.sessionid and
                    acdr.sessionseqnum = cqdr.sessionseqnum and
                    acdr.profileid = cqdr.profileid and 
                    acdr.nodeid = cqdr.nodeid and
                    acdr.qindex = cqdr.qindex
            where 
                ccdr.applicationname = ''AUCustomerServiceCBA'' and
                ccdr.startdatetime >= ''2019-10-01 00:00:00.000'' and
                cqdr.sessionid is null and
                acdr.sessionid is null
            for read only
            '
        ) t
    where
        startdatetime >= @StartDate


    insert into tmp_cisco_ciscalls
    (
        applicationname,
        contacttype,
        sessionid,
        contactdisposition,
        startdatetime, 
        enddatetime, 
        queuetime
    )
    select
        *
    from 
        openquery(
            CISCO,
            '
            select    
                ccdr.applicationname,
                ccdr.contacttype,
                ccdr.sessionid,
                ccdr.contactdisposition,
                nvl(acdr.startdatetime, ccdr.startdatetime) startdatetime, 
                nvl(acdr.enddatetime, ccdr.enddatetime) enddatetime, 
                nvl(cqdr.queuetime, 0) queuetime
            from 
                contactcalldetail ccdr
                inner join contactqueuedetail cqdr on
                    cqdr.sessionid = ccdr.sessionid and 
                    cqdr.sessionseqnum = ccdr.sessionseqnum and
                    cqdr.profileid = ccdr.profileid and
                    cqdr.nodeid = ccdr.nodeid
                left join agentconnectiondetail acdr on
                    acdr.sessionid = cqdr.sessionid and
                    acdr.sessionseqnum = cqdr.sessionseqnum and
                    acdr.profileid = cqdr.profileid and 
                    acdr.nodeid = cqdr.nodeid and
                    acdr.qindex = cqdr.qindex
            where 
                ccdr.applicationname = ''AUCustomerServiceCBA'' and
                ccdr.startdatetime >= ''2019-10-01 00:00:00.000'' and
                acdr.sessionid is null
            for read only
            '
        ) t
    where
        startdatetime >= @StartDate

    insert into tmp_cisco_ciscalls
    (
        applicationname,
        contacttype,
        sessionid,
        contactdisposition,
        startdatetime, 
        enddatetime, 
        queuetime
    )
    select
        *
    from 
        openquery(
            CISCO,
            '
            select    
                ccdr.applicationname,
                ccdr.contacttype,
                ccdr.sessionid,
                ccdr.contactdisposition,
                nvl(acdr.startdatetime, ccdr.startdatetime) startdatetime, 
                nvl(acdr.enddatetime, ccdr.enddatetime) enddatetime, 
                nvl(cqdr.queuetime, 0) queuetime
            from 
                contactcalldetail ccdr
                inner join agentconnectiondetail acdr on
                    acdr.sessionid = ccdr.sessionid and
                    acdr.sessionseqnum = ccdr.sessionseqnum and
                    acdr.profileid = ccdr.profileid and 
                    acdr.nodeid = ccdr.nodeid 
                left join contactqueuedetail cqdr on
                    cqdr.sessionid = acdr.sessionid and 
                    cqdr.sessionseqnum = acdr.sessionseqnum and 
                    cqdr.profileid = acdr.profileid and 
                    cqdr.nodeid = acdr.nodeid and
                    cqdr.qindex = acdr.qindex
            where 
                ccdr.applicationname = ''AUCustomerServiceCBA'' and
                ccdr.startdatetime >= ''2019-10-01 00:00:00.000'' and
                cqdr.sessionid is null
            for read only
            '
        ) t
    where
        startdatetime >= @StartDate
    
    update tmp_cisco_ciscalls 
    set
        SessionKey = 
            convert(varchar(50), sessionid) + '.' + 
            convert(varchar(50), sessionseqnum) + '.' + 
            replace(replace(replace(convert(varchar(23), startdatetime, 126), '-', ''), 'T', ''), ':', '')

    select
	    case
		    when datepart(hour, CallStartDateTime) < 8 then datename(day, dateadd(day, -1, CallStartDateTime)) + ' ' + datename(month, dateadd(day, -1, CallStartDateTime))
		    else datename(day, CallStartDateTime) + ' ' + datename(month, CallStartDateTime)
	    end [Day Group],
	    case
		    when datepart(hour, CallStartDateTime) < 8 then datepart(hour, CallStartDateTime) + 24
		    else datepart(hour, CallStartDateTime)
	    end [Hour Group],
	    convert(varchar(2), CallStartDateTime, 8) + ':00' [Hour Display], 
	    count(distinct SessionID) [Call Count],
	    count
	    (
		    distinct
		    case
			    when ContactDisposition = 'Handled' then null
			    else SessionID
		    end
	    ) [Hung Up Call Count],
	    avg(QueueTime * 1.00) [Average Wait Time (s)]
    from
        (
            select distinct
                SessionID,
                case 
                    when contactdisposition = 1 then 'Abandoned'
                    when contactdisposition = 2 then 'Handled'
                    when contactdisposition = 3 then 'Do not care'
                    when contactdisposition = 4 then 'Aborted'
                    when contactdisposition between 5 and 22 then 'Rejected'
                    when contactdisposition = 99 then 'Cleared'
                    else 'Unknown'
                end ContactDisposition,
                [db-au-stage].dbo.xfn_ConvertUTCToLocal(StartDateTime, 'AUS Eastern Standard Time') CallStartDateTime,
                [db-au-stage].dbo.xfn_ConvertUTCToLocal(EndDateTime, 'AUS Eastern Standard Time') CallEndDateTime,    
                StartDateTime CallStartDateTimeUTC,
                EndDateTime CallEndDateTimeUTC,
                QueueTime
            from
                tmp_cisco_ciscalls
            where
	            StartDateTime >= '2019-09-08 00:00:00' and
	            ApplicationName = 'AUCustomerServiceCBA' and
                contacttype <> 3
        ) t
    where
	    CallStartDateTime >= '2019-10-01 08:00:00' 
    group by
	    case
		    when datepart(hour, CallStartDateTime) < 8 then datename(day, dateadd(day, -1, CallStartDateTime)) + ' ' + datename(month, dateadd(day, -1, CallStartDateTime))
		    else datename(day, CallStartDateTime) + ' ' + datename(month, CallStartDateTime)
	    end,
	    case
		    when datepart(hour, CallStartDateTime) < 8 then datepart(hour, CallStartDateTime) + 24
		    else datepart(hour, CallStartDateTime)
	    end,
	    convert(varchar(2), CallStartDateTime, 8)

end
GO
