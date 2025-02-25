USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_Account]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL033_STAR_Account]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160512
Prerequisite:   
Description:    load account dimension
Change History:
                20160512 - LL - created
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

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-star]..Dim_Account') is null
    begin

        create sequence dbo.AccountSID
            start with 1
            increment by 1

        create table [db-au-star]..Dim_Account
        (
            [Account_SK] int not null identity(1,1),
            [Account_CODE] varchar(50) not null,
            [Account_Desc] varchar(200) null,
            [Account_Operator] varchar(50) not null,
            [Account_Order] int not null,
            [Account_Hierarchy_Type] varchar(200) null,
            [Parent_Account_SK] int null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null,
            [Account_Category] varchar(200) null,
            [Account_SID] int not null default (next value for dbo.AccountSID),
            FIPAccount varchar(50),
            SAPPE3Account varchar(50),
            FIPTOB varchar(50),
            SAPTOB varchar(50),
            TOM varchar(50),
            AccountType varchar(5),
            StatutoryMapping nvarchar(255),
            InternalMapping nvarchar(255),
            Technical varchar(5),
            Intercompany varchar(5)        
        )

        create clustered index Dim_Account_PK on [db-au-star].dbo.Dim_Account(Account_SK)
        create nonclustered index idx_Account_Code on [db-au-star].dbo.Dim_Account(Account_CODE,Account_Hierarchy_Type) include (Account_SK,Account_Desc,Account_Order,Parent_Account_SK,Account_SID)
        create nonclustered index idx_Account_SK on [db-au-star].dbo.Dim_Account(Account_SK) include (Account_CODE,Account_Desc,Account_Order,Parent_Account_SK)
        create nonclustered index idx_Parent_Account on [db-au-star].dbo.Dim_Account(Parent_Account_SK) include (Account_SK,Account_CODE,Account_Desc,Account_Order)
        create nonclustered index IX02_Dim_Account on [db-au-star].dbo.Dim_Account(Account_SID)

        set identity_insert [db-au-star]..Dim_Account on

        insert into [db-au-star]..Dim_Account
        (
            [Account_SK],
            [Account_CODE],
            [Account_Desc],
            [Account_Operator],
            [Account_Order],
            [Account_Hierarchy_Type],
            [Parent_Account_SK],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID],
            [Account_Category],
            [Account_SID]
        )
        select
            -1 [Account_SK],
            'UNKNOWN' [Account_CODE],
            'UNKNOWN' [Account_Desc],
            'UNKNOWN' [Account_Operator],
            0 [Account_Order],
            'UNKNOWN' [Account_Hierarchy_Type],
            null [Parent_Account_SK],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID],
            'UNKNOWN' [Account_Category],
            -1 [Account_SID]

        set identity_insert [db-au-star]..Dim_Account off

    end

    if object_id('tempdb..#Dim_Account') is not null
        drop table #Dim_Account

    select *
    into #Dim_Account
    from
        [db-au-star]..Dim_Account
    where
        1 = 0

    insert into #Dim_Account
    (
        [Account_CODE],
        [Account_Desc],
        [Account_Operator],
        [Account_Order],
        [Account_Hierarchy_Type],
        [Parent_Account_SK],
        [Account_SID],
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
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.AccountCode,
        s.AccountDescription,
        s.AccountOperator,
        s.AccountOrder,
        s.AccountHierarchyType,
        case
            when isnull(s.ParentAccountCode, '') = '' then 0
            else isnull(p.Account_SK, -1)
        end,
        -1,
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
        getdate(),
        -1
    from
        [db-au-cmdwh]..glAccounts s
        outer apply
        (
            select top 1 
                Account_SK
            from
                [db-au-star]..Dim_Account p
            where
                p.Account_CODE = s.ParentAccountCode
        ) p

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_Account with(tablock) t
        using #Dim_Account s on
            rtrim(s.[Account_CODE]) = rtrim(t.[Account_CODE])

        when 
            matched and
            binary_checksum
                (
                    t.[Account_Desc],
                    t.[Account_Operator],
                    t.[Account_Order],
                    t.[Account_Hierarchy_Type],
                    t.[Parent_Account_SK],
                    t.FIPAccount,
                    t.SAPPE3Account,
                    t.FIPTOB,
                    t.SAPTOB,
                    t.TOM,
                    t.AccountType,
                    t.StatutoryMapping,
                    t.InternalMapping,
                    t.Technical,
                    t.Intercompany
                ) <>
            binary_checksum
                (
                    s.[Account_Desc],
                    s.[Account_Operator],
                    s.[Account_Order],
                    s.[Account_Hierarchy_Type],
                    s.[Parent_Account_SK],
                    s.FIPAccount,
                    s.SAPPE3Account,
                    s.FIPTOB,
                    s.SAPTOB,
                    s.TOM,
                    s.AccountType,
                    s.StatutoryMapping,
                    s.InternalMapping,
                    s.Technical,
                    s.Intercompany
                ) 
        then

            update
            set
                [Account_Desc] = s.[Account_Desc],
                [Account_Operator] = s.[Account_Operator],
                [Account_Order] = s.[Account_Order],
                [Account_Hierarchy_Type] = s.[Account_Hierarchy_Type],
                [Parent_Account_SK] = s.[Parent_Account_SK],
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
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Account_CODE],
                [Account_Desc],
                [Account_Operator],
                [Account_Order],
                [Account_Hierarchy_Type],
                [Parent_Account_SK],
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
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Account_CODE],
                s.[Account_Desc],
                s.[Account_Operator],
                s.[Account_Order],
                s.[Account_Hierarchy_Type],
                s.[Parent_Account_SK],
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
