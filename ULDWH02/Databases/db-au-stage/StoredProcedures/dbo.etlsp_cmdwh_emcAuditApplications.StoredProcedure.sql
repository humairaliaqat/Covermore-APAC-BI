USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_emcAuditApplications]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_cmdwh_emcAuditApplications]
as
begin
/*
    20121026, LS,   bug fix on company key duplicates due to merged subcompanies
    20140317, LS,   TFS 9410, UK data
	20151027, DM,	Penguin v16 Release Update Destination Column
	20151208, DM,	Penguin v16.5 Release update PolicyNo column length to varchar(50)
*/

    set nocount on

    exec etlsp_StagingIndex_EMC

    if object_id('[db-au-cmdwh].dbo.emcAuditApplications') is null
    begin

        create table [db-au-cmdwh].dbo.emcAuditApplications
        (
            CountryKey varchar(2) not null,
            ApplicationKey varchar(15) not null,
            AuditApplicationKey varchar(15) not null,
            CompanyKey varchar(10) null,
            ApplicationID int not null,
            AuditRecordID int not null,
            AuditDate datetime null,
            AuditUserLogin varchar(50) null,
            AuditUser varchar(255) null,
            AuditAction varchar(5) null,
            ApplicationType varchar(25) null,
            AgencyCode varchar(7) null,
            AssessorID int null,
            CreatorID int null,
            Priority varchar(50) null,
            CreateDate datetime null,
            ReceiveDate datetime null,
            AssessedDate datetime null,
            IsEndorsementSigned bit null,
            EndorsementDate datetime null,
            ApplicationStatus varchar(25) null,
            ApprovalStatus varchar(15) null,
            AgeApprovalStatus varchar(15) null,
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
            HasAgeDestinationDuration bit null,
            IsDutyOfDisclosure bit null,
            IsCruise bit null
        )

        create clustered index idx_emcAuditApplications_ApplicationKey on [db-au-cmdwh].dbo.emcAuditApplications(ApplicationKey)
        create index idx_emcAuditApplications_CountryKey on [db-au-cmdwh].dbo.emcAuditApplications(CountryKey)
        create index idx_emcAuditApplications_ApplicationID on [db-au-cmdwh].dbo.emcAuditApplications(ApplicationID, CountryKey)
        create index idx_emcAuditApplications_AuditApplicationKey on [db-au-cmdwh].dbo.emcAuditApplications(AuditApplicationKey)
        create index idx_emcAuditApplications_AuditDate on [db-au-cmdwh].dbo.emcAuditApplications(AuditDate, CountryKey)

    end

    if object_id('etl_emcAuditApplications') is not null
        drop table etl_emcAuditApplications

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), e.ClientID) ApplicationKey,
        dk.CountryKey + '-' + convert(varchar(12), e.RecID) AuditApplicationKey,
        dk.CountryKey + '-' + convert(varchar(4), Compid) + '-' + convert(varchar(3), isnull(dk.SubCompid, 0)) CompanyKey,
        e.ClientID ApplicationID,
        RecID AuditRecordID,
        AUDIT_DATETIME AuditDate,
        AUDIT_USERNAME AuditUserLogin,
        au.AuditUser,
        AUDIT_ACTION AuditAction,
        eat.ApplicationType,
        Alpha AgencyCode,
        AssessorID,
        CreatedByID CreatorID,
        ep.[Priority],
        EnteredDt CreateDate,
        ReceivedDt ReceiveDate,
        AssessedDt AssessedDate,
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
        AgeDestDuration HasAgeDestinationDuration,
        DutyOfDisclosure IsDutyOfDisclosure,
        Cruise IsCruise
    into etl_emcAuditApplications
    from
        emc_EMC_audit_tblemcApplications_AU e
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
                s.FullName AuditUser
            from
                emc_EMC_tblSecurity_AU s
            where
                s.Login = e.AUDIT_USERNAME
        ) au
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

    union

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), e.ClientID) ApplicationKey,
        dk.CountryKey + '-' + convert(varchar(12), e.RecID) AuditApplicationKey,
        dk.CountryKey + '-' + convert(varchar(4), Compid) + '-' + convert(varchar(3), isnull(dk.SubCompid, 0)) CompanyKey,
        e.ClientID ApplicationID,
        RecID AuditRecordID,
        AUDIT_DATETIME AuditDate,
        AUDIT_USERNAME AuditUserLogin,
        au.AuditUser,
        AUDIT_ACTION AuditAction,
        eat.ApplicationType,
        Alpha AgencyCode,
        AssessorID,
        CreatedByID CreatorID,
        ep.[Priority],
        EnteredDt CreateDate,
        ReceivedDt ReceiveDate,
        AssessedDt AssessedDate,
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
        AgeDestDuration HasAgeDestinationDuration,
        DutyOfDisclosure IsDutyOfDisclosure,
        Cruise IsCruise
    from
        emc_UKEMC_Audit_tblemcApplications_UK e
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
                s.FullName AuditUser
            from
                emc_UKEMC_tblSecurity_UK s
            where
                s.Login = e.AUDIT_USERNAME
        ) au
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


    delete ea
    from
        [db-au-cmdwh].dbo.emcAuditApplications ea
        inner join etl_emcAuditApplications t on
            t.AuditApplicationKey = ea.AuditApplicationKey


    insert into [db-au-cmdwh].dbo.emcAuditApplications with (tablock)
    (
        CountryKey,
        ApplicationKey,
        AuditApplicationKey ,
        CompanyKey,
        ApplicationID,
        AuditRecordID,
        AuditDate,
        AuditUserLogin,
        AuditUser,
        AuditAction,
        ApplicationType,
        AgencyCode,
        AssessorID,
        CreatorID,
        [Priority],
        CreateDate,
        ReceiveDate,
        AssessedDate,
        IsEndorsementSigned,
        EndorsementDate,
        ApplicationStatus,
        ApprovalStatus,
        AgeApprovalStatus,
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
        HasAgeDestinationDuration,
        IsDutyOfDisclosure,
        IsCruise
    )
    select
        CountryKey,
        ApplicationKey,
        AuditApplicationKey ,
        CompanyKey,
        ApplicationID,
        AuditRecordID,
        AuditDate,
        AuditUserLogin,
        AuditUser,
        AuditAction,
        ApplicationType,
        AgencyCode,
        AssessorID,
        CreatorID,
        [Priority],
        CreateDate,
        ReceiveDate,
        AssessedDate,
        IsEndorsementSigned,
        EndorsementDate,
        ApplicationStatus,
        ApprovalStatus,
        AgeApprovalStatus,
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
        HasAgeDestinationDuration,
        IsDutyOfDisclosure,
        IsCruise
    from
        etl_emcAuditApplications

end


GO
