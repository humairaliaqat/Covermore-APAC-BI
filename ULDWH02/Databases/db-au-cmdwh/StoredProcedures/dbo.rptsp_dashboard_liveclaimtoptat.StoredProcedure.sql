USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_liveclaimtoptat]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_dashboard_liveclaimtoptat]
as
begin

    ;with cte_selectedtat as
    (
        select 
            *,
            case
                when TAT = max(TAT) over (partition by WorkType) then 1
                else 0
            end Selected
        from
            [db-au-workspace]..live_dashboard_claims_tat    
        where
            TATCount <> 0
    )
    select 
        WorkType,
        AssignedUser,
        TAT,
        TATCount
    from
        cte_selectedtat t
    where
        Selected = 1

end
GO
