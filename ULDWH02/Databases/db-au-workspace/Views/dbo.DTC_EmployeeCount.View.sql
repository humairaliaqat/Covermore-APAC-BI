USE [db-au-workspace]
GO
/****** Object:  View [dbo].[DTC_EmployeeCount]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DTC_EmployeeCount] as
select
    [Date],
    OrganisationID,
    BusinessUnitID,
    SubLevelID,
    case
        when BusinessUnitID = '0' then OrganisationEmployeecount - sum(EmployeeCount) over (partition by [Date],OrganisationID) 
        else EmployeeCount
    end EmployeeCount
from
    (
    select 
        [Date],
        OrganisationID,
        BusinessUnitID,
        SubLevelID,
        f.OrganisationEmployeecount,
        f.BUEmployeecount,
        f.SLEmployeeCount,
        case
            when SubLevelID <> '0' then f.SLEmployeeCount
            when BusinessUnitID <> '0' then f.BUEmployeecount - sum(f.SLEmployeeCount) over (partition by [Date],OrganisationID,BusinessUnitID)
            --else f.OrganisationEmployeecount - sum(f.BUEmployeecount) over (partition by [Date],OrganisationID)
            else 0
        end EmployeeCount
    from
        (
            select
                [Date], 
                t .*
            from
                [db-au-cmdwh]..Calendar d 
                cross apply
                (
                    select
                        OrganisationID, 
                        BusinessUnitID, 
                        SubLevelID,
                        EmployeeCount
                    from
                        (
                            select
                                Org_id OrganisationID, 
                                Group_id BusinessUnitID,
                                SubLevel_id SubLevelID,
                                EmployeeCount, 
                                rank() over (partition by Org_id, Group_id order by t .FromDate desc) MyRank
                            from
                                [db-au-workspace]..DTC_EmployeeNumbersMateralised t
                            where
                                t .FromDate <= d .[Date] and 
                                t .ToDate >= d .[Date]
                        ) t
                    where
                        MyRank = 1
                ) t
            where
                datepart(day, [Date]) = 1
        ) t
        cross apply
        (
            select
                case
                    when BusinessUnitID = '0' then EmployeeCount
                    else 0
                end OrganisationEmployeecount,
                case
                    when BusinessUnitID <> '0' and SubLevelID = '0' then EmployeeCount
                    else 0
                end BUEmployeecount,
                case
                    when SubLevelID <> '0' then EmployeeCount
                    else 0
                end SLEmployeeCount
        ) f
    ) t
where
    OrganisationID is not null and
    exists
    (
        select
            null
        from
            [DTC_BaseEAPDashboardReport] r
        where
            r.Org_ID = t.OrganisationID and
            r.tran_date >= t.[Date] and
            r.tran_date <  dateadd(month, 1, t.[Date]) and
            r.qty > 0
    )
GO
