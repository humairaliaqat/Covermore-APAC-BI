USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoCalls]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--http://www.cisco.com/c/dam/en/us/td/docs/voice_ip_comm/cust_contact/contact_center/crs/express_9_0/user/guide/uccx90dbschemagd.pdf
CREATE procedure [dbo].[etlsp_ETL041_CiscoCalls]  
--declare
    @StartDate datetime = null,
    @EndDate datetime = null

as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160714
Prerequisite:   Requires CISCO Informix database.                
Description:    one proc to rule them all, this is to replace cisCalls, cisOutboundCall and cisRNA
Parameters:     
Change History:
                20160714 - LL - created
                20160823 - LL - add application (proxy for trigger point, proxy for company)
                20190326 - LL - resume work
                                move from reading directly to reading from staging
                20190328 - LL - bring in moar data
                20190410 - LL - change business rules on queuehandled, queueabandoned, metservicelevel
                                take into account of unknown queuedisposition and refer to contactdisposition
                                change business rules on talktime and connect time, only use connect time for outgoing
                20190415 - LL - bug fix, incude nodeid & profileid in join cisco_contactcalldetail to cisco_contactqueuedetail
                                duplicate values, reused id between 20016 and 2019 e.g. session id 232000015647,232000002262
                
*************************************************************************************************************************************/

--select
--    @StartDate = '2015-07-01',
--    @EndDate = '2015-07-31'


    set nocount on

    declare
        @batchid int = -1,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int
        
    declare @mergeoutput table (MergeAction varchar(20))

    if @StartDate is not null
        select 
            @StartDate = dbo.xfn_ConvertLocalToUTC(@StartDate, 'AUS Eastern Standard Time'),
            @EndDate = dateadd(d, 1, dbo.xfn_ConvertLocalToUTC(@EndDate, 'AUS Eastern Standard Time'))

    else 

    begin 
    
        exec syssp_getrunningbatch
            @SubjectArea = 'CISCO ODS',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out
    
        select 
            @StartDate = dbo.xfn_ConvertLocalToUTC(@start, 'AUS Eastern Standard Time'),
            @EndDate = dateadd(d, 1, dbo.xfn_ConvertLocalToUTC(@end, 'AUS Eastern Standard Time'))
                   
    end 

    select
        @name = object_name(@@procid)
        
    exec syssp_genericerrorhandler 
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    
    if object_id('[db-au-stage]..cisco_ciscalls') is not null
        drop table [db-au-stage]..cisco_ciscalls

    create table [db-au-stage]..cisco_ciscalls
    (
        [sessionid] bigint,
        [sessionseqnum] int,
        [nodeid] int,
        [profileid] int,
        [contacttype] int,
        [contactdisposition] int,
        [dispositionreason] varchar(100),
        [originatortype] int,
        [originatorid] int,
        [originatoragent] varchar(50),
        [originatorext] varchar(50),
        [originatordn] varchar(30),
        [destinationtype] int,
        [destinationid] int,
        [destinationagent] varchar(50),
        [destinationext] varchar(50),
        [destinationdn] varchar(30),
        [startdatetime] datetime2,
        [enddatetime] datetime2,
        [callednumber] varchar(30),
        [origcallednumber] varchar(30),
        [applicationtaskid] bigint,
        [applicationid] int,
        [applicationname] varchar(30),
        [connecttime] int,
        [varcsqname] varchar(40),
        [varext] varchar(40),
        [varclassification] varchar(40),
        [varivroption] varchar(40),
        [varivrreference] varchar(40),
        [varwrapup] varchar(40),
        [accountnumber] varchar(40),
        [callerentereddigits] varchar(40),
        [badcalltag] char(1),
        [transfer] bit,
        [redirect] bit,
        [conference] bit,
        [ringtime] int,
        [talktime] int,
        [holdtime] int,
        [worktime] int,
        [wrapuptime] int,
        [wrapupdata] varchar(40),
        [targetid] int,
        [targettype] int,
        [queuedisposition] int,
        [queuetime] int,
        [metservicelevel] bit,
        [csqname] varchar(50),
        [servicelevelpercentage] int,
        [resourcename] varchar(50),
        [loginid] varchar(50),
        [teamname] varchar(50),
        [supervisorflag] int,
        [callresult] int,
        [campaignid] int,
        [dialinglistid] int,
        [origprotocolcallref] varchar(50),
        [destprotocolcallref] varchar(50),
        [SessionKey] varchar(50)
    )
    
    insert into [db-au-stage]..cisco_ciscalls
    select --top 10
        ccdr.sessionid,
        ccdr.sessionseqnum,
        ccdr.nodeid,
        ccdr.profileid,
        ccdr.contacttype,
        ccdr.contactdisposition,
        ccdr.dispositionreason,
        ccdr.originatortype,
        ccdr.originatorid,
        org.resourcename originatoragent,
        org.extension originatorext,
        ccdr.originatordn,
        ccdr.destinationtype,
        ccdr.destinationid,
        dst.resourcename destinationagent,
        dst.extension destinationext,
        ccdr.destinationdn,
        coalesce(acdr.startdatetime, ccdr.startdatetime) startdatetime, 
        coalesce(acdr.enddatetime, ccdr.enddatetime) enddatetime, 
        ccdr.callednumber,
        ccdr.origcallednumber,
        ccdr.applicationtaskid,
        ccdr.applicationid,
        ccdr.applicationname,
        ccdr.connecttime,
        ccdr.customvariable1 varcsqname,
        ccdr.customvariable2 varext,
        ccdr.customvariable3 varclassification,
        ccdr.customvariable6 varivroption,
        ccdr.customvariable8 varivrreference,
        ccdr.customvariable10 varwrapup,
        ccdr.accountnumber,
        ccdr.callerentereddigits,
        ccdr.badcalltag,
        ccdr.transfer,
        ccdr.redirect,
        ccdr.conference,
        coalesce(acdr.ringtime,0) ringtime, 
        coalesce(acdr.talktime, 0) talktime, 
        coalesce(acdr.holdtime, 0) holdtime,
        coalesce(acdr.worktime, 0) worktime,
        coalesce(csq.wrapuptime, 0) wrapuptime,
        coalesce(acdr.callwrapupdata, '') wrapupdata,
        coalesce(cqdr.targetid, 0) targetid,
        coalesce(cqdr.targettype, -1) targettype,
        cqdr.disposition queuedisposition,
        coalesce(cqdr.queuetime, 0) queuetime,
        cqdr.metservicelevel,
        csq.csqname,
        coalesce(csq.servicelevelpercentage, 0) servicelevelpercentage,
        res.resourcename,
        res.resourceloginid loginid,
        tea.teamname,
        case
            when exists 
                (
                    select
                        1
                    from
                        cisco_supervisor s with(nolock)
                    where
                        s.active = 1 and
                        s.resourceloginid = res.resourceloginid and
                        s.managedteamid = tea.teamid
                )
            then 1
            else 0
        end supervisorflag,
        case
            when acdr.callresult = 0 then ccdr.callresult
            else acdr.callresult
        end callresult,
        ccdr.campaignid,
        ccdr.dialinglistid,
        ccdr.origprotocolcallref,
        ccdr.destprotocolcallref,
        '' as [SessionKey]
    from 
        cisco_contactcalldetail ccdr with(nolock)
        left join cisco_resource org with(nolock) on
            org.resourceid = ccdr.originatorid
        left join cisco_resource dst with(nolock) on
            dst.resourceid = ccdr.destinationid 
        inner join cisco_contactqueuedetail cqdr with(nolock) on
            cqdr.sessionid = ccdr.sessionid and 
            cqdr.sessionseqnum = ccdr.sessionseqnum and
            cqdr.profileid = ccdr.profileid and
            cqdr.nodeid = ccdr.nodeid
        inner join cisco_agentconnectiondetail acdr with(nolock) on
            acdr.sessionid = cqdr.sessionid and
            acdr.sessionseqnum = cqdr.sessionseqnum and
            acdr.profileid = cqdr.profileid and 
            acdr.nodeid = cqdr.nodeid and
            acdr.qindex = cqdr.qindex
        left join cisco_resource res with(nolock) on
            acdr.resourceid = res.resourceid
        left join cisco_contactservicequeue csq with(nolock) on 
            cqdr.targetid = csq.recordid and 
            cqdr.profileid = csq.profileid
        left join cisco_team tea with(nolock) on
            res.assignedteamid = tea.teamid
    where
        ccdr.startdatetime >= @StartDate and
        ccdr.startdatetime <  @EndDate


    insert into [db-au-stage]..cisco_ciscalls
    select --top 10
        ccdr.sessionid,
        ccdr.sessionseqnum,
        ccdr.nodeid,
        ccdr.profileid,
        ccdr.contacttype,
        ccdr.contactdisposition,
        ccdr.dispositionreason,
        ccdr.originatortype,
        ccdr.originatorid,
        org.resourcename originatoragent,
        org.extension originatorext,
        ccdr.originatordn,
        ccdr.destinationtype,
        ccdr.destinationid,
        dst.resourcename destinationagent,
        dst.extension destinationext,
        ccdr.destinationdn,
        coalesce(acdr.startdatetime, ccdr.startdatetime) startdatetime, 
        coalesce(acdr.enddatetime, ccdr.enddatetime) enddatetime, 
        ccdr.callednumber,
        ccdr.origcallednumber,
        ccdr.applicationtaskid,
        ccdr.applicationid,
        ccdr.applicationname,
        ccdr.connecttime,
        ccdr.customvariable1 varcsqname,
        ccdr.customvariable2 varext,
        ccdr.customvariable3 varclassification,
        ccdr.customvariable6 varivroption,
        ccdr.customvariable8 varivrreference,
        ccdr.customvariable10 varwrapup,
        ccdr.accountnumber,
        ccdr.callerentereddigits,
        ccdr.badcalltag,
        ccdr.transfer,
        ccdr.redirect,
        ccdr.conference,
        coalesce(acdr.ringtime,0) ringtime, 
        coalesce(acdr.talktime, 0) talktime, 
        coalesce(acdr.holdtime, 0) holdtime,
        coalesce(acdr.worktime, 0) worktime,
        coalesce(csq.wrapuptime, 0) wrapuptime,
        coalesce(acdr.callwrapupdata, '') wrapupdata,
        coalesce(cqdr.targetid, 0) targetid,
        coalesce(cqdr.targettype, -1) targettype,
        cqdr.disposition queuedisposition,
        coalesce(cqdr.queuetime, 0) queuetime,
        cqdr.metservicelevel,
        csq.csqname,
        coalesce(csq.servicelevelpercentage, 0) servicelevelpercentage,
        res.resourcename,
        res.resourceloginid loginid,
        tea.teamname,
        case
            when exists 
                (
                    select
                        1
                    from
                        cisco_supervisor s with(nolock)
                    where
                        s.active = 1 and
                        s.resourceloginid = res.resourceloginid and
                        s.managedteamid = tea.teamid
                )
            then 1
            else 0
        end supervisorflag,
        case
            when acdr.callresult = 0 then ccdr.callresult
            else acdr.callresult
        end callresult,
        ccdr.campaignid,
        ccdr.dialinglistid,
        ccdr.origprotocolcallref,
        ccdr.destprotocolcallref,
        '' as [SessionKey] 
    from 
        cisco_contactcalldetail ccdr with(nolock)
        left join cisco_resource org with(nolock) on
            org.resourceid = ccdr.originatorid
        left join cisco_resource dst with(nolock) on
            dst.resourceid = ccdr.destinationid 
        left join cisco_contactqueuedetail cqdr with(nolock) on
            cqdr.sessionid = ccdr.sessionid and 
            cqdr.sessionseqnum = ccdr.sessionseqnum and
            cqdr.profileid = ccdr.profileid and
            cqdr.nodeid = ccdr.nodeid
        left join cisco_agentconnectiondetail acdr with(nolock) on
            acdr.sessionid = cqdr.sessionid and
            acdr.sessionseqnum = cqdr.sessionseqnum and
            acdr.profileid = cqdr.profileid and 
            acdr.nodeid = cqdr.nodeid and
            acdr.qindex = cqdr.qindex
        left join cisco_resource res with(nolock) on
            acdr.resourceid = res.resourceid
        left join cisco_contactservicequeue csq with(nolock) on 
            cqdr.targetid = csq.recordid and 
            cqdr.profileid = csq.profileid
        left join cisco_team tea with(nolock) on
            res.assignedteamid = tea.teamid
    where
        ccdr.startdatetime >= @StartDate and
        ccdr.startdatetime <  @EndDate and
        cqdr.sessionid is null and
        acdr.sessionid is null
            

    insert into [db-au-stage]..cisco_ciscalls
    select
        ccdr.sessionid,
        ccdr.sessionseqnum,
        ccdr.nodeid,
        ccdr.profileid,
        ccdr.contacttype,
        ccdr.contactdisposition,
        ccdr.dispositionreason,
        ccdr.originatortype,
        ccdr.originatorid,
        org.resourcename originatoragent,
        org.extension originatorext,
        ccdr.originatordn,
        ccdr.destinationtype,
        ccdr.destinationid,
        dst.resourcename destinationagent,
        dst.extension destinationext,
        ccdr.destinationdn,
        coalesce(acdr.startdatetime, ccdr.startdatetime) startdatetime, 
        coalesce(acdr.enddatetime, ccdr.enddatetime) enddatetime, 
        ccdr.callednumber,
        ccdr.origcallednumber,
        ccdr.applicationtaskid,
        ccdr.applicationid,
        ccdr.applicationname,
        ccdr.connecttime,
        ccdr.customvariable1 varcsqname,
        ccdr.customvariable2 varext,
        ccdr.customvariable3 varclassification,
        ccdr.customvariable6 varivroption,
        ccdr.customvariable8 varivrreference,
        ccdr.customvariable10 varwrapup,
        ccdr.accountnumber,
        ccdr.callerentereddigits,
        ccdr.badcalltag,
        ccdr.transfer,
        ccdr.redirect,
        ccdr.conference,
        coalesce(acdr.ringtime,0) ringtime, 
        coalesce(acdr.talktime, 0) talktime, 
        coalesce(acdr.holdtime, 0) holdtime,
        coalesce(acdr.worktime, 0) worktime,
        coalesce(csq.wrapuptime, 0) wrapuptime,
        coalesce(acdr.callwrapupdata, '') wrapupdata,
        coalesce(cqdr.targetid, 0) targetid,
        coalesce(cqdr.targettype, -1) targettype,
        cqdr.disposition queuedisposition,
        coalesce(cqdr.queuetime, 0) queuetime,
        cqdr.metservicelevel,
        csq.csqname,
        coalesce(csq.servicelevelpercentage, 0) servicelevelpercentage,
        res.resourcename,
        res.resourceloginid loginid,
        tea.teamname,
        case
            when exists 
                (
                    select
                        1
                    from
                        cisco_supervisor s with(nolock)
                    where
                        s.active = 1 and
                        s.resourceloginid = res.resourceloginid and
                        s.managedteamid = tea.teamid
                )
            then 1
            else 0
        end supervisorflag,
        case
            when acdr.callresult = 0 then ccdr.callresult
            else acdr.callresult
        end callresult,
        ccdr.campaignid,
        ccdr.dialinglistid,
        ccdr.origprotocolcallref,
        ccdr.destprotocolcallref,
        '' as [SessionKey]
    from 
        cisco_contactcalldetail ccdr with(nolock)
        left join cisco_resource org with(nolock) on
            org.resourceid = ccdr.originatorid
        left join cisco_resource dst with(nolock) on
            dst.resourceid = ccdr.destinationid 
        inner join cisco_contactqueuedetail cqdr with(nolock) on
            cqdr.sessionid = ccdr.sessionid and 
            cqdr.sessionseqnum = ccdr.sessionseqnum and
            cqdr.profileid = ccdr.profileid and
            cqdr.nodeid = ccdr.nodeid
        left join cisco_agentconnectiondetail acdr with(nolock) on
            acdr.sessionid = cqdr.sessionid and
            acdr.sessionseqnum = cqdr.sessionseqnum and
            acdr.profileid = cqdr.profileid and 
            acdr.nodeid = cqdr.nodeid and
            acdr.qindex = cqdr.qindex
        left join cisco_resource res with(nolock) on
            acdr.resourceid = res.resourceid
        left join cisco_contactservicequeue csq with(nolock) on 
            cqdr.targetid = csq.recordid and 
            cqdr.profileid = csq.profileid
        left join cisco_team tea with(nolock) on
            res.assignedteamid = tea.teamid
    where
        ccdr.startdatetime >= @StartDate and
        ccdr.startdatetime <  @EndDate and
        acdr.sessionid is null


    insert into [db-au-stage]..cisco_ciscalls
    select 
        ccdr.sessionid,
        ccdr.sessionseqnum,
        ccdr.nodeid,
        ccdr.profileid,
        ccdr.contacttype,
        ccdr.contactdisposition,
        ccdr.dispositionreason,
        ccdr.originatortype,
        ccdr.originatorid,
        org.resourcename originatoragent,
        org.extension originatorext,
        ccdr.originatordn,
        ccdr.destinationtype,
        ccdr.destinationid,
        dst.resourcename destinationagent,
        dst.extension destinationext,
        ccdr.destinationdn,
        coalesce(acdr.startdatetime, ccdr.startdatetime) startdatetime, 
        coalesce(acdr.enddatetime, ccdr.enddatetime) enddatetime, 
        ccdr.callednumber,
        ccdr.origcallednumber,
        ccdr.applicationtaskid,
        ccdr.applicationid,
        ccdr.applicationname,
        ccdr.connecttime,
        ccdr.customvariable1 varcsqname,
        ccdr.customvariable2 varext,
        ccdr.customvariable3 varclassification,
        ccdr.customvariable6 varivroption,
        ccdr.customvariable8 varivrreference,
        ccdr.customvariable10 varwrapup,
        ccdr.accountnumber,
        ccdr.callerentereddigits,
        ccdr.badcalltag,
        ccdr.transfer,
        ccdr.redirect,
        ccdr.conference,
        coalesce(acdr.ringtime,0) ringtime, 
        coalesce(acdr.talktime, 0) talktime, 
        coalesce(acdr.holdtime, 0) holdtime,
        coalesce(acdr.worktime, 0) worktime,
        coalesce(csq.wrapuptime, 0) wrapuptime,
        coalesce(acdr.callwrapupdata, '') wrapupdata,
        coalesce(cqdr.targetid, 0) targetid,
        coalesce(cqdr.targettype, -1) targettype,
        cqdr.disposition queuedisposition,
        coalesce(cqdr.queuetime, 0) queuetime,
        cqdr.metservicelevel,
        csq.csqname,
        coalesce(csq.servicelevelpercentage, 0) servicelevelpercentage,
        res.resourcename,
        res.resourceloginid loginid,
        tea.teamname,
        case
            when exists 
                (
                    select
                        1
                    from
                        cisco_supervisor s with(nolock)
                    where
                        s.active = 1 and
                        s.resourceloginid = res.resourceloginid and
                        s.managedteamid = tea.teamid
                )
            then 1
            else 0
        end supervisorflag,
        case
            when acdr.callresult = 0 then ccdr.callresult
            else acdr.callresult
        end callresult,
        ccdr.campaignid,
        ccdr.dialinglistid,
        ccdr.origprotocolcallref,
        ccdr.destprotocolcallref,
        '' as [SessionKey]
    from 
        cisco_contactcalldetail ccdr with(nolock)
        left join cisco_resource org with(nolock) on
            org.resourceid = ccdr.originatorid
        left join cisco_resource dst with(nolock) on
            dst.resourceid = ccdr.destinationid 
        inner join cisco_agentconnectiondetail acdr with(nolock) on
            acdr.sessionid = ccdr.sessionid and
            acdr.sessionseqnum = ccdr.sessionseqnum and
            acdr.profileid = ccdr.profileid and 
            acdr.nodeid = ccdr.nodeid 
        left join cisco_resource res with(nolock) on
            acdr.resourceid = res.resourceid
        left join cisco_contactqueuedetail cqdr with(nolock) on
            cqdr.sessionid = acdr.sessionid and 
            cqdr.sessionseqnum = acdr.sessionseqnum and 
            cqdr.profileid = acdr.profileid and 
            cqdr.nodeid = acdr.nodeid and
            cqdr.qindex = acdr.qindex
        left join cisco_contactservicequeue csq with(nolock) on 
            cqdr.targetid = csq.recordid and 
            cqdr.profileid = csq.profileid
        left join cisco_team tea with(nolock) on
            res.assignedteamid = tea.teamid
    where
        ccdr.startdatetime >= @StartDate and
        ccdr.startdatetime <  @EndDate and
        cqdr.sessionid is null

    
    --alter table [db-au-stage]..cisco_ciscalls add SessionKey varchar(50) null
    update [db-au-stage]..cisco_ciscalls 
    set SessionKey = convert(varchar(50), sessionid) + '.' + 
            convert(varchar(50), sessionseqnum) + '.' + 
            replace(replace(replace(convert(varchar(23), startdatetime, 126), '-', ''), 'T', ''), ':', '')

    --create table if not exists
    if object_id('[db-au-cmdwh].dbo.cisCalls') is null
    begin
        
        create table [db-au-cmdwh].dbo.cisCalls
        (
            BIRowID bigint not null identity(1,1),
            SessionKey varchar(50) not null,
            SessionID bigint,
            SessionSequence int,
            NodeID int,
            ProfileID int,
            ContactType varchar(50),
            ContactDisposition varchar(50),
            DispositionReason varchar(100),
            OriginatorTypeID int,
            OriginatorType varchar(50),
            OriginatorID int,
            OriginatorAgent varchar(50),
            OriginatorExt varchar(50),
            OriginatorNumber varchar(50),
            DestinationTypeID int,
            DestinationType varchar(50),
            DestinationID int,
            DestinationAgent varchar(50),
            DestinationExt varchar(50),
            DestinationNumber varchar(50),
            CallResult varchar(50),
            CallStartDateTime datetime,
            CallEndDateTime datetime,
            CallStartDateTimeUTC datetime,
            CallEndDateTimeUTC datetime,
            GatewayNumber varchar(50),
            DialedNumber varchar(50),
            Transfer int,
            Redirect int,
            Conference int,
            ConnectTime int,
            RingTime int,
            TalkTime int,
            HoldTime int,
            WorkTime int,
            WrapUpTime int,
            TargetType varchar(50),
            TargetID int,
            CSQName varchar(50),
            QueueDisposition varchar(50),
            QueueHandled int,
            QueueAbandoned int,
            QueueTime int,
            ServiceLevelPercentage int,
            MetServiceLevel int,
            Agent varchar(50),
            Team varchar(50),
            LoginID varchar(50),
            SupervisorFlag int,
            VarCSQName varchar(40),
            VarEXT varchar(40),
            VarClassification varchar(40),
            VarIVROption varchar(40),
            VarIVRReference varchar(40),
            VarWrapUp varchar(40),
            WrapUpData varchar(40),
            AccountNumber varchar(40),
            CallerEnteredDigits varchar(40),
            BadCallTag char(1),
            ApplicationID int,
            ApplicationName varchar(30),
            CampaignID int,
            DialinglistID int,
            OriginProtocol varchar(50),
            DestinationProtocol varchar(50),
            UpdateDateTime datetime default getdate()
        ) 
            
        create clustered index idx_cisCalls_BIRowID on [db-au-cmdwh].dbo.cisCalls(BIRowID)
        create nonclustered index idx_cisCalls_SessionKey on [db-au-cmdwh].dbo.cisCalls(SessionKey)
        create nonclustered index idx_cisCalls_SessionID on [db-au-cmdwh].dbo.cisCalls(SessionID) include(CallStartDateTime,CallEndDateTime)
        create nonclustered index idx_cisCalls_Time on [db-au-cmdwh].dbo.cisCalls(CallStartDateTime,CallEndDateTime)
            
    end    


--1,900 duplicates in 15 months
--due to multiple queues cross joined to multiple agent connections
--leave it for now

--select top 10000
--    convert(varchar(50), sessionid) + '.' + 
--    convert(varchar(50), sessionseqnum) + '.' + 
--    replace(replace(replace(convert(varchar(23), startdatetime, 126), '-', ''), 'T', ''), ':', '') SK,
--    count(*)
--from
--    [db-au-stage]..cisco_ciscalls
--group by
--    convert(varchar(50), sessionid) + '.' + 
--    convert(varchar(50), sessionseqnum) + '.' + 
--    replace(replace(replace(convert(varchar(23), startdatetime, 126), '-', ''), 'T', ''), ':', '')
--having count(*) > 1

--select *
--from
--    [db-au-stage]..cisco_ciscalls
--where
--    sessionid = 144000184384
--order by 
--    sessionseqnum,
--    startdatetime


    begin transaction

    begin try
            
        delete 
        from
            [db-au-cmdwh]..cisCalls
        where
            SessionKey in
            (
                select 
                    SessionKey
                from
                    [db-au-stage]..cisco_ciscalls
            )
               
        insert into [db-au-cmdwh]..cisCalls with (tablock)
        (
            SessionKey,
            SessionID,
            SessionSequence,
            NodeID,
            ProfileID,
            ContactType,
            ContactDisposition,
            DispositionReason,
            OriginatorTypeID,
            OriginatorType,
            OriginatorID,
            OriginatorAgent,
            OriginatorExt,
            OriginatorNumber,
            DestinationTypeID,
            DestinationType,
            DestinationID,
            DestinationAgent,
            DestinationExt,
            DestinationNumber,
            CallResult,
            CallStartDateTime,
            CallEndDateTime,
            CallStartDateTimeUTC,
            CallEndDateTimeUTC,
            GatewayNumber,
            DialedNumber,
            Transfer,
            Redirect,
            Conference,
            ConnectTime,
            RingTime,
            TalkTime,
            HoldTime,
            WorkTime,
            WrapUpTime,
            TargetType,
            TargetID,
            QueueDisposition,
            QueueHandled,
            QueueAbandoned,
            QueueTime,
            CSQName,
            ServiceLevelPercentage,
            MetServiceLevel,
            Agent,
            Team,
            LoginID ,
            SupervisorFlag,
            VarCSQName,
            VarEXT,
            VarClassification,
            VarIVROption,
            VarIVRReference,
            VarWrapUp,
            WrapUpData,
            AccountNumber,
            CallerEnteredDigits,
            BadCallTag,
            ApplicationID,
            ApplicationName,
            CampaignID,
            DialinglistID,
            OriginProtocol,
            DestinationProtocol,
            UpdateDateTime
        )
        select distinct
            SessionKey,
            SessionID,
            sessionseqnum SessionSequence,
            NodeID,
            ProfileID,
            case contacttype
                when 1 then 'Incoming'
                when 2 then 'Outgoing'
                when 3 then 'Internal'
                when 4 then 'Redirect in'
                when 5 then 'Transfer in'
                when 6 then 'Preview outbound'
                when 7 then 'IVR outbound'
                when 8 then 'Agent outbound'
                when 9 then 'Agent outbound to IVR'
                else 'Unknown'
            end ContactType,
            case 
                when contactdisposition = 1 then 'Abandoned'
                when contactdisposition = 2 then 'Handled'
                when contactdisposition = 3 then 'Do not care'
                when contactdisposition = 4 then 'Aborted'
                when contactdisposition between 5 and 22 then 'Rejected'
                when contactdisposition = 99 then 'Cleared'
                else 'Unknown'
            end ContactDisposition,
            DispositionReason,
            originatortype OriginatorTypeID,
            case originatortype
                when 1 then 'Agent'
                when 2 then 'Device'
                when 3 then 'Unknown'
                else 'Unknown'
            end OriginatorType,
            OriginatorID,
            OriginatorAgent,
            OriginatorExt,
            originatordn OriginatorNumber,
            destinationtype DestinationTypeID,
            case destinationtype
                when 1 then 'Agent'
                when 2 then 'Device'
                when 3 then 'Unknown'
                else 'Unknown'
            end DestinationType,
            DestinationID,
            DestinationAgent,
            DestinationExt,
            destinationdn DestinationNumber,
            case callresult
                when 1 then 'Voice'
                when 2 then 'Fax/Modem'
                when 3 then 'Answering Machine'
                when 4 then 'Invalid Number'
                when 5 then 'Do Not Call'
                when 6 then 'Wrong Number'
                when 7 then 'Customer Not Available'
                when 8 then 'Callback'
                when 9 then 'Agent Rejected'
                when 10 then 'Agent Closed'
                when 11 then 'Busy'
                when 12 then 'RNA'
                when 20 then 'Transfered'
                else 'Unkown'
            end CallResult,
            dbo.xfn_ConvertUTCToLocal(StartDateTime, 'AUS Eastern Standard Time') CallStartDateTime,
            dbo.xfn_ConvertUTCToLocal(EndDateTime, 'AUS Eastern Standard Time') CallEndDateTime,    
            StartDateTime CallStartDateTimeUTC,
            EndDateTime CallEndDateTimeUTC,
            origcallednumber GatewayNumber,
            callednumber DialedNumber,
            Transfer, 
            Redirect, 
            Conference,
            ConnectTime,
            RingTime,
            case
                when contacttype in (2,6,7,8,9) then isnull(nullif(talktime, 0), connecttime) --'Outgoing'
                else talktime
            end TalkTime, 
            HoldTime,
            WorkTime,
            WrapUpTime,
            case targettype
                when 0 then 'CSQ'
                when 1 then 'Agent'
                else 'Unknown'
            end TargetType,
            TargetID,
            case queuedisposition
                when 1 then 'Abandoned'
                when 2 then 'Handled'
                when 3 then 'Dequeued'
                when 4 then 'Handled by script'
                when 5 then 'Handled by other CSQ'
                when 0 then 'Transferred'
                else 'Unknown'
            end QueueDisposition,
            case 
                when queuedisposition in (2,4,5) and talktime > 0 then 1 
                when isnull(queuedisposition, 6) > 5 and contactdisposition = 2 and talktime > 0 then 1 
                else 0 
            end as QueueHandled,
            case 
                when queuedisposition = 1 then 1 
                when isnull(queuedisposition, 6) > 5 and contactdisposition = 1 then 1 
                else 0 
            end as QueueAbandoned,
            QueueTime,
            isnull(csqname, 'Unknown') CSQName,
            ServiceLevelPercentage,
            case 
                when queuedisposition in (2,4,5) and talktime > 0 then isnull(metservicelevel, 0)
                when isnull(queuedisposition, 6) > 5 and contactdisposition = 2 and talktime > 0 then isnull(metservicelevel, 0)
                else 0 
            end as MetServiceLevel,
            isnull(resourcename, 'Unknown') Agent,
            isnull(teamname, 'Unknown') Team,
            LoginID,
            SupervisorFlag,
            VarCSQName,
            VarEXT,
            VarClassification,
            VarIVROption,
            VarIVRReference,
            VarWrapUp,
            WrapUpData,
            AccountNumber,
            CallerEnteredDigits,
            BadCallTag,
            ApplicationID,
            ApplicationName,
            CampaignID,
            DialinglistID,
            origprotocolcallref,
            destprotocolcallref,
            getdate()
        from
            [db-au-stage]..cisco_ciscalls


    end try
        
    begin catch
        
        if @@trancount > 0
            rollback transaction
                
        exec syssp_genericerrorhandler 
            @SourceInfo = 'cisCalls data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
            
    end catch    

    if @@trancount > 0
        commit transaction

    if object_id('[db-au-stage]..cisco_ciscalls') is not null
        drop table [db-au-stage]..cisco_ciscalls

end

GO
