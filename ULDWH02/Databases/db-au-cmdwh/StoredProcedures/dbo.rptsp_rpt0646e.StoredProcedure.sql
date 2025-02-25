USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0646e]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0646e]
    @Country varchar(2),
    @ReportingPeriod varchar(30),
    @StartDate date = null,
    @EndDate date = null,
    @TimeReference varchar(10) = 'Local'
    
as
begin

--20150522, LS, create
--note: this is actually RPT0664, not RPT0646

--declare
--    @Country varchar(2),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date,
--    @TimeReference varchar(10)
    
--select
--    @Country = 'AU',
--    @ReportingPeriod = 'Current Fiscal Year',
--    @TimeReference = 'Local'

    set nocount on

    declare 
        @start date,
        @end date

    if @ReportingPeriod = '_User Defined' 
        select 
            @start = @StartDate,
            @end = @EndDate
    else
        select 
            @start = StartDate,
            @end = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod

    if object_id('tempdb..#estimate') is not null
        drop table #estimate

    select
        cem.SectionKey,
        cem.BenefitCategory,
        cem.EstimateCategory,
        r.EstimateDate,
        cem.EstimateMovement
    into #estimate
    from
        clmClaimEstimateMovement cem
        inner join clmClaim cl on
            cl.ClaimKey = cem.ClaimKey
        cross apply
        (
            select
                case
                    when @TimeReference = 'Local' then cem.EstimateDate
                    else cem.EstimateDateUTC
                end EstimateDate
        ) r
    where
        cl.CountryKey = @Country and
        (
            (
                @TimeReference = 'Local' and
                (
                    cem.EstimateDate >= @start and
                    cem.EstimateDate <  dateadd(day,1 , @end)
                )
            ) or
            (
                @TimeReference = 'UTC' and
                (
                    cem.EstimateDateUTC >= @start and
                    cem.EstimateDateUTC <  dateadd(day,1 , @end)
                )
            )
        )

    if object_id('tempdb..#aggregate') is not null
        drop table #aggregate

    select 
        convert(date, convert(varchar(7), EstimateDate, 120) + '-01') [EstimateMonth],
        BenefitCategory,
        convert(money, 0) EstimateBalance,
        count(
            distinct
            case
                when EstimateCategory = 'New' then SectionKey
                else null
            end
        ) NewEstimateCount,
        sum(
            case
                when EstimateCategory = 'New' then EstimateMovement
                else 0
            end
        ) NewEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Reopened' then SectionKey
                else null
            end
        ) ReopenedEstimateCount,
        sum(
            case
                when EstimateCategory = 'Reopened' then EstimateMovement
                else 0
            end
        ) ReopenedEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Deleted' then SectionKey
                else null
            end
        ) DeletedEstimateCount,
        sum(
            case
                when EstimateCategory = 'Deleted' then EstimateMovement
                else 0
            end
        ) DeletedEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Redundant' then SectionKey
                else null
            end
        ) RevisedToZeroEstimateCount,
        sum(
            case
                when EstimateCategory = 'Redundant' then EstimateMovement
                else 0
            end
        ) RevisedToZeroEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Increased' then SectionKey
                else null
            end
        ) IncreasedEstimateCount,
        sum(
            case
                when EstimateCategory = 'Increased' then EstimateMovement
                else 0
            end
        ) IncreasedEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Decreased' then SectionKey
                else null
            end
        ) DecreasedEstimateCount,
        sum(
            case
                when EstimateCategory = 'Decreased' then EstimateMovement
                else 0
            end
        ) DecreasedEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Settlement Nil' then SectionKey
                else null
            end
        ) SettledForEstimateEstimateCount,
        sum(
            case
                when EstimateCategory = 'Settlement Nil' then EstimateMovement
                else 0
            end
        ) SettledForEstimateEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Settlement Gain' then SectionKey
                else null
            end
        ) SettledGainEstimateCount,
        sum(
            case
                when EstimateCategory = 'Settlement Gain' then EstimateMovement
                else 0
            end
        ) SettledGainEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Settlement Loss' then SectionKey
                else null
            end
        ) SettledLossEstimateCount,
        sum(
            case
                when EstimateCategory = 'Settlement Loss' then EstimateMovement
                else 0
            end
        ) SettledLossEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Progress Payment' then SectionKey
                else null
            end
        ) ProgressPaymentEstimateCount,
        sum(
            case
                when EstimateCategory = 'Progress Payment' then EstimateMovement
                else 0
            end
        ) ProgressPaymentEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Progress on Nil' then SectionKey
                else null
            end
        ) ProgressOnNilEstimateCount,
        sum(
            case
                when EstimateCategory = 'Progress on Nil' then EstimateMovement
                else 0
            end
        ) ProgressOnNilEstimateValue,
        count(
            distinct
            case
                when EstimateCategory = 'Recovery Movement' then SectionKey
                else null
            end
        ) RecoveryMovementEstimateCount,
        sum(
            case
                when EstimateCategory = 'Recovery Movement' then EstimateMovement
                else 0
            end
        ) RecoveryMovementEstimateValue,
        @start StartDate,
        @end EndDate
    into #aggregate
    from
        #estimate
    group by
        convert(date, convert(varchar(7), EstimateDate, 120) + '-01'),
        BenefitCategory


    insert into #aggregate
    select 
        [Date] [EstimateMonth],
        BenefitCategory,
        EstimateBalance,
        0 NewEstimateCount,
        0 NewEstimateValue,
        0 ReopenedEstimateCount,
        0 ReopenedEstimateValue,
        0 DeletedEstimateCount,
        0 DeletedEstimateValue,
        0 RevisedToZeroEstimateCount,
        0 RevisedToZeroEstimateValue,
        0 IncreasedEstimateCount,
        0 IncreasedEstimateValue,
        0 DecreasedEstimateCount,
        0 DecreasedEstimateValue,
        0 SettledForEstimateEstimateCount,
        0 SettledForEstimateEstimateValue,
        0 SettledGainEstimateCount,
        0 SettledGainEstimateValue,
        0 SettledLossEstimateCount,
        0 SettledLossEstimateValue,
        0 ProgressPaymentEstimateCount,
        0 ProgressPaymentEstimateValue,
        0 ProgressOnNilEstimateCount,
        0 ProgressOnNilEstimateValue,
        0 RecoveryMovementEstimateCount,
        0 RecoveryMovementEstimateValue,
        @start StartDate,
        @end EndDate
    from
        clmClaimEstimateBalance
    where
        @TimeReference = 'Local' and
        CountryKey = @Country and
        [Date] >= @start and
        [Date] <  dateadd(day,1 , @end)

    select *
    from
        #aggregate
    
end




GO
