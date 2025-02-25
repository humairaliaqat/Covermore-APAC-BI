USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_101_Stage]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- Modified:    DM 1/2/2018 - Adjusted to bring in the posting and company codes for all timesheet lines
--              LL 20180213 - remove patrx.void_flag = 0 filter, bring all and to be flaged accordingly
--                            hold off this one
--              DM 20180410 - Brought in Appointment data into the staging on full refresh
--              DM 20181008 - Fix for department updates performed after go-live
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_101_Stage] 
	@StartDate varchar(10) = null, 
	@EndDate varchar(10) = null,
	@FullReload tinyint = 0
AS
BEGIN

	SET NOCOUNT ON;


	declare 
		@batchID int, 
		@start varchar(10), 
		@end varchar(10), 
		@sDate date,
		@eDate date,
		@sql varchar(max) 

	-- get date range from batch or parameter
	if @StartDate is null and @EndDate is null 
	begin 
		exec syssp_getrunningbatch
			@SubjectArea = 'Clientele',
			@BatchID = @batchID out,
			@StartDate = @sDate out,
			@EndDate = @eDate out 

		set @start = convert(varchar, @sDate, 126)
		set @end = convert(varchar, @eDate, 126)
	end
    else 
        select 
            @start = coalesce(@StartDate, convert(varchar, dateadd(day, -7, getdate()), 126)), 
            @end = coalesce(@EndDate, convert(varchar, dateadd(day, 7, getdate()), 126))

	if @FullReload = 1 
		set @start = '1990-01-01'

	-- Penelope custom data migration lookup tables 
	if @FullReload = 1 
	begin 
		
		-- Individual 
		if object_id('[db-au-stage].dbo.dtc_cli_Base_Person') is not null drop table [db-au-stage].dbo.dtc_cli_Base_Person
		select * into [db-au-stage].dbo.dtc_cli_Base_Person 
		from openquery([DTCSYD03CL1], 'select * from [Penelope_DM].dbo.[Base_Person]')

		create index idx_dtc_cli_Base_Person_Per_ID on [db-au-stage].dbo.dtc_cli_Base_Person (Per_ID)

		if object_id('[db-au-stage].dbo.dtc_cli_Person_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Person_Lookup
		select * into [db-au-stage].dbo.dtc_cli_Person_Lookup from openquery(penelopeprod, 'select * from public.custom_migration_individuals_lookup')

		create index idx_dtc_cli_Person_Lookup_uniqueindid on [db-au-stage].dbo.dtc_cli_Person_Lookup (uniqueindid)

		-- Funder 
		if object_id('[db-au-stage].dbo.dtc_cli_Base_Org') is not null drop table [db-au-stage].dbo.dtc_cli_Base_Org
		select * into [db-au-stage].dbo.dtc_cli_Base_Org 
		from openquery([DTCSYD03CL1], 'select * from [Penelope_DM].dbo.[Base_Org]')

		if object_id('[db-au-stage].dbo.dtc_cli_Org_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Org_Lookup
		select * into [db-au-stage].dbo.dtc_cli_Org_Lookup 
		from openquery(penelopeprod, 'select * from public.custom_migration_funder_lookup')

		-- FunderDepartment
		if object_id('[db-au-stage].dbo.dtc_cli_Base_Group') is not null drop table [db-au-stage].dbo.dtc_cli_Base_Group
		select * into [db-au-stage].dbo.dtc_cli_Base_Group 
		from openquery([DTCSYD03CL1], 'select * from [Penelope_DM].dbo.[Base_Department]')

		if object_id('[db-au-stage].dbo.dtc_cli_Group_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Group_Lookup
		select * into [db-au-stage].dbo.dtc_cli_Group_Lookup 
		from openquery(penelopeprod, 'select * from public.custom_migration_funder_department_lookup')

		-- User
		if object_id('[db-au-stage].dbo.dtc_cli_Worker') is not null drop table [db-au-stage].dbo.dtc_cli_Worker 
		select * into [db-au-stage].dbo.dtc_cli_Worker 
		from openquery(penelopeprod, 'select * from public.custom_migration_workers') 

		if object_id('[db-au-stage].dbo.dtc_cli_Worker_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Worker_Lookup 
		select * into [db-au-stage].dbo.dtc_cli_Worker_Lookup 
		from openquery(penelopeprod, 'select * from public.custom_migration_workers_lookup') 

		-- Site 
		if object_id('[db-au-stage].dbo.dtc_cli_Site') is not null drop table [db-au-stage].dbo.dtc_cli_Site 
		select * into [db-au-stage].dbo.dtc_cli_Site 
		from openquery(penelopeprod, 'select * from public.custom_migration_sites') 
		 
		if object_id('[db-au-stage].dbo.dtc_cli_Site_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Site_Lookup 
		select * into [db-au-stage].dbo.dtc_cli_Site_Lookup 
		from openquery(penelopeprod, 'select * from public.custom_migration_sites_lookup') 

		if object_id('[db-au-stage].dbo.dtc_cli_Temp_Offices') is not null drop table [db-au-stage].dbo.dtc_cli_Temp_Offices
		select * into [db-au-stage].dbo.dtc_cli_Temp_Offices 
		from openquery(DTCSYD03CL1, 'select * from Penelope_DM.dbo.Temp_Offices')

		-- Policy 
		-----------------------------------------------------------------------------------------------------------------

		--if object_id('[db-au-stage].dbo.dtc_cli_Temp_Policy') is not null drop table [db-au-stage].dbo.dtc_cli_Temp_Policy
		--select * into [db-au-stage].dbo.dtc_cli_Temp_Policy 
		--from openquery([DTCSYD03CL1], 'select * from [Penelope_DM].dbo.[Temp_Policy]')

		--if object_id('[db-au-stage].dbo.dtc_cli_Temp_PolicyService') is not null drop table [db-au-stage].dbo.dtc_cli_Temp_PolicyService
		--select * into [db-au-stage].dbo.dtc_cli_Temp_PolicyService 
		--from openquery([DTCSYD03CL1], 'select * from [Penelope_DM].dbo.[Temp_PolicyServices]')

		-----------------------------------------------------------------------------------------------------------------

		if object_id('[db-au-stage].dbo.dtc_cli_Individual_Public_Policy_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Individual_Public_Policy_Lookup
		select * into [db-au-stage].dbo.dtc_cli_Individual_Public_Policy_Lookup from openquery(penelopeprod, 'select * from public.custom_migration_individualpolicy_publicpolicy_lookup')

		if object_id('[db-au-stage].dbo.dtc_cli_Public_Policy_Setup_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Public_Policy_Setup_Lookup
		select * into [db-au-stage].dbo.dtc_cli_Public_Policy_Setup_Lookup from openquery(penelopeprod, 'select * from public.custom_migration_publicpolicy_setup_lookup')

		if object_id('[db-au-stage].dbo.dtc_cli_Group_Policy_Setup_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Group_Policy_Setup_Lookup
		select * into [db-au-stage].dbo.dtc_cli_Group_Policy_Setup_Lookup from openquery(penelopeprod, 'select * from public.custom_migration_grouppolicy_setup_lookup')

		-- Case & ServiceFile
		if object_id('[db-au-stage].dbo.dtc_cli_Base_Job') is not null drop table [db-au-stage].dbo.dtc_cli_Base_Job
		select * into [db-au-stage].dbo.dtc_cli_Base_Job 
		from openquery([DTCSYD03CL1], 'select * from [Penelope_DM].dbo.[Base_Job]')

		if object_id('[db-au-stage].dbo.dtc_cli_Case_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_Case_Lookup
		select * into [db-au-stage].dbo.dtc_cli_Case_Lookup from openquery(penelopeprod, 'select * from public.custom_migration_cases_lookup')

		if object_id('[db-au-stage].dbo.dtc_cli_ServiceFile_Lookup') is not null drop table [db-au-stage].dbo.dtc_cli_ServiceFile_Lookup
		select * into [db-au-stage].dbo.dtc_cli_ServiceFile_Lookup from openquery(penelopeprod, 'select * from public.custom_migration_servicefile_lookup')

	end


	-------------------- Clientele data --------------------
	-- Individual
	if object_id('[db-au-stage].dbo.dtc_cli_Person') is not null drop table [db-au-stage].dbo.dtc_cli_Person
	select * into [db-au-stage].dbo.dtc_cli_Person 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.Person')

	create nonclustered index idx_dtc_cli_Person_Per_ID 
	on [db-au-stage].dbo.dtc_cli_Person ([Per_ID])
	include ([LastName],[FirstName],[Address1],[Address2],[City],[State],[Zip],[Country])

	
	-- Funder
	if object_id('[db-au-stage].dbo.dtc_cli_Org') is not null drop table [db-au-stage].dbo.dtc_cli_Org
	select * into [db-au-stage].dbo.dtc_cli_org 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.Org') 

	create nonclustered index idx_dtc_cli_Org_AcctMgr 
	on [db-au-stage].dbo.dtc_cli_org (AcctMgr) 
	include (Org_ID)

	
	-- FunderDepartment
	if object_id('[db-au-stage].dbo.dtc_cli_Group') is not null drop table [db-au-stage].dbo.dtc_cli_Group
	select * into [db-au-stage].dbo.dtc_cli_Group 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.Groups')

	
	-- FunderPopulation
	if object_id('[db-au-stage].dbo.dtc_cli_OrgEmployeeHist') is not null drop table [db-au-stage].dbo.dtc_cli_OrgEmployeeHist
	select * into [db-au-stage].dbo.dtc_cli_OrgEmployeeHist 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.OrgEmployeeHist where isnull(employeeCnt,0) > 0') 


	-- User 
	if object_id('[db-au-stage].dbo.dtc_cli_PaResCls') is not null drop table [db-au-stage].dbo.dtc_cli_PaResCls 
	select * into [db-au-stage].dbo.dtc_cli_PaResCls 
	from openquery([SAEAPSYD03VDB01], 'select * from DTProAccounting.dbo.parescls')

	if object_id('[db-au-stage].dbo.dtc_cli_PaResrce') is not null drop table [db-au-stage].dbo.dtc_cli_PaResrce 
	select * into [db-au-stage].dbo.dtc_cli_PaResrce 
	from openquery([SAEAPSYD03VDB01], 'select * from DTProAccounting.dbo.paresrce')

	if object_id('[db-au-stage].dbo.dtc_cli_PaStaff') is not null drop table [db-au-stage].dbo.dtc_cli_PaStaff 
	select * into [db-au-stage].dbo.dtc_cli_PaStaff 
	from openquery([SAEAPSYD03VDB01], 'select * from DTProAccounting.dbo.pastaff')

	-- Site
	if object_id('[db-au-stage].dbo.dtc_cli_DTOffice') is not null drop table [db-au-stage].dbo.dtc_cli_DTOffice 
	select * into [db-au-stage].dbo.dtc_cli_DTOffice 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.DTOffice')

	if object_id('[db-au-stage].dbo.dtc_cli_DTOfficeRooms') is not null drop table [db-au-stage].dbo.dtc_cli_DTOfficeRooms 
	select * into [db-au-stage].dbo.dtc_cli_DTOfficeRooms 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.DTOfficeRooms')

	if @FullReload = 1 
	begin 
		--Appointments
		if object_id('[db-au-stage].dbo.dtc_cli_DiaryLookup') is not null drop table [db-au-stage].dbo.dtc_cli_DiaryLookup 
		select * into [db-au-stage].dbo.dtc_cli_DiaryLookup 
		from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.DiaryLookup')
	end

	-- Service
	if object_id('[db-au-stage].dbo.dtc_cli_ServiceType') is not null drop table [db-au-stage].dbo.dtc_cli_ServiceType
	select * into [db-au-stage].dbo.dtc_cli_ServiceType 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.ServiceType') 

	create index idx_dtc_cli_ServiceType_ServiceType_ID on [db-au-stage].dbo.dtc_cli_ServiceType (ServiceType_ID)


	-- Item 
	/*
	if object_id('[db-au-stage].dbo.dtc_cli_ServiceTypeActivity') is not null drop table [db-au-stage].dbo.dtc_cli_ServiceTypeActivity
	select * into [db-au-stage].dbo.dtc_cli_ServiceTypeActivity 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.ServiceTypeActivity') 
	*/

	-- only use the one from ProAccounting
	if object_id('[db-au-stage].dbo.dtc_cli_paactvty') is not null drop table [db-au-stage].dbo.dtc_cli_paactvty 
	select * into [db-au-stage].dbo.dtc_cli_paactvty 
	from openquery([SAEAPSYD03VDB01], 'select * from DTProAccounting.dbo.paactvty')


	-- Policy
	if object_id('[db-au-stage].dbo.dtc_cli_Contract') is not null drop table [db-au-stage].dbo.dtc_cli_Contract
	select * into [db-au-stage].dbo.dtc_cli_Contract 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.Contract')

	if object_id('[db-au-stage].dbo.dtc_cli_ContractService') is not null drop table [db-au-stage].dbo.dtc_cli_ContractService
	select * into [db-au-stage].dbo.dtc_cli_ContractService 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.ContractService') 

	create index idx_dtc_cli_ContractService_ContractService_ID on [db-au-stage].dbo.dtc_cli_ContractService (ContractService_ID) 
	create index idx_dtc_cli_ContractService_ServiceType_ID on [db-au-stage].dbo.dtc_cli_ContractService (ServiceType_ID) 

	if object_id('[db-au-stage].dbo.dtc_cli_ContractServiceActivity') is not null drop table [db-au-stage].dbo.dtc_cli_ContractServiceActivity
	select * into [db-au-stage].dbo.dtc_cli_ContractServiceActivity 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.ContractServiceActivity')

	if object_id('[db-au-stage].dbo.dtc_cli_InvoiceType') is not null drop table [db-au-stage].dbo.dtc_cli_InvoiceType
	select * into [db-au-stage].dbo.dtc_cli_InvoiceType 
	from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.DTC_InvoiceType')

	
	-- Case & ServiceFile
	if object_id('[db-au-stage].dbo.dtc_cli_Job') is not null drop table [db-au-stage].dbo.dtc_cli_Job 

	select * 
	into [db-au-stage].dbo.dtc_cli_Job 
	from openquery([SAEAPSYD03VDB01], 
	'select 
		Job_ID,
		Contract_ID,
		ContractService_ID,
		Org_ID,
		Group_ID,
		Sublevel_ID,
		OpenDate,
		Status, 
		ChangeDate,
		OpenBy,
		ChangeUser,
		Job_Num,	
		Comments,
		Per_ID,
		IsFamilyMember, 
		CostCentre,
		Invoice_Person_ID, 
		AssignTo, 
		AssignDate,
		OrgJobLocation_ID,
		BookingPhNo, 
		SendEmail,
		InvoiceText,
		ManualRevenueAccrual,
		CustomerRefCode 
	from 
		eFrontOffice.dbo.Job'
	)

	create index idx_dtc_cli_Job_ContractService_ID on [db-au-stage].dbo.dtc_cli_Job (ContractService_ID)
	create index idx_dtc_cli_Job_Org_ID on [db-au-stage].dbo.dtc_cli_Job (Org_ID)
	create index idx_dtc_cli_Job_Per_ID on [db-au-stage].dbo.[dtc_cli_Job] (Per_ID) include (OrgJobLocation_ID)

	create index idx_dtc_cli_Job_Job_Num on [db-au-stage].dbo.[dtc_cli_Job] (Job_Num)
	include (Job_ID, Contract_ID, ContractService_ID, Per_ID)

	create index idx_dtc_cli_Job_Job_Num_ContractServiceID on [db-au-stage].dbo.[dtc_cli_Job] (Job_Num) include (ContractService_ID)

	create index idx_dtc_cli_Job_CostCentre on [db-au-stage].dbo.[dtc_cli_Job] ([CostCentre]) include ([Job_ID])

	create index idx_dtc_cli_Job_Job_ID_CostCentre on [db-au-stage].dbo.[dtc_cli_Job] ([Job_ID],[CostCentre])

	if object_id('[db-au-stage].dbo.dtc_cli_OrgJobLocation') is not null drop table [db-au-stage].dbo.dtc_cli_OrgJobLocation 
	select * into [db-au-stage].dbo.dtc_cli_OrgJobLocation from openquery([SAEAPSYD03VDB01], 'select * from [eFrontOffice].dbo.OrgJobLocation')


	-- ServiceEvent & ServiceEventActivity & ServiceEventAttendee
	if object_id('[db-au-stage].dbo.dtc_cli_patrxdet') is not null drop table [db-au-stage].dbo.dtc_cli_patrxdet 

	set @sql = 
	'select *
	into [db-au-stage].dbo.dtc_cli_patrxdet 
	from openquery([SAEAPSYD03VDB01], 
	''select 
		trx_ctrl_num,
		project_code,
		tran_date,
		resource_code,
		tran_type,
		activity_code,
		qty,
		created_date,
		last_edit_date,
		created_user,
		last_edit_user,
		project_sell_rate,
		project_sell_amt,
		project_sell_nocharge_amt,
		project_sell_fee_amt,
		inv_ctrl_num,
		batch_ctrl_num,
		description
	from DTProAccounting.dbo.patrxdet 
	where 
		tran_date between ''''' + @start + ''''' and ''''' + @end + ''''' 
		or created_date between ''''' + @start + ''''' and ''''' + @end + ''''' 
		or last_edit_date between ''''' + @start + ''''' and ''''' + @end + '''''
	'')'

	if @FullReload = 1 
	set @sql = 
	'select *
	into [db-au-stage].dbo.dtc_cli_patrxdet 
	from openquery([SAEAPSYD03VDB01], 
	''select 
		trx_ctrl_num,
		project_code,
		tran_date,
		resource_code,
		tran_type,
		activity_code,
		qty,
		created_date,
		last_edit_date,
		created_user,
		last_edit_user,
		project_sell_rate,
		project_sell_amt,
		project_sell_nocharge_amt,
		project_sell_fee_amt,
		inv_ctrl_num,
		batch_ctrl_num,
		description 
	from DTProAccounting.dbo.patrxdet'')'

	exec(@sql)

	create index idx_dtc_cli_patrxdet_project_code on [db-au-stage].dbo.dtc_cli_patrxdet (project_code)

	/*
	FF = Fixed Fee
	FFPD = Fixed fee plus Disbursement
	FFS = TM = Time and Materials (FFS = Fee for Service, not the same meaning as in Penelope)
	*/
	if object_id('[db-au-stage].dbo.dtc_cli_patrx') is not null drop table [db-au-stage].dbo.dtc_cli_patrx 

	set @sql = 
	'select * 
	into [db-au-stage].dbo.dtc_cli_patrx 
	from openquery([SAEAPSYD03VDB01], 
	''select 
		trx_ctrl_num,
		invoice_date,
		invoice_number,
		project_code,
		posted_state,
		created_date,
		last_edit_date,
		created_user,
		last_edit_user,
		batch_ctrl_num,
		due_date,
		onhold_flag,
		fee_basis_code,
		apply_to,
		project_currency_code,
		posting_date,
		project_sell_pretax_amt,
		project_sell_tax_amt,
		project_sell_taxinc_amt,
		sell_tax_code,
		invoice_flag,
		posting_code,
		company_code,
        void_flag
	from 
		DTProAccounting.dbo.patrx 
	where 
        void_flag = 0
		and (
			exists (
				select null 
				from DTProAccounting.dbo.patrxdet 
				where 
					inv_ctrl_num = patrx.trx_ctrl_num 
					and (
						tran_date between ''''' + @start + ''''' and ''''' + @end + ''''' 
						or created_date between ''''' + @start + ''''' and ''''' + @end + ''''' 
						or last_edit_date between ''''' + @start + ''''' and ''''' + @end + '''''
					)
			) 
			or created_date between ''''' + @start + ''''' and ''''' + @end + ''''' 
			or last_edit_date between ''''' + @start + ''''' and ''''' + @end + '''''  
		)
	'')'

	if @FullReload = 1 
	set @sql = 
	'select * 
	into [db-au-stage].dbo.dtc_cli_patrx 
	from openquery([SAEAPSYD03VDB01], 
	''select 
		trx_ctrl_num,
		invoice_date,
		invoice_number,
		project_code,
		posted_state,
		created_date,
		last_edit_date,
		created_user,
		last_edit_user,
		batch_ctrl_num,
		due_date,
		onhold_flag,
		fee_basis_code,
		apply_to,
		project_currency_code,
		posting_date,
		project_sell_pretax_amt,
		project_sell_tax_amt,
		project_sell_taxinc_amt,
		sell_tax_code,
		invoice_flag,
		posting_code,
		company_code,
        void_flag
	from 
		DTProAccounting.dbo.patrx 
    where
        void_flag = 0
	'')'

	exec(@sql)

	create index idx_dtc_cli_patrx on [db-au-stage].dbo.dtc_cli_patrx (trx_ctrl_num) 
	
	if object_id('[db-au-stage].dbo.dtc_cli_papaysch') is not null drop table [db-au-stage].dbo.dtc_cli_papaysch 
	set @sql = 
	'select * 
	into [db-au-stage].dbo.dtc_cli_papaysch 
	from openquery([SAEAPSYD03VDB01], 
	''select * 
	from DTProAccounting.dbo.papaysch
	'')'

	exec(@sql)

	if object_id('[db-au-stage].dbo.dtc_cli_papaysch_more') is not null drop table [db-au-stage].dbo.dtc_cli_papaysch_more 
	set @sql = 
	'select * 
	into [db-au-stage].dbo.dtc_cli_papaysch_more 
	from openquery([SAEAPSYD03VDB01], 
	''select * 
	from DTProAccounting.dbo.papaysch_more 
	'')'

	if @FullReload = 1 
	set @sql = 
	'select * 
	into [db-au-stage].dbo.dtc_cli_papaysch_more 
	from openquery([SAEAPSYD03VDB01], 
	''select * 
	from DTProAccounting.dbo.papaysch_more 
	'')'

	exec(@sql)
	
	if object_id('[db-au-stage].dbo.dtc_cli_pabatch') is not null drop table [db-au-stage].dbo.dtc_cli_pabatch
	select * 
	into [db-au-stage].dbo.dtc_cli_pabatch 
	from openquery([SAEAPSYD03VDB01], 
	'select *
	from DTProAccounting.dbo.pabatch
	')

	if object_id('[db-au-stage].dbo.dtc_cli_pataxtypdet') is not null drop table [db-au-stage].dbo.dtc_cli_pataxtypdet
	select * 
	into [db-au-stage].dbo.dtc_cli_pataxtypdet 
	from openquery([SAEAPSYD03VDB01], 
	'select *
	from DTProAccounting.dbo.pataxtypdet
	')

	if object_id('[db-au-stage].dbo.dtc_cli_paprojct') is not null drop table [db-au-stage].dbo.dtc_cli_paprojct 
	select * 
	into [db-au-stage].dbo.dtc_cli_paprojct 
	from openquery([SAEAPSYD03VDB01], 
	'select 
		project_code, 
		project_sell_tax_code, 
		fee_basis_code, 
		case project_status_code 
			when ''QUOTE'' then ''Quote'' 
			when ''CLOSED'' then ''Closed'' 
			when ''OPEN'' then ''Open'' 
			when ''COMPLETED'' then ''Completed'' 
		end Status,
		posting_code,
		company_code
	from DTProAccounting.dbo.paprojct
	')

	create index idx_dtc_cli_paprojct on [db-au-stage].dbo.dtc_cli_paprojct (project_code) 


	if object_id('[db-au-stage].dbo.dtc_cli_DT_StaffAccrualTimesheets') is not null drop table [db-au-stage].dbo.dtc_cli_DT_StaffAccrualTimesheets
	select * 
	into [db-au-stage].dbo.dtc_cli_DT_StaffAccrualTimesheets 
	from openquery([SAEAPSYD03VDB01], 
	'select * 
	from DTProAccounting.dbo.DT_StaffAccrualTimesheets
	')
	
	if object_id('[db-au-stage].dbo.dtc_cli_vwTimesheetInvoiceDate') is not null drop table [db-au-stage].dbo.dtc_cli_vwTimesheetInvoiceDate 
	select * 
	into [db-au-stage].dbo.dtc_cli_vwTimesheetInvoiceDate 
	from openquery([DTCSYD03CL1], 'select * from eFrontOfficeDW.dbo.vwTimesheetInvoiceDate')

	-- JobClientProfile 
	if object_id('[db-au-stage].dbo.dtc_cli_ProfileAnswers') is not null drop table [db-au-stage].dbo.dtc_cli_ProfileAnswers
	select *
	into [db-au-stage].dbo.dtc_cli_ProfileAnswers 
	from  openquery([SAEAPSYD03VDB01], 
	'select * 
	from eFrontOffice.dbo.ProfileAnswers')

	if object_id('[db-au-stage].dbo.dtc_cli_JobClientProfile') is not null drop table [db-au-stage].dbo.dtc_cli_JobClientProfile 
	set @sql = 
	'select * 
	into [db-au-stage].dbo.dtc_cli_JobClientProfile 
	from openquery([SAEAPSYD03VDB01], 
	''select jcp.* 
	from 
		eFrontOffice.dbo.JobClientProfile jcp 
		join eFrontOffice.dbo.Job j on j.Job_ID = jcp.Job_ID 
	where 
		j.OpenDate between ''''' + @start + ''''' and ''''' + @end + ''''' 
		or j.ChangeDate between ''''' + @start + ''''' and ''''' + @end + ''''' 
		or j.RSArriveDate between ''''' + @start + ''''' and ''''' + @end + ''''' 
		or j.RSChangeDate between ''''' + @start + ''''' and ''''' + @end + ''''' 
		or j.AssignDate between ''''' + @start + ''''' and ''''' + @end + ''''' 
		or j.ClosedDate between ''''' + @start + ''''' and ''''' + @end + '''''
	'')'

	if @FullReload = 1 
	set @sql = 
	'select * 
	into [db-au-stage].dbo.dtc_cli_JobClientProfile 
	from openquery([SAEAPSYD03VDB01], 
	''select jcp.* 
	from 
		eFrontOffice.dbo.JobClientProfile jcp 
	'')'

	exec(@sql) 

	create index idx_dtc_cli_ProfileAnswers_ProfileQuestion_ID_ on [db-au-stage].dbo.dtc_cli_ProfileAnswers (ProfileQuestion_ID, Answer_Number)

	-- accounts
	if object_id('[db-au-stage].dbo.dtc_cli_DTNSW_araccts') is not null drop table [db-au-stage].dbo.dtc_cli_DTNSW_araccts 
	select *
	into [db-au-stage].dbo.dtc_cli_DTNSW_araccts 
	from openquery([SAEAPSYD03VDB01], 
	'select * from DTNSW.dbo.araccts')

	if object_id('[db-au-stage].dbo.dtc_cli_DTPRIME_araccts') is not null drop table [db-au-stage].dbo.dtc_cli_DTPRIME_araccts 
	select *
	into [db-au-stage].dbo.dtc_cli_DTPRIME_araccts 
	from openquery([SAEAPSYD03VDB01], 
	'select * from DTPRIME.dbo.araccts')

	if object_id('[db-au-stage].dbo.dtc_cli_DTSING_araccts') is not null drop table [db-au-stage].dbo.dtc_cli_DTSING_araccts 
	select *
	into [db-au-stage].dbo.dtc_cli_DTSING_araccts 
	from openquery([SAEAPSYD03VDB01], 
	'select * from DTSING.dbo.araccts')

	if object_id('[db-au-stage].dbo.dtc_cli_DTSPRING_araccts') is not null drop table [db-au-stage].dbo.dtc_cli_DTSPRING_araccts 
	select *
	into [db-au-stage].dbo.dtc_cli_DTSPRING_araccts 
	from openquery([SAEAPSYD03VDB01], 
	'select * from DTSPRING.dbo.araccts')

	--20181008 - DM - To Fix ANZ Bank - Technology BU - added and matched after Go Live.
	insert into [db-au-stage]..dtc_cli_base_group
	select gm.Group_Id, gm.GroupName, gm.BIRowID + m.id, 'Dept_' + cast(gm.BIRowID + m.id as varchar)
	from [db-au-dtc].dbo.usrCustomGroupMatching gm
	cross apply (select max(id) as id from [db-au-stage]..dtc_cli_base_group) m
	where not exists (select 1 from [db-au-stage]..dtc_cli_base_group bg where gm.Group_id = bg.Group_id)
	
	insert into [db-au-stage]..dtc_cli_group_lookup
	select bg.Pene_id, bo.Pene_Id, gm.FunderID, gm.FunderDepartmentId
	from [db-au-dtc].dbo.usrCustomGroupMatching gm
	JOIN [db-au-stage]..dtc_cli_base_group bg on gm.Group_Id = bg.group_id
	JOIN [db-au-stage]..dtc_cli_Base_Org bo on gm.Org_id = bo.Org_id
	where not exists (
		select 1 from [db-au-stage]..dtc_cli_group_lookup where bg.Pene_id = uniquedepartmentid
	)

END
GO
