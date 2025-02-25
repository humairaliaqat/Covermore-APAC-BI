USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbCase]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_cbCase]
as
begin
/*
20131014, LS,   add new risk columns
                move deleted flag to audit ETL (change from scanning source server to use audit action)
20131129, LS,   read case type from master table
20131202, LS,    case management
20131216, LS,   bug fix, invalid expire dates
20140225, LS,   lookup program description from master table
                CaseType set to blank when null
20140331, LS,   bug fix, invalid departure dates
20140410, LS,   fix policy link
20140715, LS,   TFS12109
                enlarge column size
                change column type
                use transaction (as carebase has intra-day refreshes)
                lookup master data for incident & catastrophe
20140820, LS,   use Client's DomainCode for Country
20150720, LS,   T16930, Carebase 4.6, additional columns
20151020, LT,   added error trapping to cc.POLICY_NO (ie
20181029, LL,   add CustomerID
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    /* case */
    if object_id('[db-au-cmdwh].dbo.cbCase') is null
    begin

        create table [db-au-cmdwh].dbo.cbCase
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [CaseKey] nvarchar(20) not null,
            [LinkedCaseKey] nvarchar(20) null,
            [OpenedByKey] nvarchar(35) null,
            [ClosedByKey] nvarchar(35) null,
            [CaseNo] nvarchar(15) not null,
            [LinkedCaseNo] nvarchar(15) null,
            [CreateDate] datetime null,
            [CreateTimeUTC] datetime null,
            [OpenDate] datetime null,
            [OpenTime] datetime null,
            [OpenTimeUTC] datetime null,
            [CloseDate] datetime null,
            [CloseTimeUTC] datetime null,
            [FirstCloseDate] datetime null,
            [FirstCloseTimeUTC] datetime null,
            [FirstClosedByID] nvarchar(30) null,
            [FirstClosedBy] nvarchar(55) null,
            [OpenedByID] nvarchar(30) null,
            [OpenedBy] nvarchar(55) null,
            [ClosedByID] nvarchar(30) null,
            [ClosedBy] nvarchar(55) null,
            [TimeInCase] numeric(9,3) null,
            [Team] nvarchar(50) null,
            [CaseStatus] nvarchar(10) null,
            [CaseType] nvarchar(255) null,
            [CaseCode] nvarchar(5) null,
            [CaseDescription] nvarchar(4000) null,
            [TotalEstimate] int null,
            [IsDeleted] bit null,
            [DisorderType] nvarchar(100) null,
            [DisorderSubType] nvarchar(100) null,
            [MedicalCode] nvarchar(10) null,
            [DiagnosticCategory] nvarchar(250) null,
            [ARDRGRange] nvarchar(15) null,
            [MedicalSurgical] nvarchar(10) not null,
            [ResearchSpecific] nvarchar(100) null,
            [DisasterDate] datetime null,
            [Disaster] nvarchar(100) null,
            [DisasterCountry] nvarchar(25) null,
            [FirstName] nvarchar(100) null,
            [Surname] nvarchar(100) null,
            [Sex] nvarchar(1) null,
            [DOB] varbinary(100) null,
            [Location] nvarchar(200) null,
            [CountryCode] nvarchar(3) null,
            [Country] nvarchar(25) null,
            [ProtocolCode] nvarchar(1) null,
            [Protocol] nvarchar(10) not null,
            [ClientCode] nvarchar(2) null,
            [ClientName] nvarchar(100) null,
            [ProgramCode] nvarchar(2) null,
            [Program] nvarchar(35) null,
            [IncidentType] nvarchar(60) null,
            [ClaimNo] nvarchar(40) null,
            [Catastrophe] nvarchar(50) null,
            [UWCoverID] int null,
            [UWCoverStatus] nvarchar(100) null,
            [RiskLevel] nvarchar(50) null,
            [RiskReason] nvarchar(100) null,
            [CultureCode] nvarchar(10) null,
            [CaseFee] money,
            [HasReviewCheck] bit,
            [HasReviewCompleted] bit,
            [HasSoughtMedicalCare] bit,
            [IsCustomerHospitalised] bit,
            [HasMedicalSteerageOccured] bit,
			[CustomerID] bigint null
        )

        create clustered index idx_cbCase_BIRowID on [db-au-cmdwh].dbo.cbCase(BIRowID)
        create nonclustered index idx_cbCase_CaseKey on [db-au-cmdwh].dbo.cbCase(CaseKey) include (ClientCode,Protocol)
        create nonclustered index idx_cbCase_CaseNo on [db-au-cmdwh].dbo.cbCase(CaseNo,CountryKey)
        create nonclustered index idx_cbCase_CaseStatus on [db-au-cmdwh].dbo.cbCase(CaseStatus,IsDeleted) include (CaseKey,CaseNo)
        create nonclustered index idx_cbCase_ClientCode on [db-au-cmdwh].dbo.cbCase(ClientCode)
        create nonclustered index idx_cbCase_ClientName on [db-au-cmdwh].dbo.cbCase(ClientName) include (Country,Protocol,ClientCode)
        create nonclustered index idx_cbCase_CloseDate on [db-au-cmdwh].dbo.cbCase(CloseDate,IsDeleted) include (ClientName,CaseKey,CaseNo,ClosedBy)
        create nonclustered index idx_cbCase_ClosedByKey on [db-au-cmdwh].dbo.cbCase(ClosedByKey)
        create nonclustered index idx_cbCase_FirstCloseDate on [db-au-cmdwh].dbo.cbCase(FirstCloseDate,IsDeleted) include (CaseKey,CaseNo,ClientCode,ClientName)
        create nonclustered index idx_cbCase_OpenDate on [db-au-cmdwh].dbo.cbCase(OpenDate,IsDeleted) include (OpenTimeUTC,CaseKey,ClientCode,ClientName)
        create nonclustered index idx_cbCase_OpenedByKey on [db-au-cmdwh].dbo.cbCase(OpenedByKey)
        create nonclustered index idx_cbCase_OpenTime on [db-au-cmdwh].dbo.cbCase(OpenTime)
        create nonclustered index idx_cbCase_RiskLevel on [db-au-cmdwh].dbo.cbCase(RiskLevel)
        create nonclustered index idx_cbCase_UWCoverStatus on [db-au-cmdwh].dbo.cbCase(UWCoverStatus)
		create nonclustered index idx_cbCase_CustomerID on [db-au-cmdwh].dbo.cbCase(CustomerID) include (BIRowID)

    end

    if object_id('tempdb..#cbCase') is not null
        drop table #cbCase

    select
        /* case details */
        isnull(DomainCountry, 'AU') CountryKey,
        left('AU-' + CASE_NO, 20) CaseKey,
        left('AU-' + LINKCASE_NO, 20) LinkedCaseKey,
        left('AU-' + AC, 35) OpenedByKey,
        left('AU-' + CLOSED_BY, 35) ClosedByKey,
        CASE_NO CaseNo,
        LINKCASE_NO LinkedCaseNo,
        dbo.xfn_ConvertUTCtoLocal(CREATED_DT, 'AUS Eastern Standard Time') CreateDate,
        CREATED_DT CreateTimeUTC,
        convert(date, dbo.xfn_ConvertUTCtoLocal(OPEN_DATE, 'AUS Eastern Standard Time')) OpenDate,
        dbo.xfn_ConvertUTCtoLocal(OPEN_DATE, 'AUS Eastern Standard Time') OpenTime,
        OPEN_DATE OpenTimeUTC,
        dbo.xfn_ConvertUTCtoLocal(CLOSE_DATE, 'AUS Eastern Standard Time') CloseDate,
        CLOSE_DATE CloseTimeUTC,
        AC OpenedByID,
        OpenedBy,
        CLOSED_BY ClosedByID,
        ClosedBy,
        TimeInCase,
        Team,
        case
            when STATUS = 'C' then 'Closed'
            when STATUS = 'O' then 'Open'
            when STATUS = 'T' then 'Incomplete'
        end CaseStatus,
        isnull(ct.CT_DESCRIPTION, '') CaseType,
        CASE_CODE CaseCode,
        case_descript CaseDescription,
        TOT_EST TotalEstimate,
        case
            when DELETED = 'Y' then 1
            else 0
        end IsDeleted,
        DisorderType,
        DisorderSubType,
        MedicalCode,
        DiagnosticCategory,
        ARDRGRange,
        case
            when MEDICAL_SURGICAL = 'M' then 'Medical'
            else 'Surgical'
        end MedicalSurgical,
        RESEARCH_SPECIFIC ResearchSpecific,
        DisasterDate,
        Disaster,
        DIsasterCountry,

        /* customer details */
        FIRST FirstName,
        SURNAME Surname,
        Sex,
        EncryptDOB DOB,
        LOC_DESC Location,
        CNTRY_CODE CountryCode,
        Country,

        /* claim details */
        PROB_TYPE ProtocolCode,
        case
            when PROB_TYPE = 'M' then 'Medical'
            when PROB_TYPE = 'T' then 'Technical'
            else 'Undefined'
        end Protocol,
        CLI_CODE ClientCode,
        ClientName,
        POL_CODE ProgramCode,
        ProgramDescription Program,
        isnull(IncidentType, INCIDENT_TYPE) IncidentType,
        CLAIM_NUM ClaimNo,
        isnull(Catastrophe, CAT_CODE) Catastrophe,
        UWCOVERSTATUS_ID UWCoverID,
        UWCoverStatus,
        RiskLevel,
        RiskReason,
        CultureCode,
        Case_Fee CaseFee,
        HasReviewCheck,
        HasReviewCompleted,
        MedicalCareSort HasSoughtMedicalCare,
        CustomerHospitalised IsCustomerHospitalised,
        MedicalSteerageOccured HasMedicalSteerageOccured
    into #cbCase
    from
        carebase_CMN_MAIN_aucm cm
        left join carebase_UCT_CASETYPE_aucm ct on
            ct.CT_ID = cm.CASETYPE_ID
        outer apply
        (
            select top 1
                CLI_DESC ClientName,
                DomainCode DomainCountry
            from
                carebase_PCL_CLIENT_aucm cl
            where
                cl.CLI_CODE = cm.CLI_CODE
        ) cl
        outer apply
        (
            select top 1
                CNTRY_DESC Country
            from
                carebase_UCO_COUNTRY_aucm co
            where
                co.CNTRY_CODE = cm.CNTRY_CODE
        ) co
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME OpenedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = cm.AC
        ) ob
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME ClosedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = cm.CLOSED_BY
        ) cb
        outer apply
        (
            select top 1
                DISORDERDESC DisorderType
            from
                carebase_DISORDER_TYPE_aucm dt
            where
                dt.DISORDER_ID = cm.DISORDER_TYPE
        ) dt
        outer apply
        (
            select top 1
                SUBTYPEDESC DisorderSubType
            from
                carebase_DISORDER_SUBTYPE_aucm dst
            where
                dst.SUBTYPEID = cm.DISORDER_SUBTYPE
        ) dst
        outer apply
        (
            select top 1
                MDC MedicalCode,
                MDC_DESCRIPTION DiagnosticCategory,
                AR_DRG_RANGE ARDRGRange
            from
                carebase_DIAGNOSTIC_CATEGORY_aucm dx
            where
                dx.DX_CAT_ID = cm.DX_CAT_ID
        ) dx
        outer apply
        (
            select top 1
                DISASTER_DATE DisasterDate,
                DISASTER_DESC Disaster,
                CNTRY_DESC DIsasterCountry
            from
                carebase_DISASTERS_aucm ds
                left join carebase_UCO_COUNTRY_aucm co on
                    co.CNTRY_CODE = ds.CNTRY_CODE
            where
                ds.DISASTER_ID = cm.DISASTER_ID
        ) ds
        outer apply
        (
            select top 1
                TEAM_DESC Team
            from
                carebase_TEAMS_aucm tm
                inner join carebase_TEAMS_CLIENT_aucm tc on
                    tc.TEAM_ID = tm.TEAM_ID
            where
                tc.CLI_CODE = cm.CLI_CODE
        ) tm
        outer apply
        (
            select top 1
                [DESCRIPTION] UWCoverStatus
            from
                carebase_tblUWCoverStatus_aucm uw
            where
                uw.UWCOVERSTATUS_ID = cm.UWCOVERSTATUS_ID
        ) uw
        outer apply
        (
            select top 1
                rl.DESCRIPTION RiskLevel
            from
                carebase_tblRiskLevels_aucm rl
            where
                rl.RISKLEVEL_ID = cm.RISKLEVEL_ID
        ) rl
        outer apply
        (
            select top 1
                rr.DESCRIPTION RiskReason
            from
                carebase_tblRiskReasons_aucm rr
            where
                rr.RISKREASON_ID = cm.RISKREASON_ID
        ) rr
        outer apply
        (
            select top 1
                pd.POL_DESC ProgramDescription
            from
                carebase_POL_POLICY_aucm pd
            where
                pd.CLI_CODE = cm.CLI_CODE and
                pd.POL_CODE = cm.POL_CODE
        ) pd
        outer apply
        (
            select top 1
                it.INCIDENT_TYPE IncidentType
            from
                carebase_NIT_INCIDENTTYPE_aucm it
            where
                it.ID = cm.INCIDENTTYPE_ID
        ) it
        outer apply
        (
            select top 1
                cat.CAT_CODE Catastrophe
            from
                carebase_tblClientCatCodes_aucm cat
            where
                cat.CATCODE_ID = cm.CATCODE_ID
        ) cat


    begin transaction cbCase

    begin try

        delete
        from [db-au-cmdwh].dbo.cbCase
        where
            CaseKey in
            (
                select
                    left('AU-' + CASE_NO, 20) collate database_default
                from
                    carebase_CMN_MAIN_aucm
            )

        insert into [db-au-cmdwh].dbo.cbCase with(tablock)
        (
            CountryKey,
            CaseKey,
            LinkedCaseKey,
            OpenedByKey,
            ClosedByKey,
            CaseNo,
            LinkedCaseNo,
            CreateDate,
            CreateTimeUTC,
            OpenDate,
            OpenTime,
            OpenTimeUTC,
            CloseDate,
            CloseTimeUTC,
            OpenedByID,
            OpenedBy,
            ClosedByID,
            ClosedBy,
            TimeInCase,
            Team,
            CaseStatus,
            CaseType,
            CaseCode,
            CaseDescription,
            TotalEstimate,
            IsDeleted,
            DisorderType,
            DisorderSubType,
            MedicalCode,
            DiagnosticCategory,
            ARDRGRange,
            MedicalSurgical,
            ResearchSpecific,
            DisasterDate,
            Disaster,
            DisasterCountry,
            FirstName,
            Surname,
            Sex,
            DOB,
            Location,
            CountryCode,
            Country,
            ProtocolCode,
            Protocol,
            ClientCode,
            ClientName,
            ProgramCode,
            Program,
            IncidentType,
            ClaimNo,
            Catastrophe,
            UWCoverID,
            UWCoverStatus,
            RiskLevel,
            RiskReason,
            CultureCode,
            CaseFee,
            HasReviewCheck,
            HasReviewCompleted,
            HasSoughtMedicalCare,
            IsCustomerHospitalised,
            HasMedicalSteerageOccured
        )
        select
            CountryKey,
            CaseKey,
            LinkedCaseKey,
            OpenedByKey,
            ClosedByKey,
            CaseNo,
            LinkedCaseNo,
            CreateDate,
            CreateTimeUTC,
            OpenDate,
            OpenTime,
            OpenTimeUTC,
            CloseDate,
            CloseTimeUTC,
            OpenedByID,
            OpenedBy,
            ClosedByID,
            ClosedBy,
            TimeInCase,
            Team,
            CaseStatus,
            CaseType,
            CaseCode,
            CaseDescription,
            TotalEstimate,
            IsDeleted,
            DisorderType,
            DisorderSubType,
            MedicalCode,
            DiagnosticCategory,
            ARDRGRange,
            MedicalSurgical,
            ResearchSpecific,
            DisasterDate,
            Disaster,
            DisasterCountry,
            FirstName,
            Surname,
            Sex,
            DOB,
            Location,
            CountryCode,
            Country,
            ProtocolCode,
            Protocol,
            ClientCode,
            ClientName,
            ProgramCode,
            Program,
            IncidentType,
            ClaimNo,
            Catastrophe,
            UWCoverID,
            UWCoverStatus,
            RiskLevel,
            RiskReason,
            CultureCode,
            CaseFee,
            HasReviewCheck,
            HasReviewCompleted,
            HasSoughtMedicalCare,
            IsCustomerHospitalised,
            HasMedicalSteerageOccured
        from
            #cbCase

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbCase

        exec syssp_genericerrorhandler 'cbCase data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbCase


    /* policy */
    if object_id('[db-au-cmdwh].dbo.cbPolicy') is null
    begin

        create table [db-au-cmdwh].dbo.cbPolicy
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [CaseKey] nvarchar(20) not null,
            [TRIPSPolicyKey] nvarchar(41) null,
            [PolicyTransactionKey] nvarchar(41) null,
            [CaseNo] nvarchar(15) not null,
            [IsMainPolicy] bit not null,
            [PolicyNo] nvarchar(25) null,
            [IssueDate] datetime null,
            [ExpiryDate] datetime null,
            [VerifyDate] datetime null,
            [VerifiedBy] nvarchar(10) null,
            [ConsultantInitial] nvarchar(30) null,
            [PolicyType] nvarchar(25) null,
            [SingleFamily] nvarchar(15) null,
            [PlanCode] nvarchar(15) null,
            [DepartureDate] datetime null,
            [InsurerName] nvarchar(20) null,
            [Excess] int null,
            [ProductCode] nvarchar(3) null
        )

        create clustered index idx_cbPolicy_BIRowID on [db-au-cmdwh].dbo.cbPolicy(BIRowID)
        create nonclustered index idx_cbPolicy_CaseKey on [db-au-cmdwh].dbo.cbPolicy(CaseKey,IsMainPolicy,PolicyNo)
        create nonclustered index idx_cbPolicy_CaseNo on [db-au-cmdwh].dbo.cbPolicy(CaseNo,CountryKey)
        create nonclustered index idx_cbPolicy_PolicyNo on [db-au-cmdwh].dbo.cbPolicy(PolicyNo) include (CaseKey,CaseNo)
        create nonclustered index idx_cbPolicy_PolicyTransactionKey on [db-au-cmdwh].dbo.cbPolicy(PolicyTransactionKey,CaseKey) include (PolicyNo)
        create nonclustered index idx_cbPolicy_TRIPSPolicyKey on [db-au-cmdwh].dbo.cbPolicy(TRIPSPolicyKey)

    end

    if object_id('tempdb..#cbPolicy') is not null
        drop table #cbPolicy

    select
        /* case details */
        'AU' CountryKey,
        left('AU-' + CASE_NO, 20) CaseKey,
        p.TRIPSPolicyKey,
        pp.PolicyTransactionKey,
        CASE_NO CaseNo,
        1 IsMainPolicy,
        POLICY_NO PolicyNo,
        ISSUED IssueDate,
        case
            when year(EXPIRES) < 1900 then null
            else EXPIRES
        end ExpiryDate,
        DATE_VER1 VerifyDate,
        VER_BY1 VerifiedBy,
        POL_AC1 ConsultantInitial,
        TYPE_POL PolicyType,
        FAM_SING SingleFamily,
        POL_PLAN PlanCode,
        case
            when year(DEP_DATE) < 1900 then null
            else DEP_DATE
        end DepartureDate,
        NAME_INS1 InsurerName,
        POL_EXCESS Excess,
        CM_PRODCODE ProductCode
    into #cbPolicy
    from
        carebase_CMN_MAIN_aucm cc
        cross apply
        (
            select
                case
                    when CLI_CODE in ('AI', 'AW', 'MN', 'NZ', 'TZ', 'WE') then 'NZ'
                    when CLI_CODE in ('UK') then 'UK'
                    when CLI_CODE in ('MM') then 'MY'
                    when CLI_CODE in ('MS') then 'SG'
                    else 'AU'
                end CountryKey,
                case
                    when CLI_CODE in ('AA', 'AU', 'ME') then 'TIP'
                    else 'CM'
                end CompanyKey
        ) keys
        outer apply
        (
            select top 1
                PolicyKey TRIPSPolicyKey
            from
                [db-au-cmdwh].dbo.penPolicy p
            where
                p.CountryKey = keys.CountryKey and
                p.PolicyNumber =
                    case
                        when cc.POLICY_NO is null then null
                        when cc.POLICY_NO like '% %' then null
                        when cc.POLICY_NO like '%(%' then null
                        when cc.POLICY_NO like '%)%' then null
                        when cc.POLICY_NO like '%.%' then null
                        when cc.POLICY_NO like '%,%' then null
                        when cc.POLICY_NO like '%$%' then null
                        when cc.POLICY_NO like '%\%' then null                                --20151020_LT added error trapping
                        when isnumeric(cc.POLICY_NO) = 1 and len(cc.POLICY_NO) < 10 then
                            convert(varchar(25), cc.POLICY_NO)
                        else null
                    end collate database_default
        ) p
        outer apply
        (
            select top 1
                PolicyTransactionKey
            from
                [db-au-cmdwh].dbo.penPolicyTransSummary pt
            where
                pt.CountryKey = keys.CountryKey and
                pt.PolicyNumber = cc.POLICY_NO collate database_default
        ) pp

    union all

    select
        'AU' CountryKey,
        left('AU-' + CASE_NO, 20) CaseKey,
        p.TRIPSPolicyKey,
        pp.PolicyTransactionKey,
        CASE_NO CaseNo,
        0 IsMainPolicy,
        POLICYNO2 PolicyNo,
        ISSUED2 IssueDate,
        case
            when year(EXPIRES2) < 1900 then null
            else EXPIRES2
        end ExpiryDate,
        DATE_VER2 VerifyDate,
        VER_BY2 VerifiedBy,
        POL_AC2 ConsultantInitial,
        TYPE_POL2 PolicyType,
        FAM_SING2 SingleFamily,
        POL_PLAN2 PlanCode,
        case
            when year(DEP_DATE2) < 1900 then null
            else DEP_DATE2
        end DepartureDate,
        NAME_INS2 InsurerName,
        0 Excess,
        '' ProductCode
    from
        carebase_CMN_MAIN_aucm cc
        cross apply
        (
            select
                case
                    when CLI_CODE in ('AI', 'AW', 'MN', 'NZ', 'TZ', 'WE') then 'NZ'
                    when CLI_CODE in ('UK') then 'UK'
                    when CLI_CODE in ('MM') then 'MY'
                    when CLI_CODE in ('MS') then 'SG'
                    else 'AU'
                end CountryKey,
                case
                    when CLI_CODE in ('AA', 'AU', 'ME') then 'TIP'
                    else 'CM'
                end CompanyKey
        ) keys
        outer apply
        (
            select top 1
                PolicyKey TRIPSPolicyKey
            from
                [db-au-cmdwh].dbo.penPolicy p
            where
                CountryKey = keys.CountryKey and
                p.PolicyNumber =
                    case
                        when cc.POLICYNO2 is null then null
                        when cc.POLICYNO2 like '% %' then null
                        when cc.POLICYNO2 like '%(%' then null
                        when cc.POLICYNO2 like '%)%' then null
                        when cc.POLICYNO2 like '%.%' then null
                        when cc.POLICYNO2 like '%,%' then null
                        when cc.POLICYNO2 like '%$%' then null
                        when cc.POLICYNO2 like '%/%' then null
                        when isnumeric(cc.POLICYNO2) = 1 and len(cc.POLICYNO2) < 10 then
                            convert(varchar(25), cc.POLICYNO2)
                        else null
                    end collate database_default
        ) p
        outer apply
        (
            select top 1
                PolicyTransactionKey
            from
                [db-au-cmdwh].dbo.penPolicyTransSummary pt
            where
                CountryKey = keys.CountryKey and
                pt.PolicyNumber = cc.POLICY_NO collate database_default
        ) pp
    where
        POLICYNO2 is not null


    begin transaction cbPolicy

    begin try

        delete
        from [db-au-cmdwh].dbo.cbPolicy
        where
            CaseKey in
            (
                select
                    left('AU-' + CASE_NO, 20) collate database_default
                from
                    carebase_CMN_MAIN_aucm
            )

        insert into [db-au-cmdwh].dbo.cbPolicy with(tablock)
        (
            CountryKey,
            CaseKey,
            TRIPSPolicyKey,
            PolicyTransactionKey,
            CaseNo,
            IsMainPolicy,
            PolicyNo,
            IssueDate,
            ExpiryDate,
            VerifyDate,
            VerifiedBy,
            ConsultantInitial,
            PolicyType,
            SingleFamily,
            PlanCode,
            DepartureDate,
            InsurerName,
            Excess,
            ProductCode
        )
        select
            CountryKey,
            CaseKey,
            TRIPSPolicyKey,
            PolicyTransactionKey,
            CaseNo,
            IsMainPolicy,
            PolicyNo,
            IssueDate,
            ExpiryDate,
            VerifyDate,
            VerifiedBy,
            ConsultantInitial,
            PolicyType,
            SingleFamily,
            PlanCode,
            DepartureDate,
            InsurerName,
            Excess,
            ProductCode
        from
            #cbPolicy

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbPolicy

        exec syssp_genericerrorhandler 'cbPolicy data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbPolicy


    /* case management */
    if object_id('[db-au-cmdwh].dbo.cbCaseManagement') is null
    begin

        create table [db-au-cmdwh].dbo.cbCaseManagement
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [CaseKey] nvarchar(20) not null,
            [CaseManagementKey] nvarchar(20) null,
            [CaseNo] nvarchar(15) not null,
            [CaseManagementID] int not null,
            [CSIData] nvarchar(max) not null,
            [TemplateName] nvarchar(200) null
        )

        create clustered index idx_cbCaseManagement_BIRowID on [db-au-cmdwh].dbo.cbCaseManagement(BIRowID)
        create nonclustered index idx_cbCaseManagement_CaseKey on [db-au-cmdwh].dbo.cbCaseManagement(CaseKey)

    end

    if object_id('tempdb..#cbCaseManagement') is not null
        drop table #cbCaseManagement

    select
        'AU' CountryKey,
        left('AU-' + CASE_NO, 20) CaseKey,
        left('AU-' + convert(varchar, CaseMgtID), 20) CaseManagementKey,
        Case_No CaseNo,
        CaseMgtID CaseManagementID,
        CSIData,
        TemplateName
    into #cbCaseManagement
    from
        carebase_tblCaseManagement_aucm cm
        inner join carebase_tblCMTemplates_aucm cmt on
            cmt.TemplateID = cm.TemplateID


    begin transaction cbCaseManagement

    begin try

        delete
        from [db-au-cmdwh].dbo.cbCaseManagement
        where
            CaseManagementKey in
            (
                select
                    left('AU-' + convert(varchar, CaseMgtID), 20) collate database_default
                from
                    carebase_tblCaseManagement_aucm
            )

        insert into [db-au-cmdwh].dbo.cbCaseManagement with(tablock)
        (
            CountryKey,
            CaseKey,
            CaseManagementKey,
            CaseNo,
            CaseManagementID,
            CSIData,
            TemplateName
        )
        select
            CountryKey,
            CaseKey,
            CaseManagementKey,
            CaseNo,
            CaseManagementID,
            CSIData,
            TemplateName
        from
            #cbCaseManagement

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbCaseManagement

        exec syssp_genericerrorhandler 'cbCaseManagement data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbCaseManagement


    /* update first closed */
    update cc
    set
        cc.FirstCloseDate = isnull(cn.FirstCloseDate, cc.CloseDate),
        cc.FirstCloseTimeUTC = isnull(cn.FirstCloseTimeUTC, cc.CloseTimeUTC),
        cc.FirstClosedByID = isnull(cn.FirstClosedByID, cc.ClosedByID),
        cc.FirstClosedBy = isnull(cn.FirstClosedBy, cc.ClosedBy)
    from
        [db-au-cmdwh].dbo.cbCase cc
        outer apply
        (
            select top 1
                CreateDate FirstCloseDate,
                CreateTimeUTC FirstCloseTimeUTC,
                cn.UserID FirstClosedByID,
                cn.UserName FirstClosedBy
            from
                [db-au-cmdwh].dbo.cbNote cn
            where
                cn.CaseKey = cc.CaseKey and
                cn.NoteCode = 'CC'
            order by
                CreateDate
        ) cn
    where
        cc.CaseKey in
        (
            select
                left('AU-' + CASE_NO, 20) collate database_default
            from
                carebase_CMN_MAIN_aucm
        )

end
GO
