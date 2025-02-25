USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vPolicyRecon]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vPolicyRecon]
as
select
    coalesce(op.[Country], oq.[Country], sp.[Country], sq.[Country], pc.[Country]) [Country],
    coalesce(op.[Alpha], oq.[Alpha], sp.[Alpha], sq.[Alpha], pc.[Alpha]) [Alpha],
    coalesce(op.[Month], oq.[Month], sp.[Month], sq.[Month], pc.[Month]) [Month],
    isnull(oq.[Quote Count], 0) [ODS Quote Count],
    isnull(op.[Policy Count], 0) [ODS Policy Count],
    isnull(op.[Premium], 0) [ODS Premium],
    isnull(op.[Sell Price], 0) [ODS Sell Price],
    isnull(op.[GST], 0) [ODS GST],
    isnull(sq.[Quote Count], 0) [STAR Quote Count],
    isnull(sp.[Policy Count], 0) [STAR Policy Count],
    isnull(sp.[Premium], 0) [STAR Premium],
    isnull(sp.[Sell Price], 0) [STAR Sell Price],
    isnull(sp.[GST], 0) [STAR GST],
    isnull(pc.[Quote Count], 0) [CUBE Quote Count],
    isnull(pc.[Policy Count], 0) [CUBE Policy Count],
    isnull(pc.[Premium], 0) [CUBE Premium],
    isnull(pc.[Sell Price], 0) [CUBE Sell Price],
    isnull(pc.[GST], 0) [CUBE GST],
    [Var Quote Count],
    [Var Policy Count],
    [Var Premium],
    [Var Sell Price],
    [Var GST],
    [CVar Quote Count],
    [CVar Policy Count],
    [CVar Premium],
    [CVar Sell Price],
    [CVar GST]
from
    [db-au-workspace]..ETL032_recon_odspolicy op
    full outer join [db-au-workspace]..ETL032_recon_odsquote oq on
        oq.[Country] = op.[Country] and
        oq.[Alpha] = op.[Alpha] and
        oq.[Month] = op.[Month]
    full outer join [db-au-workspace]..ETL032_recon_starpolicy sp on
        sp.[Country] = op.[Country] and
        sp.[Alpha] = op.[Alpha] and
        sp.[Month] = op.[Month]
    full outer join [db-au-workspace]..ETL032_recon_starquote sq on
        sq.[Country] = oq.[Country] and
        sq.[Alpha] = oq.[Alpha] and
        sq.[Month] = oq.[Month]
    full outer join [db-au-workspace]..ETL032_recon_policycube pc on
        pc.[Country] = coalesce(op.[Country], oq.[Country]) and
        pc.[Alpha] = coalesce(op.[Alpha], oq.[Alpha]) and
        pc.[Month] = coalesce(op.[Month], oq.[Month])
    outer apply
    (
        select
            round((isnull(oq.[Quote Count], 0) - isnull(sq.[Quote Count], 0)), 0) [Var Quote Count],
            round((isnull(op.[Policy Count], 0) - isnull(sp.[Policy Count], 0)), 0) [Var Policy Count],
            round((isnull(op.[Premium], 0) - isnull(sp.[Premium], 0)), 0) [Var Premium],
            round((isnull(op.[Sell Price], 0) - isnull(sp.[Sell Price], 0)), 0) [Var Sell Price],
            round((isnull(op.[GST], 0) - isnull(sp.[GST], 0)), 0) [Var GST],
            round((isnull(oq.[Quote Count], 0) - isnull(pc.[Quote Count], 0)), 0) [CVar Quote Count],
            round((isnull(op.[Policy Count], 0) - isnull(pc.[Policy Count], 0)), 0) [CVar Policy Count],
            round((isnull(op.[Premium], 0) - isnull(pc.[Premium], 0)), 0) [CVar Premium],
            round((isnull(op.[Sell Price], 0) - isnull(pc.[Sell Price], 0)), 0) [CVar Sell Price],
            round((isnull(op.[GST], 0) - isnull(pc.[GST], 0)), 0) [CVar GST]
    ) v
where
    coalesce(op.[Month], oq.[Month], sp.[Month], sq.[Month], pc.[Month]) >= '2011-07-01' 
    --and
    --(
    --    [Var Quote Count] +
    --    [Var Policy Count] +
    --    [Var Premium] +
    --    [Var Sell Price] +
    --    [Var GST]
    --) > 0
;
GO
