USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL049_factClaimEstimateMovement]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL049_factClaimEstimateMovement]
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin
--20150722, LS, put in stored procedure
--20180315, SD, Changed reference to penPolicy and joined the tables on OutletAlphaKey

--uncomment to debug
--declare @DateRange varchar(30)
--declare @StartDate date
--declare @EndDate date
--select @DateRange = 'Last 30 Days'

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
    
    set @name = 'etlsp_ETL049_factClaimEstimateMovement'

    /* get dates */
    select
        @start = @StartDate,
        @end = @EndDate

    if @DateRange <> '_User Defined'
        select
            @start = StartDate,
            @end = EndDate
        from
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @DateRange

    /* check if this is running on a batch or standalone */
    begin try
    
        exec syssp_getrunningbatch
            @SubjectArea = 'Claim STAR',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out
        
        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Running'
            
    end try
    
    begin catch
    
        set @batchid = -1
    
    end catch

    if object_id('[db-au-star].dbo.factClaimEstimateMovement') is null
    begin

        create table [db-au-star].dbo.factClaimEstimateMovement
        (
            [BIRowID] bigint not null identity(1,1),
            [AccountingDate] date not null,
            [UnderwritingDate] date not null,
            [DevelopmentDay] bigint not null,
            [DomainSK] int not null,
            [OutletSK] int not null,
            [AreaSK] int not null,
            [ProductSK] int not null,
            [ClaimSK] bigint not null,
            [ClaimEventSK] bigint not null,
            [BenefitSK] bigint not null,
            [ClaimKey] varchar(40) null,
            [PolicyTransactionKey] varchar(41) null,
            [SectionKey] [varchar](40) not null,
            [ClaimSizeType] [varchar](20) null,
            [EstimateGroup] [varchar](50) null,
            [EstimateCategory] [varchar](50) null,
            [PaymentEstimateMovement] money not null default 0,
            [RecoveryEstimateMovement] money not null default 0,
            [CreateBatchID] int
        )

        create clustered index idx_factClaimEstimateMovement_BIRowID on [db-au-star].dbo.factClaimEstimateMovement(BIRowID)
        create nonclustered index idx_factClaimEstimateMovement_ClaimKey on [db-au-star].dbo.factClaimEstimateMovement(ClaimKey)

    end

    /*what has changed during the period*/
    exec etlsp_ETL049_helper_UpdatedClaim
        @StartDate = @start,
        @EndDate = @end
        
    if object_id('etl_UpdatedClaim') is null
        create table etl_UpdatedClaim (ClaimKey varchar(40))


    if object_id('tempdb..#factClaimEstimateMovement') is not null
        drop table #factClaimEstimateMovement

    select 
        cem.EstimateDate [AccountingDate],
        convert(date, isnull(cl.PolicyIssuedDate, cl.CreateDate)) [UnderwritingDate],
        case
            when datediff(day, convert(date, isnull(cl.PolicyIssuedDate, cl.CreateDate)), cem.EstimateDate) < 0 then 0
            else datediff(day, convert(date, isnull(cl.PolicyIssuedDate, cl.CreateDate)), cem.EstimateDate)
        end DevelopmentDay,
        isnull(dd.DomainSK, -1) DomainSK,
        isnull(o.OutletSK, -1) OutletSK,
        isnull(fpt.AreaSK, -1) AreaSK,
        isnull(fpt.ProductSK, -1) ProductSK,
        dcl.ClaimSK,
        isnull(cs.ClaimEventSK, -1) ClaimEventSK,
        isnull(cs.BenefitSK, -1) BenefitSK,
        cl.ClaimKey,
        cl.PolicyTransactionKey,
        cem.SectionKey,
        isnull(cs.Bucket, 'Underlying') ClaimSizeType,
        case
            when EstimateCategory = 'Decreased' then 'Revalued Estimates'
            when EstimateCategory = 'Deleted' then 'Removed Estimates'
            when EstimateCategory = 'Increased' then 'Revalued Estimates'
            when EstimateCategory = 'New' then 'Added Estimates'
            when EstimateCategory = 'Progress on Nil' then 'Added Estimates'
            when EstimateCategory = 'Progress Payment' then 'Revalued Estimates'
            when EstimateCategory = 'Redundant' then 'Removed Estimates'
            when EstimateCategory = 'Reopened' then 'Added Estimates'
            when EstimateCategory = 'Settlement Gain' then 'Estimate Gain/Loss on Settlement'
            when EstimateCategory = 'Settlement Loss' then 'Estimate Gain/Loss on Settlement'
            when EstimateCategory = 'Settlement Nil' then 'Estimate Gain/Loss on Settlement'
            when EstimateCategory = 'Settlement on Nil' then 'Estimate Gain/Loss on Settlement'
        end EstimateGroup,
        case
            when EstimateCategory = 'Decreased' then 'Decreased Estimates'
            when EstimateCategory = 'Deleted' then 'Deleted Estimates'
            when EstimateCategory = 'Increased' then 'Increased Estimates'
            when EstimateCategory = 'New' then 'New Estimates'
            when EstimateCategory = 'Progress on Nil' then 'Progress Payment on Nil'
            when EstimateCategory = 'Progress Payment' then 'Progress Payment'
            when EstimateCategory = 'Redundant' then 'Revised to Zero'
            when EstimateCategory = 'Reopened' then 'Reopend Estimates'
            when EstimateCategory = 'Settlement Gain' then 'Gains on Settlement'
            when EstimateCategory = 'Settlement Loss' then 'Losses on Settlement'
            when EstimateCategory = 'Settlement Nil' then 'Settled for Estimate Value'
            when EstimateCategory = 'Settlement on Nil' then 'Settlement on Nil'
        end EstimateCategory,
        EstimateMovement PaymentEstimateMovement,
        RecoveryEstimateMovement
    into #factClaimEstimateMovement
    from
        [db-au-cmdwh]..clmClaimEstimateMovement cem with(nolock)
        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
            cl.ClaimKey = cem.ClaimKey
        cross apply
        (
            select top 1 
                dcl.ClaimSK
            from
                [db-au-star]..dimClaim dcl
            where
                dcl.ClaimKey = cl.ClaimKey
        ) dcl
        outer apply
        (
            select top 1 
                OutletKey
            from
                [db-au-cmdwh]..penPolicyTransSummary pt
            where
                pt.PolicyTransactionKey = cl.PolicyTransactionKey
        ) opt
        outer apply
        (
            select top 1 
                OutletKey
            from
                [db-au-cmdwh]..penPolicy p
                inner join [db-au-cmdwh]..penOutlet o on
                    o.OutletStatus = 'Current' and
                    o.OutletAlphaKey = p.OutletAlphaKey and
                    o.CountryKey = p.CountryKey
            where
                cl.PolicyTransactionKey is null and
                p.PolicyKey = cl.PolicyKey
        ) op
        outer apply
        (
            select top 1 
                o.OutletSK,
                o.Country
            from
                [db-au-star]..dimOutlet o with(nolock)
            where
                o.OutletKey = isnull(opt.OutletKey, isnull(op.OutletKey, cl.OutletKey)) and
                o.isLatest = 'Y'
        ) o
        outer apply
        (
            select top 1
                DomainSK
            from
                [db-au-star]..dimDomain dd
            where
                dd.CountryCode = cl.CountryKey
        ) dd
        outer apply
        (
            select top 1 
                ProductSK,
                AreaSK
            from
                [db-au-star]..factPolicyTransaction fpt
            where
                fpt.PolicyTransactionKey = cl.PolicyTransactionKey
        ) fpt
        outer apply
        (
            select top 1 
                dce.ClaimEventSK,
                db.BenefitSK,
                isDeleted,
                cs.EstimateValue,
                cs.RecoveryEstimateValue,
                csi.Bucket
            from
                [db-au-cmdwh]..clmSection cs
                outer apply
                (
                    select top 1 
                        dce.ClaimEventSK
                    from
                        [db-au-star]..dimClaimEvent dce
                    where
                        dce.EventKey = cs.EventKey
                ) dce
                outer apply
                (
                    select top 1 
                        BenefitSK
                    from
                        [db-au-cmdwh]..vclmBenefitCategory cb
                        outer apply
                        (
                            select
                                case
                                    when BenefitCategory like '%medical%' then 'Medical'
                                    when BenefitCategory like '%cancel%' then 'Cancellation'
                                    when BenefitCategory like '%luggage%' then 'Luggage'
                                    when BenefitCategory like '%additional%' then 'Additional Expenses'
                                    else 'Other'
                                end BenefitGroup,
                                isnull(BenefitCategory, 'Unknown') BenefitCategory
                        ) b
                        outer apply
                        (
                            select top 1 
                                bg.BenefitSK
                            from
                                [db-au-star]..dimBenefit bg
                            where
                                bg.BenefitCategory = b.BenefitCategory and
                                bg.BenefitGroup = b.BenefitGroup
                        ) bg
                    where
                        cb.BenefitSectionKey = cs.BenefitSectionKey
                ) db
                outer apply
                (
                    select top 1 
                        csi.Bucket
                    from
                        [db-au-cmdwh]..vclmClaimSectionIncurred csi
                    where
                        csi.ClaimKey = cl.ClaimKey and
                        csi.SectionKey = cs.SectionKey
                ) csi
            where
                cs.SectionKey = cem.SectionKey
        ) cs
    where
        cl.ClaimKey in
        (
            select
                Claimkey
            from
                etl_UpdatedClaim
        )

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        delete 
        from
            [db-au-star]..factClaimEstimateMovement
        where
            ClaimKey in
            (
                select
                    ClaimKey
                from
                    etl_UpdatedClaim
            )

        insert into [db-au-star]..factClaimEstimateMovement with(tablock)
        (
            [AccountingDate],
            [UnderwritingDate],
            [DevelopmentDay],
            [DomainSK],
            [OutletSK],
            [AreaSK],
            [ProductSK],
            [ClaimSK],
            [ClaimEventSK],
            [BenefitSK],
            [ClaimKey],
            [PolicyTransactionKey],
            [SectionKey],
            [ClaimSizeType],
            [EstimateGroup],
            [EstimateCategory],
            [PaymentEstimateMovement],
            [RecoveryEstimateMovement],
            [CreateBatchID]
        )
        select
            [AccountingDate],
            [UnderwritingDate],
            [DevelopmentDay],
            [DomainSK],
            [OutletSK],
            [AreaSK],
            [ProductSK],
            [ClaimSK],
            [ClaimEventSK],
            [BenefitSK],
            [ClaimKey],
            [PolicyTransactionKey],
            [SectionKey],
            [ClaimSizeType],
            [EstimateGroup],
            [EstimateCategory],
            [PaymentEstimateMovement],
            [RecoveryEstimateMovement],
            @batchid
        from
            #factClaimEstimateMovement

        set @insertcount = @@rowcount

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
            @SourceInfo = 'factClaimEstimateMovement data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
