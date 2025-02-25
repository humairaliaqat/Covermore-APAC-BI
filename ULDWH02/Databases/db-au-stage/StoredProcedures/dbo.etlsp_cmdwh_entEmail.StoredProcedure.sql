USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entEmail]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entEmail]
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

    if object_id('[db-au-cmdwh].dbo.entEmail') is null
    begin

        create table [db-au-cmdwh].dbo.entEmail
        (
            BIRowID bigint identity(1,1) not null,
            EmailID bigint not null,
            CustomerID bigint not null,
            UpdateDate datetime,
            STATUS nvarchar(10),
            SourceSystem nchar(14),
            EmailAddress nvarchar(255),
            EmailType nvarchar(20),
            UserAddress nvarchar(255),
            Domain nvarchar(255),
            UpdateBatchID bigint
        )

        create clustered index idx_entEmail_BIRowID on [db-au-cmdwh].dbo.entEmail(BIRowID)
        create nonclustered index idx_entEmail_CustomerID on [db-au-cmdwh].dbo.entEmail(CustomerID) include(BIRowID,EmailID,EmailAddress)
        create nonclustered index idx_entEmail_EmailAddress on [db-au-cmdwh].dbo.entEmail(EmailAddress) include(BIRowID,CustomerID)
        create nonclustered index idx_entEmail_EmailID on [db-au-cmdwh].dbo.entEmail(EmailID)  include(BIRowID,CustomerID)
        create nonclustered index idx_entEmail_UserAddress on [db-au-cmdwh].dbo.entEmail(UserAddress,Domain) include(BIRowID,CustomerID)

    end

    if object_id('tempdb..#entEmail') is not null
        drop table #entEmail

    select 
        try_convert(bigint, rtrim(ROWID_OBJECT)) EmailID,
        try_convert(bigint, rtrim(PRTY_FK)) CustomerID,
        LAST_UPDATE_DATE UpdateDate,
        STATUS,
        LAST_ROWID_SYSTEM SourceSystem,
        isnull(lower(EMAIL_VAL), '') EmailAddress,
        EMAIL_TYP EmailType
    into #entEmail
    from
        ent_C_PARTY_EMAIL_aucm

--select
--    COLUMN_NAME + ' ' + DATA_TYPE + isnull('(' + convert(varchar, CHARACTER_MAXIMUM_LENGTH) + ')', '') + ',',
--    COLUMN_NAME + ',',
--    COLUMN_NAME + ' = s.' + COLUMN_NAME + ',',
--    's.' + COLUMN_NAME + ','
--from
--    tempdb.INFORMATION_SCHEMA.COLUMNS
--where
--    table_name like '#entEmail%'

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        --delete 
        --from
        --    [db-au-cmdwh].dbo.entEmail
        --where
        --    CustomerID in
        --    (
        --        select 
        --            try_convert(bigint, rtrim(ORIG_ROWID_OBJECT))
        --        from
        --            ent_vC_PARTY_XREF_aucm
        --    )

        insert into [db-au-cmdwh].dbo.entEmail
        (
            EmailID,
            CustomerID,
            UpdateDate,
            STATUS,
            SourceSystem,
            EmailAddress,
            EmailType,
            UserAddress,
            Domain,
            UpdateBatchID
        )
        select
            EmailID,
            CustomerID,
            UpdateDate,
            STATUS,
            SourceSystem,
            EmailAddress,
            EmailType,
            replace
            (
                case
                    when charindex('+', EmailAddress) > 0 then substring(EmailAddress, 1, charindex('+', EmailAddress) - 1) 
                    else substring(EmailAddress, 1, charindex('@', EmailAddress) - 1) 
                end,
                '.',
                ''
            ) UserAddress,
            substring(EmailAddress, charindex('@', EmailAddress) + 1, len(EmailAddress) - charindex('@', EmailAddress)) Domain,
            @batchid
        from
            #entEmail t
        where
            not exists
            (
                select
                    null
                from
                    [db-au-cmdwh]..entEmail r
                where
                    t.EmailID = r.EmailID and
                    t.CustomerID = r.CustomerID
            )


        --merge into [db-au-cmdwh].dbo.entEmail with(tablock) t
        --using #entEmail s on
        --    s.EmailID = t.EmailID

        --when matched then

        --    update
        --    set
        --        EmailID = s.EmailID,
        --        CustomerID = s.CustomerID,
        --        UpdateDate = s.UpdateDate,
        --        STATUS = s.STATUS,
        --        SourceSystem = s.SourceSystem,
        --        EmailAddress = s.EmailAddress,
        --        EmailType = s.EmailType,
        --        UpdateBatchID = @batchid

        --when not matched by target then
        --    insert
        --    (
        --        EmailID,
        --        CustomerID,
        --        UpdateDate,
        --        STATUS,
        --        SourceSystem,
        --        EmailAddress,
        --        EmailType,
        --        UpdateBatchID
        --    )
        --    values
        --    (
        --        s.EmailID,
        --        s.CustomerID,
        --        s.UpdateDate,
        --        s.STATUS,
        --        s.SourceSystem,
        --        s.EmailAddress,
        --        s.EmailType,
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
            @SourceInfo = 'entEmail data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction


end

GO
