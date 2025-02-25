USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterpriseProfileEMC]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vEnterpriseProfileEMC]
as
select 
    ec.CustomerID,
    m.Condition,
    sum
    (
        case
            when ConditionStatus = 'Approved' then 1
            else 0
        end
    ) ApprovedCount,
    sum
    (
        case
            when ConditionStatus <> 'Approved' then 1
            else 0
        end
    ) DeniedCount,
    min(MedicalScore) MinScore,
    max(MedicalScore) MaxScore
from
    entCustomer ec with(nolock)
    inner join emcApplicants ea with(nolock) on
        ea.CustomerID = ec.CustomerID
    inner join emcMedical m with(nolock) on
        m.ApplicationKey = ea.ApplicationKey
group by
    ec.CustomerID,
    m.Condition

GO
