USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_Scenario]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL033_STAR_Scenario]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160512
Prerequisite:   
Description:    load Scenario dimension
Change History:
                20160512 - LL - created
    
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

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-star]..Dim_Scenario') is null
    begin

        create table [db-au-star]..Dim_Scenario
        (
            [Scenario_SK] int not null identity(1,1),
            [Scenario_Code] varchar(50) not null,
            [Scenario_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_Scenario_PK on [db-au-star].dbo.Dim_Scenario(Scenario_SK)
        create nonclustered index IX01_Dim_Scenario on [db-au-star].dbo.Dim_Scenario(Scenario_Code)

        set identity_insert [db-au-star]..Dim_Scenario on

        insert into [db-au-star]..Dim_Scenario
        (
            [Scenario_SK],
            [Scenario_Code],
            [Scenario_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [Scenario_SK],
            'UNKNOWN' [Scenario_Code],
            'UNKNOWN' [Scenario_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_Scenario off

    end

    if object_id('tempdb..#Dim_Scenario') is not null
        drop table #Dim_Scenario

    select *
    into #Dim_Scenario
    from
        [db-au-star]..Dim_Scenario
    where
        1 = 0

    insert into #Dim_Scenario
    (
        [Scenario_Code],
        [Scenario_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.ScenarioCode,
        s.ScenarioDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glScenarios s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_Scenario with(tablock) t
        using #Dim_Scenario s on
            s.[Scenario_Code] = t.[Scenario_Code]

        when 
            matched and
            binary_checksum(t.[Scenario_Desc]) <>
            binary_checksum(s.[Scenario_Desc]) 
        then

            update
            set
                [Scenario_Desc] = s.[Scenario_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Scenario_Code],
                [Scenario_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Scenario_Code],
                s.[Scenario_Desc],
                getdate(),
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
