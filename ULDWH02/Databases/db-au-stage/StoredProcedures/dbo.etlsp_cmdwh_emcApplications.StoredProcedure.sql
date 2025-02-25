USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_emcApplications]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_cmdwh_emcApplications]
as
begin
/*
    20121026, LS,   bug fix on company key duplicates due to merged subcompanies
    20140317, LS,   TFS 9410, UK data
	20151027, DM,	Penguin Policy v16 Release, Update column "PrimaryCountry"
	20151208, DM,	Penguin v16.5 Release update PolicyNo column length to varchar(50)
	20160419, LT,	Penguin v18.5 Release Added isAccepted column 
	20170419, LT,	Penguin 24.0 Release increased AreaName to varchar(100)
*/

    set nocount on

    exec etlsp_StagingIndex_EMC

    if object_id('[db-au-cmdwh].dbo.emcApplications') is null
    begin

        create table [db-au-cmdwh].dbo.emcApplications
        (
            CountryKey varchar(2) not null,
            ApplicationKey varchar(15) not null,
            CompanyKey varchar(10) null,
            AgencyKey varchar(10) null,
            OutletAlphaKey varchar(33) null,
            AssessorKey varchar(10) null,
            CreatorKey varchar(10) null,
            ApplicationID int not null,
            RecordID int not null,
            ApplicationType varchar(25) null,
            AgencyCode varchar(7) null,
            AssessorID int null,
            Assessor varchar(50) null,
            CreatorID int null,
            Creator varchar(50) null,
            Priority varchar(50) null,
            CreateDate datetime null,
            ReceiveDate datetime null,
            AssessedDate datetime null,
            CreateDateOnly date null,
            AssessedDateOnly date null,
            IsEndorsementSigned bit null,
            EndorsementDate datetime null,
            ApplicationStatus varchar(25) null,
            ApprovalStatus varchar(15) null,
            AgeApprovalStatus varchar(15) null,
            MedicalRisk decimal(18, 2) null,
            AreaName varchar(100) null,
            AreaCode varchar(50) null,
            ScreeningVersion varchar(10) null,
            PlanCode varchar(50) null,
            ProductCode varchar(3) null,
            ProductType varchar(100) null,
            DepartureDate datetime null,
            ReturnDate datetime null,
            TripDuration int null,
            Destination VARCHAR(MAX) null,
            TravellerCount int null,
            ValuePerTraveller decimal(18, 2) null,
            TripType varchar(20) null,
            PolicyNo varchar(50) null,
            OtherInsurer varchar(50) null,
            InputType varchar(10) null,
            FileLocation varchar(50) null,
            FileLocationDate datetime null,
            ClaimNo int null,
            ClaimDate datetime null,
            IsClaimRelatedToEMC bit null,
            IsDeclarationSigned bit null,
            IsAnnualBusinessPlan bit null,
            IsApplyingForEMCCover bit null,
            IsApplyingForCMCover bit null,
            IsSendOutcomeByEmail bit null,
            HasAgeDestinationDuration bit null,
            IsDutyOfDisclosure bit null,
            IsCruise bit null,
            IsAnnualMultiTrip bit null,
            IsWinterSport bit null,
            IsOnlineAssessment bit null,
            OnlineAssessment varchar(max) null,
            EMCPremium decimal(18, 2) not null,
            AgePremium decimal(18, 2) not null,
            Excess decimal(18, 2) not null,
            GeneralLimit decimal(18, 2) not null,
            PaymentDuration varchar(15) null,
            RestrictedConditions varchar(255) null,
            OtherRestrictions varchar(255) null,
            PaymentComments varchar(4096) null,
            IsAwaitingMedicalReview bit null,
            HasBeenTreatedLast12Months bit null,
            HasVisitedDoctorLast90Days bit null,
            IsSeekingMedicalOverseas bit null,
            IsTravellingAgainstMedicalAdvice bit null,
            HasDiagnosedTerminalCondition bit null,
            HasReceviedAdviceTerminalCondition bit null,
            MedicalTotalCount int null,
            MedicalApprovedCount int null,
            MedicalAutoAcceptCount int null,
            MedicalDeniedCount int null,
            MedicalAwaitingAssessmentCount int null,
            MedicalNotAssessedCount int null,
			IsMultipleDestinations bit null,
			IsAccepted bit null
        )

        create clustered index idx_emcApplications_AssessedDateOnly on [db-au-cmdwh].dbo.emcApplications(AssessedDateOnly)
        create index idx_emcApplications_ApplicationID on [db-au-cmdwh].dbo.emcApplications(ApplicationID, CountryKey)
        create index idx_emcApplications_ApplicationKey on [db-au-cmdwh].dbo.emcApplications(ApplicationKey)
        create index idx_emcApplications_AreaName on [db-au-cmdwh].dbo.emcApplications(AreaName)
        create index idx_emcApplications_AssessedDate on [db-au-cmdwh].dbo.emcApplications(AssessedDate, CountryKey) include(ApplicationKey)
        create index idx_emcApplications_CompanyKey on [db-au-cmdwh].dbo.emcApplications(CompanyKey)
        create index idx_emcApplications_CountryKey on [db-au-cmdwh].dbo.emcApplications(CountryKey)
        create index idx_emcApplications_CreateDate on [db-au-cmdwh].dbo.emcApplications(CreateDate, CountryKey)
        create index idx_emcApplications_ReceiveDate on [db-au-cmdwh].dbo.emcApplications(ReceiveDate, CountryKey)
        create index idx_emcApplications_CreateDateOnly on [db-au-cmdwh].dbo.emcApplications(CreateDateOnly)
        create index idx_emcApplications_TravelDates on [db-au-cmdwh].dbo.emcApplications (DepartureDate, ReturnDate) include (ApplicationKey,ApplicationID,AssessedDateOnly)

    end

    if object_id('etl_emcApplications') is not null
        drop table etl_emcApplications

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), e.ClientID) ApplicationKey,
        dk.CountryKey + '-' + convert(varchar(4), Compid) + '-' + convert(varchar(3), isnull(dk.SubCompid, 0)) CompanyKey,
        dk.CountryKey + '-' + rtrim(Alpha) collate database_default AgencyKey,
        dk.PrefixKey + rtrim(Alpha) collate database_default OutletAlphaKey,
        'AU-' + convert(varchar(7), AssessorID) AssessorKey,
        'AU-' + convert(varchar(7), CreatedByID) CreatorKey,
        e.ClientID ApplicationID,
        RecID RecordID,
        eat.ApplicationType,
        Alpha AgencyCode,
        AssessorID,
        sa.Assessor,
        CreatedByID CreatorID,
        sc.Creator,
        ep.[Priority],
        EnteredDt CreateDate,
        ReceivedDt ReceiveDate,
        AssessedDt AssessedDate,
        EnteredDt CreateDateOnly,
        convert(date, AssessedDt) AssessedDateOnly,
        SignedEndReq IsEndorsementSigned,
        EndRecDt EndorsementDate,
        case e.CaseStatusID
            when 1 then 'Being Assessed'
            when 2 then 'On Hold'
            when 3 then 'Awaiting Response'
            when 4 then 'Flagged for Follow Up'
            when 5 then 'New Case'
            when 6 then 'Awaiting Documentation'
            when 8 then 'Completed'
        end ApplicationStatus,
        ApprovalStatus,
        case AgeApproval
            when 'A' then 'Approved'
            when 'D' then 'Denied'
            when 'N' then 'Not Assessed'
            else ''
        end AgeApprovalStatus,
        MedicalRisk,
        m.AreaName,
        m.AreaCode,
        ScreeningVersion,
        case
            when e.ProdPlan is null then Prod
            when e.ProdPlan like '% %' then e.ProdPlan
            when e.ProdPlan like '%.%' then e.ProdPlan
            when e.ProdPlan like '%,%' then e.ProdPlan
            when e.ProdPlan like '%$%' then e.ProdPlan
            when isnumeric(e.ProdPlan) = 1 then
                isnull(
                    (
                        select top 1
                            PlanCode
                        from
                            emc_EMC_tblPlanCode_AU p
                        where
                            p.PlanCodeId = e.ProdPlan
                    ),
                    e.ProdPlan
                )
            else e.ProdPlan
        end PlanCode,
        pt.PolCode ProductCode,
        pt.PolType ProductType,
        DeptDt DepartureDate,
        RetDt ReturnDate,
        datediff(day, DeptDt, RetDt) + 1 TripDuration,
        Destination,
        tottravellers TravellerCount,
        totvaluepertraveller ValuePerTraveller,
        tt.TripType,
        PolNo PolicyNo,
        OtherInsurer,
        it.InputType,
        FileLoc FileLocation,
        FileLocDate FileLocationDate,
        [Claim#] ClaimNo,
        ClaimDt ClaimDate,
        RelatedToEMC IsClaimRelatedToEMC,
        Declaration IsDeclarationSigned,
        AnnualBusPlan IsAnnualBusinessPlan,
        AppliedforCover IsApplyingForEMCCover,
        AppliedForCMCover IsApplyingForCMCover,
        eMailResponse IsSendOutcomeByEmail,
        AgeDestDuration HasAgeDestinationDuration,
        DutyOfDisclosure IsDutyOfDisclosure,
        Cruise IsCruise,
        isAnnualMultiTrip,
        isWinterSport,
        case
            when o.OA_ID is not null then 1
            else 0
        end isOnlineAssessment,
        convert(varchar(max), OnlineAssessment) OnlineAssessment,
        mt.IsAwaitingMedicalReview,
        mt.HasBeenTreatedLast12Months,
        mt.HasVisitedDoctorLast90Days,
        eq.IsSeekingMedicalOverseas,
        eq.IsTravellingAgainstMedicalAdvice,
        eq.HasDiagnosedTerminalCondition,
        eq.HasReceviedAdviceTerminalCondition,
        isnull(mc.MedicalTotalCount, 0) MedicalTotalCount,
        isnull(mc.MedicalApprovedCount, 0) MedicalApprovedCount,
        isnull(mc.MedicalAutoAcceptCount, 0) MedicalAutoAcceptCount,
        isnull(mc.MedicalDeniedCount, 0) MedicalDeniedCount,
        isnull(mc.MedicalAwaitingAssessmentCount, 0) MedicalAwaitingAssessmentCount,
        isnull(mc.MedicalNotAssessedCount, 0) MedicalNotAssessedCount,
		IsMultipleDestinations,
		e.IsAccepted
    into etl_emcApplications
    from
        emc_EMC_tblEMCApplications_AU e
        outer apply
        (
            select top 1
                dk.CountryKey,
                dk.PrefixKey,
                SubCompid
            from
                emc_EMC_Companies_AU c
                left join emc_EMC_tblParentCompany_AU p on
                    p.ParentCompanyid = c.ParentCompanyid
                outer apply
                (
                    select
                        case
                            when p.ParentCompanyCode = 'TIP' then 'TIP'
                            else 'CM'
                        end ParentCompanyKey
                ) pc
                outer apply dbo.fn_GetDomainKeys(c.DomainID, pc.ParentCompanyKey, 'AU') dk
                outer apply
                (
                    select top 1
                        SubCompid
                    from
                        emc_EMC_tblSubCompanies_AU sc
                    where
                        sc.Compid = c.Compid and
                        (
                            sc.SubCompCode = e.Alpha or
                            e.Alpha is null
                        )
                    order by
                        SubCompid
                ) sc
            where
                c.Compid = e.CompID
        ) dk
        outer apply
        (
            select top 1
                a.AppType ApplicationType
            from
                emc_EMC_tblAppTypes_AU a
            where
                a.AppTypeID = e.AppTypeID
        ) eat
        outer apply
        (
            select top 1
                s.FullName Assessor
            from
                emc_EMC_tblSecurity_AU s
            where
                s.UserID = e.AssessorID
        ) sa
        outer apply
        (
            select top 1
                s.FullName Creator
            from
                emc_EMC_tblSecurity_AU s
            where
                s.UserID = e.CreatedByID
        ) sc
        outer apply
        (
            select top 1
                [Priority]
            from
                emc_EMC_tblPriorities_AU p
            where
                p.PriorityID = e.PriorityID
        ) ep
        outer apply
        (
            select top 1
                sm.SingMulti TripType
            from
                emc_EMC_tblSingMulti_AU sm
            where
                sm.SingMultiID = e.SingMultiID
        ) tt
        outer apply
        (
            select top 1
                it.InputType InputType
            from
                emc_EMC_tblInputType_AU it
            where
                it.InputTypeID = e.InputTypeID
        ) it
        left join emc_EMC_tblOnlineAssessment_AU o on
            o.ClientID = e.ClientID
        outer apply
        (
            select top 1
                pt.PolCode,
                pt.PolType
            from
                emc_EMC_tblPolicyTypes_AU pt
            where
                pt.PolTypeID = e.PolTypeID
        ) pt
        outer apply
        (
            select top 1
                MedicalRisk,
                ScreeningVersion,
                eMailResponse,
                isAnnualMultiTrip,
                isWinterSport
            from
                emc_EMC_tblEMCNames_AU n
            where
                n.ClientID = e.ClientID and
                n.ContType = 'C'
        ) c
        outer apply
        (
            select top 1
                m.AreaName,
                m.AreaCode
            from
                emc_EMC_tblEmcPenguinAreaMapping_AU m
            where
                m.AreaMappingID = e.PenguinAreaMappingID
                --and m.HealixRegionID = c.RegionID
        ) m
        outer apply
        (
            select
                max(
                    case
                        when mtt.RxType = 'Medical Review' then RxRecd
                        else 0
                    end
                ) IsAwaitingMedicalReview,
                max(
                    case
                        when mtt.RxType = 'Hospital Treatment' then RxRecd
                        else 0
                    end
                ) HasBeenTreatedLast12Months,
                max(
                    case
                        when mtt.RxType = 'Doctor Visit' then RxRecd
                        else 0
                    end
                ) HasVisitedDoctorLast90Days
            from
                emc_EMC_tblMedicalTreatment_AU mt
                inner join emc_EMC_tblMedicalTreatmentTypes_AU mtt on
                    mtt.RxTypeCode = mt.RxTypeID
            where
                mt.ClientID = e.ClientID
        ) mt
        outer apply
        (
            select
                max(
                    case
                        when eq.QId = 1 then QVal
                        else 0
                    end
                ) IsSeekingMedicalOverseas,
                max(
                    case
                        when eq.QId = 2 then QVal
                        else 0
                    end
                ) IsTravellingAgainstMedicalAdvice,
                max(
                    case
                        when eq.QId = 3 then QVal
                        else 0
                    end
                ) HasDiagnosedTerminalCondition,
                max(
                    case
                        when eq.QId = 4 then QVal
                        else 0
                    end
                ) HasReceviedAdviceTerminalCondition
            from
                emc_EMC_tblMedicalExtraQuestionDetails_AU eq
            where
                eq.ClientID = e.ClientID
        ) eq
        outer apply
        (
            select
                count(m.Counter) MedicalTotalCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'A' then m.Counter
                        else null
                    end
                ) MedicalApprovedCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'U' then m.Counter
                        else null
                    end
                ) MedicalAutoAcceptCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'D' then m.Counter
                        else null
                    end
                ) MedicalDeniedCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'P' then m.Counter
                        else null
                    end
                ) MedicalAwaitingAssessmentCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'N' then m.Counter
                        else null
                    end
                ) MedicalNotAssessedCount
            from emc_EMC_Medical_AU m
            where m.ClientID = e.ClientID
        ) mc

    union

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), e.ClientID) ApplicationKey,
        dk.CountryKey + '-' + convert(varchar(4), Compid) + '-' + convert(varchar(3), isnull(dk.SubCompid, 0)) CompanyKey,
        dk.CountryKey + '-' + rtrim(Alpha) collate database_default AgencyKey,
        dk.PrefixKey + rtrim(Alpha) collate database_default OutletAlphaKey,
        'UK-' + convert(varchar(7), AssessorID) AssessorKey,
        'UK-' + convert(varchar(7), CreatedByID) CreatorKey,
        e.ClientID ApplicationID,
        RecID RecordID,
        eat.ApplicationType,
        Alpha AgencyCode,
        AssessorID,
        sa.Assessor,
        CreatedByID CreatorID,
        sc.Creator,
        ep.[Priority],
        EnteredDt CreateDate,
        ReceivedDt ReceiveDate,
        AssessedDt AssessedDate,
        EnteredDt CreateDateOnly,
        convert(date, AssessedDt) AssessedDateOnly,
        SignedEndReq IsEndorsementSigned,
        EndRecDt EndorsementDate,
        case e.CaseStatusID
            when 1 then 'Being Assessed'
            when 2 then 'On Hold'
            when 3 then 'Awaiting Response'
            when 4 then 'Flagged for Follow Up'
            when 5 then 'New Case'
            when 6 then 'Awaiting Documentation'
            when 8 then 'Completed'
        end ApplicationStatus,
        ApprovalStatus,
        case AgeApproval
            when 'A' then 'Approved'
            when 'D' then 'Denied'
            when 'N' then 'Not Assessed'
            else ''
        end AgeApprovalStatus,
        MedicalRisk,
        m.AreaName,
        m.AreaCode,
        ScreeningVersion,
        case
            when e.ProdPlan is null then Prod
            when e.ProdPlan like '% %' then e.ProdPlan
            when e.ProdPlan like '%.%' then e.ProdPlan
            when e.ProdPlan like '%,%' then e.ProdPlan
            when e.ProdPlan like '%$%' then e.ProdPlan
            when isnumeric(e.ProdPlan) = 1 then
                isnull(
                    (
                        select top 1
                            PlanCode
                        from
                            emc_UKEMC_tblPlanCode_UK p
                        where
                            p.PlanCodeId = e.ProdPlan
                    ),
                    e.ProdPlan
                )
            else e.ProdPlan
        end PlanCode,
        pt.PolCode ProductCode,
        pt.PolType ProductType,
        DeptDt DepartureDate,
        RetDt ReturnDate,
        datediff(day, DeptDt, RetDt) + 1 TripDuration,
        Destination,
        tottravellers TravellerCount,
        totvaluepertraveller ValuePerTraveller,
        tt.TripType,
        PolNo PolicyNo,
        OtherInsurer,
        it.InputType,
        FileLoc FileLocation,
        FileLocDate FileLocationDate,
        [Claim#] ClaimNo,
        ClaimDt ClaimDate,
        RelatedToEMC IsClaimRelatedToEMC,
        Declaration IsDeclarationSigned,
        AnnualBusPlan IsAnnualBusinessPlan,
        AppliedforCover IsApplyingForEMCCover,
        AppliedForCMCover IsApplyingForCMCover,
        eMailResponse IsSendOutcomeByEmail,
        AgeDestDuration HasAgeDestinationDuration,
        DutyOfDisclosure IsDutyOfDisclosure,
        Cruise IsCruise,
        isAnnualMultiTrip,
        isWinterSport,
        case
            when o.OA_ID is not null then 1
            else 0
        end isOnlineAssessment,
        convert(varchar(max), OnlineAssessment) OnlineAssessment,
        mt.IsAwaitingMedicalReview,
        mt.HasBeenTreatedLast12Months,
        mt.HasVisitedDoctorLast90Days,
        eq.IsSeekingMedicalOverseas,
        eq.IsTravellingAgainstMedicalAdvice,
        eq.HasDiagnosedTerminalCondition,
        eq.HasReceviedAdviceTerminalCondition,
        isnull(mc.MedicalTotalCount, 0) MedicalTotalCount,
        isnull(mc.MedicalApprovedCount, 0) MedicalApprovedCount,
        isnull(mc.MedicalAutoAcceptCount, 0) MedicalAutoAcceptCount,
        isnull(mc.MedicalDeniedCount, 0) MedicalDeniedCount,
        isnull(mc.MedicalAwaitingAssessmentCount, 0) MedicalAwaitingAssessmentCount,
        isnull(mc.MedicalNotAssessedCount, 0) MedicalNotAssessedCount,
		IsMultipleDestinations,
		e.IsAccepted
    from
        emc_UKEMC_tblEMCApplications_UK e
        outer apply
        (
            select top 1
                dk.CountryKey,
                dk.PrefixKey,
                SubCompid
            from
                emc_UKEMC_Companies_UK c
                left join emc_UKEMC_tblParentCompany_UK p on
                    p.ParentCompanyid = c.ParentCompanyid
                outer apply
                (
                    select
                        case
                            when p.ParentCompanyCode = 'TIP' then 'TIP'
                            else 'CM'
                        end ParentCompanyKey
                ) pc
                outer apply dbo.fn_GetDomainKeys(c.DomainID, pc.ParentCompanyKey, 'UK') dk
                outer apply
                (
                    select top 1
                        SubCompid
                    from
                        emc_UKEMC_tblSubCompanies_UK sc
                    where
                        sc.Compid = c.Compid and
                        (
                            sc.SubCompCode = e.Alpha or
                            e.Alpha is null
                        )
                    order by
                        SubCompid
                ) sc
            where
                c.Compid = e.CompID
        ) dk
        outer apply
        (
            select top 1
                a.AppType ApplicationType
            from
                emc_UKEMC_tblAppTypes_UK a
            where
                a.AppTypeID = e.AppTypeID
        ) eat
        outer apply
        (
            select top 1
                s.FullName Assessor
            from
                emc_UKEMC_tblSecurity_UK s
            where
                s.UserID = e.AssessorID
        ) sa
        outer apply
        (
            select top 1
                s.FullName Creator
            from
                emc_UKEMC_tblSecurity_UK s
            where
                s.UserID = e.CreatedByID
        ) sc
        outer apply
        (
            select top 1
                [Priority]
            from
                emc_UKEMC_tblPriorities_UK p
            where
                p.PriorityID = e.PriorityID
        ) ep
        outer apply
        (
            select top 1
                sm.SingMulti TripType
            from
                emc_UKEMC_tblSingMulti_UK sm
            where
                sm.SingMultiID = e.SingMultiID
        ) tt
        outer apply
        (
            select top 1
                it.InputType InputType
            from
                emc_UKEMC_tblInputType_UK it
            where
                it.InputTypeID = e.InputTypeID
        ) it
        left join emc_UKEMC_tblOnlineAssessment_UK o on
            o.ClientID = e.ClientID
        outer apply
        (
            select top 1
                pt.PolCode,
                pt.PolType
            from
                emc_UKEMC_tblPolicyTypes_UK pt
            where
                pt.PolTypeID = e.PolTypeID
        ) pt
        outer apply
        (
            select top 1
                MedicalRisk,
                ScreeningVersion,
                eMailResponse,
                isAnnualMultiTrip,
                isWinterSport
            from
                emc_UKEMC_tblEMCNames_UK n
            where
                n.ClientID = e.ClientID and
                n.ContType = 'C'
        ) c
        outer apply
        (
            select top 1
                m.AreaName,
                m.AreaCode
            from
                emc_UKEMC_tblEmcPenguinAreaMapping_UK m
            where
                m.AreaMappingID = e.PenguinAreaMappingID
                --and m.HealixRegionID = c.RegionID
        ) m
        outer apply
        (
            select
                max(
                    case
                        when mtt.RxType = 'Medical Review' then RxRecd
                        else 0
                    end
                ) IsAwaitingMedicalReview,
                max(
                    case
                        when mtt.RxType = 'Hospital Treatment' then RxRecd
                        else 0
                    end
                ) HasBeenTreatedLast12Months,
                max(
                    case
                        when mtt.RxType = 'Doctor Visit' then RxRecd
                        else 0
                    end
                ) HasVisitedDoctorLast90Days
            from
                emc_UKEMC_tblMedicalTreatment_UK mt
                inner join emc_UKEMC_tblMedicalTreatmentTypes_UK mtt on
                    mtt.RxTypeCode = mt.RxTypeID
            where
                mt.ClientID = e.ClientID
        ) mt
        outer apply
        (
            select
                max(
                    case
                        when eq.QId = 1 then QVal
                        else 0
                    end
                ) IsSeekingMedicalOverseas,
                max(
                    case
                        when eq.QId = 2 then QVal
                        else 0
                    end
                ) IsTravellingAgainstMedicalAdvice,
                max(
                    case
                        when eq.QId = 3 then QVal
                        else 0
                    end
                ) HasDiagnosedTerminalCondition,
                max(
                    case
                        when eq.QId = 4 then QVal
                        else 0
                    end
                ) HasReceviedAdviceTerminalCondition
            from
                emc_UKEMC_tblMedicalExtraQuestionDetails_UK eq
            where
                eq.ClientID = e.ClientID
        ) eq
        outer apply
        (
            select
                count(m.Counter) MedicalTotalCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'A' then m.Counter
                        else null
                    end
                ) MedicalApprovedCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'U' then m.Counter
                        else null
                    end
                ) MedicalAutoAcceptCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'D' then m.Counter
                        else null
                    end
                ) MedicalDeniedCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'P' then m.Counter
                        else null
                    end
                ) MedicalAwaitingAssessmentCount,
                count(distinct
                    case
                        when m.DeniedAccepted = 'N' then m.Counter
                        else null
                    end
                ) MedicalNotAssessedCount
            from emc_UKEMC_Medical_UK m
            where m.ClientID = e.ClientID
        ) mc


    delete e
    from
        [db-au-cmdwh].dbo.emcApplications e
        inner join etl_emcApplications t on
            e.ApplicationKey = t.ApplicationKey


    insert into [db-au-cmdwh].dbo.emcApplications with (tablock)
    (
        CountryKey,
        ApplicationKey,
        CompanyKey,
        AgencyKey,
        OutletAlphaKey,
        AssessorKey,
        CreatorKey,
        ApplicationID,
        RecordID,
        ApplicationType,
        AgencyCode,
        AssessorID,
        Assessor,
        CreatorID,
        Creator,
        [Priority],
        CreateDate,
        ReceiveDate,
        AssessedDate,
        CreateDateOnly,
        AssessedDateOnly,
        IsEndorsementSigned,
        EndorsementDate,
        ApplicationStatus,
        ApprovalStatus,
        AgeApprovalStatus,
        MedicalRisk,
        AreaName,
        AreaCode,
        ScreeningVersion,
        PlanCode,
        ProductCode,
        ProductType,
        DepartureDate,
        ReturnDate,
        TripDuration,
        Destination,
        TravellerCount,
        ValuePerTraveller,
        TripType,
        PolicyNo,
        OtherInsurer,
        InputType,
        FileLocation,
        FileLocationDate,
        ClaimNo,
        ClaimDate,
        IsClaimRelatedToEMC,
        IsDeclarationSigned,
        IsAnnualBusinessPlan,
        IsApplyingForEMCCover,
        IsApplyingForCMCover,
        IsSendOutcomeByEmail,
        HasAgeDestinationDuration,
        IsDutyOfDisclosure,
        IsCruise,
        isAnnualMultiTrip,
        isWinterSport,
        isOnlineAssessment,
        OnlineAssessment,
        EMCPremium,
        AgePremium,
        Excess,
        GeneralLimit,
        PaymentDuration,
        RestrictedConditions,
        OtherRestrictions,
        PaymentComments,
        IsAwaitingMedicalReview,
        HasBeenTreatedLast12Months,
        HasVisitedDoctorLast90Days,
        IsSeekingMedicalOverseas,
        IsTravellingAgainstMedicalAdvice,
        HasDiagnosedTerminalCondition,
        HasReceviedAdviceTerminalCondition,
        MedicalTotalCount,
        MedicalApprovedCount,
        MedicalAutoAcceptCount,
        MedicalDeniedCount,
        MedicalAwaitingAssessmentCount,
        MedicalNotAssessedCount,
		IsMultipleDestinations,
		IsAccepted
    )
    select
        CountryKey,
        ApplicationKey,
        CompanyKey,
        AgencyKey,
        OutletAlphaKey,
        AssessorKey,
        CreatorKey,
        ApplicationID,
        RecordID,
        ApplicationType,
        AgencyCode,
        AssessorID,
        Assessor,
        CreatorID,
        Creator,
        [Priority],
        CreateDate,
        ReceiveDate,
        AssessedDate,
        CreateDateOnly,
        AssessedDateOnly,
        IsEndorsementSigned,
        EndorsementDate,
        ApplicationStatus,
        ApprovalStatus,
        AgeApprovalStatus,
        MedicalRisk,
        AreaName,
        AreaCode,
        ScreeningVersion,
        PlanCode,
        ProductCode,
        ProductType,
        DepartureDate,
        ReturnDate,
        TripDuration,
        Destination,
        TravellerCount,
        ValuePerTraveller,
        TripType,
        PolicyNo,
        OtherInsurer,
        InputType,
        FileLocation,
        FileLocationDate,
        ClaimNo,
        ClaimDate,
        IsClaimRelatedToEMC,
        IsDeclarationSigned,
        IsAnnualBusinessPlan,
        IsApplyingForEMCCover,
        IsApplyingForCMCover,
        IsSendOutcomeByEmail,
        HasAgeDestinationDuration,
        IsDutyOfDisclosure,
        IsCruise,
        isAnnualMultiTrip,
        isWinterSport,
        isOnlineAssessment,
        OnlineAssessment,
        0 EMCPremium,
        0 AgePremium,
        0 Excess,
        0 GeneralLimit,
        0 PaymentDuration,
        0 RestrictedConditions,
        0 OtherRestrictions,
        null PaymentComments,
        IsAwaitingMedicalReview,
        HasBeenTreatedLast12Months,
        HasVisitedDoctorLast90Days,
        IsSeekingMedicalOverseas,
        IsTravellingAgainstMedicalAdvice,
        HasDiagnosedTerminalCondition,
        HasReceviedAdviceTerminalCondition,
        MedicalTotalCount,
        MedicalApprovedCount,
        MedicalAutoAcceptCount,
        MedicalDeniedCount,
        MedicalAwaitingAssessmentCount,
        MedicalNotAssessedCount,
		IsMultipleDestinations,
		IsAccepted
    from
        etl_emcApplications

end


GO
