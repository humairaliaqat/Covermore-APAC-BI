USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entPhone]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entPhone]
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

    if object_id('[db-au-cmdwh].dbo.entPhone') is null
    begin

        create table [db-au-cmdwh].dbo.entPhone
        (
            BIRowID bigint identity(1,1) not null,
            PhoneID bigint not null,
            CustomerID bigint not null,
            UpdateDate datetime,
            STATUS nvarchar(10),
            SourceSystem nchar(14),
            CountryCode nvarchar(5),
            PhoneNumber nvarchar(25),
            ContactType nvarchar(20),
            UpdateBatchID bigint
        )

        create clustered index idx_entPhone_BIRowID on [db-au-cmdwh].dbo.entPhone(BIRowID)
        create nonclustered index idx_entPhone_CustomerID on [db-au-cmdwh].dbo.entPhone(CustomerID) include(BIRowID,PhoneID,PhoneNumber)
        create nonclustered index idx_entPhone_PhoneNumber on [db-au-cmdwh].dbo.entPhone(PhoneNumber) include(BIRowID,CustomerID)
        create nonclustered index idx_entPhone_PhoneID on [db-au-cmdwh].dbo.entPhone(PhoneID)  include(BIRowID,CustomerID)

    end

    if object_id('tempdb..#entPhone') is not null
        drop table #entPhone

    select 
        try_convert(bigint, rtrim(ROWID_OBJECT)) PhoneID,
        try_convert(bigint, rtrim(PRTY_FK)) CustomerID,
        LAST_UPDATE_DATE UpdateDate,
        STATUS,
        LAST_ROWID_SYSTEM SourceSystem,
        PH_CNTRY_CD CountryCode,
        FULL_PH_VAL PhoneNumber,
        PH_TYP ContactType
    into #entPhone
    from
        ent_C_PARTY_PHONE_aucm


--select
--    COLUMN_NAME + ' ' + DATA_TYPE + isnull('(' + convert(varchar, CHARACTER_MAXIMUM_LENGTH) + ')', '') + ',',
--    COLUMN_NAME + ',',
--    COLUMN_NAME + ' = s.' + COLUMN_NAME + ',',
--    's.' + COLUMN_NAME + ','
--from
--    tempdb.INFORMATION_SCHEMA.COLUMNS
--where
--    table_name like '#entPhone%'

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        --delete 
        --from
        --    [db-au-cmdwh].dbo.entPhone
        --where
        --    CustomerID in
        --    (
        --        select 
        --            try_convert(bigint, rtrim(ORIG_ROWID_OBJECT))
        --        from
        --            ent_vC_PARTY_XREF_aucm
        --    )

        insert into [db-au-cmdwh].dbo.entPhone with(tablock)
        (
            PhoneID,
            CustomerID,
            UpdateDate,
            STATUS,
            SourceSystem,
            CountryCode,
            PhoneNumber,
            ContactType,
            UpdateBatchID
        )
        select
            PhoneID,
            CustomerID,
            UpdateDate,
            STATUS,
            SourceSystem,
            CountryCode,
            PhoneNumber,
            ContactType,
            @batchid
        from
            #entPhone t
        where
            not exists
            (
                select
                    null
                from
                    [db-au-cmdwh]..entPhone r
                where
                    t.PhoneID = r.PhoneID and
                    t.CustomerID = r.CustomerID
            )

        --merge into [db-au-cmdwh].dbo.entPhone with(tablock) t
        --using #entPhone s on
        --    s.PhoneID = t.PhoneID

        --when matched then

        --    update
        --    set
        --        PhoneID = s.PhoneID,
        --        CustomerID = s.CustomerID,
        --        UpdateDate = s.UpdateDate,
        --        STATUS = s.STATUS,
        --        SourceSystem = s.SourceSystem,
        --        CountryCode = s.CountryCode,
        --        PhoneNumber = s.PhoneNumber,
        --        ContactType = s.ContactType,
        --        UpdateBatchID = @batchid

        --when not matched by target then
        --    insert
        --    (
        --        PhoneID,
        --        CustomerID,
        --        UpdateDate,
        --        STATUS,
        --        SourceSystem,
        --        CountryCode,
        --        PhoneNumber,
        --        ContactType,
        --        UpdateBatchID
        --    )
        --    values
        --    (
        --        s.PhoneID,
        --        s.CustomerID,
        --        s.UpdateDate,
        --        s.STATUS,
        --        s.SourceSystem,
        --        s.CountryCode,
        --        s.PhoneNumber,
        --        s.ContactType,
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
            @SourceInfo = 'entPhone data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction


end

GO
