USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Account]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL033_ODS_Account]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160506
Prerequisite:   
Description:    load account table
Change History:
                20160506 - LL - created
                20180517 - LL - add Zurich mapping
    
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

    if object_id('[db-au-cmdwh]..glAccounts') is null
    begin

        create table [db-au-cmdwh]..glAccounts
        (
            BIRowID bigint identity(1,1) not null,
            ParentAccountCode varchar(50),
            AccountCode varchar(50) not null,
            AccountDescription nvarchar(255),
            AccountHierarchyType varchar(200),
            AccountCategory nvarchar(50),
            AccountOperator char(1),
            AccountOrder int,
            FIPAccount varchar(50),
            SAPPE3Account varchar(50),
            FIPTOB varchar(50),
            SAPTOB varchar(50),
            TOM varchar(50),
            AccountType varchar(5),
            StatutoryMapping nvarchar(255),
            InternalMapping nvarchar(255),
            Technical varchar(5),
            Intercompany varchar(5),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx on [db-au-cmdwh]..glAccounts (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glAccounts (AccountCode) include (ParentAccountCode,AccountDescription,AccountHierarchyType,AccountCategory,AccountOperator,AccountOrder)
        create nonclustered index idx_parent on [db-au-cmdwh]..glAccounts (ParentAccountCode) include (AccountCode,AccountDescription)

    end

    if object_id('tempdb..#glAccounts') is not null
        drop table #glAccounts

    select *
    into #glAccounts
    from
        [db-au-cmdwh]..glAccounts
    where
        1 = 0

    insert into #glAccounts
    (
        ParentAccountCode,
        AccountCode,
        AccountDescription,
        AccountHierarchyType,
        AccountCategory,
        AccountOperator,
        AccountOrder,
        FIPAccount,
        SAPPE3Account,
        FIPTOB,
        SAPTOB,
        TOM,
        AccountType,
        StatutoryMapping,
        InternalMapping,
        Technical,
        Intercompany
    )
    select 
        s.[Parent Account Code],
        s.[Child Account Code],
        s.[Child Account Description],
        s.[Account Hierarchy Type],
        s.[Account Category],
        s.[Account Operator],
        s.[Account Order],
        s.[FIP Account],
        convert(bigint, s.[SAP PE3 Account]),
        s.[FIP TOB],
        convert(bigint, s.[SAP TOB]),
        s.[TOM],
        s.[Account Type],
        s.[Statutory Mapping],
        s.[Internal Mapping],
        s.[Technical],
        s.[Intercompany]
    from
        [db-au-stage]..sungl_excel_account s
    where
        isnull(ltrim(rtrim(s.[Child Account Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glAccounts with(tablock) t
        using #glAccounts s on
            rtrim(s.AccountCode) = rtrim(t.AccountCode)

        when 
            matched and
            binary_checksum
                (
                    t.ParentAccountCode,
                    t.AccountDescription,
                    t.AccountHierarchyType,
                    t.AccountCategory,
                    t.AccountOperator,
                    t.AccountOrder,
                    t.FIPAccount,
                    t.SAPPE3Account,
                    t.FIPTOB,
                    t.SAPTOB,
                    t.TOM,
                    t.AccountType,
                    t.StatutoryMapping,
                    t.InternalMapping,
                    t.Technical,
                    t.Intercompany,
                    t.DeleteDateTime
                ) <>
            binary_checksum
                (
                    s.ParentAccountCode,
                    s.AccountDescription,
                    s.AccountHierarchyType,
                    s.AccountCategory,
                    s.AccountOperator,
                    s.AccountOrder,
                    s.FIPAccount,
                    s.SAPPE3Account,
                    s.FIPTOB,
                    s.SAPTOB,
                    s.TOM,
                    s.AccountType,
                    s.StatutoryMapping,
                    s.InternalMapping,
                    s.Technical,
                    s.Intercompany,
                    s.DeleteDateTime
                ) 
        then

            update
            set
                ParentAccountCode = s.ParentAccountCode,
                AccountDescription = s.AccountDescription,
                AccountHierarchyType = s.AccountHierarchyType,
                AccountCategory = s.AccountCategory,
                AccountOperator = s.AccountOperator,
                AccountOrder = s.AccountOrder,
                FIPAccount = s.FIPAccount,
                SAPPE3Account = s.SAPPE3Account,
                FIPTOB = s.FIPTOB,
                SAPTOB = s.SAPTOB,
                TOM = s.TOM,
                AccountType = s.AccountType,
                StatutoryMapping = s.StatutoryMapping,
                InternalMapping = s.InternalMapping,
                Technical = s.Technical,
                Intercompany = s.Intercompany,
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
                FIPAccount,
                SAPPE3Account,
                FIPTOB,
                SAPTOB,
                TOM,
                AccountType,
                StatutoryMapping,
                InternalMapping,
                Technical,
                Intercompany,
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
                s.FIPAccount,
                s.SAPPE3Account,
                s.FIPTOB,
                s.SAPTOB,
                s.TOM,
                s.AccountType,
                s.StatutoryMapping,
                s.InternalMapping,
                s.Technical,
                s.Intercompany,
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


    --SAP master
    if object_id('[db-au-cmdwh]..glSAPAccounts') is null
    begin

        create table [db-au-cmdwh]..glSAPAccounts
        (
            BIRowID bigint identity(1,1) not null,
            AccountCode varchar(50),
            AccountDescription varchar(255),
            GroupAccountNumber varchar(50)
        )

        create clustered index cidx on [db-au-cmdwh]..glSAPAccounts (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glSAPAccounts (AccountCode) include (AccountDescription,GroupAccountNumber)

    end

    merge into [db-au-cmdwh]..glSAPAccounts  t
    using [db-au-stage]..sungl_excel_sap s on
        rtrim(s.[SAP PE3 Account]) = rtrim(t.AccountCode)

    when matched 
    then

        update
        set
            AccountDescription = s.[SAP PE3 Account Description],
            GroupAccountNumber = s.[Group account number]

    when not matched by target then
        insert
        (
            AccountCode,
            AccountDescription,
            GroupAccountNumber
        )
        values
        (
            s.[SAP PE3 Account],
            s.[SAP PE3 Account Description],
            s.[Group account number]
        )
    ;

    --Zurich TOM master
    if object_id('[db-au-cmdwh]..glTOMAccounts') is null
    begin

        create table [db-au-cmdwh]..glTOMAccounts
        (
            BIRowID bigint identity(1,1) not null,
            TOMCode varchar(50),
            TOMDescription varchar(255),
            TOMSET varchar(50),
            TOMKey varchar(50)
        )

        create clustered index cidx on [db-au-cmdwh]..glTOMAccounts (BIRowID)
        create nonclustered index idx_code on [db-au-cmdwh]..glTOMAccounts (TOMCode) include (TOMDescription,TOMSET)
        create nonclustered index idx_key on [db-au-cmdwh]..glTOMAccounts (TOMKey) include (TOMCode)

    end

    truncate table [db-au-cmdwh]..glTOMAccounts

    insert into [db-au-cmdwh]..glTOMAccounts
    (
        TOMCode,
        TOMDescription,
        TOMSET,
        TOMKey
    )
    select
        s.[TOM],
        s.[TOM Description],
        s.[TOM SET],
        s.[TOM KEY]
    from
        [db-au-stage]..sungl_excel_tom s


end

GO
