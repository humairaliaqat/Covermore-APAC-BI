USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmBenefit_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_cmdwh_clmBenefit_rollup]
as
begin
/*
20130305, LS,   TFS 7740, AAA schema changes
20130408, LS,   Online claim's bug (multiple description for one section code), prevent duplicates in clmBenefit
20140506, LS,   change from truncate to delete (klreg & klsection are now incremental)
20140805, LS,   T12242 Global Claim
                use batch logging
20141111, LS,   T14092 Claims.Net Global
                add new UK data set
20150625, LS,   F24838, NZ non-existent KLBENEFIT bug
*/

    set nocount on

    exec etlsp_StagingIndex_Claim

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
        @SubjectArea = 'Claim ODS',
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


    if object_id('[db-au-cmdwh].dbo.clmBenefit') is null
    begin

        create table [db-au-cmdwh].dbo.clmBenefit
        (
            [CountryKey] varchar(2) not null,
            [BenefitSectionKey] varchar(40) null,
            [BenefitSectionID] int not null,
            [BenefitCode] nvarchar(25) null,
            [BenefitDesc] nvarchar(255) null,
            [ProductCode] nvarchar(5) null,
            [BenefitValidFrom] datetime null,
            [BenefitValidTo] datetime null,
            [BenefitLimit] money null,
            [PrintOrder] smallint null,
            [CommonCategory] nvarchar(25) null,
            [BIRowID] bigint not null identity(1,1),
            [CreateDateTime] datetime null,
            [UpdateDateTime] datetime null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        )

        create clustered index idx_clmBenefit_BIRowID on [db-au-cmdwh].dbo.clmBenefit(BIRowID)
        create nonclustered index idx_clmBenefit_BenefitSectionKey on [db-au-cmdwh].dbo.clmBenefit(BenefitSectionKey) include (BenefitCode,BenefitDesc,CountryKey,CommonCategory,ProductCode,BenefitValidFrom,BenefitValidTo,BenefitLimit)
        create nonclustered index idx_clmBenefit_BenefitSectionID on [db-au-cmdwh].dbo.clmBenefit(BenefitSectionID,CountryKey) include (BenefitCode,BenefitDesc,ProductCode,BenefitValidFrom,BenefitValidTo,BenefitLimit)
        create nonclustered index idx_clmBenefit_ProductCode on [db-au-cmdwh].dbo.clmBenefit(ProductCode,BenefitValidFrom,BenefitValidTo) include (BenefitCode,BenefitDesc,BenefitLimit,BenefitSectionKey)

    end

    if object_id('etl_claims_benefit') is not null
        drop table etl_claims_benefit

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, b.KBSECT_ID) collate database_default BenefitSectionKey,
        b.KBSECT_ID BenefitSectionID,
        convert(varchar(25), b.KBCODE) BenefitCode,
        convert(varchar(255), b.KBDESC) BenefitDesc,
        b.KBPROD ProductCode,
        b.KBVALIDFROM BenefitValidFrom,
        b.KBVALIDTO BenefitValidTo,
        b.KBLIMIT BenefitLimit,
        b.KBPRINTORDER PrintOrder,
        null CommonCategory
    into etl_claims_benefit
    from
        claims_klbenefit_au b
        cross apply dbo.fn_GetDomainKeys(b.KLDOMAINID, 'CM', 'AU') dk

    union all

    --AU decommisioned KLBENEFIT work around, AAA schema changes
    select distinct
        dk.CountryKey,
        dk.CountryKey + '-X' + (isnull(c.KLPRODUCT, '') + isnull(s.KSSECTCODE, '')) collate database_default BenefitSectionKey,
        0 BenefitSectionID,
        s.KSSECTCODE BenefitCode,
        min(s.KSSECTDESC) BenefitDesc,
        c.KLPRODUCT ProductCode,
        null BenefitValidFrom,
        null BenefitValidTo,
        null BenefitLimit,
        null PrintOrder,
        null CommonCategory
    from
        claims_klsection_au s
        inner join claims_klreg_au c on
            c.KLCLAIM = s.KSCLAIM_ID
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'AU') dk
        left join claims_klbenefit_au b on
            b.KBPROD = c.KLPRODUCT and
            b.KBCODE = s.KSSECTCODE and
            b.KLDOMAINID = c.KLDOMAINID
    where
        b.KBSECT_ID is null and
        s.KSSECTCODE is not null
    group by
        dk.CountryKey,
        s.KSSECTCODE,
        c.KLPRODUCT
        
    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, b.KBSECT_ID) collate database_default BenefitSectionKey,
        b.KBSECT_ID BenefitSectionID,
        convert(varchar(25), b.KBCODE) BenefitCode,
        convert(varchar(255), b.KBDESC) BenefitDesc,
        b.KBPROD ProductCode,
        b.KBVALIDFROM BenefitValidFrom,
        b.KBVALIDTO BenefitValidTo,
        b.KBLIMIT BenefitLimit,
        b.KBPRINTORDER PrintOrder,
        null CommonCategory
    from
        claims_klbenefit_uk2 b
        cross apply dbo.fn_GetDomainKeys(b.KLDOMAINID, 'CM', 'UK') dk

    union all

    select distinct
        dk.CountryKey,
        dk.CountryKey + '-X' + (isnull(c.KLPRODUCT, '') + isnull(s.KSSECTCODE, '')) collate database_default BenefitSectionKey,
        0 BenefitSectionID,
        s.KSSECTCODE BenefitCode,
        min(s.KSSECTDESC) BenefitDesc,
        c.KLPRODUCT ProductCode,
        null BenefitValidFrom,
        null BenefitValidTo,
        null BenefitLimit,
        null PrintOrder,
        null CommonCategory
    from
        claims_klsection_uk2 s
        inner join claims_klreg_uk2 c on
            c.KLCLAIM = s.KSCLAIM_ID
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk
        left join claims_klbenefit_uk2 b on
            b.KBPROD = c.KLPRODUCT and
            b.KBCODE = s.KSSECTCODE and
            b.KLDOMAINID = c.KLDOMAINID
    where
        b.KBSECT_ID is null and
        s.KSSECTCODE is not null
    group by
        dk.CountryKey,
        s.KSSECTCODE,
        c.KLPRODUCT

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, b.KBSECT_ID) collate database_default BenefitSectionKey,
        b.KBSECT_ID BenefitSectionID,
        b.KBCODE BenefitCode,
        b.KBDESC BenefitDesc,
        b.KBPROD ProductCode,
        b.KBVALIDFROM BenefitValidFrom,
        b.KBVALIDTO BenefitValidTo,
        b.KBLIMIT BenefitLimit,
        b.KBPRINTORDER PrintOrder,
        b.KBCOMMONCATEGORY CommonCategory
    from
        claims_klbenefit_nz b
        cross apply
        (
            select
                'NZ' CountryKey
        ) dk

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, b.KBSECT_ID) collate database_default BenefitSectionKey,
        b.KBSECT_ID BenefitSectionID,
        b.KBCODE BenefitCode,
        b.KBDESC BenefitDesc,
        b.KBPROD ProductCode,
        b.KBVALIDFROM BenefitValidFrom,
        b.KBVALIDTO BenefitValidTo,
        b.KBLIMIT BenefitLimit,
        b.KBPRINTORDER PrintOrder,
        b.KBCOMMONCATEGORY CommonCategory
    from
        claims_klbenefit_uk b
        cross apply
        (
            select
                'UK' CountryKey
        ) dk

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].dbo.clmBenefit with(tablock) t
        using etl_claims_benefit s on
            s.BenefitSectionKey = t.BenefitSectionKey

        when
            matched and
            binary_checksum(
                t.BenefitCode,
                t.BenefitDesc,
                t.ProductCode,
                t.BenefitValidFrom,
                t.BenefitValidTo,
                t.BenefitLimit
            ) <>
            binary_checksum(
                s.BenefitCode,
                s.BenefitDesc,
                s.ProductCode,
                s.BenefitValidFrom,
                s.BenefitValidTo,
                s.BenefitLimit
            )
        then

            update
            set
                BenefitCode = s.BenefitCode,
                BenefitDesc = s.BenefitDesc,
                ProductCode = s.ProductCode,
                BenefitValidFrom = s.BenefitValidFrom,
                BenefitValidTo = s.BenefitValidTo,
                BenefitLimit = s.BenefitLimit,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                CountryKey,
                BenefitSectionKey,
                BenefitSectionID,
                BenefitCode,
                BenefitDesc,
                ProductCode,
                BenefitValidFrom,
                BenefitValidTo,
                BenefitLimit,
                PrintOrder,
                CommonCategory,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.CountryKey,
                s.BenefitSectionKey,
                s.BenefitSectionID,
                s.BenefitCode,
                s.BenefitDesc,
                s.ProductCode,
                s.BenefitValidFrom,
                s.BenefitValidTo,
                s.BenefitLimit,
                s.PrintOrder,
                s.CommonCategory,
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
            @SourceInfo = 'clmBenefit data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end

GO
