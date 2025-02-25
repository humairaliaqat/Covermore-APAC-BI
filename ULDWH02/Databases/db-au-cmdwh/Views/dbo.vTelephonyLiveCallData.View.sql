USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vTelephonyLiveCallData]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vTelephonyLiveCallData]
as

/****************************************************************************************************/
--  Name:          vTelephonyLiveCallData
--  Author:        Leonardus Setyabudi
--  Date Created:  20150101
--  Description:   This view captures telephony call data in real time
--  
--  Change History: 20150101 - LS - Created
--					20150527 - LT - Amended Company case statement for Australia Post. It was including
--									DTC CSQ name (eg DTC_EAP_Centre, DTC_EAP_Rebook)
--					20151009 - LT - F26668 Amended company case statement to include helloworld and P&O
--                  20151027 - LS - bring in Cisco's team
--					20151030 - LT - Added Virgin to CSQName
--                  20160823 - LL - routing updates
--
/****************************************************************************************************/

with
cte_calls as
(
    select
        isnull(t.TeamName, 'Unknown') Team,
        isnull(t.resourcename, 'Unknown') Agent,
        t.resourceloginid LoginID,
        t.SupervisorFlag,
        isnull(t.SessionID,0) as SessionID,
        isnull(t.Disposition,'') as Disposition,
        isnull(dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time'),'1900-01-01') as CallStartDateTime,
        isnull(dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time'),'1900-01-01') as CallEndDateTime,    
        isnull(t.CSQName,'') as CSQName,
        isnull(t.ApplicationName, '') ApplicationName,
        case
            when ApplicationName = 'Accounts Receivable' then 'CoverMore'
            when ApplicationName = 'AUClaimsInternal' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceAAA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceANZ' then 'Air New Zealand'
            when ApplicationName = 'AUCustomerServiceAP' then 'Australia Post'
            when ApplicationName = 'AUCustomerServiceCM' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceHIF' then 'HIF'
            when ApplicationName = 'AUCustomerServiceHW' then 'helloworld'
            when ApplicationName = 'AUCustomerServiceIAL' then 'IAL'
            when ApplicationName = 'AUCustomerServiceMB' then 'Medibank'
            when ApplicationName = 'AUCustomerServicePO' then 'P&O'
            when ApplicationName = 'AUCustomerServicePrincess' then 'Princess'
            when ApplicationName = 'AUCustomerServiceRAA_SA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRAC_WA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRACQ_QLD' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRACV_VIC' then 'AAA'
            when ApplicationName = 'AUCustomerServiceTele_Claims' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceTele_Sales' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceVA' then 'Virgin'
            when ApplicationName = 'AUDTC' then 'Employee Assistance'
            when ApplicationName = 'AUMedicalAssistanceACE01' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceACE02' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceInternal' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceTriage01' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceTriage02' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceWestpacNZ' then 'Medical Assistance'
            when ApplicationName = 'CNMedicalAssistance' then 'Medical Assistance'
            when ApplicationName = 'IS_Service_Desk' then 'CoverMore Global Service'
            when ApplicationName = 'MYMedicalAssistance' then 'Medical Assistance'
            when ApplicationName = 'NZCustomerServiceANZ' then 'Air New Zealand'
            when ApplicationName = 'NZCustomerServiceCM' then 'CoverMore NZ'
            when ApplicationName = 'NZCustomerServiceIAG_AMI' then 'IAG'
            when ApplicationName = 'NZCustomerServiceIAG_STATE' then 'IAG'
            when ApplicationName = 'NZCustomerServicePO' then 'P&O'
            when ApplicationName = 'NZCustomerServiceWestpac' then 'Westpac'
            else 'Other'
        end Company,
        isnull(t.OriginatorNumber,'') as OriginatorNumber,
        isnull(t.DestinationNumber,'') as DestinationNumber,
        isnull(t.CalledNumber,'') as CalledNumber,
        isnull(t.OrigCalledNumber,'') as OrigCalledNumber,
        0 as RingNoAnswer,
        isnull(t.CallsPresented,0) as CallsPresented,
        isnull(t.CallsHandled,0) as CallsHandled,
        isnull(t.CallsAbandoned,0) as CallsAbandoned,
        isnull(t.RingTime,0) as RingTime,
        isnull(t.TalkTime,0) as TalkTime,
        isnull(t.HoldTime,0) as HoldTime,
        isnull(t.WorkTime,0) as WorkTime,
        isnull(t.WrapUpTime,0) as WrapUpTime,
        isnull(t.QueueTime,0) as QueueTime,
        isnull(t.MetServiceLevel,0) MetServiceLevel,
        isnull(t.[Transfer],0) as [Transfer],
        isnull(t.Redirect,0) as Redirect,
        isnull(t.Conference,0) as Conference
    from 
        openquery(
            CISCO,
            '
            select    
                cqdr.sessionid,
                cqdr.sessionseqnum,
                cqdr.nodeid,
                cqdr.profileid,
                cqdr.qindex,
                cqdr.targetid,
                acdr.resourceid,
                case cqdr.disposition 
                    when 1 then ''Abandoned''
                    when 2 then ''Handled''
                    when 3 then ''Dequeued''
                    when 4 then ''Handled by script''
                    when 5 then ''Handled by other CSQ''
                    when 0 then ''Transferred''
                    else ''Unknown''
                end as Disposition,
                ccdr.startdatetime callStartDatetime, 
                ccdr.enddatetime callEndDatetime, 
                csq.csqname,
                csq.servicelevelpercentage,
                ccdr.originatordn OriginatorNumber, 
                ccdr.destinationdn DestinationNumber, 
                ccdr.callednumber, 
                ccdr.origcallednumber,
                1 as CallsPresented,
                case 
                    when cqdr.disposition = 2 and acdr.talktime > 0 then 1 
                    else 0 
                end as CallsHandled,
                case 
                    when cqdr.disposition = 1 then 1 
                    else 0 
                end as CallsAbandoned,
                nvl(acdr.ringtime,0) RingTime, 
                nvl(acdr.talktime, 0) TalkTime, 
                nvl(acdr.holdtime, 0) HoldTime,
                nvl(acdr.worktime, 0) WorkTime,
                nvl(csq.wrapuptime, 0) WrapUpTime,
                nvl(cqdr.queuetime, 0) QueueTime,
                cqdr.metservicelevel,
                ccdr.transfer, 
                ccdr.redirect, 
                ccdr.conference,
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
                end SupervisorFlag,
                ccdr.applicationname
            from 
                Contactqueuedetail cqdr
                inner join Contactcalldetail ccdr on 
                    cqdr.sessionid = ccdr.sessionid and 
                    cqdr.sessionseqnum = ccdr.sessionseqnum and 
                    cqdr.profileid = ccdr.profileid and 
                    cqdr.nodeid = ccdr.nodeid 
                left outer join Contactservicequeue csq on 
                    cqdr.targetid = csq.recordid and 
                    cqdr.profileid = csq.profileid
                left outer join Agentconnectiondetail acdr on 
                    cqdr.sessionid = acdr.sessionid and 
                    cqdr.sessionseqnum = acdr.sessionseqnum and 
                    cqdr.profileid = acdr.profileid and 
                    cqdr.nodeid = acdr.nodeid and 
                    cqdr.qindex = acdr.qindex and 
                    not 
                    (
                        cqdr.disposition = 1 or 
                        (
                            cqdr.disposition = 2 and 
                            acdr.talktime = 0
                        )
                    )
                left outer join resource r on
                    r.resourceid = acdr.resourceid and
                    r.profileid = acdr.profileid
                left outer join team tm on
                    tm.teamid = r.assignedteamid and
                    tm.profileid = r.profileid
            where 
                cqdr.targettype = 0 and 
                ccdr.startdatetime between 
                    extend (today, year to second) - interval (660) minute(3) to minute and 
                    extend (today, year to second) + interval (839) minute(3) to minute + interval (59) second(3) to second
            for read only
            '
        ) t
    where
        dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time') >= convert(date, getdate())
    
    union all

    select
        isnull(t.TeamName, 'Unknown') Team,
        isnull(t.resourcename, 'Unknown') Agent,
        t.resourceloginid LoginID,
        t.SupervisorFlag,
        isnull(t.SessionID,0) as SessionID,
        isnull(t.Disposition,'') as Disposition,
        isnull(dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time'),'1900-01-01') as CallStartDateTime,
        isnull(dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time'),'1900-01-01') as CallEndDateTime,    
        isnull(t.CSQName,'') as CSQName,
        isnull(t.ApplicationName, '') ApplicationName,
        case
            when ApplicationName = 'Accounts Receivable' then 'CoverMore'
            when ApplicationName = 'AUClaimsInternal' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceAAA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceANZ' then 'Air New Zealand'
            when ApplicationName = 'AUCustomerServiceAP' then 'Australia Post'
            when ApplicationName = 'AUCustomerServiceCM' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceHIF' then 'HIF'
            when ApplicationName = 'AUCustomerServiceHW' then 'helloworld'
            when ApplicationName = 'AUCustomerServiceIAL' then 'IAL'
            when ApplicationName = 'AUCustomerServiceMB' then 'Medibank'
            when ApplicationName = 'AUCustomerServicePO' then 'P&O'
            when ApplicationName = 'AUCustomerServicePrincess' then 'Princess'
            when ApplicationName = 'AUCustomerServiceRAA_SA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRAC_WA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRACQ_QLD' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRACV_VIC' then 'AAA'
            when ApplicationName = 'AUCustomerServiceTele_Claims' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceTele_Sales' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceVA' then 'Virgin'
            when ApplicationName = 'AUDTC' then 'Employee Assistance'
            when ApplicationName = 'AUMedicalAssistanceACE01' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceACE02' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceInternal' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceTriage01' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceTriage02' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceWestpacNZ' then 'Medical Assistance'
            when ApplicationName = 'CNMedicalAssistance' then 'Medical Assistance'
            when ApplicationName = 'IS_Service_Desk' then 'CoverMore Global Service'
            when ApplicationName = 'MYMedicalAssistance' then 'Medical Assistance'
            when ApplicationName = 'NZCustomerServiceANZ' then 'Air New Zealand'
            when ApplicationName = 'NZCustomerServiceCM' then 'CoverMore NZ'
            when ApplicationName = 'NZCustomerServiceIAG_AMI' then 'IAG'
            when ApplicationName = 'NZCustomerServiceIAG_STATE' then 'IAG'
            when ApplicationName = 'NZCustomerServicePO' then 'P&O'
            when ApplicationName = 'NZCustomerServiceWestpac' then 'Westpac'
            else 'Other'
        end Company,
        isnull(t.OriginatorNumber,'') as OriginatorNumber,
        isnull(t.DestinationNumber,'') as DestinationNumber,
        isnull(t.CalledNumber,'') as CalledNumber,
        isnull(t.OrigCalledNumber,'') as OrigCalledNumber,
        isnull(t.RingNoAnswer,0) as RingNoAnswer,
        0 as CallsPresented,
        0 as CallsHandled,
        0 as CallsAbandoned,
        0 as RingTime,
        0 as TalkTime,
        0 as HoldTime,
        0 as WorkTime,
        0 as WrapUpTime,
        0 as QueueTime,
        isnull(t.MetServiceLevel,0) MetServiceLevel,
        isnull(t.[Transfer],0) as [Transfer],
        isnull(t.Redirect,0) as Redirect,
        isnull(t.Conference,0) as Conference          
    from 
        openquery(
            CISCO,
            '
            select    
                cqdr.sessionid,
                cqdr.sessionseqnum,
                cqdr.nodeid,
                cqdr.profileid,
                cqdr.qindex,
                cqdr.targetid,
                acdr.resourceid,
                case cqdr.disposition when 1 then ''Abandoned''
                when 2 then ''Handled''
                when 3 then ''Dequeued''
                when 4 then ''Handled by script''
                when 5 then ''Handled by other CSQ''
                when 0 then ''Transferred''
                else ''Unknown''
                end as Disposition,
                acdr.startdatetime callStartDatetime, 
                acdr.enddatetime callEndDatetime, 
                csq.csqname,
                csq.servicelevelpercentage,
                ccdr.originatordn OriginatorNumber, 
                ccdr.destinationdn DestinationNumber, 
                ccdr.callednumber, 
                ccdr.origcallednumber,
                1 as RingNoAnswer,
                cqdr.metservicelevel,
                ccdr.transfer, 
                ccdr.redirect, 
                ccdr.conference,
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
                end SupervisorFlag,
                ccdr.applicationname
            from 
                Contactqueuedetail cqdr
                inner join Contactcalldetail ccdr on 
                    cqdr.sessionid = ccdr.sessionid and 
                    cqdr.sessionseqnum = ccdr.sessionseqnum and 
                    cqdr.profileid = ccdr.profileid and 
                    cqdr.nodeid = ccdr.nodeid 
                left outer  join Contactservicequeue csq on 
                    cqdr.targetid = csq.recordid and 
                    cqdr.profileid = csq.profileid
                left outer join Agentconnectiondetail acdr on 
                    cqdr.sessionid = acdr.sessionid and 
                    cqdr.sessionseqnum = acdr.sessionseqnum and 
                    cqdr.profileid = acdr.profileid and 
                    cqdr.nodeid = acdr.nodeid and 
                    cqdr.qindex = acdr.qindex 
                left outer join resource r on
                    r.resourceid = acdr.resourceid and
                    r.profileid = acdr.profileid
                left outer join team tm on
                    tm.teamid = r.assignedteamid and
                    tm.profileid = r.profileid
            where 
                cqdr.targettype = 0 and
                acdr.ringtime >= 0 and 
                acdr.talktime = 0 and
                ccdr.startdatetime between 
                    extend (today, year to second) - interval (660) minute(3) to minute and 
                    extend (today, year to second) + interval (839) minute(3) to minute + interval (59) second(3) to second
            for read only
            '
        ) t
    where
        dbo.xfn_ConvertUTCToLocal(t.CallStartDateTime,'AUS Eastern Standard Time') >= convert(date, getdate())
)
select 
    *,
    case 
		when Company in
        (
            'CoverMore Global Service',
            'TIP',
            'Medical Assistance',
            'Employee Assistance',
            'Air New Zealand',
            'IAG',
            'P&O',
            'AAA',
            'CoverMore NZ',
            'CoverMore MY',
            'Virgin',
            'Princess',
            'Westpac',
            'HIF',
            'IAL',
            'Other'
        --) then 0
        ) then 1
        else 1
    end IncludeInCSDashboard
from
    cte_calls    






GO
