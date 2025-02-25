USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entSecondaryScore]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entSecondaryScore]
as
begin

    select 
        CustomerID
    into #related
    from
        [db-au-cmdwh]..entCustomer ec
    where
        coalesce(ec.ClaimScore, ec.PrimaryScore) >= 1000 and
        ec.UpdateBatchID in
        (
            select 
                Batch_ID
            from
                [db-au-log]..Batch_Run_Status
            where
                Subject_Area = 'EnterpriseMDM ODS' and
                Batch_Start_Time >= dateadd(day, -2, convert(date, getdate())) and
                Batch_Start_Time >= '2017-01-19'
        )

    insert into #related
    select 
        CustomerID
    from
        [db-au-cmdwh]..entBlacklist

    update ec
    set
        SecondaryScore = isnull(RelatedScore, 0)
    from
        [db-au-cmdwh]..entCustomer ec
        cross apply 
        (
            select
                sum(isnull(PrimaryScore, 0) * Multiplier) + sum(isnull(SecondaryScore, 0) * 0.01) RelatedScore
            from
                [db-au-cmdwh].dbo.fn_EnterpriseRelation(ec.CustomerID, null)
        ) r
    where
        ec.CustomerID in
        (
            select 
                CustomerID
            from
                #related
        )

    --truncate table #related

    --insert into #related
    --select 
    --    CustomerID
    --from
    --    [db-au-cmdwh]..entBlacklist

    --update ec
    --set
    --    SecondaryScore = isnull(RelatedScore, 0)
    --from
    --    [db-au-cmdwh]..entCustomer ec
    --    cross apply 
    --    (
    --        select
    --            sum(isnull(PrimaryScore, 0) * Multiplier) + sum(isnull(SecondaryScore, 0) * 0.01) RelatedScore
    --        from
    --            [db-au-cmdwh].dbo.fn_EnterpriseRelation(ec.CustomerID, null)
    --    ) r
    --where
    --    ec.CustomerID in
    --    (
    --        select 
    --            CustomerID
    --        from
    --            #related
    --    )


end
GO
