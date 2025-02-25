USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_emcApplicant]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_emcApplicant]
as
begin

/*
    20140317, LS,   TFS 9410, UK data
*/

    set nocount on

    exec etlsp_StagingIndex_EMC

    if object_id('[db-au-cmdwh].dbo.emcApplicants') is null
    begin

        create table [db-au-cmdwh].dbo.emcApplicants
        (

            CountryKey varchar(2) not null,
            ApplicationKey varchar(15) null,
            ApplicantKey varchar(15) not null,
            ApplicationID int null,
            ApplicantID int not null,
            ApplicantHash varchar(50) null,
            RelaxedApplicantHash varchar(50) null,
            Title varchar(5) null,
            FirstName varchar(50) null,
            Surname varchar(50) null,
            Street varbinary(350) null,
            Suburb varbinary(100) null,
            State varbinary(100) null,
            PostCode varbinary(100) null,
            Phone varbinary(100) null,
            MobilePhone varbinary(100) null,
            Email varbinary(300) null,
            DOB varbinary(100) null,
            AgeOfDeparture int null,
            Sex varchar(6) null,
            Height float null,
            HeightUnit varchar(20) null,
            Weight float null,
            WeightUnit varchar(20) null,
            EDCDate datetime null,
            BloodPressure varchar(10) null,
            BloodPressureDate datetime null,
            BloodSugarLevel varchar(10) null,
            BloodSugarLevelDate datetime null,
            CreatinineLevel varchar(10) null,
            CreatinineRecordDate datetime null,
            isSmokedInLast6Months bit null,
            isRegularyExercise bit null,
            ExerciseDetails varchar(400) null,
            HasEpilepsy bit null,
            HadStroke bit null,
            HasMedicalCondition bit null,
            HasSeriousCondition bit null,
            HasHeartCondition bit null,
            IsCardiacAssessmentIncluded bit null,
            IsCardiacUnchanged bit null,
            TranslatorContactID int null,
            TranslatorFirstName varchar(50) null,
            TranslatorSurname varchar(50) null,
            TranslatorRelation varchar(25) null,
            TranslatorPhone varbinary(100) null,
            ConsultantContactID int null,
            ConsultantFirstName varchar(50) null,
            ConsultantSurname varchar(50) null,
            ConsultantPhone varbinary(100) null,
            ConsultantFax varbinary(100) null,
            ConsultantEmail varbinary(300) null,
            IsAgentConsentGiven bit null,
            IsEnrolmentFormOnFile bit null,
            CustomerID bigint
        )

        create clustered index idx_emcApplicants_ApplicationKey on [db-au-cmdwh].dbo.emcApplicants(ApplicationKey)
        create index idx_emcApplicants_CountryKey on [db-au-cmdwh].dbo.emcApplicants(CountryKey)
        create index idx_emcApplicants_ApplicationID on [db-au-cmdwh].dbo.emcApplicants(ApplicationID, CountryKey)
        create index idx_emcApplicants_ApplicantID on [db-au-cmdwh].dbo.emcApplicants(ApplicantID, CountryKey)
        create index idx_emcApplicants_TranslatorContactID on [db-au-cmdwh].dbo.emcApplicants(TranslatorContactID, CountryKey)
        create index idx_emcApplicants_ConsultantContactID on [db-au-cmdwh].dbo.emcApplicants(ConsultantContactID, CountryKey)
        create index idx_emcApplicants_ApplicantHash on [db-au-cmdwh].dbo.emcApplicants(ApplicantHash)
        create index idx_emcApplicants_RelaxedApplicantHash on [db-au-cmdwh].dbo.emcApplicants(RelaxedApplicantHash) include (CustomerID)
        create index idx_emcApplicants_RelaxedApplicantHash on [db-au-cmdwh].dbo.emcApplicants(CustomerID) include (RelaxedApplicantHash,ApplicationKey,ApplicationID)

    end

    if object_id('etl_emcApplicants') is not null
        drop table etl_emcApplicants

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), n.ClientID) ApplicationKey,
        dk.CountryKey + '-' + convert(varchar(12), ContID) ApplicantKey,
        n.ClientID ApplicationID,
        ContID ApplicantID,
        convert(
            varchar(50),
            hashbytes(
                'SHA1',
                ltrim(rtrim(lower(FirstName))) +
                ltrim(rtrim(lower(Surname))) +
                convert(varchar(10), na.DDOB, 120)
            ),
            1
        ) ApplicantHash,
        convert(
            varchar(50),
            hashbytes(
                'SHA1',

                isnull(lower(ltrim(rtrim(soundex(FirstName)))), '') +
                isnull(lower(ltrim(rtrim(soundex(Surname)))), '') +
                isnull(convert(varchar(10), na.DDOB, 120), '') +
                isnull(convert(varchar(7), dateadd(day, -7, e.DeptDt), 120), '') +
                isnull(convert(varchar(7), dateadd(day, 7, e.RetDt), 120), '') 
                --+
                --isnull(e.Destination, '')
            )
        ) RelaxedApplicantHash,
        Title,
        FirstName,
        Surname,
        Street,
        Suburb,
        State,
        Pcode PostCode,
        PhoneBH Phone,
        PhoneAH MobilePhone,
        Email,
        DOB,
        case
            when datediff(month, na.DDOB, e.DeptDt) % 12 = 0 and datepart(day, e.DeptDt) < datepart(day, na.DDOB) then
            datediff(month, na.DDOB, e.DeptDt) / 12 - 1
            else datediff(month, na.DDOB, e.DeptDt) / 12
        end AgeOfDeparture,
        Sex,
        Height,
        hm.Unit HeightUnit,
        Weight,
        wm.Unit WeightUnit,
        EDC EDCDate,
        BPReading BloodPressure,
        BPDate BloodPressureDate,
        BSL BloodSugarLevel,
        BSLDate BloodSugarLevelDate,
        CreatinineLevel,
        CreatinineRecordDate,
        Smoked isSmokedInLast6Months,
        ExerciseRegular isRegularyExercise,
        ExcerciseDetails ExerciseDetails,
        Epilepsy HasEpilepsy,
        CVA_TIA HadStroke,
        HasConditions HasMedicalCondition,
        SeriousCondition HasSeriousCondition,
        HeartCondition HasHeartCondition,
        CardiacAssessmentIncluded IsCardiacAssessmentIncluded,
        CardiacCondMedsUnchanged IsCardiacUnchanged,
        TranslatorContactID,
        TranslatorFirstName,
        TranslatorSurname,
        TranslatorRelation,
        TranslatorPhone,
        ConsultantContactID,
        ConsultantFirstName,
        ConsultantSurname,
        ConsultantPhone,
        ConsultantFax,
        ConsultantEmail,
        Consent IsAgentConsentGiven,
        EnrolFormOnFile IsEnrolmentFormOnFile
    into etl_emcApplicants
    from
        emc_EMC_tblEMCNames_AU n
        inner join emc_EMC_tblEMCApplications_AU e on
            e.ClientID = n.ClientID
        outer apply dbo.fn_GetEMCDomainKeys(e.ClientID, 'AU') dk
        cross apply
        (
            select
                convert(datetime, [db-au-cmdwh].dbo.sysfn_DecryptEMCString(n.DOB)) DDOB
        ) na
        left join emc_EMC_tblMeasurementUnits_AU hm on
            hm.UnitID = e.HeightUnitsID
        left join emc_EMC_tblMeasurementUnits_AU wm on
            wm.UnitID = e.WeightUnitsID
        outer apply
        (
            select top 1
                ContID TranslatorContactID,
                Firstname TranslatorFirstName,
                Surname TranslatorSurname,
                Relationship TranslatorRelation,
                PhoneBH TranslatorPhone
            from
                emc_EMC_tblEMCNames_AU t
            where
                t.ClientID = n.ClientID and
                ContType = 'T'
        ) t
        outer apply
        (
            select top 1
                ContID ConsultantContactID,
                Firstname ConsultantFirstName,
                Surname ConsultantSurname,
                PhoneBH ConsultantPhone,
                Fax ConsultantFax,
                Email ConsultantEmail
            from emc_EMC_tblEMCNames_AU c
            where
                c.ClientID = n.ClientID and
                ContType = 'A'
        ) c
    where
        ContType = 'C'

    union

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), n.ClientID) ApplicationKey,
        dk.CountryKey + '-' + convert(varchar(12), ContID) ApplicantKey,
        n.ClientID ApplicationID,
        ContID ApplicantID,
        convert(
            varchar(50),
            hashbytes(
                'SHA1',
                ltrim(rtrim(lower(FirstName))) +
                ltrim(rtrim(lower(Surname))) +
                convert(varchar(10), na.DDOB, 120)
            ),
            1
        ) ApplicantHash,
        convert(
            varchar(50),
            hashbytes(
                'SHA1',
                isnull(lower(ltrim(rtrim(soundex(FirstName)))), '') +
                isnull(lower(ltrim(rtrim(soundex(Surname)))), '') +
                isnull(convert(varchar(10), na.DDOB, 120), '') +
                isnull(convert(varchar(7), dateadd(day, -7, e.DeptDt), 120), '') +
                isnull(convert(varchar(7), dateadd(day, 7, e.RetDt), 120), '') 
                --isnull(e.Destination, '')
            )
        ) RelaxedApplicantHash,
        Title,
        FirstName,
        Surname,
        Street,
        Suburb,
        State,
        Pcode PostCode,
        PhoneBH Phone,
        PhoneAH MobilePhone,
        Email,
        DOB,
        case
            when datediff(month, na.DDOB, e.DeptDt) % 12 = 0 and datepart(day, e.DeptDt) < datepart(day, na.DDOB) then
            datediff(month, na.DDOB, e.DeptDt) / 12 - 1
            else datediff(month, na.DDOB, e.DeptDt) / 12
        end AgeOfDeparture,
        Sex,
        Height,
        hm.Unit HeightUnit,
        Weight,
        wm.Unit WeightUnit,
        EDC EDCDate,
        BPReading BloodPressure,
        BPDate BloodPressureDate,
        BSL BloodSugarLevel,
        BSLDate BloodSugarLevelDate,
        CreatinineLevel,
        CreatinineRecordDate,
        Smoked isSmokedInLast6Months,
        ExerciseRegular isRegularyExercise,
        ExcerciseDetails ExerciseDetails,
        Epilepsy HasEpilepsy,
        CVA_TIA HadStroke,
        HasConditions HasMedicalCondition,
        SeriousCondition HasSeriousCondition,
        HeartCondition HasHeartCondition,
        CardiacAssessmentIncluded IsCardiacAssessmentIncluded,
        CardiacCondMedsUnchanged IsCardiacUnchanged,
        TranslatorContactID,
        TranslatorFirstName,
        TranslatorSurname,
        TranslatorRelation,
        TranslatorPhone,
        ConsultantContactID,
        ConsultantFirstName,
        ConsultantSurname,
        ConsultantPhone,
        ConsultantFax,
        ConsultantEmail,
        Consent IsAgentConsentGiven,
        EnrolFormOnFile IsEnrolmentFormOnFile
    from
        emc_UKEMC_tblEMCNames_UK n
        inner join emc_UKEMC_tblEMCApplications_UK e on
            e.ClientID = n.ClientID
        outer apply dbo.fn_GetEMCDomainKeys(e.ClientID, 'UK') dk
        cross apply
        (
            select
                convert(datetime, [db-au-cmdwh].dbo.sysfn_DecryptEMCString(n.DOB)) DDOB
        ) na
        left join emc_UKEMC_tblMeasurementUnits_UK hm on
            hm.UnitID = e.HeightUnitsID
        left join emc_UKEMC_tblMeasurementUnits_UK wm on
            wm.UnitID = e.WeightUnitsID
        outer apply
        (
            select top 1
                ContID TranslatorContactID,
                Firstname TranslatorFirstName,
                Surname TranslatorSurname,
                Relationship TranslatorRelation,
                PhoneBH TranslatorPhone
            from
                emc_UKEMC_tblEMCNames_UK t
            where
                t.ClientID = n.ClientID and
                ContType = 'T'
        ) t
        outer apply
        (
            select top 1
                ContID ConsultantContactID,
                Firstname ConsultantFirstName,
                Surname ConsultantSurname,
                PhoneBH ConsultantPhone,
                Fax ConsultantFax,
                Email ConsultantEmail
            from emc_UKEMC_tblEMCNames_UK c
            where
                c.ClientID = n.ClientID and
                ContType = 'A'
        ) c
    where
        ContType = 'C'


    delete ea
    from
        [db-au-cmdwh].dbo.emcApplicants ea
        inner join etl_emcApplicants t on
            t.ApplicantKey = ea.ApplicantKey


    insert into [db-au-cmdwh].dbo.emcApplicants with(tablock)
    (
        CountryKey,
        ApplicationKey,
        ApplicantKey,
        ApplicationID,
        ApplicantID,
        ApplicantHash,
        RelaxedApplicantHash,
        Title,
        FirstName,
        Surname,
        Street,
        Suburb,
        [State],
        PostCode,
        Phone,
        MobilePhone,
        Email,
        DOB,
        AgeOfDeparture,
        Sex,
        Height,
        HeightUnit,
        [Weight],
        WeightUnit,
        EDCDate,
        BloodPressure,
        BloodPressureDate,
        BloodSugarLevel,
        BloodSugarLevelDate,
        CreatinineLevel,
        CreatinineRecordDate,
        isSmokedInLast6Months,
        isRegularyExercise,
        ExerciseDetails,
        HasEpilepsy,
        HadStroke,
        HasMedicalCondition,
        HasSeriousCondition,
        HasHeartCondition,
        IsCardiacAssessmentIncluded,
        IsCardiacUnchanged,
        TranslatorContactID,
        TranslatorFirstName,
        TranslatorSurname,
        TranslatorRelation,
        TranslatorPhone,
        ConsultantContactID,
        ConsultantFirstName,
        ConsultantSurname,
        ConsultantPhone,
        ConsultantFax,
        ConsultantEmail,
        IsAgentConsentGiven,
        IsEnrolmentFormOnFile
    )
    select
        CountryKey,
        ApplicationKey,
        ApplicantKey,
        ApplicationID,
        ApplicantID,
        ApplicantHash,
        RelaxedApplicantHash,
        Title,
        FirstName,
        Surname,
        Street,
        Suburb,
        [State],
        PostCode,
        Phone,
        MobilePhone,
        Email,
        DOB,
        AgeOfDeparture,
        Sex,
        Height,
        HeightUnit,
        [Weight],
        WeightUnit,
        EDCDate,
        BloodPressure,
        BloodPressureDate,
        BloodSugarLevel,
        BloodSugarLevelDate,
        CreatinineLevel,
        CreatinineRecordDate,
        isSmokedInLast6Months,
        isRegularyExercise,
        ExerciseDetails,
        HasEpilepsy,
        HadStroke,
        HasMedicalCondition,
        HasSeriousCondition,
        HasHeartCondition,
        IsCardiacAssessmentIncluded,
        IsCardiacUnchanged,
        TranslatorContactID,
        TranslatorFirstName,
        TranslatorSurname,
        TranslatorRelation,
        TranslatorPhone,
        ConsultantContactID,
        ConsultantFirstName,
        ConsultantSurname,
        ConsultantPhone,
        ConsultantFax,
        ConsultantEmail,
        IsAgentConsentGiven,
        IsEnrolmentFormOnFile
    from
        etl_emcApplicants

end
GO
