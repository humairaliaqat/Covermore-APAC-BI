USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Account_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL033_ODS_Account_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load account table
Change History:
                20160506 - LL - created
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

    if object_id('[db-au-cmdwh]..glAccounts_ind') is null
    begin

        create table [db-au-cmdwh]..glAccounts_ind
        (
            BIRowID bigint identity(1,1) not null,
            ParentAccountCode varchar(50),
            AccountCode varchar(50) not null,
            AccountDescription nvarchar(255),
            AccountHierarchyType varchar(200),
            AccountCategory nvarchar(50),
            AccountOperator char(1),
            AccountOrder int,
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx_ind on [db-au-cmdwh]..glAccounts_ind (BIRowID)
        create nonclustered index idx_ind on [db-au-cmdwh]..glAccounts_ind (AccountCode) include (ParentAccountCode,AccountDescription,AccountHierarchyType,AccountCategory,AccountOperator,AccountOrder)
        create nonclustered index idx_parent_ind on [db-au-cmdwh]..glAccounts_ind (ParentAccountCode) include (AccountCode,AccountDescription)

    end

    if object_id('tempdb..#glAccounts_ind') is not null
        drop table #glAccounts_ind

    select *
    into #glAccounts_ind
    from
        [db-au-cmdwh]..glAccounts_ind
    where
        1 = 0

    insert into #glAccounts_ind
    (
        ParentAccountCode,
        AccountCode,
        AccountDescription,
        AccountHierarchyType,
        AccountCategory,
        AccountOperator,
        AccountOrder
    )
    select 
        s.[Parent Account Code],
        s.[Child Account Code],
        s.[Child Account Description],
        s.[Account Hierarchy Type],
        s.[Account Category],
        s.[Account Operator],
        s.[Account Order]
    from
        [db-au-stage]..sungl_excel_account_ind s
    where
        isnull(ltrim(rtrim(s.[Child Account Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glAccounts_ind with(tablock) t
        using #glAccounts_ind s on
            rtrim(s.AccountCode) = rtrim(t.AccountCode)

        when 
            matched and
            binary_checksum(t.ParentAccountCode,t.AccountDescription,t.AccountHierarchyType,t.AccountCategory,t.AccountOperator,t.AccountOrder,t.DeleteDateTime) <>
            binary_checksum(s.ParentAccountCode,s.AccountDescription,s.AccountHierarchyType,s.AccountCategory,s.AccountOperator,s.AccountOrder,s.DeleteDateTime) 
        then

            update
            set
                ParentAccountCode = s.ParentAccountCode,
                AccountDescription = s.AccountDescription,
                AccountHierarchyType = s.AccountHierarchyType,
                AccountCategory = s.AccountCategory,
                AccountOperator = s.AccountOperator,
                AccountOrder = s.AccountOrder,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ParentAccountCode,
                AccountCode,
                AccountDescription,
                AccountHierarchyType,
                AccountCategory,
                AccountOperator,
                AccountOrder,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ParentAccountCode,
                s.AccountCode,
                s.AccountDescription,
                s.AccountHierarchyType,
                s.AccountCategory,
                s.AccountOperator,
                s.AccountOrder,
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
