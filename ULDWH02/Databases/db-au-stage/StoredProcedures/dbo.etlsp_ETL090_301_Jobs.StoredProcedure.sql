USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_301_Jobs]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_301_Jobs] 
AS
BEGIN

	SET NOCOUNT ON;

	-- Job => Case & CaseMember & ServiceFile & ServiceFileMember & ServiceFileWorker
	-- exclude all previously imported jobs 


	/*--------------------------------------------------------
							   Case						  
	pnpCase
		CaseSK
		FunderSK
		FunderDepartmentSK
		CaseID							'CLI_JOB_' + Job_ID (also lookup from previous migration)
		FunderID						'CLI_ORG_' + Org_ID (also lookup from previous migration)
		FunderDepartmentID				'CLI_GRP_' + Grp_ID / Sublevel_ID (also lookup from previous migration)
		NickName						ServiceType + coalesce(' ' + convert(varchar(8), OpenDate, 112), '') + coalesce(' ' + OJL.LocationName, '') 
		Status							Status
		Setting							
		HouseholdIncome					
		RelationshipStatus					
		FamilyStatus					
		casreldate
		casblendedf
		casotherinhome
		Accomodations
		casneap1
		JobImpact
		ViolenceThreat
		FamilySize
		CreatedDatetime					OpenDate
		UpdatedDatetime					ChangeDate
		CreatedBy						OpenBy
		UpdatedBy						ChangeUser
		FileNumber						Job_Num	
		UpdatedForRealDatetime			
		Summary							Comments
		Reopen
		ReopenDatetime
		FormalRef
		ReferralDatetime
		Referral
		CaseIntakeCreatedDatetime
		CaseIntakeUpdatedDatetime
		CaseIntakeCreatedBy
		CaseIntakeUpdatedBy		
		InvoiceText						InvoiceText
		PolicyReference
		PolicySK
		PolicyID
		ManualRevenueAccrual
	*/--------------------------------------------------------

	-- 1. transform 
	if object_id('tempdb..#jobs') is not null drop table #jobs 

	select 
		coalesce(convert(varchar, sfl.kcaseid), 'CLI_JOB_' + j.Job_ID) CaseID,
		coalesce(convert(varchar, sfl.kprogprovid), 'CLI_JOB_' + j.Job_ID) ServiceFileID,
		'CLI_ORG_' + coalesce(p.Org_ID, j.Org_ID) FunderID,
		--'CLI_GRP_' + case when j.Sublevel_ID is not null and j.Sublevel_ID <> '0' and j.Sublevel_ID <> '0z0' then j.Sublevel_ID else j.Group_ID end FunderDepartmentID,
		coalesce('CLI_GRP_' + coalesce(nullif(p.Sublevel_ID, '0'), nullif(p.Group_ID, '0')),
		'CLI_GRP_' + case when j.Sublevel_ID is not null and j.Sublevel_ID <> '0' and j.Sublevel_ID <> '0z0' then j.Sublevel_ID collate database_default else j.Group_ID collate database_default end) FunderDepartmentID,
		st.ServiceType + coalesce(' ' + convert(varchar(8), j.OpenDate, 112), '') + coalesce(' ' + ojl.LocationName, '') NickName, 
		st.ServiceType,
		coalesce(convert(varchar, sfl.kagserid), 'CLI_SRV_' + cs.ServiceType_ID) ServiceID, 
		s.Stream,
		sp.Status, 
		j.OpenDate CreatedDatetime,
		j.ChangeDate UpdatedDatetime,
		j.OpenBy CreatedBy,
		j.ChangeUser UpdatedBy,
		j.Job_Num FileNumber,	
		j.Comments Summary,
		coalesce('CLI_PER_' + j.Per_ID, 'CLI_OJL_' + j.OrgJobLocation_ID) IndividualID,	-- use OrgJobLocation_ID if Per_ID is null
		j.IsFamilyMember, 
		'CLI_PER_' + j.Invoice_Person_ID BillIndividualID, 
		'CLI_USR_' + j.AssignTo WorkerID, 
		j.AssignDate,
		j.Job_Num ClienteleJobNumber,
		ojl.LocationName,
		j.CostCentre,
		j.InvoiceText,
		c.ContractNumber PolicyReference,
		'CLI_CON_' + c.Contract_id PolicyID,
		j.ManualRevenueAccrual,
		j.CustomerRefCode 
	into #jobs 
	from 
		[db-au-stage].dbo.dtc_cli_job j 
		join [db-au-stage].dbo.dtc_cli_ContractService cs on cs.ContractService_id = j.ContractService_id collate database_default
		join [db-au-stage].dbo.dtc_cli_ServiceType st on st.ServiceType_ID = cs.ServiceType_ID 
		left join [db-au-stage].dbo.dtc_cli_OrgJobLocation ojl on ojl.OrgJobLocation_ID = j.OrgJobLocation_ID collate database_default 
		left join [db-au-stage].dbo.dtc_cli_Base_Job bj on bj.Job_id = j.Job_ID collate database_default 
		left join [db-au-stage].dbo.dtc_cli_ServiceFile_Lookup sfl on sfl.uniquecaseid = bj.Pene_id 
		left join [db-au-stage].dbo.dtc_cli_Person p on p.Per_ID = j.Per_ID collate database_default 
		left join [db-au-stage].dbo.dtc_cli_Contract c on cs.Contract_ID = c.Contract_ID 
		left join [db-au-dtc]..pnpService s on s.ServiceID = coalesce(convert(varchar, sfl.kagserid), 'CLI_SRV_' + cs.ServiceType_ID) 
		left join [db-au-stage]..dtc_cli_paprojct sp on sp.project_code = j.Job_Num 
	where 
		j.Org_ID <> 'oldham44D118A4005F44B4AF5669F0F1' 
		and sfl.kcaseid is null	

	
	-- create lookup table for funder
	if object_id('tempdb..#funder') is not null drop table #funder 

	select 
		f.FunderSK,
		f.FunderID FunderID,
		coalesce('CLI_ORG_' + bo.Org_id, f.FunderID) ClienteleOrgID		 
	into #funder
	from 
		[db-au-dtc].dbo.pnpFunder f 
		left join [db-au-stage].dbo.dtc_cli_org_lookup ol on convert(varchar, ol.kfunderid) = f.FunderID 
		left join [db-au-stage].dbo.dtc_cli_base_org bo on bo.Pene_id = ol.uniquefunderid 
	where 
		f.IsCurrent = 1

	create index idx_tmp_funder_funderid on #funder (ClienteleOrgID)
	
	-- create lookup table for funderdepartment
	if object_id('tempdb..#funderdepartment') is not null drop table #funderdepartment 

	select 
		fd.FunderDepartmentSK,
		fd.FunderDepartmentID FunderDepartmentID,
		coalesce('CLI_GRP_' + bg.Group_ID, fd.FunderDepartmentID) ClienteleGroupID 
	into #funderdepartment
	from 
		[db-au-dtc].dbo.pnpFunderDepartment fd 
		left join [db-au-stage].dbo.dtc_cli_group_lookup gl on convert(varchar, gl.kfunderdeptid) = fd.FunderDepartmentID 
		left join [db-au-stage].dbo.dtc_cli_base_group bg on bg.Pene_id = gl.uniquedepartmentid 
		
	create index idx_tmp_funderdepartment_funderdepartmentid on #funderdepartment (ClienteleGroupID)	
	
	
	if object_id('tempdb..#case') is not null drop table #case 

	select 
		f.FunderSK,
		f.FunderID PenelopeFunderID,
		fd.FunderDepartmentSK,
		fd.FunderDepartmentID PenelopeFunderDepartmentID,
		j.* 
	into #case
	from 
		#jobs j 
		left join #funder f on f.ClienteleOrgID = j.FunderID
		left join #funderdepartment fd on fd.ClienteleGroupID = j.FunderDepartmentID 

	
	-- 2. load
	merge [db-au-dtc]..pnpCase as tgt
	using #case 
		on #case.CaseID = tgt.CaseID
	when not matched by target then 
		insert (
			FunderSK,
			FunderDepartmentSK,
			CaseID,
			FunderID,
			FunderDepartmentID,
			NickName,
			Status,
			CreatedDateTime,
			UpdatedDateTime,
			CreatedBy,
			UpdatedBy,
			FileNumber,
			Summary,
			CostCentre,
			Location,
			Referral
		)
		values (
			#case.FunderSK,
			#case.FunderDepartmentSK,
			#case.CaseID,
			#case.PenelopeFunderID,
			#case.PenelopeFunderDepartmentID,
			#case.NickName,
			#case.Status,
			#case.CreatedDateTime,
			#case.UpdatedDateTime,
			#case.CreatedBy,
			#case.UpdatedBy,
			#case.FileNumber,
			#case.Summary,
			#case.CostCentre,
			#case.LocationName,
			#case.CustomerRefCode
		)
	when matched then update set 
		tgt.FunderSK = #case.FunderSK,
		tgt.FunderDepartmentSK = #case.FunderDepartmentSK,
		tgt.FunderID = #case.PenelopeFunderID,
		tgt.FunderDepartmentID = #case.PenelopeFunderDepartmentID,
		tgt.NickName = #case.NickName,
		tgt.Status = #case.Status,
		tgt.CreatedDateTime = #case.CreatedDateTime,
		tgt.UpdatedDateTime = #case.UpdatedDateTime,
		tgt.CreatedBy = #case.CreatedBy,
		tgt.UpdatedBy = #case.UpdatedBy,
		tgt.FileNumber = #case.FileNumber,
		tgt.Summary = #case.Summary,
		tgt.CostCentre = #case.CostCentre,
		tgt.Location = #case.LocationName,
		tgt.Referral = #case.CustomerRefCode
	;
	
	
	/*--------------------------------------------------------
							CaseMember
	pnpCaseMember
		CaseMemberSK					
		CaseSK							pnpCase.CaseSK
		IndividualSK					outer apply ('CLI_PER_' + Per_ID) (also lookup from previous migration)
		CaseMemberID					'CLI_JOB_' + Job_ID
		Relationship					case when ServiceType in ('traumaAssist - Case Management','Change@Work R - Case Management') then 'Customer/Org' when IsFamilyMember = 0 then 'Family Member' else 'Self' end
		SafetyFlag
		IsCaseInitiator					'1'
		IsPrimaryClient					'1'
		CreatedDatetime					OpenDate
		UpdatedDatetime					UpdateDate			
	*/--------------------------------------------------------
	
	
	-- trauma case will have null in the Per_ID column 
	-- need to create dummy individual records from OrgJobLocation
	if object_id('tempdb..#ojl') is not null drop table #ojl 
	select 
		1 IsCurrent,
		'1900-01-01' StartDate,
		'9999-12-31' EndDate,
		f.FunderSK,
		'CLI_OJL_' + ojl.OrgJobLocation_ID IndividualID,
		'CLI_ORG_' + ojl.Org_ID FunderID, 
		case 
			when charindex(' ', ojl.Contact) > 0 then substring(ojl.Contact, 1, charindex(' ', ojl.Contact) - 1) 
			else ojl.Contact 
		end FirstName,
		case 
			when charindex(' ', ojl.Contact) > 0 then substring(ojl.Contact, charindex(' ', ojl.Contact) + 1, 8000)
		end LastName,
		ojl.LocationName WorkContact,
		ojl.Addr1 WorkAddressLine1,
		ojl.Addr2 WorkAddressLine2,
		ojl.Suburb WorkAddressCity,
		ojl.State WorkAddressState,
		ojl.Postcode WorkAddressPostcode,
		ojl.RSArriveDate CreatedDatetime,
		ojl.RSChangeDate UpdatedDatetime
	into #ojl 
	from 
		[db-au-stage]..dtc_cli_OrgJobLocation ojl 
		outer apply (
			select top 1 FunderSK 
			from [db-au-dtc]..pnpFunder 
			where FunderID = 'CLI_ORG_' + ojl.Org_ID and IsCurrent = 1 
		) f 
	where 
		not exists (
			select null from [db-au-stage]..dtc_cli_job j 
			where j.OrgJobLocation_ID = ojl.OrgJobLocation_ID collate database_default and j.Per_ID is not null
		)


	merge [db-au-dtc]..pnpIndividual tgt 
	using #ojl s on s.IndividualID = tgt.IndividualID 
	when not matched by target then 
		insert (
			IsCurrent,
			StartDate,
			EndDate,
			FunderSK,
			IndividualID,
			FunderID, 
			FirstName,
			LastName,
			WorkContact,
			WorkAddressLine1,
			WorkAddressLine2,
			WorkAddressCity,
			WorkAddressState,
			WorkAddressPostcode,
			CreatedDatetime,
			UpdatedDatetime
		)
		values (
			s.IsCurrent,
			s.StartDate,
			s.EndDate,
			s.FunderSK,
			s.IndividualID,
			s.FunderID, 
			s.FirstName,
			s.LastName,
			s.WorkContact,
			s.WorkAddressLine1,
			s.WorkAddressLine2,
			s.WorkAddressCity,
			s.WorkAddressState,
			s.WorkAddressPostcode,
			s.CreatedDatetime,
			s.UpdatedDatetime
		)
	when matched then update 
	set 
		tgt.IsCurrent = s.IsCurrent,
		tgt.StartDate = s.StartDate,
		tgt.EndDate = s.EndDate,
		tgt.FunderSK = s.FunderSK,
		tgt.FunderID = s.FunderID, 
		tgt.FirstName = s.FirstName,
		tgt.LastName = s.LastName,
		tgt.WorkContact = s.WorkContact,
		tgt.WorkAddressLine1 = s.WorkAddressLine1,
		tgt.WorkAddressLine2 = s.WorkAddressLine2,
		tgt.WorkAddressCity = s.WorkAddressCity,
		tgt.WorkAddressState = s.WorkAddressState,
		tgt.WorkAddressPostcode = s.WorkAddressPostcode,
		tgt.CreatedDatetime = s.CreatedDatetime,
		tgt.UpdatedDatetime = s.UpdatedDatetime
	;
	

	-- 1. transform (using the previous temp table for Jobs)

	-- create lookup table for individual
	if object_id('tempdb..#individual') is not null drop table #individual 

	select 
		i.IndividualSK,
		coalesce('CLI_PER_' + bp.Per_ID, i.IndividualID) IndividualID 
	into #individual 
	from 
		[db-au-dtc].dbo.pnpIndividual i 
		left join [db-au-stage].dbo.dtc_cli_person_lookup pl on convert(varchar, pl.kindid) = i.IndividualID 
		left join [db-au-stage].dbo.dtc_cli_base_person bp on bp.Pene_id = pl.uniqueindid 
	where 
		i.IsCurrent = 1
	
	create index idx_tmp_individual_individualid on #individual (IndividualID)	


	if object_id('tempdb..#casemember') is not null drop table #casemember 

	select 
		c.CaseSK,
		i.IndividualSK,
		j.CaseID CaseMemberID,
		case when ServiceType in ('traumaAssist - Case Management','Change@Work R - Case Management') then 'Customer/Org' when IsFamilyMember = 0 then 'Family Member' else 'Self' end Relationship,
		'1' IsCaseInitiator,
		'1' IsPrimaryClient,
		j.CreatedDatetime,
		j.UpdatedDatetime
	into #casemember
	from 
		#jobs j
		join [db-au-dtc].dbo.pnpCase c on c.CaseID = j.CaseID 
		join #individual i on i.IndividualID = j.IndividualID 
	

	-- 2. load 
	merge [db-au-dtc]..pnpCaseMember as tgt
	using #casemember 
		on #casemember.CaseMemberID = tgt.CaseMemberID
	when not matched by target then 
		insert (
			CaseSK,
			IndividualSK,
			CaseMemberID,
			Relationship,
			IsCaseInitiator,
			IsPrimaryClient,
			CreatedDatetime,
			UpdatedDatetime
		)
		values (
			#casemember.CaseSK,
			#casemember.IndividualSK,
			#casemember.CaseMemberID,
			#casemember.Relationship,
			#casemember.IsCaseInitiator,
			#casemember.IsPrimaryClient,
			#casemember.CreatedDatetime,
			#casemember.UpdatedDatetime
		)
	when matched then update set 
		tgt.CaseSK = #casemember.CaseSK,
		tgt.IndividualSK = #casemember.IndividualSK,
		tgt.Relationship = #casemember.Relationship,
		tgt.IsCaseInitiator = #casemember.IsCaseInitiator,
		tgt.IsPrimaryClient = #casemember.IsPrimaryClient,
		tgt.CreatedDatetime = #casemember.CreatedDatetime,
		tgt.UpdatedDatetime = #casemember.UpdatedDatetime
	;	
	


	/*
	pnpServiceFile
		ServiceFileSK
		ServiceSK
		CaseSK							
		FunderSK
		FunderDepartmentSK
		PrimaryWorkerUserSK
		PresentingServiceFileMemberSK
		BillIndividualSK				Invoice_Person_ID		
		SecBillIndividualSK
		RegServiceEventSK
		ServiceFileID					'CLI_JOB_' + Job_ID (also lookup from previous migration)
		CaseID							'CLI_JOB_' + Job_ID (also lookup from previous migration)
		FunderID						'CLI_ORG_' + Org_ID (also lookup from previous migration)
		FunderDepartmentID				'CLI_GRP_' + Grp_ID / Sublevel_ID (also lookup from previous migration)
		Service							ServiceType
		Stream
		WorkshopID
		PrimaryWorkerID					'CLI_USR_' + resource_code (also lookup from previous migration)
		SecWorkerID
		StartDate						OpenDate
		EndDate
		Status							Status
		BookOnly
		CreatedDatetime					OpenDate
		UpdatedDatetime					ChangeDate
		CreatedBy						OpenBy
		UpdatedBy						ChangeUser
		FeeOvr
		kppfunagreid
		SessionRemind
		DaysRemind
		EstimatedSessions
		BillIndividualPercent
		PresentingServiceFileMemberID
		RegServiceEventID
		ClienteleJobNumber				Job_Number	
		CostCentre
		InvoiceText						InvoiceText
		CounsellingType
		RelatedWorkImpact
		WorkImpactNature
		ReferralSource
		SelfReferralSource
		EmploymentPeriod
		WorkPlaceDiversityGroup
		CaseManagement
	*/

	-- 1. transform (using the previous temp table for Jobs)

	-- create lookup table for user
	if object_id('tempdb..#user') is not null drop table #user 

	select 
		u.UserSK,
		coalesce('CLI_USR_' + wl.uniqueworkerid, u.WorkerID) WorkerID 
	into #user 
	from 
		[db-au-dtc].dbo.pnpUser u  
		left join [db-au-stage].dbo.dtc_cli_Worker_Lookup wl on convert(varchar, wl.kcworkerid) = u.WorkerID 
	where 
		u.IsCurrent = 1 
		and u.WorkerID is not null 
	
	create index idx_tmp_user_workerid on #user (WorkerID)


	if object_id('tempdb..#servicefile') is not null drop table #servicefile 

	select 
		s.ServiceSK,
		c.CaseSK,
		f.FunderSK,
		f.FunderID PenelopeFunderID,
		fd.FunderDepartmentSK,
		fd.FunderDepartmentID PenelopeFunderDepartmentID,
		u.UserSK PrimaryWorkerUserSK,
		i.IndividualSK PresentingServiceFileMemberSK,
		bi.IndividualSK BillIndividualSK,
		j.ServiceFileID,
		j.CaseID,
		j.FunderID,
		j.FunderDepartmentID,
		j.ServiceType Service,
		j.Stream,
		j.WorkerID PrimaryWorkerID,
		j.CreatedDatetime StartDate,
		j.Status,
		j.CreatedDatetime,
		j.UpdatedDatetime,
		j.CreatedBy,
		j.UpdatedBy,
		j.CaseID PresentingServiceFileMemberID,
		j.ClienteleJobNumber,
		j.CostCentre,
		j.InvoiceText,
		j.PolicyReference,
		p.PolicySK,
		j.PolicyID,
		j.ManualRevenueAccrual
	into #servicefile
	from 
		#jobs j 
		join [db-au-dtc].dbo.pnpCase c on c.CaseID = j.CaseID 
		left join [db-au-dtc].dbo.pnpService s on s.ServiceID = j.ServiceID 
		left join #funder f on f.ClienteleOrgID = j.FunderID 
		left join #funderdepartment fd on fd.ClienteleGroupID = j.FunderDepartmentID 
		left join #user u on u.WorkerID = j.WorkerID 
		left join #individual i on i.IndividualID = j.IndividualID 
		left join #individual bi on bi.IndividualID = j.BillIndividualID 
		left join [db-au-dtc].dbo.pnpPolicy p on p.PolicyID = j.PolicyID 


	-- 2. load 
	merge [db-au-dtc].dbo.pnpServiceFile as tgt
	using #servicefile 
		on #servicefile.ServiceFileID = tgt.ServiceFileID
	when not matched by target then 
		insert (
			ServiceSK,
			CaseSK,
			FunderSK,
			FunderDepartmentSK,
			PrimaryWorkerUserSK,
			PresentingServiceFileMemberSK,
			BillIndividualSK,
			ServiceFileID,
			CaseID,
			FunderID,
			FunderDepartmentID,
			Service,
			Stream,
			PrimaryWorkerID,
			StartDate,
			Status,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,
			UpdatedBy,
			PresentingServiceFileMemberID,
			ClienteleJobNumber,
			CostCentre,
			InvoiceText,
			PolicyReference,
			PolicySK,
			PolicyID,
			ManualRevenueAccrual
		)
		values (
			#servicefile.ServiceSK,
			#servicefile.CaseSK,
			#servicefile.FunderSK,
			#servicefile.FunderDepartmentSK,
			#servicefile.PrimaryWorkerUserSK,
			#servicefile.PresentingServiceFileMemberSK,
			#servicefile.BillIndividualSK,
			#servicefile.ServiceFileID,
			#servicefile.CaseID,
			#servicefile.PenelopeFunderID,
			#servicefile.PenelopeFunderDepartmentID,
			#servicefile.Service,
			#servicefile.Stream,
			#servicefile.PrimaryWorkerID,
			#servicefile.StartDate,
			#servicefile.Status,
			#servicefile.CreatedDatetime,
			#servicefile.UpdatedDatetime,
			#servicefile.CreatedBy,
			#servicefile.UpdatedBy,
			#servicefile.PresentingServiceFileMemberID,
			#servicefile.ClienteleJobNumber,
			#servicefile.CostCentre,
			#servicefile.InvoiceText,
			#servicefile.PolicyReference,
			#servicefile.PolicySK,
			#servicefile.PolicyID,
			#servicefile.ManualRevenueAccrual
		)
	when matched then update set 
		tgt.ServiceSK = #servicefile.ServiceSK,
		tgt.CaseSK = #servicefile.CaseSK,
		tgt.FunderSK = #servicefile.FunderSK,
		tgt.FunderDepartmentSK = #servicefile.FunderDepartmentSK,
		tgt.PrimaryWorkerUserSK = #servicefile.PrimaryWorkerUserSK,
		tgt.PresentingServiceFileMemberSK = #servicefile.PresentingServiceFileMemberSK,
		tgt.BillIndividualSK = #servicefile.BillIndividualSK,
		tgt.CaseID = #servicefile.CaseID,
		tgt.FunderID = #servicefile.PenelopeFunderID,
		tgt.FunderDepartmentID = #servicefile.PenelopeFunderDepartmentID,
		tgt.Service = #servicefile.Service,
		tgt.Stream = #servicefile.Stream,
		tgt.PrimaryWorkerID = #servicefile.PrimaryWorkerID,
		tgt.StartDate = #servicefile.StartDate,
		tgt.Status = #servicefile.Status,
		tgt.CreatedDatetime = #servicefile.CreatedDatetime,
		tgt.UpdatedDatetime = #servicefile.UpdatedDatetime,
		tgt.CreatedBy = #servicefile.CreatedBy,
		tgt.UpdatedBy = #servicefile.UpdatedBy,
		tgt.PresentingServiceFileMemberID = #servicefile.PresentingServiceFileMemberID,
		tgt.ClienteleJobNumber = #servicefile.ClienteleJobNumber,
		tgt.CostCentre = #servicefile.CostCentre,
		tgt.InvoiceText = #servicefile.InvoiceText,
		tgt.PolicyReference = #servicefile.PolicyReference,
		tgt.PolicySK = #servicefile.PolicySK,
		tgt.PolicyID = #servicefile.PolicyID,
		tgt.ManualRevenueAccrual = #servicefile.ManualRevenueAccrual
	;	

	-- update LastActivityDatetime column 
	update sf
	set LastActivityDatetime = la.LastActivityDatetime
	from 
		[db-au-dtc]..pnpServiceFile sf 
		join (
			select 
				project_code, 
				max(tran_date) as LastActivityDatetime
			from 
				[db-au-stage]..dtc_cli_patrxdet 
			where tran_type = 1 
			group by 
				project_code
		) la 
			on la.project_code = sf.ClienteleJobNumber 


	/*	
	pnpServiceFileMember
		ServiceFileMemberSK
		ServiceFileSK
		IndividualSK
		FunderSK
		FunderDepartmentSK
		ServiceFileMemberID				'CLI_JOB_' + Job_ID
		Relationship					case when ServiceType in ('traumaAssist - Case Management','Change@Work R - Case Management') then 'Customer/Org' when IsFamilyMember = 0 then 'Family Member' else 'Self' end
		SafetyFlag
		IsCaseInitiator					'1'
		IsPrimaryClient					'1'
		PresentingIssue1
		PresentingIssueGroup1
		PresentingIssueGroupClass1
		PresentingIssue2
		PresentingIssueGroup2
		PresentingIssueGroupClass2
		PresentingIssue3
		PresentingIssueGroup3
		PresentingIssueGroupClass3
		CreatedDatetime					OpenDate
		UpdatedDatetime					ChangeDate
		luppmemberud1id
		luppmemberud2id
		ppmemberud3
		ppmemberud4
		consentpcehr
	*/

	-- 1. transform (using the previous temp table for Jobs)
	if object_id('tempdb..#servicefilemember') is not null drop table #servicefilemember 

	select 
		sf.ServiceFileSK,
		i.IndividualSK,
		f.FunderSK,
		fd.FunderDepartmentSK,
		j.CaseID ServiceFileMemberID,
		case when ServiceType in ('traumaAssist - Case Management','Change@Work R - Case Management') then 'Customer/Org' when IsFamilyMember = 0 then 'Family Member' else 'Self' end Relationship,
		'1' IsCaseInitiator,
		'1' IsPrimaryClient,
		j.CreatedDatetime,
		j.UpdatedDatetime
	into #servicefilemember
	from 
		#jobs j
		join [db-au-dtc].dbo.pnpServiceFile sf on sf.ServiceFileID = j.ServiceFileID 
		left join #funder f on f.FunderID = j.FunderID
		left join #funderdepartment fd on fd.FunderDepartmentID = j.FunderDepartmentID 
		join #individual i on i.IndividualID = j.IndividualID 

	-- 2. load 
	merge [db-au-dtc].dbo.pnpServiceFileMember as tgt
	using #servicefilemember 
		on #servicefilemember.ServiceFileMemberID = tgt.ServiceFileMemberID
	when not matched by target then 
		insert (
			ServiceFileSK,
			IndividualSK,
			FunderSK,
			FunderDepartmentSK,
			ServiceFileMemberID,
			Relationship,
			IsCaseInitiator,
			IsPrimaryClient,
			CreatedDatetime,
			UpdatedDatetime
		)
		values (
			#servicefilemember.ServiceFileSK,
			#servicefilemember.IndividualSK,
			#servicefilemember.FunderSK,
			#servicefilemember.FunderDepartmentSK,
			#servicefilemember.ServiceFileMemberID,
			#servicefilemember.Relationship,
			#servicefilemember.IsCaseInitiator,
			#servicefilemember.IsPrimaryClient,
			#servicefilemember.CreatedDatetime,
			#servicefilemember.UpdatedDatetime
		)
	when matched then update set 
		tgt.ServiceFileSK = #servicefilemember.ServiceFileSK,
		tgt.IndividualSK = #servicefilemember.IndividualSK,
		tgt.FunderSK = #servicefilemember.FunderSK,
		tgt.FunderDepartmentSK = #servicefilemember.FunderDepartmentSK,
		tgt.Relationship = #servicefilemember.Relationship,
		tgt.IsCaseInitiator = #servicefilemember.IsCaseInitiator,
		tgt.IsPrimaryClient = #servicefilemember.IsPrimaryClient,
		tgt.CreatedDatetime = #servicefilemember.CreatedDatetime,
		tgt.UpdatedDatetime = #servicefilemember.UpdatedDatetime
	;	

	-- PresentingServiceFileMemberSK in [db-au-dtc].dbo.pnpServiceFile
	update [db-au-dtc].dbo.pnpServiceFile
	set PresentingServiceFileMemberSK = sfm.ServiceFileMemberSK
	from [db-au-dtc].dbo.pnpServiceFile sf
        --20180321, LL, optimise
		--outer apply (
		cross apply (
			select top 1 ServiceFileMemberSK
			from [db-au-dtc].dbo.pnpServiceFileMember
			where ServiceFileMemberID = sf.PresentingServiceFileMemberID
		) sfm			
	where
		sf.PresentingServiceFileMemberSK <> sfm.ServiceFileMemberSK
		and LEFT(sf.ServiceFileID,3) = 'CLI'

	/*	
	pnpServiceFileWorker
		ServiceFileSK
		UserSK
		ServiceFileID					'CLI_JOB_' + Job_ID (also lookup from previous migration)
		WorkerID						'CLI_USR_' + resource_code (also lookup from previous migration)
		UserID							'CLI_USR_' + resource_code (also lookup from previous migration)
		IsPrimary						'1'
		Attending						'1'
		CreatedDatetime					OpenDate
		UpdatedDatetime					ChangeDate
		kfahcsiastateid
		workerattached
	*/

	-- 1. transform (using the previous temp table for Jobs)
	if object_id('tempdb..#servicefileworker') is not null drop table #servicefileworker

	select 
		sf.ServiceFileSK,
		u.UserSK,
		j.CaseID ServiceFileID,
		j.WorkerID,
		j.WorkerID UserID,
		'1' IsPrimary,
		'1' Attending,
		j.CreatedDatetime,
		j.UpdatedDatetime 
	into #servicefileworker
	from 
		#jobs j 
		join [db-au-dtc].dbo.pnpServiceFile sf on sf.ServiceFileID = j.ServiceFileID 
		join #user u on u.WorkerID = j.WorkerID 


	-- 2. load 
	merge [db-au-dtc].dbo.pnpServiceFileWorker as tgt
	using #servicefileworker 
		on #servicefileworker.ServiceFileID = tgt.ServiceFileID and #servicefileworker.WorkerID = tgt.WorkerID and #servicefileworker.CreatedDatetime = tgt.CreatedDatetime
	when not matched by target then 
		insert (
			ServiceFileSK,
			UserSK,
			ServiceFileID,
			WorkerID,
			UserID,
			IsPrimary,
			Attending,
			CreatedDatetime,
			UpdatedDatetime
		)
		values (
			#servicefileworker.ServiceFileSK,
			#servicefileworker.UserSK,
			#servicefileworker.ServiceFileID,
			#servicefileworker.WorkerID,
			#servicefileworker.UserID,
			#servicefileworker.IsPrimary,
			#servicefileworker.Attending,
			#servicefileworker.CreatedDatetime,
			#servicefileworker.UpdatedDatetime
		)
	when matched then update set 
		tgt.ServiceFileSK = #servicefileworker.ServiceFileSK,
		tgt.UserSK = #servicefileworker.UserSK,
		tgt.UserID = #servicefileworker.UserID,
		tgt.IsPrimary = #servicefileworker.IsPrimary,
		tgt.Attending = #servicefileworker.Attending,
		tgt.UpdatedDatetime = #servicefileworker.UpdatedDatetime
	;	


END

GO
