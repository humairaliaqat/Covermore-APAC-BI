USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_emcMedical]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_emcMedical]
as
begin
/*
    20140317, LS,   TFS 9410, UK data
*/

    set nocount on

    exec etlsp_StagingIndex_EMC

    if object_id('[db-au-cmdwh].dbo.emcMedical') is null
    begin

        create table [db-au-cmdwh].dbo.emcMedical
        (
            CountryKey varchar(2) not null,
            ApplicationKey varchar(15) not null,
            AssessorKey varchar(10) null,
            MedicalKey varchar(15) not null,
            ApplicationID int not null,
            MedicalID int not null,
            GroupID int null,
            CreateDate datetime null,
            IsMedicationsChanged bit null,
            HowMedicationsChanged varchar(4000) null,
            Assessor varchar(50) null,
            Condition varchar(250) null,
            DiagnosisDate datetime null,
            ConditionStatus varchar(20) null,
            GroupStatus varchar(20) null,
            Medication varchar(2000) null,
            OnlineCondition varchar(2000) null,
            MedicalScore decimal(18, 2) null,
            GroupScore decimal(18, 2) null
        )

        create clustered index idx_emcMedical_ApplicationKey on [db-au-cmdwh].dbo.emcMedical(ApplicationKey)
        create index idx_emcMedical_CountryKey on [db-au-cmdwh].dbo.emcMedical(CountryKey)
        create index idx_emcMedical_MedicalKey on [db-au-cmdwh].dbo.emcMedical(MedicalKey)
        create index idx_emcMedical_ApplicationID on [db-au-cmdwh].dbo.emcMedical(ApplicationID, CountryKey)
        create index idx_emcMedical_MedicalID on [db-au-cmdwh].dbo.emcMedical(MedicalID, CountryKey)
        create index idx_emcMedical_GroupID on [db-au-cmdwh].dbo.emcMedical(GroupID, CountryKey)
        create index idx_emcMedical_CreateDate on [db-au-cmdwh].dbo.emcMedical(CreateDate, CountryKey)
        create index idx_emcMedical_Condition on [db-au-cmdwh].dbo.emcMedical(Condition)

    end

    if object_id('etl_emcMedical') is not null
        drop table etl_emcMedical

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), m.ClientID) ApplicationKey,
        'AU-' + convert(varchar(7), m.AssessorID) AssessorKey,
        dk.CountryKey + '-' + convert(varchar(12), m.Counter) MedicalKey,
        m.ClientID ApplicationID,
        m.Counter MedicalID,
        m.MedicalConditionsGroupID GroupID,
        mcg.CreateDate,
        e.MedsChanged IsMedicationsChanged,
        e.MedsChangedHow HowMedicationsChanged,
        s.FullName Assessor,
        m.Condition,
        DiagnosisDate,
        case m.DeniedAccepted
            when 'A' then 'Approved'
            when 'D' then 'Denied'
            when 'N' then 'Not Assessed'
            when 'P' then 'Awaiting Assessment'
            when 'U' then 'Auto Accept'
        end ConditionStatus,
        case mcg.DeniedAccepted
            when 'A' then 'Approved'
            when 'D' then 'Denied'
            when 'N' then 'Not Assessed'
            when 'P' then 'Awaiting Assessment'
            when 'U' then 'Auto Accept'
        end GroupStatus,
        Meds_Dose_Freq Medication,
        OnlineCondition,
        m.Score MedicalScore,
        mcg.Score GroupScore
    into etl_emcMedical
    from
        emc_EMC_Medical_AU m
        outer apply dbo.fn_GetEMCDomainKeys(m.ClientID, 'AU') dk
        inner join emc_EMC_tblEMCApplications_AU e on
            e.ClientID = m.ClientID
        left join emc_EMC_tblSecurity_AU s on
            s.UserID = m.AssessorID
        left join emc_EMC_tblMedicalConditionsGroup_AU mcg on
            mcg.Counter = m.MedicalConditionsGroupID

    union

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), m.ClientID) ApplicationKey,
        'UK-' + convert(varchar(7), m.AssessorID) AssessorKey,
        dk.CountryKey + '-' + convert(varchar(12), m.Counter) MedicalKey,
        m.ClientID ApplicationID,
        m.Counter MedicalID,
        m.MedicalConditionsGroupID GroupID,
        mcg.CreateDate,
        e.MedsChanged IsMedicationsChanged,
        e.MedsChangedHow HowMedicationsChanged,
        s.FullName Assessor,
        m.Condition,
        DiagnosisDate,
        case m.DeniedAccepted
            when 'A' then 'Approved'
            when 'D' then 'Denied'
            when 'N' then 'Not Assessed'
            when 'P' then 'Awaiting Assessment'
            when 'U' then 'Auto Accept'
        end ConditionStatus,
        case mcg.DeniedAccepted
            when 'A' then 'Approved'
            when 'D' then 'Denied'
            when 'N' then 'Not Assessed'
            when 'P' then 'Awaiting Assessment'
            when 'U' then 'Auto Accept'
        end GroupStatus,
        Meds_Dose_Freq Medication,
        OnlineCondition,
        m.Score MedicalScore,
        mcg.Score GroupScore
    from
        emc_UKEMC_Medical_UK m
        outer apply dbo.fn_GetEMCDomainKeys(m.ClientID, 'UK') dk
        inner join emc_UKEMC_tblEMCApplications_UK e on
            e.ClientID = m.ClientID
        left join emc_UKEMC_tblSecurity_UK s on
            s.UserID = m.AssessorID
        left join emc_UKEMC_tblMedicalConditionsGroup_UK mcg on
            mcg.Counter = m.MedicalConditionsGroupID


    delete em
    from
        [db-au-cmdwh].dbo.emcMedical em
        inner join etl_emcMedical t on
            t.MedicalKey = em.MedicalKey


    insert into [db-au-cmdwh].dbo.emcMedical with (tablock)
    (
        CountryKey,
        ApplicationKey,
        AssessorKey,
        MedicalKey,
        ApplicationID,
        MedicalID,
        GroupID,
        CreateDate,
        IsMedicationsChanged,
        HowMedicationsChanged,
        Assessor,
        Condition,
        DiagnosisDate,
        ConditionStatus,
        GroupStatus,
        Medication,
        OnlineCondition,
        MedicalScore,
        GroupScore
    )
    select
        CountryKey,
        ApplicationKey,
        AssessorKey,
        MedicalKey,
        ApplicationID,
        MedicalID,
        GroupID,
        CreateDate,
        IsMedicationsChanged,
        HowMedicationsChanged,
        Assessor,
        Condition,
        DiagnosisDate,
        ConditionStatus,
        GroupStatus,
        Medication,
        OnlineCondition,
        MedicalScore,
        GroupScore
    from
        etl_emcMedical

end
GO
