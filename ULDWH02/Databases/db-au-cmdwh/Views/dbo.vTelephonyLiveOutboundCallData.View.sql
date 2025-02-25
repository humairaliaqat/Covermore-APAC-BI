USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vTelephonyLiveOutboundCallData]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vTelephonyLiveOutboundCallData]
as
--20151027 - LS - bring in Cisco's team

select
    isnull(t.TeamName, 'Unknown') Team,
    isnull(t.resourcename, 'Unknown') Agent,
    t.resourceloginid LoginID,
    t.SupervisorFlag,
    isnull(t.SessionID,0) as SessionID,
    isnull(dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time'),'1900-01-01') as CallStartDateTime,
    isnull(dbo.xfn_ConvertUTCToLocal(t.CallEndDateTime,'AUS Eastern Standard Time'),'1900-01-01') as CallEndDateTime,    
    datediff(
        second, 
        isnull(dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time'),'1900-01-01'),
        isnull(dbo.xfn_ConvertUTCToLocal(t.CallEndDateTime,'AUS Eastern Standard Time'),'1900-01-01')
    ) CallDuration,
    isnull(t.OriginatorNumber,'') as OriginatorNumber,
    isnull(t.DestinationNumber,'') as DestinationNumber,
    isnull(t.CalledNumber,'') as CalledNumber,
    isnull(t.OutboundCallType,'') as OutboundCallType,
    isnull(t.TalkTime, 0) as TalkTime
from 
    openquery(
        CISCO,
        '
            SELECT    
                ccd.sessionid,
                ccd.sessionseqnum,
                ccd.nodeid,
                ccd.profileid,
                r.resourceid,
                ccd.startdatetime callStartDatetime, 
                ccd.enddatetime callEndDatetime, 
                ccd.originatordn OriginatorNumber, 
                ccd.destinationdn DestinationNumber, 
                ccd.callednumber, 
                case
                    when length(ccd.originatordn) > 0 then ''Non IPCC''
                    else ''IPCC''
                end OutboundCallType,
                ccd.connecttime talktime,
                r.resourceloginid,
                r.resourcename,
                tm.teamname,
                case
                    when exists 
                        (
                            select
                                1
                            from
                                supervisor s
                            where
                                s.active and
                                s.resourceloginid = r.resourceloginid and
                                s.managedteamid = tm.teamid
                        )
                    then 1
                    else 0
                end SupervisorFlag
            FROM
                contactcalldetail ccd
                inner join resource r ON
	                r.resourceid = ccd.originatorid
                left outer join team tm on
                    tm.teamid = r.assignedteamid and
                    tm.profileid = r.profileid
            WHERE
                ccd.originatortype = 1 AND /*l_agenttype*/
                ccd.contacttype <> 6 AND /*l_contacttypepreviewoutbound*/
                ccd.contacttype <> 5 AND /*l_transferin*/
                ccd.startdatetime between 
                    extend (today, year to second) - interval (660) minute(3) to minute and 
                    extend (today, year to second) + interval (839) minute(3) to minute + interval (59) second(3) to second
        '
    ) t
where
    dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time') >= convert(date, getdate())

GO
