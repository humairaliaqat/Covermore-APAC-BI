USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Scenario]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL033_ODS_Scenario]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160506
Prerequisite:   
Description:    load scenario table
Change History:
                20160506 - LL - created
    
*************************************************************************************************************************************/

    set nocount on

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
        @SubjectArea = 'SUN GL',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    if @batchid = -1
        raiserror('prevent running without batch', 15, 1) with nowait

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh]..glScenarios') is null
    begin

        create table [db-au-cmdwh]..glScenarios
        (
            BIRowID bigint identity(1,1) not null,
            ScenarioCode varchar(50) not null,
            ScenarioDescription nvarchar(255),
            ScenarioGLCode varchar(50),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx on [db-au-cmdwh]..glScenarios (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glScenarios (ScenarioCode) include (ScenarioDescription,ScenarioGLCode)

    end

    if object_id('tempdb..#glScenarios') is not null
        drop table #glScenarios

    select *
    into #glScenarios
    from
        [db-au-cmdwh]..glScenarios
    where
        1 = 0

    insert into #glScenarios
    (
        ScenarioCode,
        ScenarioDescription,
        ScenarioGLCode
    )
    select 
        t.[Scenario Code],
        t.[Scenario Description],
        t.[Scenario GL Code]
    from
        [db-au-stage]..sungl_excel_scenario t
    where
        isnull(ltrim(rtrim(t.[Scenario Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glScenarios with(tablock) t
        using #glScenarios s on
            s.ScenarioCode = t.ScenarioCode

        when 
            matched and
            binary_checksum(t.ScenarioDescription,t.ScenarioGLCode,t.DeleteDateTime) <>
            binary_checksum(s.ScenarioDescription,s.ScenarioGLCode,s.DeleteDateTime) 
        then

            update
            set
                ScenarioDescription = s.ScenarioDescription,
                ScenarioGLCode = s.ScenarioGLCode,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ScenarioCode,
                ScenarioDescription,
                ScenarioGLCode,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ScenarioCode,
                s.ScenarioDescription,
                s.ScenarioGLCode,
                getdate(),
                @batchid
            )

        when
            not matched by source and
            t.DeleteDateTime is null
        then

            update
            set
                DeleteDateTime = getdate()

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
                        when MergeAction = 'delete' then 1
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
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Error'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
