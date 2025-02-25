USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_CCATeams]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[etlsp_ETL033_ODS_CCATeams]
as
begin
/************************************************************************************************************************************
Author:         Humaira Liaqat
Date:           20210303
Prerequisite:   
Description:    load CCATeams table
Change History:
                20210303 - HL - Created code to load new dimension CCA Teams ODS table as per INC0189611 
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

    if object_id('[db-au-cmdwh]..glCCATeams') is null
    begin

        create table [db-au-cmdwh]..glCCATeams
        (
            BIRowID bigint identity(1,1) not null,
            ParentCCATeamsCode varchar(50) not null,
            ParentCCATeamsDescription nvarchar(255),
            CCATeamsCode varchar(50) not null,
            CCATeamsDescription nvarchar(255),
            CCATeamsOwnerCode varchar(50) not null,
            CCATeamsOwnerDescription nvarchar(255),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx on [db-au-cmdwh]..glCCATeams (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glCCATeams (CCATeamsCode) include (ParentCCATeamsCode,ParentCCATeamsDescription,CCATeamsDescription,CCATeamsOwnerCode,CCATeamsOwnerDescription)
        create nonclustered index idx_parent on [db-au-cmdwh]..glCCATeams (ParentCCATeamsCode) include (CCATeamsCode,CCATeamsDescription,ParentCCATeamsDescription)

    end

    if object_id('tempdb..#glCCATeams') is not null
        drop table #glCCATeams

    select *
    into #glCCATeams
    from
        [db-au-cmdwh]..glCCATeams
    where
        1 = 0

    insert into #glCCATeams
    (
        ParentCCATeamsCode,
        ParentCCATeamsDescription,
        CCATeamsCode,
        CCATeamsDescription,
        CCATeamsOwnerCode,
        CCATeamsOwnerDescription
    )
    select 
        t.[Parent CCA Teams Code],
        t.[Parent CCA Teams Code Description],
        t.[CCA Teams Code],
        t.[CCA Teams Description],
        t.[CCA Teams Owner Code],
        t.[CCA Teams Owner Description]
    from
        [db-au-stage]..sungl_excel_CCATeams t
    where
        isnull(ltrim(rtrim(t.[CCA Teams Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glCCATeams with(tablock) t
        using #glCCATeams s on
            s.CCATeamsCode = t.CCATeamsCode

        when 
            matched and
            binary_checksum(t.ParentCCATeamsCode,t.ParentCCATeamsDescription,t.CCATeamsDescription,t.CCATeamsOwnerCode,t.CCATeamsOwnerDescription,t.DeleteDateTime) <>
            binary_checksum(s.ParentCCATeamsCode,s.ParentCCATeamsDescription,s.CCATeamsDescription,s.CCATeamsOwnerCode,s.CCATeamsOwnerDescription,s.DeleteDateTime) 
        then

            update
            set
                ParentCCATeamsCode = s.ParentCCATeamsCode,
                ParentCCATeamsDescription = s.ParentCCATeamsDescription,
                CCATeamsDescription = s.CCATeamsDescription,
                CCATeamsOwnerCode = s.CCATeamsOwnerCode,
                CCATeamsOwnerDescription = s.CCATeamsOwnerDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ParentCCATeamsCode,
                ParentCCATeamsDescription,
                CCATeamsCode,
                CCATeamsDescription,
                CCATeamsOwnerCode,
                CCATeamsOwnerDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ParentCCATeamsCode,
                s.ParentCCATeamsDescription,
                s.CCATeamsCode,
                s.CCATeamsDescription,
                s.CCATeamsOwnerCode,
                s.CCATeamsOwnerDescription,
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
