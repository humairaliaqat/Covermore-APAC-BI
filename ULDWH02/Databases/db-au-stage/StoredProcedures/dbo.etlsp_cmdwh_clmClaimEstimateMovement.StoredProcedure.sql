USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmClaimEstimateMovement]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_clmClaimEstimateMovement]
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin

--20150722, LS, release to prod
--20151210, LS, for claims with no audit data, create artificial Delete event for delted section
--20160219, LS, store time portion for estimate date
--              handle bad UK estimate histories
--20160412, LS, T22358, handle bad NZ data prior to claims.net
--20160810, LL, flip benefit .. causing duplication bugs
--20170327, LL, addopt actuarial dataset code for online claims
--20170329, LL, further tweaks .. broaden online treatment to all claims
--20181121, LL, align further to actuarial dataset, remove closing after 4 months and modify the e5 closure

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
    /* check if this is running on a batch or standalone */
    if @DateRange <> '_User Defined'
        select
            @StartDate = StartDate,
            @EndDate = EndDate
        from
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @DateRange

    begin try
    
        exec syssp_getrunningbatch
            @SubjectArea = 'Claim ODS',
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

    /* synced rollup with main Claim etl */

    if object_id('etl_clmClaim_sync') is null
        create table etl_clmClaim_sync
        (
            ClaimKey varchar(40) null
        )

    if exists 
    (
        select 
            null 
        from 
            etl_clmClaim_sync 
        where 
            ClaimKey is not null
    )
    begin

        /* prepare created/updated claims to roll up */
        if object_id('etl_clmClaimEstimateMovement') is not null
            drop table etl_clmClaimEstimateMovement

        select
            ClaimKey
        into etl_clmClaimEstimateMovement
        from
            etl_clmClaim_sync

    end

    else
    begin

        /* prepare created/updated claims to roll up */
        if object_id('etl_clmClaimEstimateMovement') is not null
            drop table etl_clmClaimEstimateMovement

        select
            ClaimKey
        into etl_clmClaimEstimateMovement
        from
            [db-au-cmdwh].dbo.clmClaim
        where
            (
                CreateDate >= @StartDate and
                CreateDate <  dateadd(day, 1, @EndDate)
            ) 

        union

        select
            ClaimKey
        from
            [db-au-cmdwh].dbo.clmAuditSection
        where
            AuditDateTime >= @StartDate and
            AuditDateTime <  dateadd(day, 1, @EndDate)

        union

        select
            ClaimKey
        from
            [db-au-cmdwh].dbo.clmEstimateHistory eh
        where
            EHCreateDate >= @StartDate and
            EHCreateDate <  dateadd(day, 1, @EndDate)

    end


    if object_id('[db-au-cmdwh].dbo.clmClaimEstimateMovement') is null
    begin

        create table [db-au-cmdwh].dbo.clmClaimEstimateMovement
        (

            [BIRowID] int not null identity(1,1),
	        [ClaimKey] [varchar](40) not null,
	        [SectionKey] [varchar](40) not null,
	        [BenefitCategory] [varchar](35) not null,
	        [SectionCode] [varchar](25) null,
            [EstimateDate] [date] null,
            [EstimateDateTime] [datetime] null,
            [EstimateDateUTC] [date] null,
            [EstimateCategory] [varchar](20) null,
            [EstimateMovement] decimal(20,6) null,
            [RecoveryEstimateMovement] decimal(20,6) null,
            [PaidOnPeriod] decimal(20,6) null,
            [BatchID] int null
        )

        create clustered index idx_clmClaimEstimateMovement_BIRowID on [db-au-cmdwh].dbo.clmClaimEstimateMovement(BIRowID)
        create nonclustered index idx_clmClaimEstimateMovement_ClaimKey on [db-au-cmdwh].dbo.clmClaimEstimateMovement(ClaimKey,EstimateDate) include(EstimateMovement,BenefitCategory,EstimateCategory,RecoveryEstimateMovement,EstimateDateTime)
        create nonclustered index idx_clmClaimEstimateMovement_SectionKey on [db-au-cmdwh].dbo.clmClaimEstimateMovement(SectionKey,EstimateDate) include(ClaimKey,EstimateMovement,BenefitCategory,EstimateCategory,RecoveryEstimateMovement,EstimateDateTime)
        create nonclustered index idx_clmClaimEstimateMovement_EstimateDate on [db-au-cmdwh].dbo.clmClaimEstimateMovement(EstimateDate,EstimateDateTime) include(ClaimKey,SectionKey,EstimateMovement,RecoveryEstimateMovement)

    end

    /* combine deleted estimates & estimate history */
    if object_id('tempdb..#estimates') is not null
        drop table #estimates

    select
        ClaimKey,
        SectionKey,
        SectionCode,
        dateadd(ms, convert(int, right(BIRowID, 2)), convert(datetime, convert(varchar(10), AuditDateTime, 120) + ' 23:59:59.800')) EstimateDate, --make section deletion to be the last thing to ever happen
        AuditAction,
        case
            when CountryKey = 'AU' then 'AUD'
            when CountryKey = 'NZ' then 'NZD'
            when CountryKey = 'UK' then 'GBP'
            when CountryKey = 'SG' then 'SGD'
            when CountryKey = 'MY' then 'MYR'
            when CountryKey = 'ID' then 'IDR'
            when CountryKey = 'CN' then 'CNY'
            when CountryKey = 'IN' then 'INR'
            when CountryKey = 'US' then 'USD'
            else 'AUD'
        end Currency,
        1.0000 FXRate,
        cast(EstimateValue as decimal(20,6)) EstimateValue,
        cast(isnull(RecoveryEstimateValue, 0) as decimal(20,6)) RecoveryEstimateValue
    into #estimates
    from
        [db-au-cmdwh]..clmAuditSection with(nolock)
    where
        ClaimKey in 
        (
            select 
                ClaimKey
            from
                etl_clmClaimEstimateMovement
        ) and
        CountryKey <> '' and
        AuditAction = 'D'

    union

    select 
        eh.ClaimKey,
        eh.SectionKey,
        isnull(cs.SectionCode, cas.SectionCode) SectionCode,
        ehc.EHCreateDate,
        '' AuditAction,
        case
            when cl.CountryKey = 'AU' then 'AUD'
            when cl.CountryKey = 'NZ' then 'NZD'
            when cl.CountryKey = 'UK' then 'GBP'
            when cl.CountryKey = 'SG' then 'SGD'
            when cl.CountryKey = 'MY' then 'MYR'
            when cl.CountryKey = 'ID' then 'IDR'
            when cl.CountryKey = 'CN' then 'CNY'
            when cl.CountryKey = 'IN' then 'INR'
            when cl.CountryKey = 'US' then 'USD'
            else 'AUD'
        end Currency,
        1.0000 FXRate,
        EHEstimateValue EstimateValue,
        isnull(EHRecoveryEstimateValue, 0) RecoveryEstimateValue
    from
        [db-au-cmdwh]..clmEstimateHistory eh with(nolock)
        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
            cl.ClaimKey = eh.ClaimKey
        --bad UK estimate histories, multiple histories on same date (no time values)
        cross apply
        (
            select
                case
                    when EHCreateDate = convert(date, EHCreateDate) then dateadd(ms, convert(int, right(convert(varchar, eh.EstimateHistoryID), 2)) * 10, EHCreateDate)
                    else EHCreateDate
                end EHCreateDate
        ) ehc
        left join [db-au-cmdwh]..clmSection cs with(nolock) on
            cs.SectionKey = eh.SectionKey
        outer apply
        (
            select top 1 
                cas.SectionCode
            from
                [db-au-cmdwh]..clmAuditSection cas with(nolock)
            where
                cas.SectionKey = eh.SectionKey and
                cas.AuditDateTime < eh.EHCreateDate
            order by
                cas.AuditDateTime desc
        ) cas
    where
        cl.ClaimKey in 
        (
            select 
                ClaimKey
            from
                etl_clmClaimEstimateMovement
        ) and
        cl.CountryKey <> '' and
        (
            cl.CountryKey <> 'NZ' or
            cl.ClaimNo >= 800000
        )

    union

    select 
        eh.ClaimKey,
        eh.SectionKey,
        isnull(cs.SectionCode, cas.SectionCode) SectionCode,
        ehc.EHCreateDate,
        '' AuditAction,
        case
            when cl.CountryKey = 'AU' then 'AUD'
            when cl.CountryKey = 'NZ' then 'NZD'
            when cl.CountryKey = 'UK' then 'GBP'
            when cl.CountryKey = 'SG' then 'SGD'
            when cl.CountryKey = 'MY' then 'MYR'
            when cl.CountryKey = 'ID' then 'IDR'
            when cl.CountryKey = 'CN' then 'CNY'
            when cl.CountryKey = 'IN' then 'INR'
            when cl.CountryKey = 'US' then 'USD'
            else 'AUD'
        end Currency,
        1.0000 FXRate,
        EHEstimateValue EstimateValue,
        isnull(EHRecoveryEstimateValue, 0) RecoveryEstimateValue
    from
        [db-au-cmdwh]..clmEstimateHistory eh with(nolock)
        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
            cl.ClaimKey = eh.ClaimKey
        --bad old NZ estimate histories, ordered by id instead of date
        cross apply
        (
            select
                dateadd(ms, eh.EstimateHistoryID * 100, convert(datetime, convert(date, EHCreateDate))) EHCreateDate
        ) ehc
        left join [db-au-cmdwh]..clmSection cs with(nolock) on
            cs.SectionKey = eh.SectionKey
        outer apply
        (
            select top 1 
                cas.SectionCode
            from
                [db-au-cmdwh]..clmAuditSection cas with(nolock)
            where
                cas.SectionKey = eh.SectionKey and
                cas.AuditDateTime < eh.EHCreateDate
            order by
                cas.AuditDateTime desc
        ) cas
    where
        cl.ClaimKey in 
        (
            select 
                ClaimKey
            from
                etl_clmClaimEstimateMovement
        ) and
        eh.CountryKey = 'NZ' and
        cl.ClaimNo < 800000

    union

    select
        cs.ClaimKey,
        cs.SectionKey,
        cs.SectionCode,
        convert(varchar(10), LastEstimateDate, 120) + ' 23:59:59.900' EstimateDate, --make section deletion to be the last thing to ever happen
        'D' AuditAction,
        case
            when cs.CountryKey = 'AU' then 'AUD'
            when cs.CountryKey = 'NZ' then 'NZD'
            when cs.CountryKey = 'UK' then 'GBP'
            when cs.CountryKey = 'SG' then 'SGD'
            when cs.CountryKey = 'MY' then 'MYR'
            when cs.CountryKey = 'ID' then 'IDR'
            when cs.CountryKey = 'CN' then 'CNY'
            when cs.CountryKey = 'IN' then 'INR'
            when cs.CountryKey = 'US' then 'USD'
            else 'AUD'
        end Currency,
        1.0000 FXRate,
        isnull(LastEstimateValue, 0) EstimateValue,
        isnull(LastRecoveryValue, 0) RecoveryEstimateValue
    from
        [db-au-cmdwh]..clmSection cs with(nolock)
        cross apply
        (
            select top 1
                leh.EHCreateDate LastEstimateDate,
                leh.EHCreateDateTimeUTC LastEstimateDateUTC,
                leh.EHEstimateValue LastEstimateValue,
                leh.EHRecoveryEstimateValue LastRecoveryValue
            from
                [db-au-cmdwh]..clmEstimateHistory leh with(nolock)
            where
                leh.SectionKey = cs.SectionKey
            order by
                leh.EHCreateDate desc
        ) leh
    where
        cs.ClaimKey in 
        (
            select 
                ClaimKey
            from
                etl_clmClaimEstimateMovement
        ) and
        cs.CountryKey <> '' and
        isDeleted = 1 and
        not exists
        (
            select 
                null
            from
                [db-au-cmdwh]..clmAuditSection cas with(nolock)
            where
                cas.SectionKey = cs.SectionKey and
                cas.AuditAction = 'D'
        )

    union

    --always create a record for initial section creation
    select
        cs.ClaimKey,
        cs.SectionKey,
        cs.SectionCode,
        EntryDate EstimateDate,
        'I' AuditAction,
        case
            when cs.CountryKey = 'AU' then 'AUD'
            when cs.CountryKey = 'NZ' then 'NZD'
            when cs.CountryKey = 'UK' then 'GBP'
            when cs.CountryKey = 'SG' then 'SGD'
            when cs.CountryKey = 'MY' then 'MYR'
            when cs.CountryKey = 'ID' then 'IDR'
            when cs.CountryKey = 'CN' then 'CNY'
            when cs.CountryKey = 'IN' then 'INR'
            when cs.CountryKey = 'US' then 'USD'
            else 'AUD'
        end Currency,
        1.0000 FXRate,
        cast(0.000001 as decimal(20,6)) EstimateValue,
        cast(0.000001 as decimal(20,6)) RecoveryEstimateValue
    from
        [db-au-cmdwh]..clmSection cs with(nolock)
        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
            cl.ClaimKey = cs.ClaimKey 
        cross apply
        (
            select 
                min(AuditDateTime) EntryDate
            from
                [db-au-cmdwh]..clmAuditSection cas with(nolock)
            where
                cas.SectionKey = cs.SectionKey and
                cas.AuditAction = 'I'
        ) csa
    where
        cl.ClaimKey in 
        (
            select 
                ClaimKey
            from
                etl_clmClaimEstimateMovement
        ) and
        cs.CountryKey <> '' and
        csa.EntryDate is not null and
        not exists
        (
            select
                null
            from
                [db-au-cmdwh]..clmEstimateHistory ceh with(nolock)
            where
                ceh.SectionKey = cs.SectionKey and
                ceh.EHCreateDate <= csa.EntryDate
        )

    union

    select
        cs.ClaimKey,
        cs.SectionKey,
        cs.SectionCode,
        cl.CreateDate EstimateDate,
        'I' AuditAction,
        case
            when cs.CountryKey = 'AU' then 'AUD'
            when cs.CountryKey = 'NZ' then 'NZD'
            when cs.CountryKey = 'UK' then 'GBP'
            when cs.CountryKey = 'SG' then 'SGD'
            when cs.CountryKey = 'MY' then 'MYR'
            when cs.CountryKey = 'ID' then 'IDR'
            when cs.CountryKey = 'CN' then 'CNY'
            when cs.CountryKey = 'IN' then 'INR'
            when cs.CountryKey = 'US' then 'USD'
            else 'AUD'
        end Currency,
        1.0000 FXRate,
        cast(0.000001 as decimal(20,6)) EstimateValue,
        cast(0.000001 as decimal(20,6)) RecoveryEstimateValue
    from
        [db-au-cmdwh]..clmSection cs with(nolock)
        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
            cl.ClaimKey = cs.ClaimKey 
    where
        cl.ClaimKey in 
        (
            select 
                ClaimKey
            from
                etl_clmClaimEstimateMovement
        ) and
        cs.CountryKey <> '' and
        not exists
        (
            select 
                null
            from
                [db-au-cmdwh]..clmAuditSection cas with(nolock)
            where
                cas.SectionKey = cs.SectionKey and
                cas.AuditAction = 'I'
        ) and
        not exists
        (
            select
                null
            from
                [db-au-cmdwh]..clmEstimateHistory ceh with(nolock)
            where
                ceh.SectionKey = cs.SectionKey and
                ceh.EHCreateDate <= cl.CreateDate
        )

    union

    --create a record for section where the first estimate history is 0
    select
        cs.ClaimKey,
        cs.SectionKey,
        cs.SectionCode,
        convert(date, FirstEstimateDate) EstimateDate,
        'I' AuditAction,
        case
            when cs.CountryKey = 'AU' then 'AUD'
            when cs.CountryKey = 'NZ' then 'NZD'
            when cs.CountryKey = 'UK' then 'GBP'
            when cs.CountryKey = 'SG' then 'SGD'
            when cs.CountryKey = 'MY' then 'MYR'
            when cs.CountryKey = 'ID' then 'IDR'
            when cs.CountryKey = 'CN' then 'CNY'
            when cs.CountryKey = 'IN' then 'INR'
            when cs.CountryKey = 'US' then 'USD'
            else 'AUD'
        end Currency,
        1.0000 FXRate,
        cast(0.000001 as decimal(20,6)) EstimateValue,
        cast(0.000001 as decimal(20,6)) RecoveryEstimateValue
    from
        [db-au-cmdwh]..clmSection cs with(nolock)
        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
            cl.ClaimKey = cs.ClaimKey 
        cross apply
        (
            select top 1
                ceh.EHCreateDate FirstEstimateDate,
                ceh.EHEstimateValue FirstEstimate
            from
                [db-au-cmdwh]..clmEstimateHistory ceh with(nolock)
            where
                ceh.SectionKey = cs.SectionKey 
            order by
                ceh.EHCreateDate
        ) ceh
    where
        cl.ClaimKey in 
        (
            select 
                ClaimKey
            from
                etl_clmClaimEstimateMovement
        ) and
        cs.CountryKey <> '' and
        ceh.FirstEstimate = 0

    union

    --zero the estimate on e5 completion
    --or rejection/merge
    select 
        cs.ClaimKey,
        cs.SectionKey,
        cs.SectionCode,

        --20181121, LL, change to align closer to actuarial rule
        --coalesce(we.FirstComplete, w.LastComplete, wer.FirstReject) EstimateDate,
        isnull(we.FirstComplete, wer.FirstReject) EstimateDate,

        'U' AuditAction,
        case
            when cs.CountryKey = 'AU' then 'AUD'
            when cs.CountryKey = 'NZ' then 'NZD'
            when cs.CountryKey = 'UK' then 'GBP'
            when cs.CountryKey = 'SG' then 'SGD'
            when cs.CountryKey = 'MY' then 'MYR'
            when cs.CountryKey = 'ID' then 'IDR'
            when cs.CountryKey = 'CN' then 'CNY'
            when cs.CountryKey = 'IN' then 'INR'
            when cs.CountryKey = 'US' then 'USD'
            else 'AUD'
        end Currency,
        1.0000 FXRate,
        0 EstimateValue,
        0 RecoveryEstimateValue
    from
        [db-au-cmdwh]..clmSection cs with(nolock)
        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
            cl.ClaimKey = cs.ClaimKey

        --20181121, LL, change to align closer to actuarial rule
        --outer apply
        --(
        --    select top 1
        --        w.CompletionDate LastComplete
        --    from
        --        [db-au-cmdwh]..e5Work w with(nolock)
        --    where
        --        w.ClaimKey = cl.ClaimKey and
        --        w.CreationDate >= convert(date, cl.CreateDate) and
        --        w.WorkType like '%claim%' and
        --        w.WorkType not like '%audit%' and
        --        w.StatusName = 'Complete' and
        --        w.CompletionDate is not null
        --    order by
        --        w.CompletionDate
        --) w
        --outer apply
        --(
        --    select top 1
        --        we.EventDate FirstComplete
        --    from
        --        [db-au-cmdwh]..e5Work w with(nolock)
        --        inner join [db-au-cmdwh]..e5WorkEvent we with(nolock) on
        --            we.Work_ID = w.Work_ID
        --    where
        --        w.ClaimKey = cl.ClaimKey and
        --        w.CreationDate >= convert(date, cl.CreateDate) and
        --        w.WorkType like '%claim%' and
        --        w.WorkType not like '%audit%' and
        --        we.StatusName in ('Complete', 'Rejected')
        --    order by
        --        we.EventDate
        --) we
        --outer apply
        --(
        --    select top 1
        --        we.EventDate FirstReject
        --    from
        --        [db-au-cmdwh]..e5Work w with(nolock)
        --        inner join [db-au-cmdwh]..e5WorkEvent we with(nolock) on
        --            we.Work_ID = w.Work_ID
        --    where
        --        w.ClaimKey = cl.ClaimKey and
        --        w.CreationDate >= convert(date, cl.CreateDate) and
        --        w.WorkType = 'Correspondence' and
        --        we.StatusName = 'Rejected' and
        --        not exists
        --        (
        --            select
        --                null
        --            from
        --                [db-au-cmdwh]..e5Work r with(nolock)
        --            where
        --                r.ClaimKey = cl.ClaimKey and
        --                r.WorkType like '%claim%' and
        --                r.WorkType not like '%audit%'
        --        )
        --    order by
        --        we.EventDate
        --) wer
        outer apply
        (
            select top 1
                we.EventDate FirstComplete
            from
                [db-au-cmdwh]..e5Work w with(nolock)
                inner join [db-au-cmdwh]..e5WorkEvent we with(nolock) on
                    we.Work_ID = w.Work_ID
            where
                w.ClaimKey = cl.ClaimKey and
                w.WorkType like '%claim%' and
                w.WorkType not like '%audit%' and
                we.StatusName in ('Complete', 'Rejected')
            order by
                we.EventDate
        ) we
        outer apply
        (
            select top 1
                we.EventDate FirstReject
            from
                [db-au-cmdwh]..e5Work w with(nolock)
                inner join [db-au-cmdwh]..e5WorkEvent we with(nolock) on
                    we.Work_ID = w.Work_ID
            where
                w.ClaimKey = cl.ClaimKey and
                w.WorkType = 'Correspondence' and
                we.StatusName = 'Rejected' and
                not exists
                (
                    select
                        null
                    from
                        [db-au-cmdwh]..e5Work r with(nolock)
                    where
                        r.ClaimKey = cl.ClaimKey and
                        r.WorkType like '%claim%' and
                        r.WorkType not like '%audit%'
                )
            order by
                we.EventDate
        ) wer

    where
        cl.ClaimKey in 
        (
            select 
                ClaimKey
            from
                etl_clmClaimEstimateMovement
        ) and
        cs.CountryKey <> '' and

        not exists
        (
            select
                null
            from
                [db-au-cmdwh]..clmEstimateHistory ceh with(nolock)
            where
                ceh.ClaimKey = cl.ClaimKey and
                ceh.SectionKey = cs.SectionKey and
                ceh.EHCreateDate >= convert(date, we.FirstComplete) and
                ceh.EHCreateDate <  dateadd(day, 1, convert(date, we.FirstComplete)) and
                ceh.EHEstimateValue = 0
        ) and
        not exists
        (
            select
                null
            from
                [db-au-cmdwh]..clmEstimateHistory ceh with(nolock)
            where
                ceh.SectionKey = cs.SectionKey and
                ceh.EHCreateDate < dateadd(day, 1, convert(date, we.FirstComplete))
        )

    --union

    --20181121, LL, removing this as it's no longer relevant to business practice
    ----zero the estimate for cases older than 4 months with no e5
    --select 
    --    cs.ClaimKey,
    --    cs.SectionKey,
    --    cs.SectionCode,
    --    convert(date, dateadd(month, 4, cl.CreateDate)) EstimateDate,
    --    'U' AuditAction,
    --    case
    --        when cs.CountryKey = 'AU' then 'AUD'
    --        when cs.CountryKey = 'NZ' then 'NZD'
    --        when cs.CountryKey = 'UK' then 'GBP'
    --        when cs.CountryKey = 'SG' then 'SGD'
    --        when cs.CountryKey = 'MY' then 'MYR'
    --        when cs.CountryKey = 'ID' then 'IDR'
    --        when cs.CountryKey = 'CN' then 'CNY'
    --        when cs.CountryKey = 'IN' then 'INR'
    --        when cs.CountryKey = 'US' then 'USD'
    --        else 'AUD'
    --    end Currency,
    --    1.0000 FXRate,
    --    0 EstimateValue,
    --    0 RecoveryEstimateValue
    --from
    --    [db-au-cmdwh]..clmSection cs with(nolock)
    --    inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
    --        cl.ClaimKey = cs.ClaimKey
    --where
    --    cl.ClaimKey in 
    --    (
    --        select 
    --            ClaimKey
    --        from
    --            etl_clmClaimEstimateMovement
    --    ) and
    --    cl.CreateDate < convert(date, dateadd(month, -4, getdate())) and
    --    cs.CountryKey <> '' and
    --    not exists
    --    (
    --        select 
    --            null
    --        from
    --            [db-au-cmdwh]..e5Work w with(nolock)
    --        where
    --            w.ClaimKey = cl.ClaimKey and
    --            w.CreationDate >= convert(date, cl.CreateDate) and
    --            w.WorkType like '%claim%' and
    --            w.WorkType not like '%audit%'
    --    ) and
    --    not exists
    --    (
    --        select
    --            null
    --        from
    --            [db-au-cmdwh]..clmEstimateHistory ceh with(nolock)
    --        where
    --            ceh.SectionKey = cs.SectionKey
    --    )

    create nonclustered index idx on #estimates (SectionKey,EstimateDate desc) include(SectionCode,EstimateValue,RecoveryEstimateValue,AuditAction)
    create nonclustered index idx2 on #estimates (ClaimKey,Sectionkey) include(AuditAction,EstimateValue)

    begin transaction

    begin try
    
        delete 
        from 
            [db-au-cmdwh]..clmClaimEstimateMovement
        where
            ClaimKey in
            (
                select 
                    ClaimKey
                from
                    etl_clmClaimEstimateMovement
            )

        ;with 
        cte_estimate as
        (
            select 
                t.ClaimKey,
                t.SectionKey,
                t.SectionCode,
                t.EstimateDate,
                t.Currency,
                t.FXRate,
                isnull(t.EstimateValue, 0) * f.DeleteFlag EstimateValue,
                isnull(t.RecoveryEstimateValue, 0) * f.DeleteFlag RecoveryEstimateValue,
                t.AuditAction
            from
                #estimates t
                cross apply
                (
                    select
                        case
                            when t.AuditAction = 'D' then 0
                            else 1
                        end DeleteFlag
                ) f
        ),
        cte_movement as
        (
            select 
                t.ClaimKey,
                t.SectionKey,
                t.SectionCode,
                t.EstimateDate,
                t.Currency,
                t.FXRate,
                t.EstimateValue,
                t.RecoveryEstimateValue,
                t.AuditAction,
                isnull(r.PreviousAuditAction, '') PreviousAuditAction,
                isnull(r.PreviousSectionCode, t.SectionCode) PreviousSectionCode,
                isnull(r.PreviousEstimate, 0) PreviousEstimate,
                isnull(r.PreviousRecoveryEstimate, 0) PreviousRecoveryEstimate,
                isnull(cpo.PaidOnPeriod, 0) PaidOnPeriod
            from
                cte_estimate t
                outer apply
                (
                    select top 1 
                        r.AuditAction PreviousAuditAction,
                        r.SectionCode PreviousSectionCode,
                        r.EstimateValue PreviousEstimate,
                        r.RecoveryEstimateValue PreviousRecoveryEstimate,
                        r.EstimateDate PreviousEstimateDate
                    from
                        cte_estimate r
                    where
                        r.SectionKey = t.SectionKey and
                        r.EstimateDate < t.EstimateDate
                    order by
                        Sectionkey,
                        EstimateDate desc
                ) r
                /* get payment movement during the period of previous to current estimate date */
                outer apply
                (
                    select 
                        sum(PaymentMovement) PaidOnPeriod
                    from
                        [db-au-cmdwh]..clmClaimPaymentMovement cpm with(nolock)
                    where
                        cpm.SectionKey = t.SectionKey and
                        cpm.PaymentDate >= r.PreviousEstimateDate and
                        cpm.PaymentDate <  t.EstimateDate
                ) cpo

        ),
        cte_correctedmovement as
        (
            select 
                t.ClaimKey,
                t.SectionKey,
                t.SectionCode,
                t.EstimateDate,
                t.Currency,
                t.FXRate,
                t.EstimateValue,
                t.RecoveryEstimateValue,
                case
                    when t.AuditAction = 'D' then -t.PreviousEstimate
                    when t.SectionCode <> t.PreviousSectionCode then t.EstimateValue
                    else t.EstimateValue - t.PreviousEstimate
                end EstimateMovement,
                case
                    when t.AuditAction = 'D' then -t.PreviousRecoveryEstimate
                    when t.SectionCode <> t.PreviousSectionCode then t.RecoveryEstimateValue
                    else t.RecoveryEstimateValue - t.PreviousRecoveryEstimate
                end RecoveryEstimateMovement,

                --needed for legacy code
                t.PaidOnPeriod,
                t.AuditAction,
                t.PreviousEstimate,
                t.PreviousRecoveryEstimate
            from
                cte_movement t

            union all

            select 
                t.ClaimKey,
                t.SectionKey,
                t.PreviousSectionCode SectionCode,
                dateadd(ms, -10, t.EstimateDate) EstimateDate,
                t.Currency,
                t.FXRate,
                0 EstimateValue,
                0 RecoveryEstimateValue,
                -t.PreviousEstimate EstimateMovement,
                -t.PreviousRecoveryEstimate RecoveryEstimateMovement,

                --needed for legacy code
                t.PaidOnPeriod,
                t.AuditAction,
                t.PreviousEstimate,
                t.PreviousRecoveryEstimate
            from
                cte_movement t
            where
                t.SectionCode <> t.PreviousSectionCode
        )
        insert into [db-au-cmdwh].dbo.clmClaimEstimateMovement
        (
	        ClaimKey,
	        SectionKey,
	        BenefitCategory,
	        SectionCode,
            EstimateDate,
            EstimateDateTime,
            EstimateDateUTC,
            EstimateCategory,
            EstimateMovement,
            RecoveryEstimateMovement,
            PaidOnPeriod,
            BatchID
        )
        select
	        em.ClaimKey,
	        em.SectionKey,
            isnull(cbb.BenefitCategory, 'Unknown'), 
            em.SectionCode,
	        em.EstimateDate,
	        em.EstimateDate,
            dbo.xfn_ConvertLocaltoUTC(em.EstimateDate, dm.TimeZoneCode),
            case
                when em.EstimateDate = min(em.EstimateDate) over (partition by em.ClaimKey) then 'New'
                when em.AuditAction = 'D' then 'Deleted'
                when em.RecoveryEstimateMovement <> 0 then 'Recovery Movement'
                when isnull(em.PaidOnPeriod, 0) = 0 then
                case
                    when PreviousEstimate = 0 and EstimateValue > 0 and em.EstimateDate > min(em.EstimateDate) over (partition by em.ClaimKey) then 'Reopened'
                    when PreviousEstimate > 0 and EstimateValue = 0 then 'Redundant'
                    when PreviousEstimate < EstimateValue then 'Increased'
                    when PreviousEstimate > EstimateValue then 'Decreased'
                    else 'No movement'
                end
                else
                case
                    when PreviousEstimate = 0 and EstimateValue = 0 then 'Settlement on Nil'
                    when PreviousEstimate = 0 and EstimateValue > 0 then 'Progress on Nil'
                    when EstimateValue > 0 then 'Progress Payment'
                    when isnull(PaidOnPeriod, 0) > PreviousEstimate then 'Settlement Loss'
                    when isnull(PaidOnPeriod, 0) < PreviousEstimate then 'Settlement Gain'
                    else 'Settlement Nil'
                end
            end EstimateCategory,
	        EstimateMovement,
	        RecoveryEstimateMovement,
            PaidOnPeriod,
            @batchid
        from
            cte_correctedmovement em
            outer apply
            (
                select top 1 
                    dm.TimeZoneCode
                from
                    [db-au-cmdwh]..penDomain dm
                where
                    dm.CountryKey = left(em.Claimkey, 2)
            ) dm
            outer apply
            (
                select top 1
                    cas.BenefitSectionKey
                from
                    [db-au-cmdwh]..clmAuditSection cas
                where
                    cas.SectionKey = em.SectionKey and
                    cas.AuditDateTime >= convert(date, em.EstimateDate)
                order by
                    cas.AuditDateTime
            ) cas
            outer apply
            (                
                select top 1
                    cs.BenefitSectionKey
                from
                    [db-au-cmdwh]..clmSection cs
                where
                    cs.SectionKey = em.SectionKey
            ) css
            left join [db-au-cmdwh]..vclmBenefitCategory cbb on
                cbb.BenefitSectionKey = isnull(cas.BenefitSectionKey, css.BenefitSectionKey)
        where
            --ClaimKey = 'AU-896394' and
            (
                EstimateMovement <> 0 or
                RecoveryEstimateMovement <> 0
            )


        update cl
        set
            FirstNilDate = ci.FirstNilDate
        from
            [db-au-cmdwh]..clmClaim cl
            cross apply
            (
                select 
                    min(ci.IncurredDate) FirstNilDate
                from
                    [db-au-cmdwh]..[vclmClaimIncurred] ci
                where
                    ci.ClaimKey = cl.ClaimKey and
                    ci.Estimate = 0 and
                    (
                        ci.PreviousEstimate <> 0 or
                        ci.IncurredAge <> 0 or
                        ci.Paid > 0
                    )
            ) ci
        where
            cl.ClaimKey in
            (
                select 
                    ClaimKey
                from
                    etl_clmClaimEstimateMovement
            ) 


    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'clmClaimEstimateMovement data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = -1,
            @PackageID = 'clmClaimEstimateMovement'

    end catch

    if @@trancount > 0
        commit transaction

end

GO
