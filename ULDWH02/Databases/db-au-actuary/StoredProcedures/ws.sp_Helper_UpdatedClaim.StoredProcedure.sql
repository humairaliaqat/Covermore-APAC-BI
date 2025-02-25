USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [ws].[sp_Helper_UpdatedClaim]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [ws].[sp_Helper_UpdatedClaim]
    @BatchMode bit = 0,
    @StartDate date,
    @EndDate date

as
begin

    if object_id('ws.UpdatedClaim') is not null
        drop table ws.UpdatedClaim

    select
        ClaimKey
    into ws.UpdatedClaim
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
        [db-au-cmdwh].dbo.clmAuditClaim
    where
        @BatchMode = 0 and
        AuditDateTime >= @StartDate and
        AuditDateTime <  dateadd(day, 1, @EndDate)

    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmAuditPayment
    where
        @BatchMode = 0 and
        AuditDateTime >= @StartDate and
        AuditDateTime <  dateadd(day, 1, @EndDate)

    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmPayment
    where
        @BatchMode = 0 and
        ModifiedDate >= @StartDate and
        ModifiedDate <  dateadd(day, 1, @EndDate)

    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmAuditSection
    where
        @BatchMode = 0 and
        AuditDateTime >= @StartDate and
        AuditDateTime <  dateadd(day, 1, @EndDate)

    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmEstimateHistory eh
    where
        @BatchMode = 0 and
        EHCreateDate >= @StartDate and
        EHCreateDate <  dateadd(day, 1, @EndDate)

    union

    select 
        w.ClaimKey
    from
        [db-au-cmdwh].dbo.e5WorkEvent we
        inner join [db-au-cmdwh].dbo.e5Work w on
            w.Work_ID = we.Work_ID
    where
        @BatchMode = 0 and
        we.EventDate >= @StartDate and
        we.EventDate <  dateadd(day, 1, @EndDate)

end
GO
