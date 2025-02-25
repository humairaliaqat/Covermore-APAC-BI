USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoOutboundCall]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL041_CiscoOutboundCall]  
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20150108
Prerequisite:   Requires CISCO Informix database.                
Description:    populates cisOutboundCallData table in [db-au-cmdwh]
Parameters:     
Change History:
                20150108 - LS - created
                20150326 - LS - include actual talk time
                20150623 - LS - collision on binary_checksum, session id 149000419918
                                this is a known limitation of binary_checksum, changing timestamp as first field as bandaid solution
                                binary_checksum need to be replaced with hasbytes
                20151102 - LS - bring in Cisco's team
                                
*************************************************************************************************************************************/

    set nocount on

    declare 
        @dataStartDate datetime,
        @dataEndDate datetime,
        @SQL varchar(max)
    
    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int
        
    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'CISCO ODS',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler 
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'
    
    select 
        @dataStartDate = dbo.xfn_ConvertLocalToUTC(@start, 'AUS Eastern Standard Time'),
        @dataEndDate = dateadd(d, 1, dbo.xfn_ConvertLocalToUTC(@end, 'AUS Eastern Standard Time'))

    --create table if not exists
    if object_id('[db-au-cmdwh].dbo.cisOutboundCallData') is null
    begin
    
        create table [db-au-cmdwh].dbo.cisOutboundCallData
        (
            [BIRowID] bigint not null identity(1,1),
            [SessionKey] nvarchar(50) not null,
            [SessionID] bigint not null,
            [AgentKey] nvarchar(50) not null,
            [CallStartDateTime] datetime not null,
            [CallEndDateTime] datetime not null,
            [CallDuration] int not null,
            [TalkTime] int not null,
            [OriginatorNumber] nvarchar(30) not null,
            [DestinationNumber] nvarchar(30) not null,
            [CalledNumber] nvarchar(30) not null,
            [OutboundCallType] varchar(10) not null,
            [EmployeeKey] int null,
            [OrganisationKey] int null,
            [Team] varchar(50),
            [Agent] varchar(50),
            [LoginID] varchar(50),
            [SupervisorFlag] bit,
            [CreateBatchID] int null,
            [UpdateBatchID] int null,
        ) 
        
        create clustered index idx_cisOutboundCallData_BIRowID on [db-au-cmdwh].dbo.cisOutboundCallData(BIRowID)
        create nonclustered index idx_cisOutboundCallData_SessionKey on [db-au-cmdwh].dbo.cisOutboundCallData(SessionKey)
        create nonclustered index idx_cisOutboundCallData_Agent on [db-au-cmdwh].dbo.cisOutboundCallData(AgentKey) include(CallStartDateTime,CallEndDateTime,CallDuration,TalkTime)
        create nonclustered index idx_cisOutboundCallData_CallTimes on [db-au-cmdwh].dbo.cisOutboundCallData(CallStartDateTime,CallEndDateTime) include(AgentKey,CallDuration,OutboundCallType,TalkTime)
        
    end    

    --build sql statement
    select @SQL = 
        '
        select
            ''AU-CM'' + 
            convert(nvarchar, isnull(a.ProfileID,0)) + 
            convert(
                varchar, 
                hashbytes(
                    ''MD5'', 
                    isnull(convert(nvarchar, convert(datetime, a.CallStartDateTime)), '''') + 
                    isnull(convert(nvarchar, a.ResourceID), '''') + 
                    isnull(convert(nvarchar, a.SessionID), '''') + 
                    isnull(convert(nvarchar, a.sessionseqnum), '''') + 
                    isnull(convert(nvarchar, a.nodeid), '''')
                ),
                1
            ) as SessionKey,
            isnull(a.SessionID,0) as SessionID,
            left(''AU-CM'' + convert(nvarchar,isnull(a.ProfileID,0)) + ''-'' + convert(nvarchar,isnull(a.ResourceID,0)),50) as AgentKey,
            isnull(dbo.xfn_ConvertUTCToLocal(a.CallStartDateTime,''AUS Eastern Standard Time''),''1900-01-01'') as CallStartDateTime,
            isnull(dbo.xfn_ConvertUTCToLocal(a.CallEndDateTime,''AUS Eastern Standard Time''),''1900-01-01'') as CallEndDateTime,
            datediff(second, a.CallStartDateTime, a.callEndDatetime) CallDuration,
            isnull(a.OriginatorNumber,'''') as OriginatorNumber,
            isnull(a.DestinationNumber,'''') as DestinationNumber,
            isnull(a.CalledNumber,'''') as CalledNumber,
            isnull(a.OutboundCallType,''Unknown'') OutboundCallType,
            isnull(a.TalkTime, 0) TalkTime,
            isnull(a.Team,'''') Team,
            isnull(a.Agent,'''') Agent,
            isnull(a.LoginID,'''') LoginID,
            isnull(a.SupervisorFlag, 0) SupervisorFlag
        from 
            openquery(
                CISCO,
                ''
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
                        when length(ccd.originatordn) > 0 then ''''Non IPCC''''
                        else ''''IPCC''''
                    end OutboundCallType,
                    acdr.TalkTime,
                    r.resourceloginid LoginID,
                    NVL(tea.teamname,''''Unknown'''') Team, 
                    NVL(r.resourcename,''''Unknown'''') Agent,
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
                                    s.managedteamid = tea.teamid
                            )
                        then 1
                        else 0
                    end SupervisorFlag
                FROM
	                contactcalldetail ccd
	                INNER JOIN resource r ON
		                r.resourceid = ccd.originatorid
                    LEFT OUTER JOIN Agentconnectiondetail acdr ON
                        ccd.sessionid = acdr.sessionid AND
                        ccd.sessionseqnum = acdr.sessionseqnum AND
                        ccd.profileid = acdr.profileid 
                    LEFT OUTER JOIN team tea ON 
                        r.assignedteamid = tea.teamid 
                WHERE
	                ccd.originatortype = 1 AND /*l_agenttype*/
	                ccd.contacttype <> 6 AND /*l_contacttypepreviewoutbound*/
	                ccd.contacttype <> 5 AND /*l_transferin*/
                    ccd.startdatetime >= ''''' + convert(varchar(20),@dataStartDate,120) + ''''' and 
                    ccd.startdatetime < ''''' + convert(varchar(20),@dataEndDate,120) + '''''
                ''
            ) a
        '


    if object_id('tempdb..#cisOutboundCallData') is not null 
        drop table #cisOutboundCallData
    
    create table #cisOutboundCallData
    (
        SessionKey nvarchar(50) not null,
        SessionID numeric(18, 0) null,
        AgentKey nvarchar(50) null,
        CallStartDateTime datetime null,
        CallEndDateTime datetime null,
        CallDuration int null,
        OriginatorNumber varchar(30) null,
        DestinationNumber varchar(30) null,
        CalledNumber varchar(30) null,
        OutboundCallType varchar(10) null,
        TalkTime int null,
        [Team] varchar(50),
        [Agent] varchar(50),
        [LoginID] varchar(50),
        [SupervisorFlag] bit
    )
    
    insert into #cisOutboundCallData
    execute(@SQL)
    
    alter table #cisOutboundCallData add EmployeeKey int null
    alter table #cisOutboundCallData add OrganisationKey int null
    
    update t
    set
        t.EmployeeKey = isnull(vt.EmployeeKey, -1),
        t.OrganisationKey = isnull(vt.OrganisationKey, -1)
    from
        #cisOutboundCallData t
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

    if object_id('tempdb..#tOutboundCallData') is not null 
        drop table #tOutboundCallData

    select 
        SessionKey,
        SessionID,
        AgentKey,
        CallStartDateTime,
        CallEndDateTime,
        CallDuration,
        sum(TalkTime) TalkTime,
        OriginatorNumber,
        DestinationNumber,
        CalledNumber,
        OutboundCallType,
        EmployeeKey,
        OrganisationKey,
        [Team],
        [Agent],
        [LoginID],
        [SupervisorFlag]
    into #tOutboundCallData
    from
        #cisOutboundCallData
    group by
        SessionKey,
        SessionID,
        AgentKey,
        CallStartDateTime,
        CallEndDateTime,
        CallDuration,
        OriginatorNumber,
        DestinationNumber,
        CalledNumber,
        OutboundCallType,
        EmployeeKey,
        OrganisationKey,
        [Team],
        [Agent],
        [LoginID],
        [SupervisorFlag]
        
    truncate table #cisOutboundCallData

    insert into #cisOutboundCallData
    (
        SessionKey,
        SessionID,
        AgentKey,
        CallStartDateTime,
        CallEndDateTime,
        CallDuration,
        TalkTime,
        OriginatorNumber,
        DestinationNumber,
        CalledNumber,
        OutboundCallType,
        EmployeeKey,
        OrganisationKey,
        [Team],
        [Agent],
        [LoginID],
        [SupervisorFlag]
    )
    select 
        SessionKey,
        SessionID,
        AgentKey,
        CallStartDateTime,
        CallEndDateTime,
        CallDuration,
        TalkTime,
        OriginatorNumber,
        DestinationNumber,
        CalledNumber,
        OutboundCallType,
        EmployeeKey,
        OrganisationKey,
        [Team],
        [Agent],
        [LoginID],
        [SupervisorFlag]
    from
        #tOutboundCallData

    select 
        @sourcecount = count(*)
    from
        #cisOutboundCallData

    begin transaction

    begin try
        
        merge into [db-au-cmdwh].dbo.cisOutboundCallData with(tablock) t
        using #cisOutboundCallData s on 
            s.SessionKey = t.SessionKey
            
        when matched then
        
            update
            set
                AgentKey = s.AgentKey,
                CallStartDateTime = s.CallStartDateTime,
                CallEndDateTime = s.CallEndDateTime,
                CallDuration = s.CallDuration,
                TalkTime = s.TalkTime,
                OriginatorNumber = s.OriginatorNumber,
                DestinationNumber = s.DestinationNumber,
                CalledNumber = s.CalledNumber,
                OutboundCallType = s.OutboundCallType,
                EmployeeKey = s.EmployeeKey,
                OrganisationKey = s.OrganisationKey,
                Team = s.Team,
                Agent = s.Agent,
                LoginID = s.LoginID,
                SupervisorFlag = s.SupervisorFlag,
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                SessionKey,
                SessionID,
                AgentKey,
                CallStartDateTime,
                CallEndDateTime,
                CallDuration,
                TalkTime,
                OriginatorNumber,
                DestinationNumber,
                CalledNumber,
                OutboundCallType,
                EmployeeKey,
                OrganisationKey,
                Team,
                Agent,
                LoginID,
                SupervisorFlag,
                CreateBatchID
            )
            values
            (
                s.SessionKey,
                s.SessionID,
                s.AgentKey,
                s.CallStartDateTime,
                s.CallEndDateTime,
                s.CallDuration,
                s.TalkTime,
                s.OriginatorNumber,
                s.DestinationNumber,
                s.CalledNumber,
                s.OutboundCallType,
                s.EmployeeKey,
                s.OrganisationKey,
                Team,
                Agent,
                LoginID,
                SupervisorFlag,
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
            @SourceInfo = 'cisOutboundCallData data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction
            
end

GO
