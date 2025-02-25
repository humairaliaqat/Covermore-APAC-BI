USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_State_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_ODS_State_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load state table
Change History:
                20160509 - LL - created
				20180423 - LT - created for SUN GL INDIA
    
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

    if object_id('[db-au-cmdwh]..glStates_ind') is null
    begin

        create table [db-au-cmdwh]..glStates_ind
        (
            BIRowID bigint identity(1,1) not null,
            ParentStateCode varchar(50) not null,
            ParentStateDescription nvarchar(255),
            StateCode varchar(50) not null,
            StateDescription nvarchar(255),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx_ind on [db-au-cmdwh]..glStates_ind (BIRowID)
        create nonclustered index idx_ind on [db-au-cmdwh]..glStates_ind (StateCode) include (StateDescription,ParentStateCode,ParentStateDescription)
        create nonclustered index idx_parent_ind on [db-au-cmdwh]..glStates_ind (ParentStateCode) include (StateCode,StateDescription,ParentStateDescription)

    end

    if object_id('tempdb..#glStates_ind') is not null
        drop table #glStates_ind

    select *
    into #glStates_ind
    from
        [db-au-cmdwh]..glStates_ind
    where
        1 = 0

    insert into #glStates_ind
    (
        ParentStateCode,
        ParentStateDescription,
        StateCode,
        StateDescription
    )
    select 
        t.[Parent State Code],
        t.[Parent State Description],
        t.[State Code],
        t.[State Description]
    from
        [db-au-stage]..sungl_excel_state_ind t
    where
        isnull(ltrim(rtrim(t.[State Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glStates_ind with(tablock) t
        using #glStates_ind s on
            s.StateCode = t.StateCode

        when 
            matched and
            binary_checksum(t.StateDescription,t.ParentStateCode,t.ParentStateDescription,t.DeleteDateTime) <>
            binary_checksum(s.StateDescription,s.ParentStateCode,s.ParentStateDescription,s.DeleteDateTime) 
        then

            update
            set
                StateDescription = s.StateDescription,
                ParentStateCode = s.ParentStateCode,
                ParentStateDescription = s.ParentStateDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ParentStateCode,
                ParentStateDescription,
                StateCode,
                StateDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ParentStateCode,
                s.ParentStateDescription,
                s.StateCode,
                s.StateDescription,
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
