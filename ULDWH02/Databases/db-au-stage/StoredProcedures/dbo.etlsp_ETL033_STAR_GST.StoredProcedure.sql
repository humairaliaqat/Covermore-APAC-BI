USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_GST]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL033_STAR_GST]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160512
Prerequisite:   
Description:    load GST dimension
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

    if object_id('[db-au-star]..Dim_GST') is null
    begin

        create table [db-au-star]..Dim_GST
        (
            [GST_SK] int not null identity(1,1),
            [GST_Code] varchar(50) not null,
            [GST_Description] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_GST_PK on [db-au-star].dbo.Dim_GST(GST_SK)
        create nonclustered index IX01_Dim_GST on [db-au-star].dbo.Dim_GST(GST_Code)

        set identity_insert [db-au-star]..Dim_GST on

        insert into [db-au-star]..Dim_GST
        (
            [GST_SK],
            [GST_Code],
            [GST_Description],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [GST_SK],
            'UNKNOWN' [GST_Code],
            'UNKNOWN' [GST_Description],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_GST off

    end

    if object_id('tempdb..#Dim_GST') is not null
        drop table #Dim_GST

    select *
    into #Dim_GST
    from
        [db-au-star]..Dim_GST
    where
        1 = 0

    insert into #Dim_GST
    (
        [GST_Code],
        [GST_Description],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.GSTCode,
        s.GSTDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glGSTs s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_GST with(tablock) t
        using #Dim_GST s on
            s.[GST_Code] = t.[GST_Code]

        when 
            matched and
            binary_checksum(t.[GST_Description]) <>
            binary_checksum(s.[GST_Description]) 
        then

            update
            set
                [GST_Description] = s.[GST_Description],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [GST_Code],
                [GST_Description],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[GST_Code],
                s.[GST_Description],
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
