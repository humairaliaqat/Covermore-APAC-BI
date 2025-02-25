USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmSection_rollup_backup_26032021]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_cmdwh_clmSection_rollup_backup_26032021]
as
begin

/*
20130305, LS,   TFS 7740, AAA schema changes
20140415, LS,   20728 Refactoring, change to incremental
20140506, LS,   delete based on KLREG
                metadata has been updated to make sure all related tables are at the same base KLREG
20140516, LS,   Online claim bug, null event id handler
20140811, LS,   T12242 Global Claim
                use batch logging
                use merge instead of deleting the whole section in a claim
20141111, LS,   T14092 Claims.Net Global
                add new UK data set
20150223, PW,	F23264 Incorrectly flagging all NZ Global Claims as deleted    
20150224, LS,   F23264, change the deleted flagging
                if audit data exists do not use crude work around (old system)
                audit based flagging moved to audit etl (as in payment)
20150310, LS,   exclude artificial RECY sections from deletion flagging
20150625, LS,   F24838, NZ non-existent KLBENEFIT bug
20160810, LL,   null benefit section causes duplicate records
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

    if object_id('[db-au-cmdwh].dbo.clmSection') is null
    begin

        create table [db-au-cmdwh].dbo.clmSection
        (
            [CountryKey] varchar(2) not null,
            [ClaimKey] varchar(40) not null,
            [SectionKey] varchar(40) not null,
            [EventKey] varchar(40) not null,
            [SectionID] int not null,
            [ClaimNo] int null,
            [EventID] int null,
            [SectionCode] varchar(25) null,
            [EstimateValue] money null,
            [Redundant] bit not null,
            [BenefitSectionKey] varchar(40) null,
            [BenefitSectionID] int null,
            [OriginalBenefitSectionID] int null,
            [BenefitSubSectionID] int null,
            [SectionDescription] nvarchar(200) null,
            [BenefitLimit] nvarchar(200) null,
            [RecoveryEstimateValue] money null,
            [isDeleted] bit not null default 0,
            [BIRowID] int not null identity(1,1),
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        )

        create clustered index idx_clmSection_BIRowID on [db-au-cmdwh].dbo.clmSection(BIRowID)
        create nonclustered index idx_clmSection_ClaimKey on [db-au-cmdwh].dbo.clmSection(ClaimKey) include(CountryKey,SectionKey,SectionID,BenefitSectionKey,EstimateValue,RecoveryEstimateValue,isDeleted,SectionCode,SectionDescription)
        create nonclustered index idx_clmSection_EventKey on [db-au-cmdwh].dbo.clmSection(EventKey) include(CountryKey,SectionKey,SectionID,BenefitSectionKey,EstimateValue,RecoveryEstimateValue,isDeleted,SectionCode,SectionDescription)
        create nonclustered index idx_clmSection_CountryKey on [db-au-cmdwh].dbo.clmSection(CountryKey,SectionID) include(SectionKey)
        create nonclustered index idx_clmSection_SectionKey on [db-au-cmdwh].dbo.clmSection(SectionKey) include(SectionCode,SectionDescription,EstimateValue,RecoveryEstimateValue,BenefitSectionKey)

    end

    if object_id('etl_claims_section') is not null
        drop table etl_claims_section

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) ClaimKey,
        --Online claim bug, null event id handler
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) + '-' + convert(varchar, s.KS_ID) SectionKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) EventKey,
        --AU decommisioned KLBENEFIT work around, AAA schema changes
        case
            when coalesce(b.KBSECT_ID, bfo.BenefitSectionID) is null then dk.CountryKey + '-X' + (isnull(c.KLPRODUCT, '') + isnull(s.KSSECTCODE, '') collate database_default)
            else dk.CountryKey + '-' + convert(varchar, coalesce(b.KBSECT_ID, bfo.BenefitSectionID))
        end BenefitSectionKey,
        s.KS_ID SectionID,
        s.KSCLAIM_ID ClaimNo,
        s.KSEVENT_ID EventID,
        s.KSSECTCODE SectionCode,
        s.KSESTV EstimateValue,
        isnull(s.KSREDUND, 0) Redundant,
        coalesce(b.KBSECT_ID, bfo.BenefitSectionID) BenefitSectionID,
        null OriginalBenefitSectionID,
        s.KBSS_ID BenefitSubSectionID,
        s.KSBENEFITLIMIT BenefitLimit,
        s.KSSECTDESC SectionDescription,
        s.KSRECOVEST RecoveryEstimateValue
    into etl_claims_section
    from
        claims_klsection_au s
        inner join claims_klreg_au c on
            c.KLCLAIM = s.KSCLAIM_ID
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'AU') dk
        /* claims.net bug, kbsect_id is unreliable for claims pre 2011 */
        outer apply
        (
            select top 1
                b.KBSECT_ID
            from
                claims_klbenefit_au b
            where
                b.KBCODE = s.KSSECTCODE and
                b.KBPROD = c.KLPRODUCT and
                b.KLDOMAINID = c.KLDOMAINID
            order by
                b.KBVALIDFROM desc
        ) b
        outer apply
        (
            select top 1
                b.BenefitSectionID
            from
                [db-au-cmdwh]..clmBenefit b
            where
                b.ProductCode = s.KSSECTCODE collate database_default and
                b.ProductCode = c.KLPRODUCT collate database_default and
                b.CountryKey = dk.CountryKey
            order by
                b.BenefitValidFrom desc
        ) bfo

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) ClaimKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) + '-' + convert(varchar, s.KS_ID) SectionKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) EventKey,
        case
            when coalesce(b.KBSECT_ID, bfo.BenefitSectionID) is null then dk.CountryKey + '-X' + (isnull(c.KLPRODUCT, '') + isnull(s.KSSECTCODE, '') collate database_default)
            else dk.CountryKey + '-' + convert(varchar, coalesce(b.KBSECT_ID, bfo.BenefitSectionID))
        end BenefitSectionKey,
        s.KS_ID SectionID,
        s.KSCLAIM_ID ClaimNo,
        s.KSEVENT_ID EventID,
        s.KSSECTCODE SectionCode,
        s.KSESTV EstimateValue,
        isnull(s.KSREDUND, 0) Redundant,
        coalesce(b.KBSECT_ID, bfo.BenefitSectionID) BenefitSectionID,
        null OriginalBenefitSectionID,
        s.KBSS_ID BenefitSubSectionID,
        s.KSBENEFITLIMIT BenefitLimit,
        s.KSSECTDESC SectionDescription,
        s.KSRECOVEST RecoveryEstimateValue
    from
        claims_klsection_uk2 s
        inner join claims_klreg_uk2 c on
            c.KLCLAIM = s.KSCLAIM_ID
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk
        outer apply
        (
            select top 1
                b.KBSECT_ID
            from
                claims_KLBENEFIT_uk2 b
            where
                b.KBCODE = s.KSSECTCODE and
                b.KBPROD = c.KLPRODUCT and
                b.KLDOMAINID = c.KLDOMAINID
            order by
                b.KBVALIDFROM desc
        ) b
        outer apply
        (
            select top 1
                b.BenefitSectionID
            from
                [db-au-cmdwh]..clmBenefit b
            where
                b.ProductCode = s.KSSECTCODE collate database_default and
                b.ProductCode = c.KLPRODUCT collate database_default and
                b.CountryKey = dk.CountryKey
            order by
                b.BenefitValidFrom desc
        ) bfo

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) ClaimKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) + '-' + convert(varchar, s.KS_ID) SectionKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) EventKey,
        dk.CountryKey + '-' + convert(varchar, b.KBSECT_ID) BenefitSectionKey,
        s.KS_ID SectionID,
        s.KSCLAIM_ID ClaimNo,
        s.KSEVENT_ID EventID,
        s.KSSECTCODE SectionCode,
        s.KSESTV EstimateValue,
        isnull(s.KSREDUND, 0) Redundant,
        b.KBSECT_ID BenefitSectionID,
        null OriginalBenefitSectionID,
        s.KBSS_ID BenefitSubSectionID,
        null BenefitLimit,
        null SectionDescription,
        null RecoveryEstimateValue
    from
        claims_klsection_nz s
        inner join claims_klreg_nz c on
            c.KLCLAIM = s.KSCLAIM_ID
        cross apply
        (
            select
                'NZ' CountryKey
        ) dk
        outer apply
        (
            select top 1
                b.KBSECT_ID
            from
                claims_klbenefit_nz b
            where
                b.KBCODE = s.KSSECTCODE and
                b.KBPROD = c.KLPRODUCT and
                b.KBVALIDFROM <= c.KLDISS and
                b.KBVALIDTO >= c.KLDISS
            order by
                b.KBVALIDFROM desc
        ) b

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) ClaimKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) + '-' + convert(varchar, s.KS_ID) SectionKey,
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) EventKey,
        dk.CountryKey + '-' + convert(varchar, b.KBSECT_ID) BenefitSectionKey,
        s.KS_ID SectionID,
        s.KSCLAIM_ID ClaimNo,
        s.KSEVENT_ID EventID,
        s.KSSECTCODE SectionCode,
        s.KSESTV EstimateValue,
        isnull(s.KSREDUND, 0) Redundant,
        b.KBSECT_ID BenefitSectionID,
        null OriginalBenefitSectionID,
        s.KBSS_ID BenefitSubSectionID,
        null BenefitLimit,
        null SectionDescription,
        null RecoveryEstimateValue
    from
        claims_klsection_uk s
        inner join claims_klreg_uk c on
            c.KLCLAIM = s.KSCLAIM_ID
        cross apply
        (
            select
                'UK' CountryKey
        ) dk
        outer apply
        (
            select top 1
                b.KBSECT_ID
            from
                claims_klbenefit_uk b
            where
                b.KBCODE = s.KSSECTCODE and
                b.KBPROD = c.KLPRODUCT and
                b.KBVALIDFROM <= c.KLDISS and
                b.KBVALIDTO >= c.KLDISS
            order by
                b.KBVALIDFROM desc
        ) b

    /* workaround for RECY payment without section */
    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) ClaimKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) + '-' + convert(varchar, isnull(p.KPEVENT_ID, 0)) + 'R' + convert(varchar, p.KPAY_ID) SectionKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) + '-' + convert(varchar, isnull(p.KPEVENT_ID, 0)) EventKey,
        null BenefitSectionKey,
        0 SectionID,
        p.KPCLAIM_ID ClaimNo,
        p.KPEVENT_ID EventID,
        null SectionCode,
        0 EstimateValue,
        0 Redundant,
        null BenefitSectionID,
        null OriginalBenefitSectionID,
        null BenefitSubSectionID,
        null BenefitLimit,
        null SectionDescription,
        null RecoveryEstimateValue
    from
        claims_klpayments_au p
        outer apply
        (
            select top 1
                KLDOMAINID
            from
                claims_KLREG_au c
            where
                c.KLCLAIM = p.KPCLAIM_ID
        ) c
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'AU') dk
    where
        p.KPSTATUS = 'RECY' and
        p.KPIS_ID is null

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) ClaimKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) + '-' + convert(varchar, isnull(p.KPEVENT_ID, 0)) + 'R' + convert(varchar, p.KPAY_ID) SectionKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) + '-' + convert(varchar, isnull(p.KPEVENT_ID, 0)) EventKey,
        null BenefitSectionKey,
        0 SectionID,
        p.KPCLAIM_ID ClaimNo,
        p.KPEVENT_ID EventID,
        null SectionCode,
        0 EstimateValue,
        0 Redundant,
        null BenefitSectionID,
        null OriginalBenefitSectionID,
        null BenefitSubSectionID,
        null BenefitLimit,
        null SectionDescription,
        null RecoveryEstimateValue
    from
        claims_KLPAYMENTS_uk2 p
        outer apply
        (
            select top 1
                KLDOMAINID
            from
                claims_KLREG_uk2 c
            where
                c.KLCLAIM = p.KPCLAIM_ID
        ) c
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk
    where
        p.KPSTATUS = 'RECY' and
        p.KPIS_ID is null

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) ClaimKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) + '-' + convert(varchar, isnull(p.KPEVENT_ID, 0)) + 'R' + convert(varchar, p.KPAY_ID) SectionKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) + '-' + convert(varchar, isnull(p.KPEVENT_ID, 0)) EventKey,
        null BenefitSectionKey,
        0 SectionID,
        p.KPCLAIM_ID ClaimNo,
        p.KPEVENT_ID EventID,
        null SectionCode,
        0 EstimateValue,
        0 Redundant,
        null BenefitSectionID,
        null OriginalBenefitSectionID,
        null BenefitSubSectionID,
        null BenefitLimit,
        null SectionDescription,
        null RecoveryEstimateValue
    from
        claims_klpayments_nz p
        cross apply
        (
            select
                'NZ' CountryKey
        ) dk
    where
        p.KPSTATUS = 'RECY' and
        p.KPIS_ID is null

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) ClaimKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) + '-' + convert(varchar, isnull(p.KPEVENT_ID, 0)) + 'R' + convert(varchar, p.KPAY_ID) SectionKey,
        dk.CountryKey + '-' + convert(varchar, p.KPCLAIM_ID) + '-' + convert(varchar, isnull(p.KPEVENT_ID, 0)) EventKey,
        null BenefitSectionKey,
        0 SectionID,
        p.KPCLAIM_ID ClaimNo,
        p.KPEVENT_ID EventID,
        null SectionCode,
        0 EstimateValue,
        0 Redundant,
        null BenefitSectionID,
        null OriginalBenefitSectionID,
        null BenefitSubSectionID,
        null BenefitLimit,
        null SectionDescription,
        null RecoveryEstimateValue
    from
        claims_KLPAYMENTS_uk p
        cross apply
        (
            select
                'UK' CountryKey
        ) dk
    where
        p.KPSTATUS = 'RECY' and
        p.KPIS_ID is null

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].dbo.clmSection with(tablock) t
        using etl_claims_section s on
            s.SectionKey = t.SectionKey

        when matched then

            update
            set
                ClaimKey = s.ClaimKey,
                EventKey = s.EventKey,
                SectionID = s.SectionID,
                ClaimNo = s.ClaimNo,
                EventID = s.EventID,
                SectionCode = s.SectionCode,
                EstimateValue = s.EstimateValue,
                Redundant = s.Redundant,
                BenefitSectionKey = s.BenefitSectionKey,
                BenefitSectionID = s.BenefitSectionID,
                OriginalBenefitSectionID = s.OriginalBenefitSectionID,
                BenefitSubSectionID = s.BenefitSubSectionID,
                SectionDescription = s.SectionDescription,
                BenefitLimit = s.BenefitLimit,
                RecoveryEstimateValue = s.RecoveryEstimateValue,
                isDeleted = 0,
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                CountryKey,
                ClaimKey,
                SectionKey,
                EventKey,
                SectionID,
                ClaimNo,
                EventID,
                SectionCode,
                EstimateValue,
                Redundant,
                BenefitSectionKey,
                BenefitSectionID,
                OriginalBenefitSectionID,
                BenefitSubSectionID,
                SectionDescription,
                BenefitLimit,
                RecoveryEstimateValue,
                isDeleted,
                CreateBatchID
            )
            values
            (
                s.CountryKey,
                s.ClaimKey,
                s.SectionKey,
                s.EventKey,
                s.SectionID,
                s.ClaimNo,
                s.EventID,
                s.SectionCode,
                s.EstimateValue,
                s.Redundant,
                s.BenefitSectionKey,
                s.BenefitSectionID,
                s.OriginalBenefitSectionID,
                s.BenefitSubSectionID,
                s.SectionDescription,
                s.BenefitLimit,
                s.RecoveryEstimateValue,
                0,
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

        /*this is expensive and need to be removed once NZ & UK moved to Claims.Net (audit table)*/
        /*20150224, can't be removed as there was no data migration for NZ and there wouldn't be data migration for UK*/
        if object_id('tempdb..#deletedsections') is not null
            drop table #deletedsections

        select
            'NZ' CountryKey,
            KS_ID SectionID
        into #deletedsections
        from
            ULSQLSILV04.nzclaims.dbo.KLSECTION

		union

        select
            'UK' CountryKey,
            KS_ID SectionID
        from
            ULSQLSILV04.ukclaims.dbo.KLSECTION

        update cs
        set
            isDeleted = 1,
            UpdateBatchID = @batchid
        from
            [db-au-cmdwh]..clmSection cs
            left join #deletedsections ds on
                ds.CountryKey = cs.CountryKey and
                ds.SectionID = cs.SectionID
        where
            cs.CountryKey in ('NZ', 'UK') and
            ds.SectionID is null and
            isnull(isDeleted, 0) = 0 and
            /*if it's originated from claims.net then parent claim will have at least one audit entry*/
            not exists
            (
                select null
                from
                    [db-au-cmdwh]..clmAuditClaim cac
                where
                    cac.ClaimKey = cs.ClaimKey
            ) and
            /*artificial RECY sections*/
            not
            (
                cs.SectionID = 0 and
                cs.SectionKey like '%-%-%R%'
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
            @SourceInfo = 'clmSection data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
