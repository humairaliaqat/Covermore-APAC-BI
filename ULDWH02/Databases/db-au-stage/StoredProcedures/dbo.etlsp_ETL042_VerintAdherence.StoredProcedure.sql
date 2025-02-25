USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL042_VerintAdherence]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL042_VerintAdherence]  
    @RunMode varchar(30) = 'Realtime'                                             
                                                    
as
begin
/************************************************************************************************************************************
Author:         Philip Wong
Date:           20140910
Prerequisite:   Requires Verint database.                
Description:    populates verAdherence table in [db-au-cmdwh]
Parameters:     @RunMode: Required. Value is Realtime or Not Realtime
Change History:
                20140910 - PW - Procedure created
                20141015 - LS - Refactoring
                                Use batch logging
                                remove dynamic sql as target is sql server and the original query wasn't using openquery
                20141020 - LS - move get running batch to non real time condition block 
				20180712 - DM - Changed the ActivityTimeDifference to seconds, remove records if they no-longer exist in Verint
                
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
            @SubjectArea = 'VERINT ODS',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out
            
        select 
            @rptStartDate = dbo.xfn_ConvertLocalToUTC(@start, 'AUS Eastern Standard Time'),
            @rptEndDate = dateadd(d, 1, dbo.xfn_ConvertLocalToUTC(@end, 'AUS Eastern Standard Time'))
                   
    end    


    if object_id('etl_verAdherence') is not null
        drop table etl_verAdherence

    select
        isnull(fact.PLANNEDACTIVITYID,-1) as ActivityKey,
        fact.EMPLOYEEID EmployeeKey,
        isnull(SUPERVISOR.SUPERVISOREMPLOYEEID,-1) as SupervisorEmployeeKey,
        isnull(WORKRESOURCEORGANIZATION.ORGANIZATIONID,-1) as OrganisationKey,
        isnull(fact.PLANNEDEVENTTIMELINEID,0) TimelineID,
        fact.ID AdherenceID,
        dateadd(minute, startTZ.BIAS, fact.STARTTIME) ActivityStartTime,
        dateadd(minute, endTZ.BIAS, fact.ENDTIME) ActivityEndTime,
        fact.STARTTIME ActivityStartTimeGMT,
        fact.ENDTIME ActivityEndTimeGMT,
        isnull(fact.APPROVEDBY,'') ExceptionApprover,
        case 
            when fact.ISAPPROVED = 1 then convert(float, datediff(second, fact.STARTTIME, fact.ENDTIME))/(60.0*60.0)
            else 0 
        end ApprovedExceptionDuration,
        case 
            when fact.ISAPPROVED = 0 then convert(float, datediff(second, fact.STARTTIME, fact.ENDTIME))/(60.0*60.0)
            else 0 
        end UnapprovedExceptionDuration
    into etl_verAdherence
    from 
        [ULWFM01].[BPMAINDB].dbo.ADHERENCEEXCEPTION fact
        left join [ULWFM01].[BPMAINDB].dbo.SUPERVISOR on
            fact.EMPLOYEEID = SUPERVISOR.EMPLOYEEID and  
            SUPERVISOR.STARTTIME <= fact.STARTTIME and  
            (
                fact.STARTTIME < SUPERVISOR.ENDTIME or 
                SUPERVISOR.ENDTIME is null
            )
        left join [ULWFM01].[BPMAINDB].dbo.EMPLOYEEAM as manager on    
            manager.ID = SUPERVISOR.SUPERVISOREMPLOYEEID
        left join [ULWFM01].[BPMAINDB].dbo.WORKRESOURCEORGANIZATION on    
            fact.EMPLOYEEID = WORKRESOURCEORGANIZATION.WORKRESOURCEID and  
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
            isnull(ORGANIZATION.TIMEZONE,'Australia/Sydney') = startTZ.TIMEZONE
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
            isnull(ORGANIZATION.TIMEZONE,'Australia/Sydney') = endTZ.TIMEZONE
        --where 
        --    fact.STARTTIME >= @rptStartDate and 
        --    fact.STARTTIME <  dateadd(day, 1, @rptEndDate)

    if @RunMode = 'Realtime'
    begin
    
        select *
        from
            etl_verAdherence
        
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
        if object_id('[db-au-cmdwh].dbo.verAdherence') is null
        begin
        
            create table [db-au-cmdwh].dbo.verAdherence
            (
                [BIRowID] bigint not null identity(1,1),
                [AdherenceID] int not null,
                [ActivityKey] int not null,
                [EmployeeKey] int not null,
                [SupervisorEmployeeKey] int not null,
                [OrganisationKey] int not null,
                [TimelineID] int not null,
                [ActivityStartTime] datetime not null,
                [ActivityEndTime] datetime not null,
                [ActivityStartTimeGMT] datetime not null,
                [ActivityEndTimeGMT] datetime not null,
                [ExceptionApprover] nvarchar(255) not null,
                [ApprovedExceptionDuration] float not null,
                [UnapprovedExceptionDuration] float not null,
                [CreateBatchID] int null,
                [UpdateBatchID] int null
            ) 
            
            create clustered index idx_verAdherence_BIRowID on [db-au-cmdwh].dbo.verAdherence(BIRowID)
            create nonclustered index idx_factAdherence_AdherenceID on [db-au-cmdwh].dbo.verAdherence(AdherenceID)
            create nonclustered index idx_factAdherence_Datetime on [db-au-cmdwh].dbo.verAdherence(ActivityStartTime,ActivityEndTime) include(ActivityStartTimeGMT,ActivityEndTimeGMT,ActivityKey,EmployeeKey,OrganisationKey,ApprovedExceptionDuration,UnapprovedExceptionDuration)
            create nonclustered index idx_factAdherence_ActivityKey on [db-au-cmdwh].dbo.verAdherence(ActivityKey)
            create nonclustered index idx_factAdherence_EmployeeKey on [db-au-cmdwh].dbo.verAdherence(EmployeeKey)
            create nonclustered index idx_factAdherence_SupervisorEmployeeKey on [db-au-cmdwh].dbo.verAdherence(SupervisorEmployeeKey)
            create nonclustered index idx_factAdherence_OrganisationKey on [db-au-cmdwh].dbo.verAdherence(OrganisationKey)
            
        end    

        select 
            @sourcecount = count(*)
        from
            etl_verAdherence

        begin transaction

        begin try
            
            merge into [db-au-cmdwh].dbo.verAdherence with(tablock) t
            using etl_verAdherence s on 
                s.AdherenceID = t.AdherenceID
                
            when matched then
            
                update
                set
                    ActivityKey = s.ActivityKey,
                    EmployeeKey = s.EmployeeKey,
                    SupervisorEmployeeKey = s.SupervisorEmployeeKey,
                    OrganisationKey = s.OrganisationKey,
                    TimelineID = s.TimelineID,
                    ActivityStartTime = s.ActivityStartTime,
                    ActivityEndTime = s.ActivityEndTime,
                    ActivityStartTimeGMT = s.ActivityStartTimeGMT,
                    ActivityEndTimeGMT = s.ActivityEndTimeGMT,
                    ExceptionApprover = s.ExceptionApprover,
                    ApprovedExceptionDuration = s.ApprovedExceptionDuration,
                    UnapprovedExceptionDuration = s.UnapprovedExceptionDuration,
                    UpdateBatchID = @batchid
                    
            when not matched by target then
                insert 
                (
                    AdherenceID,
                    ActivityKey,
                    EmployeeKey,
                    SupervisorEmployeeKey,
                    OrganisationKey,
                    TimelineID,
                    ActivityStartTime,
                    ActivityEndTime,
                    ActivityStartTimeGMT,
                    ActivityEndTimeGMT,
                    ExceptionApprover,
                    ApprovedExceptionDuration,
                    UnapprovedExceptionDuration,
                    CreateBatchID
                )
                values
                (
                    s.AdherenceID,
                    s.ActivityKey,
                    s.EmployeeKey,
                    s.SupervisorEmployeeKey,
                    s.OrganisationKey,
                    s.TimelineID,
                    s.ActivityStartTime,
                    s.ActivityEndTime,
                    s.ActivityStartTimeGMT,
                    s.ActivityEndTimeGMT,
                    s.ExceptionApprover,
                    s.ApprovedExceptionDuration,
                    s.UnapprovedExceptionDuration,
                    @batchid
                )
			when not matched by source then delete --Remove if it no-longer exists in Verint
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
                @SourceInfo = 'verAdherence data refresh failed',
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
