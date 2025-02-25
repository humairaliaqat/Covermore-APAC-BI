USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL042_VerintQuality]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL042_VerintQuality]  
    @RunMode varchar(30) = 'Realtime'                                             
    
as
begin
/************************************************************************************************************************************
Author:         Philip Wong
Date:           20141010
Prerequisite:   Requires Verint database.                
Description:    populates verQuality table in [db-au-cmdwh]
Parameters:     @RunMode: Required. Value is Realtime or Not Realtime
Change History:
                20141010 - PW - Procedure created
                20141015 - LS - Refactoring
                                Use batch logging
                                remove dynamic sql as target is sql server and the original query wasn't using openquery
                20141016 - PW - Removed date restriction as the Start and End dates aren't indicative of deltas.
                20141020 - LS - move get running batch to non real time condition block 
                
*************************************************************************************************************************************/

--uncomment to debug
/*
declare @RunMode varchar(30)
select @RunMode = 'Realtime'
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
    
    if object_id('etl_verQuality') is not null
        drop table etl_verQuality

    select
        fact.ID QualityKey,
        fact.EMPLOYEEID EmployeeKey,
        isnull(SUPERVISOR.SUPERVISOREMPLOYEEID,-1) as SupervisorEmployeeKey,
        isnull(WORKRESOURCEORGANIZATION.ORGANIZATIONID,-1) as OrganisationKey,
        dateadd(minute, startTZ.BIAS, fact.STARTTIME) QualityStartTime,
        dateadd(minute, endTZ.BIAS, fact.ENDTIME) QualityEndTime,
        fact.STARTTIME QualityStartTimeGMT,
        fact.ENDTIME QualityEndTimeGMT,
        fact.QualityScore
    into etl_verQuality
    from 
        [ULWFM01].[BPMAINDB].dbo.EMPLOYEEQUALITY fact
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
    /*where 
        fact.STARTTIME >= @rptStartDate and  
        fact.STARTTIME <  dateadd(day, 1, @rptEndDate)*/

    if @RunMode = 'Realtime'
    begin
    
        select *
        from
            etl_verQuality

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
        if object_id('[db-au-cmdwh].dbo.verQuality') is null
        begin
            create table [db-au-cmdwh].dbo.verQuality
            (
                [BIRowID] bigint not null identity(1,1),
                [QualityKey] int not null,
                [EmployeeKey] int not null,
                [SupervisorEmployeeKey] int not null,
                [OrganisationKey] int not null,
                [QualityStartTime] datetime not null,
                [QualityEndTime] datetime null,
                [QualityStartTimeGMT] datetime not null,
                [QualityEndTimeGMT] datetime null,
                [QualityScore] int not null,
                [CreateBatchID] int null,
                [UpdateBatchID] int null
            ) 
            
            create clustered index idx_verQuality_BIRowID on [db-au-cmdwh].dbo.verQuality(BIRowID)
            create nonclustered index idx_verQuality_Datetime on [db-au-cmdwh].dbo.verQuality(QualityStartTime,QualityEndTime) include(QualityStartTimeGMT,QualityEndTimeGMT,EmployeeKey,OrganisationKey,QualityScore)
            create nonclustered index idx_verQuality_QualityKey on [db-au-cmdwh].dbo.verQuality(QualityKey)
            create nonclustered index idx_verQuality_EmployeeKey on [db-au-cmdwh].dbo.verQuality(EmployeeKey)
            create nonclustered index idx_verQuality_SupervisorEmployeeKey on [db-au-cmdwh].dbo.verQuality(SupervisorEmployeeKey)
            create nonclustered index idx_verQuality_OrganisationKey on [db-au-cmdwh].dbo.verQuality(OrganisationKey)
            
        end    
        
        begin transaction

        begin try
            
            merge into [db-au-cmdwh].dbo.verQuality with(tablock) t
            using etl_verQuality s on 
                s.QualityKey = t.QualityKey
                
            when matched then
            
                update
                set
                    QualityKey = s.QualityKey,
                    EmployeeKey = s.EmployeeKey,
                    SupervisorEmployeeKey = s.SupervisorEmployeeKey,
                    OrganisationKey = s.OrganisationKey,
                    QualityStartTime = s.QualityStartTime,
                    QualityEndTime = s.QualityEndTime,
                    QualityStartTimeGMT = s.QualityStartTimeGMT,
                    QualityEndTimeGMT = s.QualityEndTimeGMT,
                    QualityScore = s.QualityScore,
                    UpdateBatchID = @batchid
                    
            when not matched by target then
                insert 
                (
                    QualityKey,
                    EmployeeKey,
                    SupervisorEmployeeKey,
                    OrganisationKey,
                    QualityStartTime,
                    QualityEndTime,
                    QualityStartTimeGMT,
                    QualityEndTimeGMT,
                    QualityScore,
                    CreateBatchID
                )
                values
                (
                    s.QualityKey,
                    s.EmployeeKey,
                    s.SupervisorEmployeeKey,
                    s.OrganisationKey,
                    s.QualityStartTime,
                    s.QualityEndTime,
                    s.QualityStartTimeGMT,
                    s.QualityEndTimeGMT,
                    s.QualityScore,
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
                @SourceInfo = 'verQuality data refresh failed',
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
