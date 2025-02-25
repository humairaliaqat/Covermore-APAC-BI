USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_State_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_STAR_State_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160513
Prerequisite:   
Description:    load State dimension
Change History:
                20160513 - LL - created
				20180423 - LT - created for SUN GL India
    
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
        @SubjectArea = 'SUN GL INDIA',
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

    if object_id('[db-au-star]..Dim_State_ind') is null
    begin

        create table [db-au-star]..Dim_State_ind
        (
            [State_SK] int not null identity(1,1),
            [State_Code] varchar(50) not null,
            [State_Desc] varchar(200) null,
            [Parent_State_Code] varchar(50) not null,
            [Parent_State_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_State_PK_ind on [db-au-star].dbo.Dim_State_ind(State_SK)
        create nonclustered index IX01_Dim_State_ind on [db-au-star].dbo.Dim_State_ind(State_Code)

        set identity_insert [db-au-star]..Dim_State_ind on

        insert into [db-au-star]..Dim_State_ind
        (
            [State_SK],
            [State_Code],
            [State_Desc],
            [Parent_State_Code],
            [Parent_State_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [State_SK],
            'UNKNOWN' [State_Code],
            'UNKNOWN' [State_Desc],
            'UNKNOWN' [Parent_State_Code],
            'UNKNOWN' [Parent_State_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_State_ind off

    end

    if object_id('tempdb..#Dim_State_ind') is not null
        drop table #Dim_State_ind

    select *
    into #Dim_State_ind
    from
        [db-au-star]..Dim_State_ind
    where
        1 = 0

    insert into #Dim_State_ind
    (
        [State_Code],
        [State_Desc],
        [Parent_State_Code],
        [Parent_State_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.StateCode,
        s.StateDescription,
        s.ParentStateCode,
        s.ParentStateDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glStates_ind s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_State_ind with(tablock) t
        using #Dim_State_ind s on
            s.[State_Code] = t.[State_Code]

        when 
            matched and
            binary_checksum(t.[State_Desc],t.[Parent_State_Code],t.[Parent_State_Desc]) <>
            binary_checksum(s.[State_Desc],s.[Parent_State_Code],s.[Parent_State_Desc]) 
        then

            update
            set
                [State_Desc] = s.[State_Desc],
                [Parent_State_Code] = s.[Parent_State_Code],
                [Parent_State_Desc] = s.[Parent_State_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [State_Code],
                [State_Desc],
                [Parent_State_Code],
                [Parent_State_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[State_Code],
                s.[State_Desc],
                s.[Parent_State_Code],
                s.[Parent_State_Desc],
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
