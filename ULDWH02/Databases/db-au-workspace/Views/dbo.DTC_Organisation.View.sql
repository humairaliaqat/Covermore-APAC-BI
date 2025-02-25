USE [db-au-workspace]
GO
/****** Object:  View [dbo].[DTC_Organisation]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[DTC_Organisation] as
select distinct 
    isnull(o.Industry, 'Other') Industry, 
    t.Org_id OrganisationID, 
    t.Group_id BusinessUnitID, 
    t.SubLevel_id DepartmentID,
    o.OrgName Organisation, 
    isnull(g.GroupName, 'Overall') BusinessUnit,
    isnull(sl.GroupName, 'Overall') Department
from
    [db-au-workspace]..DTC_EmployeeNumbersMateralised t 
    inner join DTC_Org as o on 
        o.Org_ID = t.Org_id 
    left join DTC_Groups as g on 
        g.Group_ID = t.Group_id
    left join DTC_Groups as sl on 
        sl.Group_ID = t.SubLevel_id
GO
