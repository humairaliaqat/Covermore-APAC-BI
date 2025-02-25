USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCBCaseCriteria]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vCBCaseCriteria] as
/*
    20130802 - LS - Case 18899, change complex criteria from >= 11 to > 11
*/
select 
    CaseKey,
    cn.SubCriteriaICount,
    cn.SubCriteriaIICount,
    cr.CRCount,
    csc.SubCriteriaI,
    csc.SubCriteriaII,
    cct.Criteria,
    case
        when cct.Criteria = 'EVACUATION' then isnull(cf.EvacuationCaseFee, 0)
        when cct.Criteria = 'COMPLEX' then isnull(cf.ComplexCaseFee, 0)
        when cct.Criteria = 'MEDIUM' then isnull(cf.MediumCaseFee, 0)
        else isnull(cf.SimpleCaseFee, 0)
    end CaseFee,
    GST
from
    cbCase cc
    cross apply
    (
        select
            sum(
                case
                    when cn.NoteCode in ('MC', 'BN', 'ZZ', 'EV', 'TN') then 1
                    else 0
                end
            ) SubCriteriaICount,
            sum(
                case
                    when cn.NoteCode not in ('MC', 'BN', 'ZZ', 'EV', 'TN') then 1
                    else 0
                end
            ) SubCriteriaIICount
        from
            cbNote cn
        where
            cn.CaseKey = cc.CaseKey
    ) cn
    cross apply
    (
        select 
            count(ClientReportKey) CRCount
        from
            cbClientReport cr
        where
            cr.CaseKey = cc.CaseKey
    ) cr
    cross apply
    (
        select
            case
                when cn.SubCriteriaICount > 1 then 'COMPLEX'
                else 'SIMPLE'
            end SubCriteriaI,
            case
                when cn.SubCriteriaIICount + cr.CRCount > 11 then 'COMPLEX'
                else 'SIMPLE'
            end SubCriteriaII
    ) csc
    cross apply
    (
        select
            case
                when csc.SubCriteriaI = 'EVACUATION' or csc.SubCriteriaII = 'EVACUATION' then 'EVACUATION'
                when csc.SubCriteriaI = 'COMPLEX' or csc.SubCriteriaII = 'COMPLEX' then 'COMPLEX'
                when csc.SubCriteriaI = 'MEDIUM' or csc.SubCriteriaII = 'MEDIUM' then 'MEDIUM'
                else 'SIMPLE'
            end Criteria
    ) cct
    outer apply
    (
        select
            SimpleMedicalCaseFee SimpleCaseFee,
            MediumMedicalCaseFee MediumCaseFee,
            ComplexMedicalCaseFee ComplexCaseFee,
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
