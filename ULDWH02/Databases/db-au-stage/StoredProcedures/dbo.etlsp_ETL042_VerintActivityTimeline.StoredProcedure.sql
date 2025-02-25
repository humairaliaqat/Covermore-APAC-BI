USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL042_VerintActivityTimeline]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL042_VerintActivityTimeline]  
    @RunMode varchar(30) = 'Realtime'                                             
    
as
begin
/************************************************************************************************************************************
Author:         Philip Wong
Date:           20140910
Prerequisite:   Requires Verint database.                
Description:    populates verActivityTimeline table in [db-au-cmdwh]
Parameters:     @RunMode: Required. Value is Realtime or Not Realtime
Change History:
                20140910 - PW - Procedure created
                20141015 - LS - Refactoring
                                Use batch logging
                                remove dynamic sql as target is sql server and the original query wasn't using openquery
                20141020 - LS - move get running batch to non real time condition block 
                20150428 - LS - duplicate key, add timelinetype as part of key
				20180709 - DM - bring through the Isunpublished flag from the Scheduled table
                
*************************************************************************************************************************************/

--uncomment to debug
/*
declare @RunMode varchar(30)
select 
    @RunMode = 'Realtime'
*/

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime
    
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
            @SubjectArea = 'VERINT ODS',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out

        select 
            @rptStartDate = dbo.xfn_ConvertLocalToUTC(@start, 'AUS Eastern Standard Time'),
            @rptEndDate = dateadd(d, 1, dbo.xfn_ConvertLocalToUTC(@end, 'AUS Eastern Standard Time'))
                   
    end    
    
    if object_id('etl_verActivityTimeline') is not null
        drop table etl_verActivityTimeline

    select
        convert(varchar, fact.EmployeeKey) + convert(varchar, datediff(s, '2013-01-01', fact.STARTTIME))  + convert(varchar, datediff(s, '2013-01-01', fact.ENDTIME)) + left(fact.TimeLineType, 1) ActivityTimelineKey,
        isnull(fact.ActivityKey,-1) as ActivityKey,
        fact.EmployeeKey,
        isnull(SUPERVISOR.SUPERVISOREMPLOYEEID,-1) as SupervisorEmployeeKey,
        isnull(WORKRESOURCEORGANIZATION.ORGANIZATIONID,-1) as OrganisationKey,
        isnull(fact.TimelineID,0) TimelineID,
        fact.TimeLineType,
        dateadd(minute, startTZ.BIAS, fact.STARTTIME) ActivityStartTime,
        dateadd(minute, endTZ.BIAS, fact.ENDTIME) ActivityEndTime,
        fact.STARTTIME ActivityStartTimeGMT,
        fact.ENDTIME ActivityEndTimeGMT,
        convert(float, datediff(second, fact.STARTTIME, fact.ENDTIME))/(60.0 * 60.0) ActivityTime,
		fact.ISUNPUBLISHED
    into etl_verActivityTimeline
    from
        (
            select
                0 as TimelineID,
                ACTIVITYID as ActivityKey,
                EMPLOYEEID as EmployeeKey,
                'Actuals' as TimeLineType,        
                STARTTIME,
                ENDTIME,
				0 as ISUNPUBLISHED
            from 
                [ULWFM01].[BPMAINDB].dbo.ACTUALEVENTTIMELINE
            where
                STARTTIME >= @rptStartDate and 
                STARTTIME <  dateadd(day, 1, @rptEndDate)
                
            union
            --MOD: 20180709 Pulling IsUnpublished through into into the DWH
            select
                ID,
                ACTIVITYID as ActivityKey,
                WORKRESOURCEID as EmployeeKey,
                'Budget' as TIMELINETYPE,        
                STARTTIME,
                ENDTIME,
				ISUNPUBLISHED
            from 
                [ULWFM01].[BPMAINDB].dbo.PLANNEDEVENTTIMELINE
            where 
                ISUNPUBLISHED = 0 and 
                --STARTTIME >= @rptStartDate and 
                STARTTIME <  dateadd(day, 1, @rptEndDate)
        ) fact
        left join [ULWFM01].[BPMAINDB].dbo.SUPERVISOR on    
            fact.EMPLOYEEKEY = SUPERVISOR.EMPLOYEEID and  
            SUPERVISOR.STARTTIME <= fact.STARTTIME and  
            (
                fact.STARTTIME < SUPERVISOR.ENDTIME or 
                SUPERVISOR.ENDTIME is null
            )
        left join [ULWFM01].[BPMAINDB].dbo.EMPLOYEEAM as manager on    
            manager.ID = SUPERVISOR.SUPERVISOREMPLOYEEID
        left join [ULWFM01].[BPMAINDB].dbo.WORKRESOURCEORGANIZATION on    
            fact.EMPLOYEEKEY = WORKRESOURCEORGANIZATION.WORKRESOURCEID and  
            WORKRESOURCEORGANIZATION.STARTTIME <= fact.STARTTIME and  
            (
                fact.STARTTIME < WORKRESOURCEORGANIZATION.ENDTIME or 
                WORKRESOURCEORGANIZATION.ENDTIME is null
            )
        left join [ULWFM01].[BPMAINDB].dbo.ORGANIZATION on 
            ORGANIZATION.ID = WORKRESOURCEORGANIZATION.ORGANIZATIONID
        left join [ULWFM01].[BPMAINDB].dbo.TIMEZONEAM as startTZ on 
            (
                (
                    startTZ.STARTTIME <= fact.STARTTIME and 
                    fact.STARTTIME < startTZ.ENDTIME
                ) or 
                (
                    startTZ.STARTTIME is null and 
                    startTZ.ENDTIME is null
                )
            ) and 
            isnull(ORGANIZATION.TIMEZONE, 'Australia/Sydney') = startTZ.TIMEZONE
        left join [ULWFM01].[BPMAINDB].dbo.TIMEZONEAM as endTZ on 
            (
                (
                    endTZ.STARTTIME <= fact.ENDTIME and 
                    fact.ENDTIME < endTZ.ENDTIME
                ) or 
                (
                    endTZ.STARTTIME is null and 
                    endTZ.ENDTIME is null
                )
            ) and 
            isnull(ORGANIZATION.TIMEZONE, 'Australia/Sydney') = endTZ.TIMEZONE


    if @RunMode = 'Realtime'
    begin
        
        select *
        from
            etl_verActivityTimeline
            
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
        if object_id('[db-au-cmdwh].dbo.verActivityTimeline') is null
        begin
        
            create table [db-au-cmdwh].dbo.verActivityTimeline
            (
                [BIRowID] bigint not null identity(1,1),
                [ActivityTimelineKey] nvarchar(50) not null,
                [ActivityKey] int not null,
                [EmployeeKey] int not null,
                [SupervisorEmployeeKey] int not null,
                [OrganisationKey] int not null,
                [TimelineID] int not null,
                [TimeLineType] nvarchar(50) not null,
                [ActivityStartTime] datetime not null,
                [ActivityEndTime] datetime not null,
                [ActivityStartTimeGMT] datetime not null,
                [ActivityEndTimeGMT] datetime not null,
                [ActivityTime] float not null,
                [CreateBatchID] int null,
                [UpdateBatchID] int null,
				[IsUnpublished] bit null
            ) 

            create clustered index idx_verActivityTimeline_BIRowID on [db-au-cmdwh].dbo.verActivityTimeline(BIRowID)
            create nonclustered index idx_verActivityTimeline_ActivityTimelineKey on [db-au-cmdwh].dbo.verActivityTimeline(ActivityTimelineKey)
            create nonclustered index idx_verActivityTimeline_Datetime on [db-au-cmdwh].dbo.verActivityTimeline(ActivityStartTime,ActivityEndTime) include(ActivityStartTimeGMT,ActivityEndTimeGMT,ActivityKey,EmployeeKey,OrganisationKey,TimeLineType,ActivityTime)
            create nonclustered index idx_verActivityTimeline_ActivityKey on [db-au-cmdwh].dbo.verActivityTimeline(ActivityKey)
            create nonclustered index idx_verActivityTimeline_EmployeeKey on [db-au-cmdwh].dbo.verActivityTimeline(EmployeeKey)
            create nonclustered index idx_verActivityTimeline_SupervisorEmployeeKey on [db-au-cmdwh].dbo.verActivityTimeline(SupervisorEmployeeKey)
            create nonclustered index idx_verActivityTimeline_OrganisationKey on [db-au-cmdwh].dbo.verActivityTimeline(OrganisationKey)
            
        end    

        select 
            @sourcecount = count(*)
        from
            etl_verActivityTimeline

        begin transaction

        begin try
            
            merge into [db-au-cmdwh].dbo.verActivityTimeline with(tablock) t
            using etl_verActivityTimeline s on 
                s.ActivityTimelineKey = t.ActivityTimelineKey
                
            when matched then
            
                update
                set
                    ActivityKey = s.ActivityKey,
                    EmployeeKey = s.EmployeeKey,
                    SupervisorEmployeeKey = s.SupervisorEmployeeKey,
                    OrganisationKey = s.OrganisationKey,
                    TimelineID = s.TimelineID,
                    TimeLineType = s.TimeLineType,
                    ActivityStartTime = s.ActivityStartTime,
                    ActivityEndTime = s.ActivityEndTime,
                    ActivityStartTimeGMT = s.ActivityStartTimeGMT,
                    ActivityEndTimeGMT = s.ActivityEndTimeGMT,
                    ActivityTime = s.ActivityTime,
                    UpdateBatchID = @batchid,
					IsUnpublished = s.ISUNPUBLISHED
                    
            when not matched by target then
                insert 
                (
                    ActivityTimeLineKey,
                    ActivityKey,
                    EmployeeKey,
                    SupervisorEmployeeKey,
                    OrganisationKey,
                    TimelineID,
                    TimeLineType,
                    ActivityStartTime,
                    ActivityEndTime,
                    ActivityStartTimeGMT,
                    ActivityEndTimeGMT,
                    ActivityTime,
                    CreateBatchID,
					IsUnpublished
                )
                values
                (
                    s.ActivityTimeLineKey,
                    s.ActivityKey,
                    s.EmployeeKey,
                    s.SupervisorEmployeeKey,
                    s.OrganisationKey,
                    s.TimelineID,
                    s.TimeLineType,
                    s.ActivityStartTime,
                    s.ActivityEndTime,
                    s.ActivityStartTimeGMT,
                    s.ActivityEndTimeGMT,
                    s.ActivityTime,
                    @batchid,
					s.ISUNPUBLISHED
                )
			when not matched by source AND t.TimeLineType = 'Budget' then
				update set IsUnpublished = 2

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
                @SourceInfo = 'verActivityTimeline data refresh failed',
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
