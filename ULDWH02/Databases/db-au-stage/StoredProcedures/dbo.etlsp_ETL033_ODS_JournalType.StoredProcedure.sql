USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_JournalType]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL033_ODS_JournalType]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160509
Prerequisite:   
Description:    load journal type table
Change History:
                20160509 - LL - created
    
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

    if object_id('[db-au-cmdwh]..glJournalTypes') is null
    begin

        create table [db-au-cmdwh]..glJournalTypes
        (
            BIRowID bigint identity(1,1) not null,
            JournalTypeCode varchar(50) not null,
            JournalTypeDescription nvarchar(255),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx on [db-au-cmdwh]..glJournalTypes (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glJournalTypes (JournalTypeCode) include (JournalTypeDescription)

    end

    if object_id('tempdb..#glJournalTypes') is not null
        drop table #glJournalTypes

    select *
    into #glJournalTypes
    from
        [db-au-cmdwh]..glJournalTypes
    where
        1 = 0

    insert into #glJournalTypes
    (
        JournalTypeCode,
        JournalTypeDescription
    )
    select 
        t.[Journal Type Code],
        t.[Journal Type Description]
    from
        [db-au-stage]..sungl_excel_journaltype t
    where
        isnull(ltrim(rtrim(t.[Journal Type Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glJournalTypes with(tablock) t
        using #glJournalTypes s on
            s.JournalTypeCode = t.JournalTypeCode

        when 
            matched and
            binary_checksum(t.JournalTypeDescription,t.DeleteDateTime) <>
            binary_checksum(s.JournalTypeDescription,s.DeleteDateTime) 
        then

            update
            set
                JournalTypeDescription = s.JournalTypeDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                JournalTypeCode,
                JournalTypeDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.JournalTypeCode,
                s.JournalTypeDescription,
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
