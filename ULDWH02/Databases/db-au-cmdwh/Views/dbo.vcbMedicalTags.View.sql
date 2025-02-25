USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vcbMedicalTags]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vcbMedicalTags] as
select --top 1000
    cc.CaseKey,
    cc.CaseNo,
    cc.DiagnosticCategory,
    cm.TemplateName TagCategory,
    --cm.CSIData,
    --CSIText,
    --SymptomStart,
    --SymptomStop,
    case
        when SymptomStop <= SymptomStart then ''
        when cm.TemplateName = 'Simple Medical - Outpatient Only' and len(replace(rtrim(ltrim(substring(CSIText, SymptomStart, SymptomStop - SymptomStart))), char(9), '')) = 75 then ''
        else replace(rtrim(ltrim(substring(CSIText, SymptomStart, SymptomStop - SymptomStart))), char(9), '') 
    end Symptom,
    --DiagnosisStart,
    --DiagnosisStop,
    case
        when DiagnosisStop <= DiagnosisStart then ''
        when cm.TemplateName like '%injur%' then replace(replace(rtrim(ltrim(substring(CSIText, DiagnosisStart, DiagnosisStop - DiagnosisStart))), char(9), '') , 'If pre ex state condition/s', '')
        else replace(rtrim(ltrim(substring(CSIText, DiagnosisStart, DiagnosisStop - DiagnosisStart))), char(9), '') 
    end MedicalCondition,
    --HospitalStart,
    --HospitalStop,
    case
        when HospitalStop <= HospitalStart then ''
        else replace(rtrim(ltrim(substring(CSIText, HospitalStart, HospitalStop - HospitalStart))), char(9), '') 
    end Hospital
from
    cbCase cc
    inner join cbClient cl on
        cl.ClientCode = cc.ClientCode
    inner join cbCaseManagement cm on
        cm.CaseKey = cc.CaseKey
    cross apply
    (
        select top 1 
            cam.CSIText
        from
            cbAuditCaseManagement cam with(nolock)
        where
            cam.CaseManagementKey = cm.CaseManagementKey
        order by
            cam.AuditDateTime desc
    ) cam
    cross apply
    (
        select
            case
                when TemplateName like '%death%' then charindex(char(9), CSIText, charindex('DESCRIBE HOW THE DEATH OCCURRED', CSIText) + 1) + 1
                when 
                    TemplateName in 
                    (
                        'Simple Medical - Outpatient Only'
                    ) 
                    then charindex(char(9), CSIText, charindex('MEDICAL CONDITION', CSIText) + 1) + 1
                when 
                    TemplateName in 
                    (
                        'Air NZ - Medical - Injury',
                        'Cover-More - Medical - Injury'
                    ) 
                    then charindex(char(9), CSIText, charindex('Describe the Injuries sustained', CSIText) + 1) + 1
                when 
                    TemplateName in 
                    (
                        'Cover-More - Medical - Illness', 
                        'Air NZ - Medical - Illness',
                        'TIP - Medical - Illness'
                    ) and 
                    CSIText like '%Symptons?%' 
                    then charindex(char(9), CSIText, charindex('Symptons?', CSIText) + 1) + 1
                when 
                    TemplateName in 
                    (
                        'Cover-More - Medical - Illness', 
                        'Air NZ - Medical - Illness',
                        'TIP - Medical - Illness'
                    )
                    then charindex(char(9), CSIText, charindex('Presenting signs/symptoms', CSIText) + 1) + 1
                else 0
            end SymptomStart,
            case
                when TemplateName like '%death%' then charindex(char(9), CSIText, charindex('CONFIRM CAUSE OF DEATH IF KNOWN', CSIText) + 1) + 1
                when 
                    TemplateName in 
                    (
                        'Air NZ - Medical - Injury',
                        'Cover-More - Medical - Injury'
                    ) 
                    then charindex(char(9), CSIText, charindex('Any pre ex', CSIText) + 1) + 1
                when 
                    TemplateName in 
                    (
                        'Cover-More - Medical - Illness', 
                        'Air NZ - Medical - Illness',
                        'TIP - Medical - Illness'
                    )
                    then charindex(char(9), CSIText, charindex('Diagnosis', CSIText, charindex('Reviewed by a doctor?', CSIText) + 1) + 1) + 1
                else 0
            end DiagnosisStart,
            case
                when TemplateName like '%death%' then charindex(char(9), CSIText, charindex('NAME OF HOSPITAL OR MORTUARY', CSIText) + 1) + 1
                when 
                    TemplateName in 
                    (
                        'Cover-More - Medical - Illness', 
                        'Air NZ - Medical - Illness',
                        'TIP - Medical - Illness',
                        'Air NZ - Medical - Injury',
                        'Cover-More - Medical - Injury'
                    )
                    then charindex(char(9), CSIText, charindex('Name of admitting hospital:', CSIText, charindex('Reviewed by a doctor?', CSIText) + 1) + 1) + 1
                else 0
            end HospitalStart
    ) locstart
    cross apply
    (
        select
            case
                when TemplateName like '%death%' then charindex('CONFIRM CAUSE OF DEATH IF KNOWN', CSIText, SymptomStart + 1)
                when 
                    TemplateName in 
                    (
                        'Simple Medical - Outpatient Only'
                    ) 
                    then charindex('Consent to transfer', CSIText, SymptomStart + 1)
                when 
                    TemplateName in 
                    (
                        'Cover-More - Medical - Illness', 
                        'Air NZ - Medical - Illness',
                        'TIP - Medical - Illness',
                        'Air NZ - Medical - Injury',
                        'Cover-More - Medical - Injury'
                    )
                    then charindex('Reviewed by a doctor?', CSIText, SymptomStart + 1)
                else 0
            end SymptomStop,
            case
                when TemplateName like '%death%' then charindex('CONFIRM IF HOSPITALISED AT TIME OF DEATH', CSIText, DiagnosisStart + 1)
                when 
                    TemplateName in 
                    (
                        'Air NZ - Medical - Injury',
                        'Cover-More - Medical - Injury'
                    ) 
                    then charindex('Any other relevant medical conditions or functional limitations', CSIText, DiagnosisStart + 1)
                when 
                    TemplateName in 
                    (
                        'Cover-More - Medical - Illness', 
                        'Air NZ - Medical - Illness',
                        'TIP - Medical - Illness'
                    ) and
                    CSIText like '%HOSPITALISATION DETAILS%' 
                    then charindex('HOSPITALISATION DETAILS', CSIText, DiagnosisStart + 1)
                when 
                    TemplateName in 
                    (
                        'Cover-More - Medical - Illness', 
                        'Air NZ - Medical - Illness',
                        'TIP - Medical - Illness'
                    ) 
                    then charindex('ORIGINAL TRAVEL PLANS', CSIText, DiagnosisStart + 1)
                else 0
            end DiagnosisStop,
            case
                when TemplateName like '%death%' then charindex('LOCATION OF HOSPITAL OR MORTUARY', CSIText, HospitalStart + 1)
                when 
                    TemplateName in 
                    (
                        'Cover-More - Medical - Illness', 
                        'Air NZ - Medical - Illness',
                        'TIP - Medical - Illness',
                        'Air NZ - Medical - Injury',
                        'Cover-More - Medical - Injury'
                    )
                    then charindex('Medical report obtained', CSIText, HospitalStart + 1)
                else 0
            end HospitalStop
    ) locstop
where
    Protocol = 'Medical' and
    cl.IsCovermoreClient = 1 and
    CSIText is not null and
    cm.TemplateName <> 'Generic'
GO
