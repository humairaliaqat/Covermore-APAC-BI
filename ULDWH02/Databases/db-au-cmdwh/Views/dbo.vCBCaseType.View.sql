USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCBCaseType]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vCBCaseType] as
select 
    CaseKey,
    BusinessUnit,
    cct.Criteria,
    case
        when cct.Criteria = 'N/A' then 0
        when cct.Criteria = 'EVACUATION' then isnull(cf.EvacuationCaseFee, 0)
        when cc.Protocol = 'Medical' and cct.Criteria = 'COMPLEX' then isnull(cf.ComplexMedicalCaseFee, 0)
        when cct.Criteria = 'COMPLEX' then isnull(cf.ComplexTechnicalCaseFee, 0)
        when cc.Protocol = 'Medical' and cct.Criteria = 'MEDIUM' then isnull(cf.MediumMedicalCaseFee, 0)
        when cct.Criteria = 'MEDIUM' then isnull(cf.MediumTechnicalCaseFee, 0)
        when cc.Protocol = 'Medical' then isnull(cf.SimpleMedicalCaseFee, 0)
        when cc.Protocol = 'Technical' then isnull(cf.SimpleTechnicalCaseFee, 0)
        else 0
    end CaseFee,
    GST
from
    cbCase cc
    cross apply
    (
        select
            case
                when cc.CaseType like '%evacuation%' then 'EVACUATION'
                when cc.CaseType like '%complex%' then 'COMPLEX'
                when cc.CaseType like '%medium%' then 'MEDIUM'
                when cc.CaseType like '%simple%' then 'SIMPLE'
                else 'N/A'
            end Criteria
    ) cct
    outer apply
    (
        select
            BusinessUnit,
            SimpleMedicalCaseFee,
            MediumMedicalCaseFee,
            ComplexMedicalCaseFee,
            SimpleTechnicalCaseFee,
            MediumTechnicalCaseFee,
            ComplexTechnicalCaseFee,
            EvacuationCaseFee,
            GST
        from
            usrCBCaseFee cf
        where
            cf.CountryKey = cc.CountryKey and
            cf.ClientCode = cc.ClientCode and
            cf.ProgramCode = cc.ProgramCode
    ) cf






GO
