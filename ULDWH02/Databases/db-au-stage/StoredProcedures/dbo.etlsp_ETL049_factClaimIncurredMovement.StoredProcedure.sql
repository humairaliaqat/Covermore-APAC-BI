USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL049_factClaimIncurredMovement]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[etlsp_ETL049_factClaimIncurredMovement]
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin

--20150722, LS, put in stored procedure

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
    
    select
        @name = object_name(@@procid)

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

    if object_id('[db-au-star].dbo.factClaimIncurredMovement') is null
    begin

        create table [db-au-star].dbo.factClaimIncurredMovement
        (
            [BIRowID] bigint not null identity(1,1),
            [Date_SK] int not null,
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

            [MovementDate] date null,
            
            [ClaimMovementCategory] varchar(10) null,

            [PaymentKey] varchar(40) null,
            [PaymentStatus] varchar(10) null,
            [PaymentType] varchar(10) null,
            [PaymentMonthType] varchar(10) null,
            [PayeeType] varchar(18) null,
            [PayeeSegment] varchar(50) null,
            [ThirdPartyLocation] varchar(13) null,
            [GoodService] varchar(16) null,
            [AuthoredBy] nvarchar(150) null,
            [ApprovedBy] nvarchar(150) null,
            [FirstPaymentLag] int null,
            [PaymentLag] int null,
            [FirstRecoveryLag] int null,
            [PaymentMovement] money,
            [LastModifiedDate] date null,
            [LastPaidAmount] money,
            [LastRecoveryAmount] money,

            [EstimateGroup] varchar(50) null,
            [EstimateCategory] varchar(50) null,
            [EstimateMovement] money,
            [LastEstimate] money,
            [LastRecoveryEstimate] money,

            [CreateBatchID] int
        )

        create clustered index idx_factClaimIncurredMovement_BIRowID on [db-au-star].dbo.factClaimIncurredMovement(BIRowID)
        create nonclustered index idx_factClaimIncurredMovement_ClaimKey on [db-au-star].dbo.factClaimIncurredMovement(ClaimKey)

    end

    /*what has changed during the period*/
    exec etlsp_ETL049_helper_UpdatedClaim
        @StartDate = @start,
        @EndDate = @end
        
    if object_id('etl_UpdatedClaim') is null
        create table etl_UpdatedClaim (ClaimKey varchar(40))

    if object_id('tempdb..#factClaimIncurredMovement') is not null
        drop table #factClaimIncurredMovement

    select *
    into #factClaimIncurredMovement
    from
        [db-au-star]..factClaimIncurredMovement
    where 
        1 = 0

    --estimate movement
    insert into #factClaimIncurredMovement
    (
        [Date_SK],
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
        [MovementDate],
        [EstimateGroup],
        [EstimateCategory],
        [EstimateMovement],
        [LastEstimate],
        [LastRecoveryEstimate]
    )
    select 
        isnull(d.Date_SK, -1) Date_SK,
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
        cem.EstimateDate MovementDate,
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
        EstimateMovement,
        case
            when cs.isDeleted = 1 then 0
            when cem.BIRowID = min(cem.BIRowID) over (partition by cem.Sectionkey) then isnull(cs.EstimateValue, 0)
            else 0
        end LastEstimate,
        case
            when cs.isDeleted = 1 then 0
            when cem.BIRowID = min(cem.BIRowID) over (partition by cem.Sectionkey) then isnull(cs.RecoveryEstimateValue, 0)
            else 0
        end LastRecoveryEstimate
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
                Date_SK
            from
                [db-au-star]..dim_date d with(nolock)
            where
                d.[Date] = cem.EstimateDate
        ) d
        outer apply
        (
            select top 1 
                o.OutletSK,
                o.Country
            from
                [db-au-star]..dimOutlet o with(nolock)
            where
                o.OutletKey = cl.OutletKey and
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
                cs.RecoveryEstimateValue
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

    --payment movement
    insert into #factClaimIncurredMovement
    (
        [Date_SK],
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
        [MovementDate],
        [PaymentKey],
        [PaymentStatus],
        [PaymentType],
        [PaymentMonthType],
        [PayeeType],
        [PayeeSegment],
        [ThirdPartyLocation],
        [GoodService],
        [AuthoredBy],
        [ApprovedBy],
        [FirstPaymentLag],
        [PaymentLag],
        [FirstRecoveryLag],
        [PaymentMovement],
        [LastModifiedDate],
        [LastPaidAmount],
        [LastRecoveryAmount]
    )
    select 
        isnull(d.Date_SK, -1) Date_SK,
        isnull(dd.DomainSK, -1) DomainSK,
        isnull(o.OutletSK, -1) OutletSK,
        isnull(fpt.AreaSK, -1) AreaSK,
        isnull(fpt.ProductSK, -1) ProductSK,
        dcl.ClaimSK,
        isnull(cs.ClaimEventSK, '-1') ClaimEventSK,
        isnull(cs.BenefitSK, '-1') BenefitSK,
        cl.ClaimKey,
        cl.PolicyTransactionKey,
        cpm.SectionKey,
        case
            when cpm.PaymentDate < '2001-01-01' then '2000-01-01'
            else cpm.PaymentDate 
        end MovementDate,
        cpm.PaymentKey,
        isnull(cpm.PaymentStatus, 'Unknown') PaymentStatus,
        case
            when cpm.FirstPayment = 1 then 'Primary'
            else 'Secondary'
        end PaymentType,
        case
            when cpm.FirstMonthPayment = 1 then 'Primary'
            else 'Secondary'
        end PaymentMonthType,
        case
            when cn.isThirdParty = 1 then 'Third Party'
            else 'Private Individual'
        end PayeeType,
        case
            when cn.isThirdParty = 1 then isnull(ns.Segment, 'Unknown')
            else 'Individual'
        end PayeeSegment,
        case
            when cn.isThirdParty = 1 and cp.TPLoc = 'DOM' then 'Domestic'
            when cn.isThirdParty = 1 and cp.TPLoc = 'INT' then 'International'
            when cn.isThirdParty = 1 then 'Unknown'
            else 'N/A'
        end ThirdPartyLocation,
        case
            when cn.isThirdParty = 1 and cp.GoodServ = 'G' then 'Good Supplier'
            when cn.isThirdParty = 1 and cp.GoodServ = 'S' then 'Service Provider'
            when cn.isThirdParty = 1 then 'Unknown'
            else 'N/A'
        end GoodService,
        coalesce(capc.CreatedByName, cpp.CreatedByName, 'Unknown') AuthoredBy,
        coalesce(capa.AuthorisedOfficerName, cpp.AuthorisedOfficerName, 'Unknown') ApprovedBy,
        isnull(FirstPaymentLag, -1) FirstPaymentLag,
        isnull(datediff(d, cl.CreateDate, cpm.PaymentDate), -1) PaymentLag,
        isnull(FirstRecoveryLag, -1) FirstRecoveryLag,
        PaymentMovement,
        case
            when cpp.LastModifiedDate is null then '3000-01-01'
            when cpp.LastModifiedDate < '2001-01-01' then '2000-01-01'
            else cpp.LastModifiedDate
        end LastModifiedDate,
        case
            when cs.isDeleted = 1 then 0
            when cpp.isDeleted = 1 then 0
            when cpm.BIRowID = min(cpm.BIRowID) over (partition by cpm.PaymentKey) then isnull(LastPaidAmount, 0)
            else 0
        end LastPaidAmount,
        case
            when cs.isDeleted = 1 then 0
            when cpp.isDeleted = 1 then 0
            when 
                cpm.PaymentDate = cpp.LastModifiedDate and 
                cpm.PaymentStatus = cpp.LastPaymentStatus and
                cpm.BIRowID = min(cpm.BIRowID) over (partition by cpm.PaymentKey) then isnull(LastRecoveryAmount, 0)
            else 0
        end LastRecoveryAmount
    from
        [db-au-cmdwh]..clmClaimPaymentMovement cpm
        inner join [db-au-cmdwh]..clmClaim cl on
            cl.ClaimKey = cpm.ClaimKey
        cross apply
        (
            select top 1 
                dcl.ClaimSK
            from
                [db-au-star]..dimClaim dcl
            where
                dcl.ClaimKey = cl.ClaimKey
        ) dcl
        cross apply
        (
            select top 1 
                Date_SK
            from
                [db-au-star]..dim_date d with(nolock)
            where
                d.[Date] = cpm.PaymentDate
        ) d
        outer apply
        (
            select top 1 
                o.OutletSK,
                o.Country
            from
                [db-au-star]..dimOutlet o with(nolock)
            where
                o.OutletKey = cl.OutletKey and
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
                cs.isDeleted,
                dce.ClaimEventSK,
                db.BenefitSK
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
            where
                cs.SectionKey = cpm.SectionKey
        ) cs
        outer apply
        (
            select top 1
                PaymentKey,
                PayeeKey,
                TPLoc,
                GoodServ
            from
                [db-au-cmdwh]..clmAuditPayment cap
            where
                cap.PaymentKey = cpm.PaymentKey and
                cap.AuditDateTime >= cpm.PaymentDate and
                cap.AuditDateTime <  dateadd(day, 1, cpm.PaymentDate)
        ) cap
        outer apply
        (
            select top 1
                isDeleted,
                PaymentKey,
                PayeeKey,
                TPLoc,
                GoodServ,
                CreatedByName,
                AuthorisedOfficerName,
                convert(date, ModifiedDate) LastModifiedDate,
                cp.PaymentStatus LastPaymentStatus,
                case
                    when cp.PaymentStatus = 'PAID' then PaymentAmount
                    else 0
                end LastPaidAmount,
                case
                    when cp.PaymentStatus = 'RECY' then PaymentAmount
                    else 0
                end LastRecoveryAmount
            from
                [db-au-cmdwh]..clmPayment cp
            where
                cp.PaymentKey = cpm.PaymentKey
        ) cpp
        outer apply
        (
            select 
                case
                    when cap.PaymentKey is not null then cap.PayeeKey
                    else cpp.PayeeKey
                end PayeeKey,
                case
                    when cap.PaymentKey is not null then cap.TPLoc
                    else cpp.TPLoc
                end TPLoc,
                case
                    when cap.PaymentKey is not null then cap.GoodServ
                    else cpp.GoodServ
                end GoodServ
        ) cp
        outer apply
        (
            select top 1
                isThirdParty
            from
                [db-au-cmdwh]..clmName cn 
            where
                cn.NameKey = cp.PayeeKey
        ) cn
        outer apply
        (
            select top 1 
                CreatedByName
            from
                [db-au-cmdwh]..clmAuditPayment cap
            where
                cap.PaymentKey = cpm.PaymentKey and
                cap.AuditAction = 'I'
        ) capc
        outer apply
        (
            select top 1 
                AuthorisedOfficerName
            from
                [db-au-cmdwh]..clmAuditPayment cap
            where
                cap.PaymentKey = cpm.PaymentKey and
                cap.PaymentStatus = 'APPR'
            order by 
                AuditDateTime
        ) capa
        cross apply
        (
            select top 1 
                datediff(d, cl.CreateDate, r.PaymentDate) FirstPaymentLag
            from
                [db-au-cmdwh]..clmClaimPaymentMovement r
            where
                r.FirstPayment = 1 and
                r.SectionKey = cpm.SectionKey
        ) fpl
        cross apply
        (
            select 
                datediff(d, cl.CreateDate, min(r.PaymentDate)) FirstRecoveryLag
            from
                [db-au-cmdwh]..clmClaimPaymentMovement r
            where
                r.PaymentStatus = 'RECY' and
                r.SectionKey = cpm.SectionKey
        ) frl
        outer apply
        (
            select top 1 
                Segment
            from
                [db-au-cmdwh]..clmPayment cp
                inner join [db-au-cmdwh]..clmName cn on
                    cn.NameKey = cp.PayeeKey
                cross apply
                (
                    select
                        isnull(Firstname, '') + ' ' +
                        isnull(Surname, '') +  ' ' +
                        isnull(AccountName, '') +  ' ' +
                        isnull(BusinessName, '') +  ' ' +
                        isnull(AddressStreet, '') Names
                ) n
                cross apply
                (
                    select
                        case
                            when Names like '%gmmi%' then 'Cost Containment'
                            when Names like '%g e m%' then 'Cost Containment'
                            when Names like '%gem%' then 'Cost Containment'
                            when Names like '%cost contain%' then 'Cost Containment'
                            when Names like '%customer%care%' then 'Assistance Service'
                            when Names like '%assistance%' then 'Assistance Service'
                            when Names like '%AA International%' then 'Assistance Service'
                            when Names like '%medical assist%' then 'Assistance Service'
                            when Names like '%japan assist%' then 'Assistance Service'
                            when Names like '%filo diretto%' then 'Assistance Service'
                            when Names like '%euro%cent%' then 'Assistance Service'
                            when Names like '%hospital%' then 'Medical Service'
                            when Names like '%health%' then 'Medical Service'
                            when Names like '%medical%' then 'Medical Service'
                            when Names like '%clinic%' then 'Medical Service'
                            when Names like '%clinique%' then 'Medical Service'
                            when Names like '%physio%' then 'Medical Service'
                            when Names like '%ambulance%' then 'Medical Service'
                            when Names like '%ambluance%' then 'Medical Service'
                            when Names like '%travmin bangkok%' then 'Medical Service'
                            when Names like 'dr %' then 'Medical Service'
                            when Names like '% dr %' then 'Medical Service'
                            when Names like '%general practice%' then 'Medical Service'
                            when Names like '%physio%' then 'Medical Service'
                            when Names like '%patholo%' then 'Medical Service'
                            when Names like '%radiolo%' then 'Medical Service'
                            when Names like '%koh samui hosp%' then 'Medical Service'
                            when Names like '%rescue%' then 'Emergency'
                            when Names like '%heli%' then 'Emergency'
                            when Names like '%evac%' then 'Emergency'
                            when Names like '%camera%' then 'Electronic'
                            when Names like '%computer%' then 'Electronic'
                            when Names like '%electr%' then 'Electronic'
                            when Names like '%jb hi_fi%' then 'Electronic'
                            when Names like '%jb comm%' then 'Electronic'
                            when Names like '%techhead%' then 'Electronic'
                            when Names like '%harvey%norman%' then 'Electronic'
                            when Names like '%hill%stewart%' then 'Electronic'
                            when Names like '%photo%video%' then 'Electronic'
                            when Names like '%noel leem%' then 'Electronic'
                            when Names like '%Carnival Australia%' then 'Transportation'
                            when Names like '%Carnival plc%' then 'Transportation'
                            when Names like '%aviat%' then 'Transportation'
                            when Names like '%flight%' then 'Transportation'
                            when Names like '%travel%' then 'Transportation'
                            when Names like '%translat%' then 'Translation'
                            when Names like '%lingui%' then 'Translation'
                            when Names like '% ling.%' then 'Translation'
                            when Names like '%language%' then 'Translation'
                            when Names like '%dima tis%' then 'Translation'
                            when Names like '%FOS%' then 'Complaint'
                            when Names like '%ombudsman%' then 'Complaint'
                            when Names like '%centricity%' then 'Investigation'
                            when Names like '%investig%' then 'Investigation'
                            when Names like '%bank%' then 'Financial Service'
                            when Names like '%western union%' then 'Financial Service'
                            when Names like '%custom house%' then 'Financial Service'
                            when Names like '%finance%' then 'Financial Service'
                            when Names like '%barclay%' then 'Financial Service'
                            when Names like '%associates%' then 'Legal Service'
                            when Names like '%legal%' then 'Legal Service'
                            when Names like '%lawyer%' then 'Legal Service'
                            when Names like '%McLarens Young%' then 'Legal Service'
                            when Names like '%N.I.R.S.%' then 'Insurance Service'
                            when Names like '%insurance%' then 'Insurance Service'
                            when Names like '%jewel%' then 'Jewellery'
                            when Names like '%celcom int%' then 'Retail'
                            else 'Unknown'
                        end Segment
                ) ns
            where
                cp.PaymentKey = cpm.PaymentKey
        ) ns
    where
        cl.ClaimKey in
        (
            select 
                ClaimKey
            from
                etl_UpdatedClaim
        )

    --claim movement
    ;with 
    cte_movement as
    (
        select
            ClaimKey,
            PolicyTransactionKey,
            CountryKey,
            OutletKey,
            MovementDate,
            StartingEstimate,
            EndingEstimate
        from
            [db-au-cmdwh]..clmClaim cl
            cross apply
            (
                select distinct
                    dateadd(day, -1, dateadd(month, 1, convert(date, convert(varchar(7), EstimateDate, 120) + '-01'))) MovementDate
                from
                    [db-au-cmdwh]..clmClaimEstimateMovement cem
                where
                    cem.ClaimKey = cl.ClaimKey
            ) cem
            cross apply
            (
                select
                    convert(date, convert(varchar(7), MovementDate, 120) + '-01') StartOfMonth,
                    dateadd(month, 1, convert(date, convert(varchar(7), MovementDate, 120) + '-01')) StartOfNextMonth
            ) cld
            outer apply
            (
                select top 1 
                    clp.Estimate StartingEstimate
                from
                    [db-au-cmdwh]..vclmClaimIncurred clp
                where
                    clp.ClaimKey = cl.ClaimKey and
                    clp.IncurredDate < StartOfMonth
                order by
                    IncurredDate desc
            ) clp
            outer apply
            (
                select top 1 
                    clp.Estimate EndingEstimate
                from
                    [db-au-cmdwh]..vclmClaimIncurred clp
                where
                    clp.ClaimKey = cl.ClaimKey and
                    clp.IncurredDate < StartOfNextMonth
                order by
                    IncurredDate desc
            ) cln
        where
            cl.ClaimKey in
            (
                select
                    Claimkey
                from
                    etl_UpdatedClaim
            )
    ),
    cte_status as
    (
        select 
            ClaimKey,
            PolicyTransactionKey,
            CountryKey,
            OutletKey,
            MovementDate,
            'New' ClaimStatus
        from
            cte_movement
        where
            StartingEstimate is null

        union all

        select 
            ClaimKey,
            PolicyTransactionKey,
            CountryKey,
            OutletKey,
            MovementDate,
            'Reopen' ClaimStatus
        from
            cte_movement
        where
            StartingEstimate = 0 and
            EndingEstimate <> 0

        union all

        select 
            ClaimKey,
            PolicyTransactionKey,
            CountryKey,
            OutletKey,
            MovementDate,
            'Closed' ClaimStatus
        from
            cte_movement
        where
            (
                StartingEstimate is null or
                StartingEstimate <> 0 
            ) and
            EndingEstimate = 0
    ) 
    insert into #factClaimIncurredMovement
    (
        [Date_SK],
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
        [MovementDate],
        [ClaimMovementCategory]
    )
    select 
        isnull(d.Date_SK, -1) Date_SK,
        isnull(dd.DomainSK, -1) DomainSK,
        isnull(o.OutletSK, -1) OutletSK,
        isnull(fpt.AreaSK, -1) AreaSK,
        isnull(fpt.ProductSK, -1) ProductSK,
        dcl.ClaimSK,
        isnull(cs.ClaimEventSK, -1) ClaimEventSK,
        isnull(cs.BenefitSK, -1) BenefitSK,
        cl.ClaimKey,
        cl.PolicyTransactionKey,
        isnull(cs.SectionKey, '') SectionKey,
        cl.MovementDate,
        ClaimStatus
    from
        cte_status cl
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
                Date_SK
            from
                [db-au-star]..dim_date d with(nolock)
            where
                d.[Date] = convert(date, cl.MovementDate)
        ) d
        outer apply
        (
            select top 1 
                o.OutletSK,
                o.Country
            from
                [db-au-star]..dimOutlet o with(nolock)
            where
                o.OutletKey = cl.OutletKey and
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
            select 
                cs.SectionKey,
                dce.ClaimEventSK,
                db.BenefitSK
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
            where
                cs.ClaimKey = cl.ClaimKey
        ) cs

    set @sourcecount = isnull(@sourcecount, 0) + @@rowcount

    begin transaction

    begin try

        delete 
        from
            [db-au-star]..factClaimIncurredMovement
        where
            ClaimKey in
            (
                select
                    ClaimKey
                from
                    etl_UpdatedClaim
            )

        insert into [db-au-star]..factClaimIncurredMovement with(tablock)
        (
            [Date_SK],
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
            [MovementDate],

            [ClaimMovementCategory],

            [PaymentKey],
            [PaymentStatus],
            [PaymentType],
            [PaymentMonthType],
            [PayeeType],
            [PayeeSegment],
            [ThirdPartyLocation],
            [GoodService],
            [AuthoredBy],
            [ApprovedBy],
            [FirstPaymentLag],
            [PaymentLag],
            [FirstRecoveryLag],
            [PaymentMovement],
            [LastModifiedDate],
            [LastPaidAmount],
            [LastRecoveryAmount],

            [EstimateGroup],
            [EstimateCategory],
            [EstimateMovement],
            [LastEstimate],
            [LastRecoveryEstimate],

            [CreateBatchID]
        )
        select
            [Date_SK],
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
            [MovementDate],

            isnull([ClaimMovementCategory], 'Unknown'),

            [PaymentKey],
            isnull([PaymentStatus], 'Unknown'),
            isnull([PaymentType], 'Unknown'),
            isnull([PaymentMonthType], 'Unknown'),
            isnull([PayeeType], 'Unknown'),
            isnull([PayeeSegment], 'Unknown'),
            isnull([ThirdPartyLocation], 'Unknown'),
            isnull([GoodService], 'Unknown'),
            isnull([AuthoredBy], 'Unknown'),
            isnull([ApprovedBy], 'Unknown'),
            isnull([FirstPaymentLag], -1),
            isnull([PaymentLag], -1),
            isnull([FirstRecoveryLag], -1),
            isnull([PaymentMovement], 0),
            isnull([LastModifiedDate], '3000-01-01'),
            isnull([LastPaidAmount], 0),
            isnull([LastRecoveryAmount], 0),

            isnull([EstimateGroup], 'Unknown'),
            isnull([EstimateCategory], 'Unknown'),
            isnull([EstimateMovement], 0),
            isnull([LastEstimate], 0),
            isnull([LastRecoveryEstimate], 0),
            @batchid
        from
            #factClaimIncurredMovement

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
            @SourceInfo = 'factClaimIncurredMovement data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
