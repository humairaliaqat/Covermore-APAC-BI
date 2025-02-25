USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Client_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_ODS_Client_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load client table
Change History:
                20160509 - LL - created
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

    if object_id('[db-au-cmdwh]..glClients_ind') is null
    begin

        create table [db-au-cmdwh]..glClients_ind
        (
            BIRowID bigint identity(1,1) not null,
            ParentClientCode varchar(50) not null,
            ParentClientDescription nvarchar(255),
            ClientCode varchar(50) not null,
            ClientDescription nvarchar(255),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx_ind on [db-au-cmdwh]..glClients_ind (BIRowID)
        create nonclustered index idx_ind on [db-au-cmdwh]..glClients_ind (ClientCode) include (ParentClientCode,ParentClientDescription,ClientDescription)
        create nonclustered index idx_parent_ind on [db-au-cmdwh]..glClients_ind (ParentClientCode) include (ClientCode,ClientDescription,ParentClientDescription)

    end

    if object_id('tempdb..#glClients_ind') is not null
        drop table #glClients_ind

    select *
    into #glClients_ind
    from
        [db-au-cmdwh]..glClients_ind
    where
        1 = 0

    insert into #glClients_ind
    (
        ParentClientCode,
        ParentClientDescription,
        ClientCode,
        ClientDescription
    )
    select 
        t.[Parent Client Code],
        t.[Parent Client Description],
        t.[Client Code],
        t.[Client Description]
    from
        [db-au-stage]..sungl_excel_client_ind t
    where
        isnull(ltrim(rtrim(t.[Client Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glClients_ind with(tablock) t
        using #glClients_ind s on
            s.ClientCode = t.ClientCode

        when 
            matched and
            binary_checksum(t.ParentClientCode,t.ParentClientDescription,t.ClientDescription,t.DeleteDateTime) <>
            binary_checksum(s.ParentClientCode,s.ParentClientDescription,s.ClientDescription,s.DeleteDateTime) 
        then

            update
            set
                ParentClientCode = s.ParentClientCode,
                ParentClientDescription = s.ParentClientDescription,
                ClientDescription = s.ClientDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ParentClientCode,
                ParentClientDescription,
                ClientCode,
                ClientDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ParentClientCode,
                s.ParentClientDescription,
                s.ClientCode,
                s.ClientDescription,
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
