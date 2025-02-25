USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_GST]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL033_ODS_GST]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160510
Prerequisite:   
Description:    load GST table
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

    if object_id('[db-au-cmdwh]..glGSTs') is null
    begin

        create table [db-au-cmdwh]..glGSTs
        (
            BIRowID bigint identity(1,1) not null,
            GSTCode varchar(50) not null,
            GSTDescription nvarchar(255),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx on [db-au-cmdwh]..glGSTs (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glGSTs (GSTCode) include (GSTDescription)

    end

    if object_id('tempdb..#glGSTs') is not null
        drop table #glGSTs

    select *
    into #glGSTs
    from
        [db-au-cmdwh]..glGSTs
    where
        1 = 0

    ;with cte_gst as
    (
        select 
            acc.ANL_CODE GSTCode,
            acc.NAME GSTDescription,
            ac.BusinessUnit,
            UpdateTime
        from
            sungl_ANL_CAT ac
            inner join sungl_ANL_CODE acc on
                acc.BusinessUnit = ac.BusinessUnit and
                acc.ANL_CAT_ID = ac.ANL_CAT_ID 
            cross apply
            (
                select
                    max(UpdateTime) UpdateTime
                from
                    (
                        select ac.LAST_CHANGE_DATETIME UpdateTime
                        union all
                        select acc.LAST_CHANGE_DATETIME UpdateTime
                    ) t
            ) ut
        where
            ac.S_HEAD = 'GST'
    ),
    cte_aggregate as
    (
        select 
            GSTCode,
            case
                when UpdateTime = max(UpdateTime) over (partition by GSTCode) then GSTDescription
                else null
            end GSTDescription
        from
            cte_gst
    )
    insert into #glGSTs
    (
        GSTCode,
        GSTDescription
    )
    select 
        GSTCode,
        max(GSTDescription) GSTDescription
    from
        cte_aggregate
    group by
        GSTCode

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glGSTs with(tablock) t
        using #glGSTs s on
            s.GSTCode = t.GSTCode

        when 
            matched and
            binary_checksum(t.GSTDescription,t.DeleteDateTime) <>
            binary_checksum(s.GSTDescription,s.DeleteDateTime) 
        then

            update
            set
                GSTDescription = s.GSTDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                GSTCode,
                GSTDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.GSTCode,
                s.GSTDescription,
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
