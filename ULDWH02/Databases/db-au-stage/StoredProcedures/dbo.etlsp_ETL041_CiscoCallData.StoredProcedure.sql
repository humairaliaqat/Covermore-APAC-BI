USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoCallData]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL041_CiscoCallData]  
    @RunMode varchar(30) = 'Realtime'
    
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131115
Prerequisite:   Requires CISCO Informix database.                
Description:    populates cisCallData table in [db-au-cmdwh]
Parameters:     @RunMode:   Required. Value is Realtime or Not Realtime
                @DateRange: Required. Standard date range or _User Defined
                @StartDate: Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01
                @EndDate:   Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01
Change History:
                20140827 - LT - Procedure created
                20140911 - LS - refactoring
                                add batch
                                index
                20140912 - LS - Session ID is not unique, adding hash for primary key
                20140915 - LS - include queue index in SessionKey to handle transfer between agents
                20140919 - LS - include target id in SessionKey to handle abandoned transfer between queue
                20141002 - LS - add agent in SessionKey
                20141020 - LS - move get running batch to non real time condition block 
                20141209 - LS - add agent connection detail start time (catch weird connection, e.g. session id 137000025176)
                20141218 - LS - add link to Verint team and employee
                20150109 - LS - bug fix, copy paste error on callEndDatetime
                20150122 - LS - remove this line (why is it there? it filters out transferred/abandoned calls):
                                AND NOT (cqdr.disposition = 1 OR (cqdr.disposition = 2 AND acdr.talktime = 0))
                20150804 - LS - collision on binary_checksum
                20151027 - LS - bring in Cisco's team
                20160609 - LS - bug fix, start and end time should be from agentconnectiondetail instead of contactcalldetail (total time) when available
                                unfortunately this started from begining and means lost of data (cisco purges data)
                                
                                sigh, opened a can of worm
                                if a call was transferred to non queue (e.g. CS to IT, CS to HR, etc) it's not included
                                fixing this
                20160624 - LL - !&@%^!&@^$!@
                20160714 - LL - look at etlsp_ETL041_CiscoCalls, eventualy this will be replaced
                                too many missing information in CiscoCallData, CiscoOutboundCall and CiscoRNA
                20160823 - LL - add application (proxy for trigger point, proxy for company)
                20181217 - LL - REQ-803, add ContactType
                
*************************************************************************************************************************************/

--uncomment to debug
/*
declare @RunMode varchar(30)
set 
    @RunMode = 'Realtime'
*/

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime
    declare @SQL varchar(8000)
    
    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int
        
    declare @mergeoutput table (MergeAction varchar(20))

    if @RunMode = 'Realtime'    --get today's datetime in UTC
        select 
            @rptStartDate = dbo.xfn_ConvertLocalToUTC(convert(date, getdate()), 'AUS Eastern Standard Time'),
            @rptEndDate = dbo.xfn_ConvertLocalToUTC(getdate(), 'AUS Eastern Standard Time')
            
    else
    begin                       --get date range and convert to UTC time, add 1 day to @rptEndDate
    
        exec syssp_getrunningbatch
            @SubjectArea = 'CISCO ODS',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out
    
        select 
            @rptStartDate = dbo.xfn_ConvertLocalToUTC(@start, 'AUS Eastern Standard Time'),
            @rptEndDate = dateadd(d, 1, dbo.xfn_ConvertLocalToUTC(@end, 'AUS Eastern Standard Time'))
                   
    end    


    --build sql statement
    select @SQL = 
        '
        select
            ''AU-CM'' + 
                convert(nvarchar, isnull(a.ProfileID,0)) + 
                convert(nvarchar, isnull(a.SessionID,0)) +
                convert(nvarchar, 
                    binary_checksum(
                        isnull(a.ResourceID,0), 
                        isnull(a.sessionseqnum,0), 
                        isnull(a.nodeid,0), 
                        isnull(a.qindex,0), 
                        isnull(a.targetid,0),
                        isnull(convert(datetime, a.agentCallStartDatetime),0)
                    )
                ) as SessionKey,
            isnull(a.SessionID,0) as SessionID,
            left(''AU-CM'' + convert(nvarchar,isnull(a.ProfileID,0)) + ''-'' + convert(nvarchar,isnull(a.ResourceID,0)),50) as AgentKey,
            left(''AU-CM'' + convert(nvarchar,isnull(a.ProfileID,0)) + ''-'' + convert(nvarchar,isnull(a.TargetID,0)),50) as CSQKey,
            isnull(a.Disposition,'''') as Disposition,
            isnull(dbo.xfn_ConvertUTCToLocal(a.CallStartDateTime,''AUS Eastern Standard Time''),''1900-01-01'') as CallStartDateTime,
            isnull(dbo.xfn_ConvertUTCToLocal(a.callEndDatetime,''AUS Eastern Standard Time''),''1900-01-01'') as CallEndDateTime,    
            isnull(a.OriginatorNumber,'''') as OriginatorNumber,
            isnull(a.DestinationNumber,'''') as DestinationNumber,
            isnull(a.CalledNumber,'''') as CalledNumber,
            isnull(a.OrigCalledNumber,'''') as OrigCalledNumber,
            isnull(a.CallsPresented,0) as CallsPresented,
            isnull(a.CallsHandled,0) as CallsHandled,
            isnull(a.CallsAbandoned,0) as CallsAbandoned,
            isnull(a.RingTime,0) as RingTime,
            isnull(a.TalkTime,0) as TalkTime,
            isnull(a.HoldTime,0) as HoldTime,
            isnull(a.WorkTime,0) as WorkTime,
            isnull(a.WrapUpTime,0) as WrapUpTime,
            isnull(a.QueueTime,0) as QueueTime,
            isnull(a.MetServiceLevel,0) MetServiceLevel,
            isnull(a.[Transfer],0) as [Transfer],
            isnull(a.Redirect,0) as Redirect,
            isnull(a.Conference,0) as Conference,
            isnull(a.Team,'''') Team,
            isnull(a.Agent,'''') Agent,
            isnull(a.LoginID,'''') LoginID,
            isnull(a.SupervisorFlag, 0) SupervisorFlag,
            isnull(a.applicationid, 0) ApplicationID,
            isnull(a.applicationname, '''') ApplicationName,
            a.contacttype ContactType 
        from 
            openquery(
                CISCO,
                ''
                SELECT    
                    cqdr.sessionid,
                    cqdr.sessionseqnum,
                    cqdr.nodeid,
                    cqdr.profileid,
                    cqdr.qindex,
                    nvl(cqdr.targetid, 0) targetid,
                    res.resourceid,
                    CASE cqdr.disposition 
                        WHEN 1 THEN ''''Abandoned''''
                        WHEN 2 THEN ''''Handled''''
                        WHEN 3 THEN ''''Dequeued''''
                        WHEN 4 THEN ''''Handled by script''''
                        WHEN 5 THEN ''''Handled by other CSQ''''
                        WHEN 0 THEN ''''Transferred''''
                        ELSE ''''Unknown''''
                    END AS Disposition,
                    nvl(acdr.startdatetime, ccdr.startdatetime) callStartDatetime, 
                    nvl(acdr.enddatetime, ccdr.enddatetime) callEndDatetime, 
                    nvl(csq.csqname, ''''Unknown'''') csqname,
                    nvl(csq.servicelevelpercentage, 0) servicelevelpercentage,
                    ccdr.originatordn OriginatorNumber, 
                    ccdr.destinationdn DestinationNumber, 
                    ccdr.callednumber, 
                    ccdr.origcallednumber,
                    NVL(tea.teamname,''''Unknown'''') Team, 
                    NVL(res.resourcename,''''Unknown'''') Agent,
                    res.resourceloginid LoginID,
                    1 AS CallsPresented,
                    CASE 
                        WHEN cqdr.disposition = 2 AND acdr.talktime > 0 THEN 1 
                        ELSE 0 
                    END AS CallsHandled,
                    CASE 
                        WHEN cqdr.disposition = 1 THEN 1 
                        ELSE 0 
                    END AS CallsAbandoned,
                    NVL(acdr.ringtime,0) RingTime, 
                    NVL(acdr.talktime, 0) TalkTime, 
                    NVL(acdr.holdtime, 0) HoldTime,
                    NVL(acdr.worktime, 0) WorkTime,
                    NVL(csq.wrapuptime, 0) WrapUpTime,
                    NVL(cqdr.queuetime, 0) QueueTime,
                    cqdr.metservicelevel,
                    ccdr.transfer, 
                    ccdr.redirect, 
                    ccdr.conference,
                    acdr.startdatetime agentCallStartDatetime,
                    case
                        when exists 
                            (
                                select
                                    1
                                from
                                    supervisor s
                                where
                                    s.active and
                                    s.resourceloginid = res.resourceloginid and
                                    s.managedteamid = tea.teamid
                            )
                        then 1
                        else 0
                    end SupervisorFlag,
                    ccdr.applicationid,
                    ccdr.applicationname,
                    ccdr.contacttype
                FROM 
                    Contactqueuedetail cqdr
                    INNER JOIN Contactcalldetail ccdr ON
                        cqdr.sessionid = ccdr.sessionid AND
                        cqdr.sessionseqnum = ccdr.sessionseqnum AND
                        cqdr.profileid = ccdr.profileid AND
                        cqdr.nodeid = ccdr.nodeid
                    LEFT JOIN Contactservicequeue csq ON
                        cqdr.targetid = csq.recordid AND
                        cqdr.profileid = csq.profileid
                    LEFT OUTER JOIN Agentconnectiondetail acdr ON
                        cqdr.sessionid = acdr.sessionid AND
                        cqdr.sessionseqnum = acdr.sessionseqnum AND
                        cqdr.profileid = acdr.profileid AND
                        cqdr.nodeid = acdr.nodeid AND
                        cqdr.qindex = acdr.qindex
                    LEFT OUTER JOIN resource res ON
                        acdr.resourceid = res.resourceid
                    LEFT OUTER JOIN team tea ON
                        res.assignedteamid = tea.teamid
                WHERE 
                    ccdr.startdatetime >= ''''' + convert(varchar(20),@rptStartDate,120) + ''''' and 
                    ccdr.startdatetime < ''''' + convert(varchar(20),@rptEndDate,120) + '''''
                ''
            ) a
            ' 


    if @RunMode = 'Realtime'
    begin
    
        execute(@SQL)
        
    end
    else
    begin

        select
            @name = object_name(@@procid)
        
        exec syssp_genericerrorhandler 
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Running'
    
        --create table if not exists
        if object_id('[db-au-cmdwh].dbo.cisCallData') is null
        begin
        
            create table [db-au-cmdwh].dbo.cisCallData
            (
                [BIRowID] bigint not null identity(1,1),
                [SessionKey] nvarchar(50) not null,
                [SessionID] [numeric](18, 0) not null,
                [AgentKey] nvarchar(50) not null,
                [CSQKey] nvarchar(50) not null,
                [Disposition] [char](20) not null,
                [CallStartDateTime] [datetime2](7) not null,
                [CallEndDateTime] [datetime2](7) not null,
                [OriginatorNumber] [nvarchar](30) not null,
                [DestinationNumber] [nvarchar](30) not null,
                [CalledNumber] [nvarchar](30) not null,
                [OrigCalledNumber] [nvarchar](30) not null,
                [CallsPresented] [int] not null,
                [CallsHandled] [int] not null,
                [CallsAbandoned] [int] not null,
                [RingTime] [int] not null,
                [TalkTime] [int] not null,
                [HoldTime] [int] not null,
                [WorkTime] [int] not null,
                [WrapUpTime] [int] not null,
                [QueueTime] [int] not null,
                [MetServiceLevel] [bit] not null,
                [Transfer] [bit] not null,
                [Redirect] [bit] not null,
                [Conference] [bit] not null,
                [EmployeeKey] int null,
                [OrganisationKey] int null,
                [CreateBatchID] int null,
                [UpdateBatchID] int null,
                [Team] varchar(50),
                [Agent] varchar(50),
                [LoginID] varchar(50),
                [SupervisorFlag] bit,
                [ApplicationID] int,
                [ApplicationName] varchar(30),
                [ContactType] int
            ) 
            
            create clustered index idx_cisCallData_BIRowID on [db-au-cmdwh].dbo.cisCallData(BIRowID)
            create nonclustered index idx_cisCallData_SessionKey on [db-au-cmdwh].dbo.cisCallData(SessionKey)
            create nonclustered index idx_cisCallData_SessionID on [db-au-cmdwh].dbo.cisCallData(SessionID) include(CSQKey,CallStartDateTime,CallEndDateTime)
            create nonclustered index idx_cisCallData_Agent on [db-au-cmdwh].dbo.cisCallData(AgentKey) include(CallStartDateTime,CallEndDateTime,CallsPresented,CallsHandled,CallsAbandoned,RingTime,TalkTime,HoldTime,WorkTime,WrapUpTime,QueueTime)
            create nonclustered index idx_cisCallData_CSQ on [db-au-cmdwh].dbo.cisCallData(CSQKey) include(AgentKey,CallStartDateTime,CallEndDateTime,CallsPresented,CallsHandled,CallsAbandoned,RingTime,TalkTime,HoldTime,WorkTime,WrapUpTime,QueueTime)
            create nonclustered index idx_cisCallData_CallTimes on [db-au-cmdwh].dbo.cisCallData(CallStartDateTime,CallEndDateTime) include(Transfer,LoginID,OriginatorNumber,SessionID,SessionKey,AgentKey,CallsPresented,CallsHandled,CallsAbandoned,RingTime,TalkTime,HoldTime,WorkTime,WrapUpTime,QueueTime,ApplicationID,ApplicationName)
            create nonclustered index idx_cisCallData_OriginatorNumber on [db-au-cmdwh].dbo.cisCallData(OriginatorNumber,CallStartDateTime desc) include(CallEndDateTime,LoginID,SessionID,SessionKey,AgentKey,CallsPresented,CallsHandled,CallsAbandoned,RingTime,TalkTime,HoldTime,WorkTime,WrapUpTime,QueueTime)
            
        end    

        if object_id('tempdb..#cisCallData') is not null 
            drop table #cisCallData
        
        create table #cisCallData
        (
            SessionKey nvarchar(50) not null,
	        SessionID numeric(18, 0) null,
	        AgentKey nvarchar(50) null,
	        CSQKey nvarchar(50) null,
	        Disposition char(20) null,
	        CallStartDateTime datetime null,
	        CallEndDateTime datetime null,
	        OriginatorNumber varchar(30) null,
	        DestinationNumber varchar(30) null,
	        CalledNumber varchar(30) null,
	        OrigCalledNumber varchar(30) null,
	        CallsPresented int null,
	        CallsHandled int null,
	        CallsAbandoned int null,
	        RingTime int null,
	        TalkTime int null,
	        HoldTime int null,
	        WorkTime int null,
	        WrapUpTime int null,
	        QueueTime int null,
	        MetServiceLevel bit null,
	        Transfer bit null,
	        Redirect bit null,
	        Conference bit null,
            [Team] varchar(50),
            [Agent] varchar(50),
            [LoginID] varchar(50),
            [SupervisorFlag] bit,
            [ApplicationID] int,
            [ApplicationName] varchar(30),
            [ContactType] int
        )
        
        insert into #cisCallData
        execute(@SQL)

        --handle non queue
        set @SQL =
            '
            select
                ''AU-CM'' + 
                    convert(nvarchar, isnull(a.ProfileID,0)) + 
                    convert(nvarchar, isnull(a.SessionID,0)) +
                    convert(nvarchar, 
                        binary_checksum(
                            isnull(a.ResourceID,0), 
                            isnull(a.sessionseqnum,0), 
                            isnull(a.nodeid,0), 
                            isnull(a.qindex,0), 
                            isnull(a.targetid,0),
                            isnull(convert(datetime, a.agentCallStartDatetime),0)
                        )
                    ) as SessionKey,
                isnull(a.SessionID,0) as SessionID,
                left(''AU-CM'' + convert(nvarchar,isnull(a.ProfileID,0)) + ''-'' + convert(nvarchar,isnull(a.ResourceID,0)),50) as AgentKey,
                left(''AU-CM'' + convert(nvarchar,isnull(a.ProfileID,0)) + ''-'' + convert(nvarchar,isnull(a.TargetID,0)),50) as CSQKey,
                isnull(a.Disposition,'''') as Disposition,
                isnull(dbo.xfn_ConvertUTCToLocal(a.CallStartDateTime,''AUS Eastern Standard Time''),''1900-01-01'') as CallStartDateTime,
                isnull(dbo.xfn_ConvertUTCToLocal(a.callEndDatetime,''AUS Eastern Standard Time''),''1900-01-01'') as CallEndDateTime,    
                isnull(a.OriginatorNumber,'''') as OriginatorNumber,
                isnull(a.DestinationNumber,'''') as DestinationNumber,
                isnull(a.CalledNumber,'''') as CalledNumber,
                isnull(a.OrigCalledNumber,'''') as OrigCalledNumber,
                isnull(a.CallsPresented,0) as CallsPresented,
                isnull(a.CallsHandled,0) as CallsHandled,
                isnull(a.CallsAbandoned,0) as CallsAbandoned,
                isnull(a.RingTime,0) as RingTime,
                isnull(a.TalkTime,0) as TalkTime,
                isnull(a.HoldTime,0) as HoldTime,
                isnull(a.WorkTime,0) as WorkTime,
                isnull(a.WrapUpTime,0) as WrapUpTime,
                isnull(a.QueueTime,0) as QueueTime,
                isnull(a.MetServiceLevel,0) MetServiceLevel,
                isnull(a.[Transfer],0) as [Transfer],
                isnull(a.Redirect,0) as Redirect,
                isnull(a.Conference,0) as Conference,
                isnull(a.Team,'''') Team,
                isnull(a.Agent,'''') Agent,
                isnull(a.LoginID,'''') LoginID,
                isnull(a.SupervisorFlag, 0) SupervisorFlag,
                isnull(a.applicationid, 0) ApplicationID,
                isnull(a.applicationname, '''') ApplicationName,
                a.contacttype ContactType
            from 
                openquery(
                    CISCO,
                    ''
                    SELECT    
                        acdr.sessionid,
                        acdr.sessionseqnum,
                        acdr.nodeid,
                        acdr.profileid,
                        acdr.qindex,
                        nvl(cqdr.targetid, 0) targetid,
                        res.resourceid,
                        CASE cqdr.disposition 
                            WHEN 1 THEN ''''Abandoned''''
                            WHEN 2 THEN ''''Handled''''
                            WHEN 3 THEN ''''Dequeued''''
                            WHEN 4 THEN ''''Handled by script''''
                            WHEN 5 THEN ''''Handled by other CSQ''''
                            WHEN 0 THEN ''''Transferred''''
                            ELSE ''''Unknown''''
                        END AS Disposition,
                        nvl(acdr.startdatetime, ccdr.startdatetime) callStartDatetime, 
                        nvl(acdr.enddatetime, ccdr.enddatetime) callEndDatetime, 
                        nvl(csq.csqname, ''''Unknown'''') csqname,
                        nvl(csq.servicelevelpercentage, 0) servicelevelpercentage,
                        ccdr.originatordn OriginatorNumber, 
                        ccdr.destinationdn DestinationNumber, 
                        ccdr.callednumber, 
                        ccdr.origcallednumber,
                        NVL(tea.teamname,''''Unknown'''') Team, 
                        NVL(res.resourcename,''''Unknown'''') Agent,
                        res.resourceloginid LoginID,
                        1 AS CallsPresented,
                        CASE 
                            WHEN cqdr.disposition = 2 AND acdr.talktime > 0 THEN 1 
                            ELSE 0 
                        END AS CallsHandled,
                        CASE 
                            WHEN cqdr.disposition = 1 THEN 1 
                            ELSE 0 
                        END AS CallsAbandoned,
                        NVL(acdr.ringtime,0) RingTime, 
                        NVL(acdr.talktime, 0) TalkTime, 
                        NVL(acdr.holdtime, 0) HoldTime,
                        NVL(acdr.worktime, 0) WorkTime,
                        NVL(csq.wrapuptime, 0) WrapUpTime,
                        NVL(cqdr.queuetime, 0) QueueTime,
                        cqdr.metservicelevel,
                        ccdr.transfer, 
                        ccdr.redirect, 
                        ccdr.conference,
                        acdr.startdatetime agentCallStartDatetime,
                        case
                            when exists 
                                (
                                    select
                                        1
                                    from
                                        supervisor s
                                    where
                                        s.active and
                                        s.resourceloginid = res.resourceloginid and
                                        s.managedteamid = tea.teamid
                                )
                            then 1
                            else 0
                        end SupervisorFlag,
                        ccdr.applicationid,
                        ccdr.applicationname,
                        ccdr.contacttype
                    FROM 
                        Agentconnectiondetail acdr
                        INNER JOIN Contactcalldetail ccdr ON 
                            acdr.sessionid = ccdr.sessionid AND 
                            acdr.sessionseqnum = ccdr.sessionseqnum AND 
                            acdr.profileid = ccdr.profileid AND 
                            acdr.nodeid = ccdr.nodeid 
                        LEFT JOIN Contactqueuedetail cqdr ON
                            cqdr.sessionid = acdr.sessionid AND 
                            cqdr.sessionseqnum = acdr.sessionseqnum AND 
                            cqdr.profileid = acdr.profileid AND 
                            cqdr.nodeid = acdr.nodeid AND
                            cqdr.qindex = acdr.qindex
                        LEFT JOIN Contactservicequeue csq ON 
                            cqdr.targetid = csq.recordid AND 
                            cqdr.profileid = csq.profileid
                        LEFT JOIN resource res ON 
                            acdr.resourceid = res.resourceid 
                        LEFT JOIN team tea ON 
                            res.assignedteamid = tea.teamid 
                    WHERE 
                        ccdr.startdatetime >= ''''' + convert(varchar(20),@rptStartDate,120) + ''''' and 
                        ccdr.startdatetime < ''''' + convert(varchar(20),@rptEndDate,120) + '''''
                    ''
                ) a
            '

        insert into #cisCallData
        execute(@SQL)

        select distinct *
        into #temp
        from
            #cisCallData

        truncate table #cisCallData

        insert into #cisCallData
        select *
        from
            #temp
        
        alter table #cisCallData add EmployeeKey int null
        alter table #cisCallData add OrganisationKey int null
        
        update t
        set
            t.EmployeeKey = isnull(vt.EmployeeKey, -1),
            t.OrganisationKey = isnull(vt.OrganisationKey, -1)
        from
            #cisCallData t
            outer apply
            (
                select top 1
                    vt.EmployeeKey,
                    vt.OrganisationKey
                from
                    [db-au-cmdwh]..cisAgent a
                    inner join [db-au-cmdwh]..verTeam vt on
                        vt.UserName = a.AgentLogin
                where
                    a.AgentKey = t.AgentKey and
                    vt.EndDate >= convert(date, t.CallStartDateTime)
                order by
                    vt.EndDate desc
            ) vt

        select 
            @sourcecount = count(*)
        from
            #cisCallData

        begin transaction

        begin try
            
            merge into [db-au-cmdwh].dbo.cisCallData with(tablock) t
            using #cisCallData s on 
                s.SessionKey = t.SessionKey
                
            when matched then
            
                update
                set
                    AgentKey = s.AgentKey,
                    CSQKey = s.CSQKey,
                    Disposition = s.Disposition,
                    CallStartDateTime = s.CallStartDateTime,
                    CallEndDateTime = s.CallEndDateTime,
                    OriginatorNumber = s.OriginatorNumber,
                    DestinationNumber = s.DestinationNumber,
                    CalledNumber = s.CalledNumber,
                    OrigCalledNumber = s.OrigCalledNumber,
                    CallsPresented = s.CallsPresented,
                    CallsHandled = s.CallsHandled,
                    CallsAbandoned = s.CallsAbandoned,
                    RingTime = s.RingTime,
                    TalkTime = s.TalkTime,
                    HoldTime = s.HoldTime,
                    WorkTime = s.WorkTime,
                    WrapUpTime = s.WrapUpTime,
                    QueueTime = s.QueueTime,
                    MetServiceLevel = s.MetServiceLevel,
                    [Transfer] = s.[Transfer],
                    Redirect = s.Redirect,
                    Conference = s.Conference,
                    EmployeeKey = s.EmployeeKey,
                    OrganisationKey = s.OrganisationKey,
                    Team = s.Team,
                    Agent = s.Agent,
                    LoginID = s.LoginID,
                    SupervisorFlag = s.SupervisorFlag,
                    ApplicationID = s.ApplicationID,
                    ApplicationName = s.ApplicationName,
                    ContactType = s.ContactType,
                    UpdateBatchID = @batchid
                    
            when not matched by target then
                insert 
                (
                    SessionKey,
                    SessionID,
                    AgentKey,
                    CSQKey,
                    Disposition,
                    CallStartDateTime,
                    CallEndDateTime,
                    OriginatorNumber,
                    DestinationNumber,
                    CalledNumber,
                    OrigCalledNumber,
                    CallsPresented,
                    CallsHandled,
                    CallsAbandoned,
                    RingTime,
                    TalkTime,
                    HoldTime,
                    WorkTime,
                    WrapUpTime,
                    QueueTime,
                    MetServiceLevel,
                    [Transfer],
                    Redirect,
                    Conference,
                    EmployeeKey,
                    OrganisationKey,
                    Team,
                    Agent,
                    LoginID,
                    SupervisorFlag,
                    ApplicationID,
                    ApplicationName,
                    ContactType,
                    CreateBatchID
                )
                values
                (
                    s.SessionKey,
                    s.SessionID,
                    s.AgentKey,
                    s.CSQKey,
                    s.Disposition,
                    s.CallStartDateTime,
                    s.CallEndDateTime,
                    s.OriginatorNumber,
                    s.DestinationNumber,
                    s.CalledNumber,
                    s.OrigCalledNumber,
                    s.CallsPresented,
                    s.CallsHandled,
                    s.CallsAbandoned,
                    s.RingTime,
                    s.TalkTime,
                    s.HoldTime,
                    s.WorkTime,
                    s.WrapUpTime,
                    s.QueueTime,
                    s.MetServiceLevel,
                    s.Transfer,
                    s.Redirect,
                    s.Conference,
                    s.EmployeeKey,
                    s.OrganisationKey,
                    s.Team,
                    s.Agent,
                    s.LoginID,
                    s.SupervisorFlag,
                    s.ApplicationID,
                    s.ApplicationName,
                    s.ContactType,
                    @batchid
                )

            output $action into @mergeoutput
            ;

            select 
                @insertcount = 
                    sum(
                        case
                            when MergeAction = 'insert' then 1
                            else 0
                        end
                    ),
                @updatecount = 
                    sum(
                        case
                            when MergeAction = 'update' then 1
                            else 0
                        end
                    )
            from
                @mergeoutput

            exec syssp_genericerrorhandler 
                @LogToTable = 1,
                @ErrorCode = '0',
                @BatchID = @batchid,
                @PackageID = @name,
                @LogStatus = 'Finished',
                @LogSourceCount = @sourcecount,
                @LogInsertCount = @insertcount,
                @LogUpdateCount = @updatecount

        end try
        
        begin catch
        
            if @@trancount > 0
                rollback transaction
                
            exec syssp_genericerrorhandler 
                @SourceInfo = 'cisCallData data refresh failed',
                @LogToTable = 1,
                @ErrorCode = '-100',
                @BatchID = @batchid,
                @PackageID = @name
            
        end catch    

        if @@trancount > 0
            commit transaction
            
    end

end
GO
