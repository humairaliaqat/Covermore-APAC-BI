USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoAgentState]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL041_CiscoAgentState]  
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20150121
Prerequisite:   Requires CISCO Informix database.                
Description:    populates cisAgentState table in [db-au-cmdwh]
Parameters:     
Change History:
                20150121 - LS - created
				20190905 - RS - Added group by in the dynamic query to pick just one event in a fraction of second to fix merge statement failure issue.
								Though the information is uptill third fraction of a second F3, but it needs to be rounded till second fraction of second 
								due to some internal conversion issue while loading the data from informix to sql server using dynamic sql.
								e.g. eventdatetime column values of 2019-09-04 05:13:17.812 and 2019-09-04 05:13:17.813 from the source were both being
								stored as 2019-09-04 05:13:17.813 in the sql server and resulting in merge failure because of duplicate rows.
								This is resolved by applying a groupup and keeping fractional part of second till second place after decimal using F2 format.
                
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
    if object_id('[db-au-cmdwh].dbo.cisAgentState') is null
    begin
    
        create table [db-au-cmdwh].dbo.cisAgentState
        (
            [BIRowID] bigint not null identity(1,1),
            [AgentKey] nvarchar(50) not null,
            [EventDateTime] datetime not null,
            [EventType] int null,
            [EventDescription] varchar(30) null,
            [EventDuration] int not null,
            [ReasonCode] int null,
            [EmployeeKey] int null,
            [OrganisationKey] int null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        ) 
        
        create clustered index idx_cisAgentState_BIRowID on [db-au-cmdwh].dbo.cisAgentState(BIRowID)
        create nonclustered index idx_cisAgentState_Agent on [db-au-cmdwh].dbo.cisAgentState(AgentKey) include(EventDateTime,EventDescription,EventDuration)
        create nonclustered index idx_cisAgentState_EventTimes on [db-au-cmdwh].dbo.cisAgentState(EventDateTime,AgentKey,EventType) include(EventDescription,EventDuration)
        
    end    

    --build sql statement
    select @SQL = 
        '
        select *
        from 
            openquery(
                CISCO,
                ''
                 select agentID,
			   ProfileID,
			   EventDateTime,
			   EventType,
					max(ReasonCode) as ReasonCode
			    from (select 
                    AgentID,
                    ProfileID,
					TO_CHAR(EventDateTime, ''''%Y-%m-%d %H:%M:%S.%F2'''') as EventDateTime,
                    EventType,
					ReasonCode
                from
	                agentstatedetail
                where
	                EventDateTime >= ''''' + convert(varchar(20),@dataStartDate,120) + ''''' and 
                    EventDateTime < ''''' + convert(varchar(20),@dataEndDate,120) + '''''
				)group by 
				    AgentID,
                    ProfileID,
					EventDateTime,
					EventType
                ''
            ) a
        '


    if object_id('tempdb..#cisAgentState') is not null 
        drop table #cisAgentState
    
    create table #cisAgentState
    (
        AgentID int null,
        ProfileID int null,
        EventDateTime datetime null,
        EventType int null,
        ReasonCode int null
    )
    
    insert into #cisAgentState
    execute(@SQL)

    --execute
    --(
    --    '
    --    select *
    --    from 
    --        openquery(
    --            CISCO,
    --            ''
    --            select 
    --                AgentID,
    --                ProfileID,
    --                EventDateTime,
    --                EventType,
    --                ReasonCode
    --            from
	   --             agentstatedetail
    --            ''
    --        ) a
    --    '
    --)
    
    alter table #cisAgentState add AgentKey nvarchar(50)
    alter table #cisAgentState add EmployeeKey int null
    alter table #cisAgentState add OrganisationKey int null
    
    update #cisAgentState
    set
        AgentKey = left('AU-CM' + convert(nvarchar, isnull(ProfileID, 0)) + '-' + convert(nvarchar, isnull(AgentID, 0)), 50)
    
    update t
    set
        t.EmployeeKey = isnull(vt.EmployeeKey, -1),
        t.OrganisationKey = isnull(vt.OrganisationKey, -1)
    from
        #cisAgentState t
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
                vt.EndDate >= convert(date, t.EventDateTime)
            order by
                vt.EndDate desc
        ) vt

    create nonclustered index idx on #cisAgentState (AgentKey,EventDateTime)

    if object_id('tempdb..#cisAgentStateProper') is not null 
        drop table #cisAgentStateProper

    select distinct
        AgentKey,
        dbo.xfn_ConvertUTCtoLocal(EventDateTime, 'AUS Eastern Standard Time') EventDateTime,
        EventType,
        case
            when EventType = 1 then 'Login'
            when EventType = 2 then 'Not Ready'
            when EventType = 3 then 'Ready'
            when EventType = 4 then 'Reserved'
            when EventType = 5 then 'Talking'
            when EventType = 6 then 'Work'
            when EventType = 7 then 'Logout'
            else 'Unknown'
        end EventDescription,
        case
            when EventType = 7 then 0
            else isnull(datediff(s, EventDateTime, NextEventTime), 0)
        end EventDuration,
        ReasonCode,
        EmployeeKey,
        OrganisationKey
    into #cisAgentStateProper
    from
        #cisAgentState t
        outer apply
        (
            select top 1
                r.EventDateTime NextEventTime
            from
                #cisAgentState r
            where
                r.AgentKey = t.AgentKey and
                r.EventDateTime > t.EventDateTime
            order by
                r.EventDateTime
        ) r

    select 
        @sourcecount = count(*)
    from
        #cisAgentState

    begin transaction

    begin try
        
        merge into [db-au-cmdwh].dbo.cisAgentState with(tablock) t
        using #cisAgentStateProper s on 
            s.AgentKey = t.AgentKey and
            s.EventDateTime = t.EventDateTime and
            s.EventType = t.EventType
            
        when matched then
        
            update
            set
                EventType = s.EventType,
                EventDescription = s.EventDescription,
                EventDuration = s.EventDuration,
                ReasonCode = s.ReasonCode,
                EmployeeKey = s.EmployeeKey,
                OrganisationKey = s.OrganisationKey,
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                AgentKey,
                EventDateTime,
                EventType,
                EventDescription,
                EventDuration,
                ReasonCode,
                EmployeeKey,
                OrganisationKey,
                CreateBatchID
            )
            values
            (
                s.AgentKey,
                s.EventDateTime,
                s.EventType,
                s.EventDescription,
                s.EventDuration,
                s.ReasonCode,
                s.EmployeeKey,
                s.OrganisationKey,
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
            @SourceInfo = 'cisAgentState data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction
            
end





GO
