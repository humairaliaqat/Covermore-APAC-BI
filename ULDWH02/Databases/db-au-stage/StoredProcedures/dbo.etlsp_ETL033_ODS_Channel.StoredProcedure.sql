USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Channel]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL033_ODS_Channel]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160510
Prerequisite:   
Description:    load channel table
Change History:
                20160510 - LL - created
    
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

    if object_id('[db-au-cmdwh]..glChannels') is null
    begin

        create table [db-au-cmdwh]..glChannels
        (
            BIRowID bigint identity(1,1) not null,
            ChannelCode varchar(50) not null,
            ChannelDescription nvarchar(255),
            ChannelTypeCode varchar(50) not null,
            ChannelTypeDescription nvarchar(255),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx on [db-au-cmdwh]..glChannels (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glChannels (ChannelCode) include (ChannelTypeCode,ChannelTypeDescription,ChannelDescription)

    end

    if object_id('tempdb..#glChannels') is not null
        drop table #glChannels

    select *
    into #glChannels
    from
        [db-au-cmdwh]..glChannels
    where
        1 = 0

    ;with cte_channel as
    (
        select 
            ahl.ANL_HRCHY_LAB TypeOfChannelCode,
            ahc.DESCR TypeOfChannel,
            acc.ANL_CODE ChannelCode,
            acc.NAME ChannelDescription,
            ac.BusinessUnit,
            UpdateTime
        from
            sungl_ANL_CAT ac
            inner join sungl_ANL_CODE acc on
                acc.BusinessUnit = ac.BusinessUnit and
                acc.ANL_CAT_ID = ac.ANL_CAT_ID 
            inner join sungl_ANL_HRCHY_LINK ahl on
                ahl.BusinessUnit = ac.BusinessUnit and
                ahl.ANL_CAT_ID = ac.ANL_CAT_ID and
                ahl.ANL_CODE = acc.ANL_CODE
            inner join sungl_ANL_HRCHY_CODE ahc on
                ahc.BusinessUnit = ac.BusinessUnit and
                ahc.ANL_CAT_ID = ac.ANL_CAT_ID and
                ahc.ANL_HRCHY_LAB = ahl.ANL_HRCHY_LAB
            cross apply
            (
                select
                    max(UpdateTime) UpdateTime
                from
                    (
                        select ac.LAST_CHANGE_DATETIME UpdateTime
                        union all
                        select acc.LAST_CHANGE_DATETIME UpdateTime
                        union all
                        select ahl.LAST_CHANGE_DATETIME UpdateTime
                    ) t
            ) ut
        where
            ac.S_HEAD = 'CHANNEL'
    ),
    cte_aggregate as
    (
        select 
            ChannelCode,
            ChannelDescription,
            case
                when UpdateTime = max(UpdateTime) over (partition by ChannelCode) then TypeOfChannelCode
                else null
            end TypeOfChannelCode,
            case
                when UpdateTime = max(UpdateTime) over (partition by ChannelCode) then TypeOfChannel
                else null
            end TypeOfChannel
        from
            cte_channel
    )
    insert into #glChannels
    (
        ChannelCode,
        ChannelDescription,
        ChannelTypeCode,
        ChannelTypeDescription
    )
    select 
        ChannelCode,
        max(ChannelDescription) ChannelDescription,
        max(TypeOfChannelCode) TypeOfChannelCode,
        max(TypeOfChannel) TypeOfChannel
    from
        cte_aggregate
    group by
        ChannelCode

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glChannels with(tablock) t
        using #glChannels s on
            s.ChannelCode = t.ChannelCode

        when 
            matched and
            binary_checksum(t.ChannelTypeCode,t.ChannelTypeDescription,t.ChannelDescription,t.DeleteDateTime) <>
            binary_checksum(s.ChannelTypeCode,s.ChannelTypeDescription,s.ChannelDescription,s.DeleteDateTime) 
        then

            update
            set
                ChannelDescription = s.ChannelDescription,
                ChannelTypeCode = s.ChannelTypeCode,
                ChannelTypeDescription = s.ChannelTypeDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ChannelCode,
                ChannelDescription,
                ChannelTypeCode,
                ChannelTypeDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ChannelCode,
                s.ChannelDescription,
                s.ChannelTypeCode,
                s.ChannelTypeDescription,
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
