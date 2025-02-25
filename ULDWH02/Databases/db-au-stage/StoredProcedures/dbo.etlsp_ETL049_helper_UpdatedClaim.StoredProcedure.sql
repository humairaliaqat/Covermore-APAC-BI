USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL049_helper_UpdatedClaim]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL049_helper_UpdatedClaim]
    @StartDate date,
    @EndDate date

as
begin

    if object_id('etl_UpdatedClaim') is not null
        drop table etl_UpdatedClaim

    select
        ClaimKey
    into etl_UpdatedClaim
    from
        [db-au-cmdwh].dbo.clmClaim
    where
        (
            CreateDate >= @StartDate and
            CreateDate <  dateadd(day, 1, @EndDate)
        ) or ClaimKey in ('AU-1557911')

    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmAuditClaim
    where
        (AuditDateTime >= @StartDate and
        AuditDateTime <  dateadd(day, 1, @EndDate))
		or ClaimKey in ('AU-1557911')

    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmAuditPayment
    where
       ( AuditDateTime >= @StartDate and
        AuditDateTime <  dateadd(day, 1, @EndDate))
		or ClaimKey in ('AU-1557911')
    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmPayment
    where
        (ModifiedDate >= @StartDate and
        ModifiedDate <  dateadd(day, 1, @EndDate))
		or ClaimKey in ('AU-1557911')
    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmAuditSection
    where
        AuditDateTime >= @StartDate and
        AuditDateTime <  dateadd(day, 1, @EndDate)
		or ClaimKey in ('AU-1557911')
    union

    select
        ClaimKey
    from
        [db-au-cmdwh].dbo.clmEstimateHistory eh
    where
        (EHCreateDate >= @StartDate and
        EHCreateDate <  dateadd(day, 1, @EndDate))
		or ClaimKey in ('AU-1557911')
    union

    select 
        w.ClaimKey
    from
        [db-au-cmdwh].dbo.e5WorkEvent we
        inner join [db-au-cmdwh].dbo.e5Work w on
            w.Work_ID = we.Work_ID
    where
        (we.EventDate >= @StartDate and
        we.EventDate <  dateadd(day, 1, @EndDate))
		or ClaimKey in ('AU-1557911')
end
GO
