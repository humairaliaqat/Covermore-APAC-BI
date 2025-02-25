USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCubeRecon]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE view [dbo].[vCubeRecon]        
as
select
    coalesce(pc.[JV], gl.[JV]) [JV],
    coalesce(pc.[Month], gl.[Month]) [Month],
    isnull(pc.[Policy Count], 0) [Policy CUBE Policy Count],
    isnull(pc.[Premium], 0) [Policy CUBE Premium],
    isnull(gl.[Policy Count], 0) [GL CUBE Policy Count],
    isnull(gl.[Premium], 0) [GL CUBE Premium],
    [Var Policy Count],
    [Var Premium]
from
    (
        select 
            [JV],
            [Month],
            sum(isnull(pc.[Policy Count], 0)) [Policy Count],
            sum(isnull(pc.[Premium], 0)) [Premium]
        from
            [db-au-workspace]..ETL032_recon_policycube pc
        group by
            [JV],
            [Month]
    ) pc
    full outer join [db-au-workspace]..ETL032_recon_glcube gl on
        gl.[JV] = pc.[JV] and
        gl.[Month] = pc.[Month]
    outer apply
    (
        select
            round(abs(isnull(pc.[Policy Count], 0) - isnull(gl.[Policy Count], 0)), 0) [Var Policy Count],
            round(abs(isnull(pc.[Premium], 0) - isnull(gl.[Premium], 0)), 0) [Var Premium]
    ) v
where
    coalesce(pc.[Month], gl.[Month]) >= '2013-07-01'
    --and
    --(
    --    [Var Policy Count] +
    --    [Var Premium]
    --) > 0

GO
