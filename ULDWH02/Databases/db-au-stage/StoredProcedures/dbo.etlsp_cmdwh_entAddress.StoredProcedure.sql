USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entAddress]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entAddress]
as
begin
/*
    20160817, LL, create
    20170118, LL, add min max dates
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

    if object_id('[db-au-cmdwh].dbo.entAddress') is null
    begin

        create table [db-au-cmdwh].dbo.entAddress
        (
            BIRowID bigint identity(1,1) not null,
            AddressID bigint not null,
            CustomerID bigint not null,
            UpdateDate datetime,
            STATUS nvarchar(10),
            SourceSystem nchar(14),
            AddressType nvarchar(20),
            Address nvarchar(511),
            Suburb nvarchar(50),
            State nvarchar(40),
            Country nvarchar(40),
            CountryCode nvarchar(3),
            PostCode nvarchar(10),
            DPID nvarchar(20),
            MinDate date,
            MaxDate date,
            UpdateBatchID bigint
        )

        create clustered index idx_entAddress_BIRowID on [db-au-cmdwh].dbo.entAddress(BIRowID)
        create nonclustered index idx_entAddress_CustomerID on [db-au-cmdwh].dbo.entAddress(CustomerID) include(BIRowID,AddressID,DPID,Address,Suburb,State,Country,PostCode,MinDate,MaxDate)
        create nonclustered index idx_entAddress_AddressID on [db-au-cmdwh].dbo.entAddress(AddressID)  include(BIRowID,CustomerID)
        create nonclustered index idx_entAddress_DPID on [db-au-cmdwh].dbo.entAddress(DPID,SourceSystem)  include(BIRowID,CustomerID)

    end

    if object_id('tempdb..#entAddress') is not null
        drop table #entAddress

    select 
        try_convert(bigint, rtrim(ROWID_OBJECT)) AddressID,
        try_convert(bigint, rtrim(PRTY_FK)) CustomerID,
        LAST_UPDATE_DATE UpdateDate,
        STATUS,
        LAST_ROWID_SYSTEM SourceSystem,
        --ADDR_TYP AddressType,
        '' AddressType,
        isnull(ADDR_LINE1, '') + isnull(' ' + ADDR_LINE2, '') Address,
        CITY Suburb,
        PRVNCE State,
        CNTRY Country,
        CNTRY_CD CountryCode,
        POST_CD PostCode,
        DLVRY_PT_DPID DPID
    into #entAddress
    from
        ent_C_PARTY_ADDRESS_aucm


--select
--    COLUMN_NAME + ' ' + DATA_TYPE + isnull('(' + convert(varchar, CHARACTER_MAXIMUM_LENGTH) + ')', '') + ',',
--    COLUMN_NAME + ',',
--    COLUMN_NAME + ' = s.' + COLUMN_NAME + ',',
--    's.' + COLUMN_NAME + ','
--from
--    tempdb.INFORMATION_SCHEMA.COLUMNS
--where
--    table_name like '#entAddress%'

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        --delete 
        --from
        --    [db-au-cmdwh].dbo.entAddress
        --where
        --    CustomerID in
        --    (
        --        select 
        --            try_convert(bigint, rtrim(ORIG_ROWID_OBJECT))
        --        from
        --            ent_vC_PARTY_XREF_aucm
        --    )

        insert into [db-au-cmdwh].dbo.entAddress
        (
            AddressID,
            CustomerID,
            UpdateDate,
            STATUS,
            SourceSystem,
            AddressType,
            Address,
            Suburb,
            State,
            Country,
            CountryCode,
            PostCode,
            DPID,
            UpdateBatchID
        )
        select
            AddressID,
            CustomerID,
            UpdateDate,
            STATUS,
            SourceSystem,
            AddressType,
            Address,
            Suburb,
            State,
            Country,
            CountryCode,
            PostCode,
            DPID,
            @batchid
        from
            #entAddress t
        where
            not exists
            (
                select
                    null
                from
                    [db-au-cmdwh]..entAddress r
                where
                    t.AddressID = r.AddressID and
                    t.CustomerID = r.CustomerID
            )


        --merge into [db-au-cmdwh].dbo.entAddress with(tablock) t
        --using #entAddress s on
        --    s.AddressID = t.AddressID

        --when matched then

        --    update
        --    set
        --        AddressID = s.AddressID,
        --        CustomerID = s.CustomerID,
        --        UpdateDate = s.UpdateDate,
        --        STATUS = s.STATUS,
        --        SourceSystem = s.SourceSystem,
        --        AddressType = s.AddressType,
        --        Address = s.Address,
        --        Suburb = s.Suburb,
        --        State = s.State,
        --        Country = s.Country,
        --        CountryCode = s.CountryCode,
        --        PostCode = s.PostCode,
        --        DPID = s.DPID,
        --        UpdateBatchID = @batchid

        --when not matched by target then
        --    insert
        --    (
        --        AddressID,
        --        CustomerID,
        --        UpdateDate,
        --        STATUS,
        --        SourceSystem,
        --        AddressType,
        --        Address,
        --        Suburb,
        --        State,
        --        Country,
        --        CountryCode,
        --        PostCode,
        --        DPID,
        --        UpdateBatchID
        --    )
        --    values
        --    (
        --        s.AddressID,
        --        s.CustomerID,
        --        s.UpdateDate,
        --        s.STATUS,
        --        s.SourceSystem,
        --        s.AddressType,
        --        s.Address,
        --        s.Suburb,
        --        s.State,
        --        s.Country,
        --        s.CountryCode,
        --        s.PostCode,
        --        s.DPID,
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


        --update dates
        
        --select top 100 *
        update ea
        set
            MinDate = epp.MinDate,
            MaxDate = epp.MaxDate
        from
            [db-au-cmdwh]..entAddress ea
            cross apply
            (
                select 
                    min(MinDate) MinDate,
                    max(MaxDate) MaxDate
                from
                    [db-au-cmdwh]..entPolicy ep with(nolock)
                    outer apply
                    (
                        select 
                            min(cl.CreateDate) MinDate,
                            max(cl.CreateDate) MaxDate
                        from
                            [db-au-cmdwh]..clmClaim cl with(nolock)
                            inner join [db-au-cmdwh]..clmName cn with(nolock) on
                                cn.ClaimKey = ep.ClaimKey and
                                cn.NameKey = ep.Reference
                        where
                            cl.ClaimKey = ep.ClaimKey and
                            (
                                cn.AddressPostCode = ea.PostCode or
                                cn.AddressSuburb = ea.Suburb
                            )

                        union all

                        select 
                            min(p.IssueDate) MinDate,
                            max(p.IssueDate) MaxDate
                        from
                            [db-au-cmdwh]..entPolicy ep with(nolock)
                            inner join [db-au-cmdwh]..penPolicy p with(nolock) on
                                p.PolicyKey = ep.PolicyKey
                            inner join [db-au-cmdwh]..penPolicyTraveller ptv with(nolock) on
                                ptv.PolicyKey = p.PolicyKey
                        where
                            ep.ClaimKey is null and
                            ep.CustomerID = ea.CustomerID and
                            (
                                ptv.PostCode = ea.PostCode or
                                ptv.Suburb = ea.Suburb
                            )
                    ) d
                where
                    ep.CustomerID = ea.CustomerID
            ) epp
        where
            CustomerID in --= 1032339--4799777
            (
                select 
                    CustomerID
                from
                    #entAddress
            )


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
            @SourceInfo = 'entAddress data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction


end

GO
