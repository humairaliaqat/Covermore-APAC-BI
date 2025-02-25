USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entIdentity]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entIdentity]
as
begin
/*
    20160817, LL, create
*/

    set nocount on

    exec etlsp_StagingIndex_EnterpriseMDM

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
        @SubjectArea = 'EnterpriseMDM ODS',
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

    if object_id('[db-au-cmdwh].dbo.entIdentity') is null
    begin

        create table [db-au-cmdwh].dbo.entIdentity
        (
            BIRowID bigint identity(1,1) not null,
            IdentityID bigint not null,
            CustomerID bigint not null,
            UpdateDate datetime,
            Status nvarchar(50),
            SourceSystem nchar(14),
            IDType nvarchar(20),
            IDSubType nvarchar(70),
            IDValue nvarchar(300),
            UpdateBatchID bigint
        )

        create clustered index idx_entIdentity_BIRowID on [db-au-cmdwh].dbo.entIdentity(BIRowID)
        create nonclustered index idx_entIdentity_CustomerID on [db-au-cmdwh].dbo.entIdentity(CustomerID) include(BIRowID,IdentityID)
        create nonclustered index idx_entIdentity_IdentityID on [db-au-cmdwh].dbo.entIdentity(IdentityID)  include(BIRowID,CustomerID)
        create nonclustered index idx_entIdentity_IDValue on [db-au-cmdwh].dbo.entIdentity(IDValue,IDType)  include(BIRowID,CustomerID)

    end

    if object_id('tempdb..#entIdentity') is not null
        drop table #entIdentity

    select --top 1000
        try_convert(bigint, rtrim(ROWID_OBJECT)) IdentityID,
        try_convert(bigint, rtrim(PRTY_FK)) CustomerID,
        LAST_UPDATE_DATE UpdateDate,
        STATUS,
        LAST_ROWID_SYSTEM SourceSystem,
        IDNTIFR_TYP IDType,
        IDNTIFR_SUB_TYP IDSubType,
        IDNTIFR_VAL IDValue
    into #entIdentity
    from
        ent_C_PARTY_IDENTIFIER_aucm
    where
        IDNTIFR_TYP <> 'Policy Transaction K'


--select
--    COLUMN_NAME + ' ' + DATA_TYPE + isnull('(' + convert(varchar, CHARACTER_MAXIMUM_LENGTH) + ')', '') + ',',
--    COLUMN_NAME + ',',
--    COLUMN_NAME + ' = s.' + COLUMN_NAME + ',',
--    's.' + COLUMN_NAME + ','
--from
--    tempdb.INFORMATION_SCHEMA.COLUMNS
--where
--    table_name like '#entIdentity%'

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        --delete 
        --from
        --    [db-au-cmdwh].dbo.entIdentity
        --where
        --    CustomerID in
        --    (
        --        select 
        --            try_convert(bigint, rtrim(ORIG_ROWID_OBJECT))
        --        from
        --            ent_vC_PARTY_XREF_aucm
        --    )

        insert into [db-au-cmdwh].dbo.entIdentity
        (
            IdentityID,
            CustomerID,
            UpdateDate,
            STATUS,
            SourceSystem,
            IDType,
            IDSubType,
            IDValue,
            UpdateBatchID
        )
        select
            IdentityID,
            CustomerID,
            UpdateDate,
            STATUS,
            SourceSystem,
            IDType,
            IDSubType,
            IDValue,
            @batchid
        from
            #entIdentity t
        where
            not exists
            (
                select
                    null
                from
                    [db-au-cmdwh]..entIdentity r
                where
                    t.IdentityID = r.IdentityID and
                    t.CustomerID = r.CustomerID
            )

        --merge into [db-au-cmdwh].dbo.entIdentity with(tablock) t
        --using #entIdentity s on
        --    s.IdentityID = t.IdentityID

        --when matched then

        --    update
        --    set
        --        IdentityID = s.IdentityID,
        --        CustomerID = s.CustomerID,
        --        UpdateDate = s.UpdateDate,
        --        STATUS = s.STATUS,
        --        SourceSystem = s.SourceSystem,
        --        IDType = s.IDType,
        --        IDSubType = s.IDSubType,
        --        IDValue = s.IDValue,
        --        UpdateBatchID = @batchid

        --when not matched by target then
        --    insert
        --    (
        --        IdentityID,
        --        CustomerID,
        --        UpdateDate,
        --        STATUS,
        --        SourceSystem,
        --        IDType,
        --        IDSubType,
        --        IDValue,
        --        UpdateBatchID
        --    )
        --    values
        --    (
        --        s.IdentityID,
        --        s.CustomerID,
        --        s.UpdateDate,
        --        s.STATUS,
        --        s.SourceSystem,
        --        s.IDType,
        --        s.IDSubType,
        --        s.IDValue,
        --        @batchid
        --    )

        --output $action into @mergeoutput
        --;

        --select
        --    @insertcount =
        --        sum(
        --            case
        --                when MergeAction = 'insert' then 1
        --                else 0
        --            end
        --        ),
        --    @updatecount =
        --        sum(
        --            case
        --                when MergeAction = 'update' then 1
        --                else 0
        --            end
        --        )
        --from
        --    @mergeoutput

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
            @SourceInfo = 'entIdentity data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction


end

GO
