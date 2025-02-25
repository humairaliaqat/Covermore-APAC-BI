USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoRNA]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL041_CiscoRNA]  
    @RunMode varchar(30) = 'Realtime'
    
as
begin
/************************************************************************************************************************************
Author:         Philip Wong
Date:           20141013
Prerequisite:   Requires CISCO Informix database.                
Description:    populates cisRNA table in [db-au-cmdwh]
Parameters:     @RunMode:   Required. Value is Realtime or Not Realtime
                @DateRange: Required. Standard date range or _User Defined
                @StartDate: Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01
                @EndDate:   Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01
Change History:
                20141013 - PW - Procedure created
                20141014 - LS - Add batch columns
                                Change call start & end time to point to agentconnectiondetail instead of contactcalldetail
                20141020 - LS - move get running batch to non real time condition block 
                20141209 - LS - add agent connection detail start time (catch weird connection, e.g. session id 137000025176)
                20141218 - LS - add link to Verint team and employee
                20151102 - LS - bring in Cisco's team
                20160823 - LL - add application (proxy for trigger point, proxy for company)
                
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
                convert(nvarchar, 
                    binary_checksum(
                        isnull(a.ResourceID,0), 
                        isnull(a.SessionID,0), 
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
            isnull(dbo.xfn_ConvertUTCToLocal(a.CallStartDateTime,''AUS Eastern Standard Time''),''1900-01-01'') as CallEndDateTime,    
            isnull(a.OriginatorNumber,'''') as OriginatorNumber,
            isnull(a.DestinationNumber,'''') as DestinationNumber,
            isnull(a.CalledNumber,'''') as CalledNumber,
            isnull(a.OrigCalledNumber,'''') as OrigCalledNumber,
            isnull(a.RingNoAnswer,0) as RingNoAnswer,
            isnull(a.Team,'''') Team,
            isnull(a.Agent,'''') Agent,
            isnull(a.LoginID,'''') LoginID,
            isnull(a.SupervisorFlag, 0) SupervisorFlag,
            isnull(a.applicationid, 0) ApplicationID,
            isnull(a.applicationname, '''') ApplicationName
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
                    cqdr.targetid,
                    res.resourceid,
                    CASE cqdr.disposition WHEN 1 THEN ''''Abandoned''''
                    WHEN 2 THEN ''''Handled''''
                    WHEN 3 THEN ''''Dequeued''''
                    WHEN 4 THEN ''''Handled by script''''
                    WHEN 5 THEN ''''Handled by other CSQ''''
                    WHEN 0 THEN ''''Transferred''''
                    ELSE ''''Unknown''''
                    END AS Disposition,
                    acdr.startdatetime callStartDatetime, 
                    acdr.enddatetime callEndDatetime, 
                    csq.csqname,
                    csq.servicelevelpercentage,
                    ccdr.originatordn OriginatorNumber, 
                    ccdr.destinationdn DestinationNumber, 
                    ccdr.callednumber, 
                    ccdr.origcallednumber,
                    NVL(tea.teamname,''''Unknown'''') Team, 
                    NVL(res.resourcename,''''Unknown'''') Agent,
                    1 AS RingNoAnswer,
                    acdr.startdatetime agentCallStartDatetime,
                    res.resourceloginid LoginID,
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
                    ccdr.applicationname
                FROM 
                    Contactqueuedetail cqdr
                    INNER JOIN Contactcalldetail ccdr ON 
                        cqdr.sessionid = ccdr.sessionid AND 
                        cqdr.sessionseqnum = ccdr.sessionseqnum AND 
                        cqdr.profileid = ccdr.profileid AND 
                        cqdr.nodeid = ccdr.nodeid 
                    INNER JOIN Contactservicequeue csq ON 
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
                    cqdr.targettype = 0 and
                    acdr.ringtime >= 0 AND acdr.talktime = 0 and
                    ccdr.startdatetime >= ''''' + convert(varchar(20),@rptStartDate,120) + ''''' and 
                    ccdr.startdatetime < ''''' + convert(varchar(20),@rptEndDate,120) + '''''
                ''
            ) a' 


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
        if object_id('[db-au-cmdwh].dbo.cisRNA') is null
        begin
        
            create table [db-au-cmdwh].dbo.cisRNA
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
                [RingNoAnswer] [int] not null,
                [EmployeeKey] int null,
                [OrganisationKey] int null,
                [CreateBatchID] int null,
                [UpdateBatchID] int null,
                [Team] varchar(50),
                [Agent] varchar(50),
                [LoginID] varchar(50),
                [SupervisorFlag] bit,
                [ApplicationID] int,
                [ApplicationName] varchar(30)
            ) 
            
            create clustered index idx_cisRNA_BIRowID on [db-au-cmdwh].dbo.cisRNA(BIRowID)
            create nonclustered index idx_cisRNA_SessionKey on [db-au-cmdwh].dbo.cisRNA(SessionKey)
            create nonclustered index idx_cisRNA_SessionID on [db-au-cmdwh].dbo.cisRNA(SessionID) include(CSQKey,CallStartDateTime,CallEndDateTime)
            create nonclustered index idx_cisRNA_Agent on [db-au-cmdwh].dbo.cisRNA(AgentKey) include(CallStartDateTime,CallEndDateTime,RingNoAnswer)
            create nonclustered index idx_cisRNA_CSQ on [db-au-cmdwh].dbo.cisRNA(CSQKey) include(AgentKey,CallStartDateTime,CallEndDateTime,RingNoAnswer)
            create nonclustered index idx_cisRNA_CallTimes on [db-au-cmdwh].dbo.cisRNA(CallStartDateTime,CallEndDateTime) include(AgentKey,RingNoAnswer,ApplicationID,ApplicationName)
            
        end 
        

        if object_id('tempdb..#cisRNA') is not null 
            drop table #cisRNA
        
        create table #cisRNA
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
	        RingNoAnswer int null,
            [Team] varchar(50),
            [Agent] varchar(50),
            [LoginID] varchar(50),
            [SupervisorFlag] bit,
            [ApplicationID] int,
            [ApplicationName] varchar(30)
        )
        
        insert into #cisRNA
        execute(@SQL)

        alter table #cisRNA add EmployeeKey int null
        alter table #cisRNA add OrganisationKey int null

        update t
        set
            t.EmployeeKey = isnull(vt.EmployeeKey, -1),
            t.OrganisationKey = isnull(vt.OrganisationKey, -1)
        from
            #cisRNA t
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
            #cisRNA

        begin transaction

        begin try
            
            merge into [db-au-cmdwh].dbo.cisRNA with(tablock) t
            using #cisRNA s on 
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
                    RingNoAnswer = s.RingNoAnswer,
                    EmployeeKey = s.EmployeeKey,
                    OrganisationKey = s.OrganisationKey,
                    Team = s.Team,
                    Agent = s.Agent,
                    LoginID = s.LoginID,
                    SupervisorFlag = s.SupervisorFlag,
                    ApplicationID = s.ApplicationID,
                    ApplicationName = s.ApplicationName,
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
                    RingNoAnswer,
                    EmployeeKey,
                    OrganisationKey,
                    Team,
                    Agent,
                    LoginID,
                    SupervisorFlag,
                    ApplicationID,
                    ApplicationName,
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
                    s.RingNoAnswer,
                    s.EmployeeKey,
                    s.OrganisationKey,
                    s.Team,
                    s.Agent,
                    s.LoginID,
                    s.SupervisorFlag,
                    s.ApplicationID,
                    s.ApplicationName,
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
                @SourceInfo = 'cisRNA data refresh failed',
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
