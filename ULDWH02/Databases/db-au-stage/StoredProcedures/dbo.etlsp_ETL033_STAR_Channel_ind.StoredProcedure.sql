USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_Channel_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_STAR_Channel_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load channel dimension
Change History:
                20160512 - LL - created
				20180423 - LT - created for SUN GL INDIA.
    
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

    if object_id('[db-au-star]..Dim_Channel_ind') is null
    begin

        create table [db-au-star]..Dim_Channel_ind
        (
            [Channel_SK] int not null identity(1,1),
            [Parent_Channel_Code] varchar(50) not null,
            [Parent_Channel_Desc] varchar(200) null,
            [Channel_Code] varchar(50) not null,
            [Channel_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_Channel_PK_ind on [db-au-star].dbo.Dim_Channel_ind(Channel_SK)
        create nonclustered index IX01_Dim_Channel_ind on [db-au-star].dbo.Dim_Channel_ind(Channel_Code)

        set identity_insert [db-au-star]..Dim_Channel_ind on

        insert into [db-au-star]..Dim_Channel_ind
        (
            [Channel_SK],
            [Parent_Channel_Code],
            [Parent_Channel_Desc],
            [Channel_Code],
            [Channel_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [Channel_SK],
            'UNKNOWN' [Parent_Channel_Code],
            'UNKNOWN' [Parent_Channel_Desc],
            'UNKNOWN' [Channel_Code],
            'UNKNOWN' [Channel_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_Channel_ind off

    end

    if object_id('tempdb..#Dim_Channel_ind') is not null
        drop table #Dim_Channel_ind

    select *
    into #Dim_Channel_ind
    from
        [db-au-star]..Dim_Channel_ind
    where
        1 = 0

    insert into #Dim_Channel_ind
    (
        [Parent_Channel_Code],
        [Parent_Channel_Desc],
        [Channel_Code],
        [Channel_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.ChannelTypeCode,
        s.ChannelTypeDescription,
        s.ChannelCode,
        s.ChannelDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glChannels_ind s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_Channel_ind with(tablock) t
        using #Dim_Channel_ind s on
            s.[Channel_Code] = t.[Channel_Code]

        when 
            matched and
            binary_checksum(t.[Parent_Channel_Code],t.[Parent_Channel_Desc],t.[Channel_Desc]) <>
            binary_checksum(s.[Parent_Channel_Code],s.[Parent_Channel_Desc],s.[Channel_Desc]) 
        then

            update
            set
                [Parent_Channel_Code] = s.[Parent_Channel_Code],
                [Parent_Channel_Desc] = s.[Parent_Channel_Desc],
                [Channel_Desc] = s.[Channel_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Parent_Channel_Code],
                [Parent_Channel_Desc],
                [Channel_Code],
                [Channel_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Parent_Channel_Code],
                s.[Parent_Channel_Desc],
                s.[Channel_Code],
                s.[Channel_Desc],
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
