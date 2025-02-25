USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_claimcloserate]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_dashboard_claimcloserate]
as
begin

    declare @lastrun datetime

    if object_id('[db-au-workspace]..live_dashboard_claims_closerate') is null
        create table [db-au-workspace]..live_dashboard_claims_closerate
        (
            CloseDate date,
            ClosedClaimCount int,
            Closed1Week int,
            Closed2Week int,
            FYTDFlag bit,
            MTDFlag bit,
            WTDFlag bit,
            UpdateTime datetime not null default(getdate())
        )

    select
        @lastrun = min(UpdateTime)
    from
        [db-au-workspace]..live_dashboard_claims_closerate

    --refresh just once a day
    if @lastrun is null or @lastrun < convert(date, getdate())
    begin
        
        truncate table [db-au-workspace]..live_dashboard_claims_closerate

        ;with cte_closed_rtm as
        (
            select 
                cl.ClaimNo,
                convert(date, isnull(InsertDateTime, cl.CreateDate)) CreateDate,
                IncurredDate CloseDate,
                datediff(day, convert(date, isnull(InsertDateTime, cl.CreateDate)), IncurredDate) ClosedDays,
                datediff(day, convert(date, isnull(InsertDateTime, cl.CreateDate)), IncurredDate) - isnull(OffDays, 0) ClosedBusinessDays
            from
                clmClaim cl
                inner join vclmClaimIncurred ci on
                    ci.ClaimKey = cl.ClaimKey
                outer apply
                (
                    select 
                        count([Date]) OffDays
                    from
                        Calendar d
                    where
                        d.[Date] >= convert(date, cl.CreateDate) and
                        d.[Date] <  dateadd(day, 1, IncurredDate) and
                        (
                            d.isHoliday = 1 or
                            d.isWeekEnd = 1
                        )
                ) ph
                --claim utc bug
                outer apply
                (
                    select top 1 
                        AuditDateTime InsertDateTime
                    from
                        clmAuditClaim cac
                    where
                        cl.CreateDate >= '2014-10-01' and
                        cl.CreateDate <  '2014-12-18' and
                        cac.ClaimKey = cl.ClaimKey and
                        cac.AuditAction = 'I'
                ) cd
            where
                cl.CountryKey = 'AU' and
                IncurredDate >= dateadd(month, -12, convert(varchar(8), getdate(), 120) + '01') and
                IncurredDate <  convert(date, getdate()) and
                (
                    --closed
                    (
                        ci.Estimate = 0 and
                        (
                            ci.PreviousEstimate <> 0 or
                            ci.RedundantMovements > 0
                        )
                    ) 
                )
        )
        insert into [db-au-workspace]..live_dashboard_claims_closerate
        (
            CloseDate,
            ClosedClaimCount,
            Closed1Week,
            Closed2Week,
            FYTDFlag,
            MTDFlag,
            WTDFlag
        )
        select 
            CloseDate,
            --convert(date, convert(varchar(8), CloseDate, 120) + '01') CloseMonth,
            count(distinct ClaimNo) ClosedClaimCount,
            count(
                distinct
                case
                    when ClosedBusinessDays <= 5 then ClaimNo
                    else null
                end
            ) Closed1Week,
            count(
                distinct
                case
                    when ClosedBusinessDays <= 10 then ClaimNo
                    else null
                end
            ) Closed2Week,
            case
                when CloseDate >= d.CurFiscalYearStart then 1
                else 0
            end FYTDFlag,
            case
                when CloseDate >= d.CurMonthStart then 1
                else 0
            end MTDFlag,
            case
                when CloseDate >= d.CurWeekStart then 1
                else 0
            end WTDFlag
        from
            cte_closed_rtm t
            cross apply
            (
                select top 1
                    CurFiscalYearStart,
                    CurMonthStart,
                    CurWeekStart
                from
                    Calendar
                where
                    [Date] = dateadd(day, -1, convert(date, getdate()))
            ) d
        group by
            CloseDate,
            CurFiscalYearStart,
            CurMonthStart,
            CurWeekStart
            --convert(date, convert(varchar(8), CloseDate, 120) + '01')

    end

end


GO
