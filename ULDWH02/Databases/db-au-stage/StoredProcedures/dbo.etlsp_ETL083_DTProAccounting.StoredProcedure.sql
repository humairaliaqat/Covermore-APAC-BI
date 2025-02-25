USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_DTProAccounting]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-11-20
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_DTProAccounting] 
	-- Add the parameters for the stored procedure here
	@StartDate date = null, 
	@EndDate date = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	declare @batchID int, @start date, @end date, @sql varchar(max) 

	-- get date range from batch or parameter
	if @StartDate is null and @EndDate is null 
		exec syssp_getrunningbatch
			@SubjectArea = 'Penelope',
			@BatchID = @batchID out,
			@StartDate = @start out,
			@EndDate = @end out 
    else 
        select 
            @start = coalesce(convert(date, @StartDate), convert(date, dateadd(day, -7, getdate()))), 
            @end = coalesce(convert(date, @EndDate), convert(date, dateadd(day, 7, getdate())))
	
	-- stage patrxdet 
	-- declare @start date = convert(date, dateadd(day, -70, getdate())), @end date = convert(date, dateadd(day, 70, getdate())), @sql varchar(max) 

	if object_id('[db-au-stage]..DTProAccounting_patrxdet_audtc') is not null drop table [db-au-stage]..DTProAccounting_patrxdet_audtc 

	set @sql = 'select * into [db-au-stage]..DTProAccounting_patrxdet_audtc 
	from openquery([SAEAPSYD03VDB01], 
	''with e as (select project_code, tran_date, resource_code from DTProAccounting..patrxdet where created_date between ''''' + convert(varchar, @start) + ''''' and ''''' + convert(varchar, @end) + ''''' or 
	last_edit_date between ''''' + convert(varchar, @start) + ''''' and ''''' + convert(varchar, @end) + '''''
	group by project_code, tran_date, resource_code) 
	select p.* from DTProAccounting..patrxdet p join e on p.project_code = e.project_code and p.tran_date = e.tran_date and p.resource_code = e.resource_code'')'

	exec(@sql)


	-- stage patrx 
	-- declare @start date = convert(date, dateadd(day, -70, getdate())), @end date = convert(date, dateadd(day, 70, getdate())), @sql varchar(max) 

	if object_id('[db-au-stage]..DTProAccounting_patrx_audtc') is not null drop table [db-au-stage]..DTProAccounting_patrx_audtc 

	set @sql = 'select * into [db-au-stage]..DTProAccounting_patrx_audtc 
	from openquery([SAEAPSYD03VDB01], 
	''with e as (select project_code, tran_date, resource_code from DTProAccounting..patrxdet where created_date between ''''' + convert(varchar, @start) + ''''' and ''''' + convert(varchar, @end) + ''''' or 
	last_edit_date between ''''' + convert(varchar, @start) + ''''' and ''''' + convert(varchar, @end) + '''''
	group by project_code, tran_date, resource_code)
	, i as (
		select distinct p.inv_ctrl_num 
		from DTProAccounting..patrxdet p 
		join e on p.project_code = e.project_code and p.tran_date = e.tran_date and p.resource_code = e.resource_code 
		where p.inv_ctrl_num is not null
	) 
	select t.* 
	from DTProAccounting..patrx t 
	left join i on i.inv_ctrl_num = t.trx_ctrl_num  
	where i.inv_ctrl_num is not null or 
	t.created_date between ''''' + convert(varchar, @start) + ''''' and ''''' + convert(varchar, @end) + ''''' or 
	t.last_edit_date between ''''' + convert(varchar, @start) + ''''' and ''''' + convert(varchar, @end) + ''''''')'

	exec(@sql)


	-- stage pabatch 
	-- declare @start date = convert(date, dateadd(day, -70, getdate())), @end date = convert(date, dateadd(day, 70, getdate())), @sql varchar(max) 
	if object_id('[db-au-stage]..DTProAccounting_pabatch_audtc') is not null drop table [db-au-stage]..DTProAccounting_pabatch_audtc 

	set @sql = 'select * into [db-au-stage]..DTProAccounting_pabatch_audtc 
	from openquery([SAEAPSYD03VDB01], 
	''select * from DTProAccounting..pabatch'')'

	exec(@sql)


	-- stage papaysch 
	-- declare @start date = convert(date, dateadd(day, -70, getdate())), @end date = convert(date, dateadd(day, 70, getdate())), @sql varchar(max) 
	if object_id('[db-au-stage]..DTProAccounting_papaysch_audtc') is not null drop table [db-au-stage]..DTProAccounting_papaysch_audtc 

	set @sql = 'select * into [db-au-stage]..DTProAccounting_papaysch_audtc 
	from openquery([SAEAPSYD03VDB01], 
	''select * from DTProAccounting..papaysch'')'

	exec(@sql)


	-- stage papaysch_more 
	-- declare @start date = convert(date, dateadd(day, -70, getdate())), @end date = convert(date, dateadd(day, 70, getdate())), @sql varchar(max) 
	if object_id('[db-au-stage]..DTProAccounting_papaysch_more_audtc') is not null drop table [db-au-stage]..DTProAccounting_papaysch_more_audtc 

	set @sql = 'select * into [db-au-stage]..DTProAccounting_papaysch_more_audtc 
	from openquery([SAEAPSYD03VDB01], 
	''select * from DTProAccounting..papaysch_more'')'

	exec(@sql)


	-- stage vwTimesheetInvoiceDate 
	-- declare @start date = convert(date, dateadd(day, -70, getdate())), @end date = convert(date, dateadd(day, 70, getdate())), @sql varchar(max) 
	if object_id('[db-au-stage]..eFrontOfficeDW_vwTimesheetInvoiceDate_audtc') is not null drop table [db-au-stage]..eFrontOfficeDW_vwTimesheetInvoiceDate_audtc 

	set @sql = 'select * into [db-au-stage]..eFrontOfficeDW_vwTimesheetInvoiceDate_audtc 
	from openquery([DTCSYD03CL1], 
	''select * from eFrontOfficeDW..vwTimesheetInvoiceDate'')'

	exec(@sql)



	-- patrxdet => ServiceEvent  
	if object_id('tempdb..#src') is not null drop table #src 

	;with d as (
		select project_code, tran_date, resource_code 
		from [db-au-stage]..DTProAccounting_patrxdet_audtc 
		where tran_type = 1 and activity_code = 'DNATTE' 
		group by project_code, tran_date, resource_code 
		having sum(qty) > 0 
	)
	select 
		project_code,
		tran_date,
		resource_code,
		'Show' Status 
	into #src 
	from 
		[db-au-stage]..DTProAccounting_patrxdet_audtc o 
	where 
		tran_type = 1 
		and not exists (select 1 from d where project_code = o.project_code and tran_date = o.tran_date and resource_code = o.resource_code)
	group by 
		project_code, tran_date, resource_code 
	union all 
	select 
		project_code,
		tran_date,
		resource_code,
		'No Show'
	from d 


	-- 1. transform 
	if object_id('tempdb..#serviceevent') is not null drop table #serviceevent 

	select 
		sf.ServiceFileSK,
		sf.CaseSK,
		sf.FunderSK,
		sf.FunderDepartmentSK,
		pwu.PrimaryWorkerUserSK,
		'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code ServiceEventID,
		sf.ServiceFileID,
		sf.CaseID,
		sf.FunderID,
		sf.FunderDepartmentID,
		pwu.PrimaryWorkerID,
		pwu.PrimaryWorkerUserID,
		s.tran_date StartDatetime,
		s.tran_date EndDatetime,
		s.Status
	into #serviceevent
	from 
		#src s 
		outer apply (
			select top 1 ServiceFileSK, CaseSK, FunderSK, FunderDepartmentSK, 
				ServiceFileID, CaseID, FunderID, FunderDepartmentID 
			from [db-au-dtc]..pnpServiceFile 
			where ClienteleJobNumber = s.project_code 
		) sf 
		outer apply (
			select top 1 UserSK PrimaryWorkerUserSK, UserID PrimaryWorkerUserID, WorkerID PrimaryWorkerID 
			from [db-au-dtc]..pnpUser 
			where ClienteleResourceCode = s.resource_code 
		) pwu

	
	-- 2. load 
	merge [db-au-dtc]..pnpServiceEvent as tgt
	using #serviceevent 
		on #serviceevent.ServiceEventID = tgt.ServiceEventID collate database_default 
	when not matched by target then 
		insert (
			ServiceFileSK,
			CaseSK,
			FunderSK,
			FunderDepartmentSK,
			PrimaryWorkerUserSK,
			ServiceEventID,
			ServiceFileID,
			CaseID,
			FunderID,
			FunderDepartmentID,
			PrimaryWorkerID,
			PrimaryWorkerUserID,
			StartDatetime,
			EndDatetime,
			Status 
		)
		values (
			#serviceevent.ServiceFileSK,
			#serviceevent.CaseSK,
			#serviceevent.FunderSK,
			#serviceevent.FunderDepartmentSK,
			#serviceevent.PrimaryWorkerUserSK,
			#serviceevent.ServiceEventID,
			#serviceevent.ServiceFileID,
			#serviceevent.CaseID,
			#serviceevent.FunderID,
			#serviceevent.FunderDepartmentID,
			#serviceevent.PrimaryWorkerID,
			#serviceevent.PrimaryWorkerUserID,
			#serviceevent.StartDatetime,
			#serviceevent.EndDatetime,
			#serviceevent.Status 
		)
	when matched then update set 
		tgt.ServiceFileSK = #serviceevent.ServiceFileSK,
		tgt.CaseSK = #serviceevent.CaseSK,
		tgt.FunderSK = #serviceevent.FunderSK,
		tgt.FunderDepartmentSK = #serviceevent.FunderDepartmentSK,
		tgt.PrimaryWorkerUserSK = #serviceevent.PrimaryWorkerUserSK,
		tgt.ServiceFileID = #serviceevent.ServiceFileID,
		tgt.CaseID = #serviceevent.CaseID,
		tgt.FunderID = #serviceevent.FunderID,
		tgt.FunderDepartmentID = #serviceevent.FunderDepartmentID,
		tgt.PrimaryWorkerID = #serviceevent.PrimaryWorkerID,
		tgt.PrimaryWorkerUserID = #serviceevent.PrimaryWorkerUserID,
		tgt.StartDatetime = #serviceevent.StartDatetime,
		tgt.EndDatetime = #serviceevent.EndDatetime,
		tgt.Status = #serviceevent.Status 
	;

	
	-- patrxdet => ServiceEventActivity 
	-- 1. transform 
	if object_id('tempdb..#serviceeventactivity') is not null drop table #serviceeventactivity 

	select 
		se.ServiceEventSK,
		se.ServiceFileSK,
		se.CaseSK,
		i.ItemSK,
		se.FunderSK,
		se.FunderDepartmentSK,
		'CLI_TSH_' + s.trx_ctrl_num ServiceEventActivityID,
		'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code ServiceEventID,
		se.ServiceFileID,
		se.CaseID,
		'CLI_ACD_' + s.Activity_Code ItemID,
		se.FunderID,
		se.FunderDepartmentID,
		i.Name,
		s.qty Quantity,
		'Time - Hour' UnitOfMeasurementClass,
		'1' UnitOfMeasurementIsTime,
		'hours' UnitOfMeasurementIsSchedule,
		'60m' UnitOfMeasurementIsName,
		1 UnitOfMeasurementIsEquivalent,
		s.project_sell_fee_amt Fee,
		s.project_sell_amt Total,
		s.created_date CreatedDatetime,
		s.last_edit_date UpdatedDatetime,
		s.created_user CreatedBy,	
		s.last_edit_user UpdatedBy,
		case 
			when exists (select 1 from [db-au-stage]..DTProAccounting_patrx_audtc where trx_ctrl_num = s.inv_ctrl_num and invoice_flag = 1) then 1 
			else 0 
		end Invoiced
	into #serviceeventactivity
	from 
		[db-au-stage]..DTProAccounting_patrxdet_audtc s 
		outer apply (
			select top 1 ServiceEventSK, ServiceFileSK, CaseSK, FunderSK, FunderDepartmentSK, 
				ServiceFileID, CaseID, FunderID, FunderDepartmentID 
			from [db-au-dtc]..pnpServiceEvent 
			where ServiceEventID = 'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code 
		) se 
		outer apply (
			select top 1 ItemSK, Name  
			from [db-au-dtc]..pnpItem 
			where ItemID = 'CLI_ACD_' + s.Activity_Code 
		) i
	where 
		s.tran_type = 1
	

	-- 2. load	
	merge [db-au-dtc]..pnpServiceEventActivity as tgt
	using #serviceeventactivity 
		on #serviceeventactivity.ServiceEventActivityID = tgt.ServiceEventActivityID collate database_default 
	when not matched by target then 
		insert (
			ServiceEventSK,
			ServiceFileSK,
			CaseSK,
			ItemSK,
			FunderSK,
			FunderDepartmentSK,
			ServiceEventActivityID,
			ServiceEventID,
			ServiceFileID,
			CaseID,
			ItemID,
			FunderID,
			FunderDepartmentID,
			Name,
			Quantity,
			UnitOfMeasurementClass,
			UnitOfMeasurementIsTime,
			UnitOfMeasurementIsSchedule,
			UnitOfMeasurementIsName,
			UnitOfMeasurementIsEquivalent,
			Fee,
			Total,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,	
			UpdatedBy,
			Invoiced
		)
		values (
			#serviceeventactivity.ServiceEventSK,
			#serviceeventactivity.ServiceFileSK,
			#serviceeventactivity.CaseSK,
			#serviceeventactivity.ItemSK,
			#serviceeventactivity.FunderSK,
			#serviceeventactivity.FunderDepartmentSK,
			#serviceeventactivity.ServiceEventActivityID,
			#serviceeventactivity.ServiceEventID,
			#serviceeventactivity.ServiceFileID,
			#serviceeventactivity.CaseID,
			#serviceeventactivity.ItemID,
			#serviceeventactivity.FunderID,
			#serviceeventactivity.FunderDepartmentID,
			#serviceeventactivity.Name,
			#serviceeventactivity.Quantity,
			#serviceeventactivity.UnitOfMeasurementClass,
			#serviceeventactivity.UnitOfMeasurementIsTime,
			#serviceeventactivity.UnitOfMeasurementIsSchedule,
			#serviceeventactivity.UnitOfMeasurementIsName,
			#serviceeventactivity.UnitOfMeasurementIsEquivalent,
			#serviceeventactivity.Fee,
			#serviceeventactivity.Total,
			#serviceeventactivity.CreatedDatetime,
			#serviceeventactivity.UpdatedDatetime,
			#serviceeventactivity.CreatedBy,	
			#serviceeventactivity.UpdatedBy,
			#serviceeventactivity.Invoiced
		)
	when matched then update set 
		tgt.ServiceEventSK = #serviceeventactivity.ServiceEventSK,
		tgt.ServiceFileSK = #serviceeventactivity.ServiceFileSK,
		tgt.CaseSK = #serviceeventactivity.CaseSK,
		tgt.ItemSK = #serviceeventactivity.ItemSK,
		tgt.FunderSK = #serviceeventactivity.FunderSK,
		tgt.FunderDepartmentSK = #serviceeventactivity.FunderDepartmentSK,
		tgt.ServiceEventID = #serviceeventactivity.ServiceEventID,
		tgt.ServiceFileID = #serviceeventactivity.ServiceFileID,
		tgt.CaseID = #serviceeventactivity.CaseID,
		tgt.ItemID = #serviceeventactivity.ItemID,
		tgt.FunderID = #serviceeventactivity.FunderID,
		tgt.FunderDepartmentID = #serviceeventactivity.FunderDepartmentID,
		tgt.Name = #serviceeventactivity.Name,
		tgt.Quantity = #serviceeventactivity.Quantity,
		tgt.UnitOfMeasurementClass = #serviceeventactivity.UnitOfMeasurementClass,
		tgt.UnitOfMeasurementIsTime = #serviceeventactivity.UnitOfMeasurementIsTime,
		tgt.UnitOfMeasurementIsSchedule = #serviceeventactivity.UnitOfMeasurementIsSchedule,
		tgt.UnitOfMeasurementIsName = #serviceeventactivity.UnitOfMeasurementIsName,
		tgt.UnitOfMeasurementIsEquivalent = #serviceeventactivity.UnitOfMeasurementIsEquivalent,
		tgt.Fee = #serviceeventactivity.Fee,
		tgt.Total = #serviceeventactivity.Total,
		tgt.CreatedDatetime = #serviceeventactivity.CreatedDatetime,
		tgt.UpdatedDatetime = #serviceeventactivity.UpdatedDatetime,
		tgt.CreatedBy = #serviceeventactivity.CreatedBy,
		tgt.UpdatedBy = #serviceeventactivity.UpdatedBy,
		tgt.Invoiced = #serviceeventactivity.Invoiced
	;


	-- patrxdet => ServiceEventAttendee 
	-- 1. transform 
	if object_id('tempdb..#serviceeventattendee') is not null drop table #serviceeventattendee  

	select 
		se.ServiceEventSK,
		null IndividualSK,
		u.UserSK,
		s.ServiceEventID,
		null IndividualID,
		s.PrimaryWorkerUserID UserID,
		s.PrimaryWorkerUserID WorkerID,
		u.FirstName + ' ' + u.LastName Name,
		'Primary Worker' Role
	into #serviceeventattendee 
	from 
		#serviceevent s 
		outer apply (
			select top 1 ServiceEventSK 
			from [db-au-dtc]..pnpServiceEvent 
			where ServiceEventID = s.ServiceEventID collate database_default 
		) se 
		outer apply (
			select top 1 UserSK, FirstName, LastName  
			from [db-au-dtc]..pnpUser  
			where UserID = s.PrimaryWorkerUserID collate database_default 
		) u 
	where 
		s.Status = 'Show'
	union all 
	select 
		se.ServiceEventSK,
		sfm.IndividualSK,
		null UserSK,
		'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code ServiceEventID,
		i.IndividualID,
		null UserID,
		null WorkerID,
		i.FirstName + ' ' + i.LastName Name,
		'Presenting Individual' Role 
	from 
		#src s 
		outer apply (
			select top 1 ServiceEventSK 
			from [db-au-dtc]..pnpServiceEvent 
			where ServiceEventID = 'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code collate database_default 
		) se 
		outer apply (
			select top 1 ServiceFileSK 
			from [db-au-dtc]..pnpServiceFile 
			where ClienteleJobNumber = s.project_code collate database_default 
		) sf 
		outer apply (
			select top 1 IndividualSK 
			from [db-au-dtc]..pnpServiceFileMember
			where ServiceFileSK = sf.ServiceFileSK
		) sfm 
		outer apply (
			select top 1 IndividualID, FirstName, LastName 
			from [db-au-dtc]..pnpIndividual 
			where IndividualSK = sfm.IndividualSK 
		) i 
	where 
		s.Status = 'Show'	
	

	-- 2. load 
	merge [db-au-dtc]..pnpServiceEventAttendee  as tgt
	using #serviceeventattendee 
		on #serviceeventattendee.ServiceEventID = tgt.ServiceEventID collate database_default and #serviceeventattendee.IndividualID = tgt.IndividualID collate database_default and #serviceeventattendee.UserID = tgt.UserID collate database_default 
	when not matched by target then 
		insert (
			ServiceEventSK,
			IndividualSK,
			UserSK,
			ServiceEventID,
			IndividualID,
			UserID,
			WorkerID,
			Name,
			Role 
		)
		values (
			#serviceeventattendee.ServiceEventSK,
			#serviceeventattendee.IndividualSK,
			#serviceeventattendee.UserSK,
			#serviceeventattendee.ServiceEventID,
			#serviceeventattendee.IndividualID,
			#serviceeventattendee.UserID,
			#serviceeventattendee.WorkerID,
			#serviceeventattendee.Name,
			#serviceeventattendee.Role 
		)
	when matched then update set 
		tgt.ServiceEventSK = #serviceeventattendee.ServiceEventSK,
		tgt.IndividualSK = #serviceeventattendee.IndividualSK,
		tgt.UserSK = #serviceeventattendee.UserSK,
		tgt.WorkerID = #serviceeventattendee.WorkerID,
		tgt.Name = #serviceeventattendee.Name,
		tgt.Role = #serviceeventattendee.Role 
	;


	-- update [db-au-dtc]..pnpServiceFile, use the first event worker as service file primary worker 
	update sf 
	set 
		PrimaryWorkerUserSK = u.PrimaryWorkerUserSK,
		PrimaryWorkerID = u.PrimaryWorkerID 
	from 
		[db-au-dtc]..pnpServiceFile sf 
		cross apply (
			select top 1 resource_code 
			from [db-au-stage]..DTProAccounting_patrxdet_audtc 
			where project_code = sf.ClienteleJobNumber 
			order by tran_date 
		) pw 
		cross apply (
			select top 1 UserSK PrimaryWorkerUserSK, WorkerID PrimaryWorkerID 
			from [db-au-dtc]..pnpUser 
			where ClienteleResourceCode = pw.resource_code and IsCurrent = 1
		) u 
	where 
		sf.PrimaryWorkerUserSK is null



	-- pnpInvoice
	-- 1. transform
	if object_id('tempdb..#inv1') is not null drop table #inv1
	select 
		f.FunderSK,
		coalesce(convert(varchar, ol.kfunderid), 'CLI_ORG_' + o.Org_ID) FunderID,
		'CLI_INV_' + i.trx_ctrl_num InvoiceID,
		i.invoice_date InvoiceDate,
		p.FirstName + ' ' + p.LastName BillTo,
		o.OrgName Name,
		coalesce(o.Address1, p.Address1) AddressLine1,
		coalesce(o.Address2, p.Address2) AddressLine2,
		coalesce(o.City, p.City) City,
		coalesce(o.State, p.State) State,
		coalesce(o.Country, p.Country) Country,
		coalesce(o.Zip, p.Zip) Postcode,
		i.created_date CreatedDatetime,
		i.last_edit_date UpdatedDatetime,
		i.created_user CreatedBy,
		i.last_edit_user UpdatedBy,
		i.posted_state InvoicePosted,
		i.batch_ctrl_num BatchNumber,
		i.due_date PaymentTermsDue,
		i.project_currency_code CurrencyCode,
		case 
			when i.project_currency_code = 'AUD' then 'Australia' 
			when i.project_currency_code = 'SGD' then 'Singapore' 
			when i.project_currency_code = 'USD' then 'United States' 
		end CurrencyCountry,
		'$' CurrencySign,
		i.posted_state BatchPosted,
		i.invoice_date BatchDate,
		i.posting_date BatchPostDate,
		b.created_date BatchCreatedDatetime,
		b.last_edit_date BatchUpdatedDatetime,
		b.created_user BatchCreatedBy,
		b.last_edit_user BatchUpdatedBy,
		b.batch_type BatchType,
		i.invoice_number InvoiceNumber,
		i.onhold_flag OnHold,
		i.fee_basis_code FeeBasisCode,
		case
			when i.fee_basis_code in ('TM', 'FFS') then 'Time and Materials' 
			when i.fee_basis_code = 'FF' then 'Fixed Fee' 
			when i.fee_basis_code = 'FFPD' then 'Fixed Fee Plus Disbursement' 
		end FeeBasis,
		i.apply_to ApplyTo,
		case 
			when i.onhold_flag = 1 then 0
			else i.project_sell_pretax_amt 
		end Amount,
		case 
			when i.onhold_flag = 1 then 0
			else i.project_sell_tax_amt 
		end TaxAmount,
		case 
			when i.onhold_flag = 1 then 0
			else i.project_sell_taxinc_amt 
		end TotalAmount
	into #inv1 
	from 
		[db-au-stage]..DTProAccounting_patrx_audtc i 
		left join [db-au-stage]..DTProAccounting_pabatch_audtc b on b.batch_ctrl_num = i.batch_ctrl_num 
		left join [db-au-stage]..dtc_cli_job j on i.project_code = j.Job_Num 
		left join [db-au-stage]..dtc_cli_org o on o.Org_ID = j.Org_ID 
		left join [db-au-stage]..dtc_cli_Person p on p.Per_ID = j.Invoice_Person_ID 
		left join [db-au-stage]..dtc_cli_Base_Org  bo on bo.Org_id = o.Org_ID 
		left join [db-au-stage]..dtc_cli_Org_Lookup ol on ol.uniquefunderid = bo.Pene_id 
		outer apply (
			select top 1 FunderSK 
			from [db-au-dtc]..pnpFunder 
			where FunderID = coalesce(convert(varchar, ol.kfunderid), 'CLI_ORG_' + o.Org_ID) and IsCurrent = 1
		) f
	
	-- 2. load
	merge [db-au-dtc]..pnpInvoice tgt 
	using #inv1 
		on #inv1.InvoiceID = tgt.InvoiceID 
	when not matched by target then 
		insert (
			InvoiceID,
			FunderSK,
			InvoiceDate,
			BillTo,
			Name,
			AddressLine1,
			AddressLine2,
			City,
			State,
			Country,
			Postcode,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,
			UpdatedBy,
			FunderID,
			InvoicePosted,
			BatchNumber,
			PaymentTermsDue,
			CurrencyCode,
			CurrencyCountry,
			CurrencySign,
			BatchPosted,
			BatchDate,
			BatchPostDate,
			BatchCreatedDatetime,
			BatchUpdatedDatetime,
			BatchCreatedBy,
			BatchUpdatedBy,
			BatchType,
			InvoiceNumber,
			OnHold,
			FeeBasisCode,
			FeeBasis,
			ApplyTo,
			Amount,
			TaxAmount,
			TotalAmount
		)
		values (
			#inv1.InvoiceID,
			#inv1.FunderSK,
			#inv1.InvoiceDate,
			#inv1.BillTo,
			#inv1.Name,
			#inv1.AddressLine1,
			#inv1.AddressLine2,
			#inv1.City,
			#inv1.State,
			#inv1.Country,
			#inv1.Postcode,
			#inv1.CreatedDatetime,
			#inv1.UpdatedDatetime,
			#inv1.CreatedBy,
			#inv1.UpdatedBy,
			#inv1.FunderID,
			#inv1.InvoicePosted,
			#inv1.BatchNumber,
			#inv1.PaymentTermsDue,
			#inv1.CurrencyCode,
			#inv1.CurrencyCountry,
			#inv1.CurrencySign,
			#inv1.BatchPosted,
			#inv1.BatchDate,
			#inv1.BatchPostDate,
			#inv1.BatchCreatedDatetime,
			#inv1.BatchUpdatedDatetime,
			#inv1.BatchCreatedBy,
			#inv1.BatchUpdatedBy,
			#inv1.BatchType,
			#inv1.InvoiceNumber,
			#inv1.OnHold,
			#inv1.FeeBasisCode,
			#inv1.FeeBasis,
			#inv1.ApplyTo,
			#inv1.Amount,
			#inv1.TaxAmount,
			#inv1.TotalAmount
		)
	when matched then update set 
		tgt.FunderSK = #inv1.FunderSK,
		tgt.InvoiceDate = #inv1.InvoiceDate,
		tgt.BillTo = #inv1.BillTo,
		tgt.Name = #inv1.Name,
		tgt.AddressLine1 = #inv1.AddressLine1,
		tgt.AddressLine2 = #inv1.AddressLine2,
		tgt.City = #inv1.City,
		tgt.State = #inv1.State,
		tgt.Country = #inv1.Country,
		tgt.Postcode = #inv1.Postcode,
		tgt.CreatedDatetime = #inv1.CreatedDatetime,
		tgt.UpdatedDatetime = #inv1.UpdatedDatetime,
		tgt.CreatedBy = #inv1.CreatedBy,
		tgt.UpdatedBy = #inv1.UpdatedBy,
		tgt.FunderID = #inv1.FunderID,
		tgt.InvoicePosted = #inv1.InvoicePosted,
		tgt.BatchNumber = #inv1.BatchNumber,
		tgt.PaymentTermsDue = #inv1.PaymentTermsDue,
		tgt.CurrencyCode = #inv1.CurrencyCode,
		tgt.CurrencyCountry = #inv1.CurrencyCountry,
		tgt.CurrencySign = #inv1.CurrencySign,
		tgt.BatchPosted = #inv1.BatchPosted,
		tgt.BatchDate = #inv1.BatchDate,
		tgt.BatchPostDate = #inv1.BatchPostDate,
		tgt.BatchCreatedDatetime = #inv1.BatchCreatedDatetime,
		tgt.BatchUpdatedDatetime = #inv1.BatchUpdatedDatetime,
		tgt.BatchCreatedBy = #inv1.BatchCreatedBy,
		tgt.BatchUpdatedBy = #inv1.BatchUpdatedBy,
		tgt.BatchType = #inv1.BatchType,
		tgt.InvoiceNumber = #inv1.InvoiceNumber,
		tgt.OnHold = #inv1.OnHold,
		tgt.FeeBasisCode = #inv1.FeeBasisCode,
		tgt.FeeBasis = #inv1.FeeBasis,
		tgt.ApplyTo = #inv1.ApplyTo,
		tgt.Amount = #inv1.Amount,
		tgt.TaxAmount = #inv1.TaxAmount,
		tgt.TotalAmount = #inv1.TotalAmount 
	;

	
	-- pnpInvoiceLine 
	if object_id('tempdb..#il') is not null drop table #il
	select 
		i.InvoiceSK,
		sea.ServiceEventActivitySK,
		pc.PolicyCoverageSK,
		pm.PolicyMemberSK,
		sf.FunderSK,
		sf.FunderDepartmentSK,
		bind.IndividualSK,
		pind.IndividualSK PatientIndividualSK,		-- IndividualSK for invoice table
		'CLI_TSH_' + il.trx_ctrl_num InvoiceLineID,
		coalesce('CLI_INV_' + il.inv_ctrl_num, 'CLI_TSH_' + il.trx_ctrl_num) InvoiceID,	-- include line id as InvoiceID when inv_ctrl_num is null 
		------------ for invoice table -------------
		/*
		convert(date, case when isnull(patrx.fee_basis_code, p.fee_basis_code) in ('FF','FFPD') then 
			case when isnull(convert(date, s.AccrualDate, 126), patrx.invoice_date) < isnull(b.created_date, il.created_date) 
				then isnull(convert(date, s.AccrualDate, 126), patrx.invoice_date) 
			else isnull(b.created_date, il.created_date) end 
		else  
			case when (il.project_sell_rate = 0 or isnull(patrx.onhold_flag,0) = 1) and isnull(convert(date, s.AccrualDate, 126), patrx.invoice_date) > isnull(b.created_date, il.created_date) 
				then isnull(b.created_date, il.created_date) 
			else IsNull(convert(date, s.AccrualDate, 126), patrx.invoice_date) end 
		end) InvoiceDate,
		*/
		id.invoiceDate InvoiceDate,
		pind.BillTo,
		f.Name,
		f.AddressLine1,
		f.AddressLine2,
		f.City,
		f.State,
		f.Country,
		f.Postcode,
		il.batch_ctrl_num BatchNumber,
		b.created_date BatchCreatedDatetime,
		b.last_edit_date BatchUpdatedDatetime,
		b.created_user BatchCreatedBy,
		b.last_edit_user BatchUpdatedBy,
		b.batch_type BatchType,
		'CLI_TSH_' + il.trx_ctrl_num InvoiceNumber,
		p.fee_basis_code FeeBasisCode,
		case
			when p.fee_basis_code in ('TM', 'FFS') then 'Time and Materials' 
			when p.fee_basis_code = 'FF' then 'Fixed Fee' 
			when p.fee_basis_code = 'FFPD' then 'Fixed Fee Plus Disbursement' 
		end FeeBasis,
		--------------------------------------------	
		'Primary Funding' InvoiceLineType,
		'PRI' InvoiceLineTypeShort,
		'CLI_TSH_' + il.trx_ctrl_num ServiceEventActivityID,
		'CLI_CSV_' + j.ContractService_ID PolicyCoverageID,
		'CLI_CON_' + j.Contract_ID + 'CLI_PER_' + j.Per_ID PolicyMemberID,
		sf.FunderID,
		sf.FunderDepartmentID,
		bind. IndividualID,
		pind.IndividualID PatientIndividualID,		-- IndividualID for invoice table
		il.qty Quantity,
		case when p.fee_basis_code in ('FF', 'FFPD') and il.tran_type in (1, 18) then 0 else il.project_sell_rate end Fee,
		case when p.fee_basis_code in ('FF', 'FFPD') and il.tran_type in (1, 18) then 0 else il.project_sell_amt end Total,
		case when p.fee_basis_code in ('FF', 'FFPD') and il.tran_type in (1, 18) then 0 else il.project_sell_nocharge_amt end Adjustment,
		case when p.fee_basis_code in ('FF', 'FFPD') and il.tran_type in (1, 18) then 0 else il.project_sell_amt + il.project_sell_nocharge_amt end Amount,
		il.created_date CreatedDatetime,
		il.last_edit_date UpdatedDatetime,
		il.created_user CreatedBy,
		il.last_edit_user UpdatedBy,
		case when p.fee_basis_code in ('FF', 'FFPD') and il.tran_type in (1, 18) then 0 else t.tax_amt * (il.project_sell_amt + il.project_sell_nocharge_amt) / 100 end TaxAmount,
		case when p.fee_basis_code in ('FF', 'FFPD') and il.tran_type in (1, 18) then 0 else il.project_sell_amt + il.project_sell_nocharge_amt + t.tax_amt * (il.project_sell_amt + il.project_sell_nocharge_amt) / 100 end TotalAmount,
		case 
			when il.project_sell_amt + il.project_sell_nocharge_amt = 0 and il.project_sell_nocharge_amt <> 0 then 1 
			else 0 
		end NonChargeable,
		il.tran_type 
	into #il 
	from 
		[db-au-stage]..DTProAccounting_patrxdet_audtc il 
		left join [db-au-stage]..dtc_cli_Job j on j.Job_Num = il.project_code 
		left join [db-au-stage]..dtc_cli_Base_Job bj on j.Job_ID = bj.Job_id 
		left join [db-au-stage]..dtc_cli_ServiceFile_Lookup jlu on jlu.uniquecaseid = bj.Pene_id 
		left join [db-au-stage]..DTProAccounting_patrx_audtc patrx on patrx.trx_ctrl_num = il.inv_ctrl_num 
		left join [db-au-stage]..dtc_cli_paprojct p on p.project_code = il.project_code 
		left join [db-au-stage]..dtc_cli_pataxtypdet t on t.tax_type_code = coalesce(patrx.sell_tax_code, p.project_sell_tax_code collate database_default) 
		left join [db-au-stage]..DTProAccounting_pabatch_audtc b on b.batch_ctrl_num = il.batch_ctrl_num 
		left join [db-au-stage]..dtc_cli_DT_StaffAccrualTimesheets s on il.trx_ctrl_num = s.trx_ctrl_num 
		left join [db-au-stage]..eFrontOfficeDW_vwTimesheetInvoiceDate_audtc id on id.trx_ctrl_num = il.trx_ctrl_num 
		outer apply (
			select top 1 InvoiceSK 
			from [db-au-dtc]..pnpInvoice 
			where InvoiceID = 'CLI_INV_' + il.inv_ctrl_num 
		) i 
		outer apply (
			select top 1 ServiceEventActivitySK 
			from [db-au-dtc]..pnpServiceEventActivity 
			where ServiceEventActivityID = 'CLI_TSH_' + il.trx_ctrl_num 
		) sea 
		outer apply (
			select top 1 PolicyCoverageSK 
			from [db-au-dtc]..pnpPolicyCoverage 
			where PolicyCoverageID = 'CLI_CSV_' + j.ContractService_ID 
		) pc 
		outer apply (
			select top 1 PolicyMemberSK 
			from [db-au-dtc]..pnpPolicyMember  
			where PolicyMemberID = 'CLI_CON_' + j.Contract_ID + 'CLI_PER_' + j.Per_ID
		) pm 
		outer apply (
			select top 1 FunderSK, FunderID, FunderDepartmentSK, FunderDepartmentID, PresentingServiceFileMemberSK, BillIndividualSK
			from [db-au-dtc]..pnpServiceFile 
			where ServiceFileID = coalesce(convert(varchar, jlu.kprogprovid), 'CLI_JOB_' + j.Job_ID) 
		) sf 
		outer apply (
			select top 1 Funder Name, AddressLine1, AddressLine2, City, State, Country, Postcode
			from [db-au-dtc]..pnpFunder 
			where FunderSK = sf.FunderSK
		) f 
		outer apply (
			select top 1 i.IndividualSK, i.IndividualID, i.FirstName + ' ' + i.LastName BillTo 
			from [db-au-dtc]..pnpIndividual i join [db-au-dtc]..pnpServiceFileMember sfm on sfm.IndividualSK = i.IndividualSK 
			where sfm.ServiceFileMemberSK = sf.PresentingServiceFileMemberSK and i.IsCurrent = 1
		) pind 
		outer apply (
			select top 1 IndividualSK, IndividualID 
			from [db-au-dtc]..pnpIndividual 
			where IndividualSK = sf.BillIndividualSK
		) bind
	where 
		il.tran_type in (1, 10, 18)
	
	
	-- 2. load 
	merge [db-au-dtc]..pnpInvoiceLine as tgt 
	using #il on #il.InvoiceLineID = tgt.InvoiceLineID 
	when not matched by target then 
		insert (
			InvoiceSK,
			ServiceEventActivitySK,
			PolicyCoverageSK,
			PolicyMemberSK,
			FunderSK,
			FunderDepartmentSK,
			IndividualSK,
			PatientIndividualSK,
			InvoiceLineID,
			InvoiceID,
			InvoiceLineType,
			InvoiceLineTypeShort,
			ServiceEventActivityID,
			PolicyCoverageID,
			PolicyMemberID,
			FunderID,
			FunderDepartmentID,
			IndividualID,
			PatientIndividualID,
			Quantity,
			Fee,
			Total,
			Adjustment,
			Amount,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,
			UpdatedBy,
			TaxAmount,
			TotalAmount,
			NonChargeable
		)
		values (
			#il.InvoiceSK,
			#il.ServiceEventActivitySK,
			#il.PolicyCoverageSK,
			#il.PolicyMemberSK,
			#il.FunderSK,
			#il.FunderDepartmentSK,
			#il.IndividualSK,
			#il.PatientIndividualSK,
			#il.InvoiceLineID,
			#il.InvoiceID,
			#il.InvoiceLineType,
			#il.InvoiceLineTypeShort,
			#il.ServiceEventActivityID,
			#il.PolicyCoverageID,
			#il.PolicyMemberID,
			#il.FunderID,
			#il.FunderDepartmentID,
			#il.IndividualID,
			#il.PatientIndividualID,
			#il.Quantity,
			#il.Fee,
			#il.Total,
			#il.Adjustment,
			#il.Amount,
			#il.CreatedDatetime,
			#il.UpdatedDatetime,
			#il.CreatedBy,
			#il.UpdatedBy,
			#il.TaxAmount,
			#il.TotalAmount,
			#il.NonChargeable
		)
	when matched then update set 
		tgt.InvoiceSK = #il.InvoiceSK,
		tgt.ServiceEventActivitySK = #il.ServiceEventActivitySK,
		tgt.PolicyCoverageSK = #il.PolicyCoverageSK,
		tgt.PolicyMemberSK = #il.PolicyMemberSK,
		tgt.FunderSK = #il.FunderSK,
		tgt.FunderDepartmentSK = #il.FunderDepartmentSK,
		tgt.IndividualSK = #il.IndividualSK,
		tgt.PatientIndividualSK = #il.PatientIndividualSK,
		tgt.InvoiceID = #il.InvoiceID,
		tgt.InvoiceLineType = #il.InvoiceLineType,
		tgt.InvoiceLineTypeShort = #il.InvoiceLineTypeShort,
		tgt.ServiceEventActivityID = #il.ServiceEventActivityID,
		tgt.PolicyCoverageID = #il.PolicyCoverageID,
		tgt.PolicyMemberID = #il.PolicyMemberID,
		tgt.FunderID = #il.FunderID,
		tgt.FunderDepartmentID = #il.FunderDepartmentID,
		tgt.IndividualID = #il.IndividualID,
		tgt.PatientIndividualID = #il.PatientIndividualID,
		tgt.Quantity = #il.Quantity,
		tgt.Fee = #il.Fee,
		tgt.Total = #il.Total,
		tgt.Adjustment = #il.Adjustment,
		tgt.Amount = #il.Amount,
		tgt.CreatedDatetime = #il.CreatedDatetime,
		tgt.UpdatedDatetime = #il.UpdatedDatetime,
		tgt.CreatedBy = #il.CreatedBy,
		tgt.UpdatedBy = #il.UpdatedBy,
		tgt.TaxAmount = #il.TaxAmount,
		tgt.TotalAmount = #il.TotalAmount,
		tgt.NonChargeable = #il.NonChargeable
	;


	create index idx_temp_inv_FeeBasisCode on #il (FeeBasisCode)


	----------------- create invoice records for patrxdet with no invoice number ---------------------
	if object_id('tempdb..#inv') is not null drop table #inv 
	select 
		* 
	into 
		#inv 
	from 
		#il 
	where 
		InvoiceID like 'CLI_TSH_%' 
		and FeeBasisCode in ('FF', 'FFPD') 
		and tran_type in (1, 18) 


	merge [db-au-dtc]..pnpInvoice tgt 
	using #inv on #inv.InvoiceID = tgt.InvoiceID 
	when not matched by target then 
		insert (
			IndividualSK,
			FunderSK,
			InvoiceID,
			IndividualID,
			InvoiceDate,
			BillTo,
			Name,
			AddressLine1,
			AddressLine2,
			City,
			State,
			Country,
			Postcode,
			BatchNumber,
			BatchCreatedDatetime,
			BatchUpdatedDatetime,
			BatchCreatedBy,
			BatchUpdatedBy,
			BatchType,
			InvoiceNumber,
			FeeBasisCode,
			FeeBasis,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,
			UpdatedBy,
			Amount,
			TaxAmount,
			TotalAmount,
			InvoicePosted
		)
		values(
			#inv.PatientIndividualSK,
			#inv.FunderSK,
			#inv.InvoiceID,
			#inv.PatientIndividualID,
			#inv.InvoiceDate,
			#inv.BillTo,
			#inv.Name,
			#inv.AddressLine1,
			#inv.AddressLine2,
			#inv.City,
			#inv.State,
			#inv.Country,
			#inv.Postcode,
			#inv.BatchNumber,
			#inv.BatchCreatedDatetime,
			#inv.BatchUpdatedDatetime,
			#inv.BatchCreatedBy,
			#inv.BatchUpdatedBy,
			#inv.BatchType,
			#inv.InvoiceNumber,
			#inv.FeeBasisCode,
			#inv.FeeBasis,
			#inv.CreatedDatetime,
			#inv.UpdatedDatetime,
			#inv.CreatedBy,
			#inv.UpdatedBy,
			#inv.Amount,
			#inv.TaxAmount,
			#inv.TotalAmount,
			'1'
		)
	when matched then update 
	set 
		tgt.IndividualSK = #inv.IndividualSK,
		tgt.FunderSK = #inv.FunderSK,
		tgt.IndividualID = #inv.IndividualID,
		tgt.InvoiceDate = #inv.InvoiceDate,
		tgt.BillTo = #inv.BillTo,
		tgt.Name = #inv.Name,
		tgt.AddressLine1 = #inv.AddressLine1,
		tgt.AddressLine2 = #inv.AddressLine2,
		tgt.City = #inv.City,
		tgt.State = #inv.State,
		tgt.Country = #inv.Country,
		tgt.Postcode = #inv.Postcode,
		tgt.BatchNumber = #inv.BatchNumber,
		tgt.BatchCreatedDatetime = #inv.BatchCreatedDatetime,
		tgt.BatchUpdatedDatetime = #inv.BatchUpdatedDatetime,
		tgt.BatchCreatedBy = #inv.BatchCreatedBy,
		tgt.BatchUpdatedBy = #inv.BatchUpdatedBy,
		tgt.BatchType = #inv.BatchType,
		tgt.InvoiceNumber = #inv.InvoiceNumber,
		tgt.FeeBasisCode = #inv.FeeBasisCode,
		tgt.FeeBasis = #inv.FeeBasis,
		tgt.CreatedDatetime = #inv.CreatedDatetime,
		tgt.UpdatedDatetime = #inv.UpdatedDatetime,
		tgt.CreatedBy = #inv.CreatedBy,
		tgt.UpdatedBy = #inv.UpdatedBy,
		tgt.Amount = #inv.Amount,
		tgt.TaxAmount = #inv.TaxAmount,
		tgt.TotalAmount = #inv.TotalAmount,
		tgt.InvoicePosted = '1'
	;

	
	-- update InvoiceSK in pnpInvoiceLine 
	update il 
	set InvoiceSK = i.InvoiceSK 
	from 
		[db-au-dtc]..pnpInvoiceLine il 
		join [db-au-dtc]..pnpInvoice i on il.InvoiceID = i.InvoiceID 
	where 
		il.InvoiceSK is null 
		and i.InvoiceID like 'CLI_TSH_%' 



	----------------- process contract fee invoices -------------------------

	if object_id('tempdb..#ffil') is not null drop table #ffil 
	select 
		InvoiceSK,
		IndividualSK,
		IndividualSK PatientIndividualSK,
		COALESCE('CLI_SCH_' + ps.trx_ctrl_num, InvoiceID) InvoiceLineID,
		InvoiceID,
		IndividualID PatientIndividualID,
		IndividualID,
		InvoiceDate,
		'Primary Funding' InvoiceLineType,
		'PRI' InvoiceLineTypeShort,
		Amount,
		TaxAmount,
		TotalAmount,
		case 
			when TotalAmount = 0 then 1 
			else 0 
		end NonChargeable,
		'Contract Fees' [Service],
		COALESCE('CLI_SCH_' + ps.trx_ctrl_num, 'CLI_INV_' + patrx.trx_ctrl_num) ServiceEventID,
		sf.FunderSK,
		sf.FunderID,
		sf.CaseSK,
		sf.CaseID,
		sf.ServiceFileSK,
		sf.ServiceFileID,
		sf.FunderDepartmentSK,
		sf.FunderDepartmentID,
		'Contract Fees' Title,
		InvoiceDate StartDatetime,
		InvoiceDate EndDatetime,
		patrx.created_date CreatedDatetime,
		patrx.last_edit_date UpdatedDatetime,
		patrx.created_user CreatedBy,
		patrx.last_edit_user UpdatedBy,
		psm.Schedule_Start_Date ScheduleStartDate,
		psm.Schedule_End_Date ScheduleEndDate
	into #ffil
	from 
		[db-au-dtc]..pnpInvoice i 
		join [db-au-stage]..DTProAccounting_patrx_audtc patrx on 'CLI_INV_' + patrx.trx_ctrl_num = i.InvoiceID 
		join [db-au-dtc]..pnpServiceFile sf on sf.ClienteleJobNumber = patrx.project_code 
		left join [db-au-stage]..DTProAccounting_papaysch_audtc ps on patrx.trx_ctrl_num = ps.inv_ctrl_num 
		left join [db-au-stage]..DTProAccounting_papaysch_more_audtc psm on psm.trx_ctrl_num = ps.trx_ctrl_num 
	where 
		FeeBasisCode in ('FF','FFPD') 
		and i.InvoiceID like 'CLI_INV_%' 
		--and not exists (select 1 from [db-au-dtc]..pnpInvoiceLine where InvoiceID = i.InvoiceID and InvoiceLineID like 'CLI_TSH_%')
		

	-- create service event records for each fixed fee invoice 
	merge [db-au-dtc]..pnpServiceEvent tgt 
	using #ffil on #ffil.ServiceEventID = tgt.ServiceEventID 
	when not matched by target then 
		insert (
			ServiceEventID,
			FunderSK,
			FunderID,
			FunderDepartmentSK,
			FunderDepartmentID,
			CaseSK,
			CaseID,
			ServiceFileSK,
			ServiceFileID,
			Title,
			StartDatetime,
			EndDatetime,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,
			UpdatedBy
		)
		values (
			#ffil.ServiceEventID,
			#ffil.FunderSK,
			#ffil.FunderID,
			#ffil.FunderDepartmentSK,
			#ffil.FunderDepartmentID,
			#ffil.CaseSK,
			#ffil.CaseID,
			#ffil.ServiceFileSK,
			#ffil.ServiceFileID,
			#ffil.Title,
			#ffil.StartDatetime,
			#ffil.EndDatetime,
			#ffil.CreatedDatetime,
			#ffil.UpdatedDatetime,
			#ffil.CreatedBy,
			#ffil.UpdatedBy
		)
	when matched then update 
		set tgt.FunderSK = #ffil.FunderSK,
			tgt.FunderID = #ffil.FunderID,
			tgt.FunderDepartmentSK = #ffil.FunderDepartmentSK,
			tgt.FunderDepartmentID = #ffil.FunderDepartmentID,
			tgt.CaseSK = #ffil.CaseSK,
			tgt.CaseID = #ffil.CaseID,
			tgt.ServiceFileSK = #ffil.ServiceFileSK,
			tgt.ServiceFileID = #ffil.ServiceFileID,
			tgt.Title = #ffil.Title,
			tgt.StartDatetime = #ffil.StartDatetime,
			tgt.EndDatetime = #ffil.EndDatetime,
			tgt.CreatedDatetime = #ffil.CreatedDatetime,
			tgt.UpdatedDatetime = #ffil.UpdatedDatetime,
			tgt.CreatedBy = #ffil.CreatedBy,
			tgt.UpdatedBy = #ffil.UpdatedBy
	;


	-- create service event activity records for each fixed fee invoice 
	/*
	item: 
	select I.trx_ctrl_num, I.invoice_number, M.Schedule_Start_date, M.Schedule_end_date, datediff(month,  M.Schedule_Start_date, M.Schedule_end_date) +1
	from patrx I
	JOIN papaysch S ON I.trx_ctrl_num = S.inv_ctrl_num
	JOIN papaysch_more M ON S.trx_ctrl_num = M.trx_ctrl_num
	*/

	if object_id('tempdb..#sea') is not null drop table #sea 
	select 
		se.ServiceEventSK,
		#ffil.*
	into 
		#sea
	from
		#ffil
		outer apply (
			select top 1 ServiceEventSK 
			from [db-au-dtc]..pnpServiceEvent 
			where ServiceEventID = #ffil.ServiceEventID
		) se

	merge [db-au-dtc]..pnpServiceEventActivity tgt 
	using #sea on #sea.ServiceEventID = tgt.ServiceEventActivityID 
	when not matched by target then 
		insert (
			ServiceEventActivityID,
			ServiceEventSK,
			ServiceEventID,
			FunderSK,
			FunderID,
			FunderDepartmentSK,
			FunderDepartmentID,
			CaseSK,
			CaseID,
			ServiceFileSK,
			ServiceFileID,
			Quantity,
			UnitOfMeasurementClass,
			UnitOfMeasurementIsTime,
			UnitOfMeasurementIsSchedule,
			UnitOfMeasurementIsName,
			UnitOfMeasurementIsEquivalent,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,
			UpdatedBy,
			Fee,
			Total,
			ScheduleStartDate,
			ScheduleEndDate
		)
		values (
			#sea.ServiceEventID,
			#sea.ServiceEventSK,
			#sea.ServiceEventID,
			#sea.FunderSK,
			#sea.FunderID,
			#sea.FunderDepartmentSK,
			#sea.FunderDepartmentID,
			#sea.CaseSK,
			#sea.CaseID,
			#sea.ServiceFileSK,
			#sea.ServiceFileID,
			0,
			'Unit',
			'0',
			'month',
			case 
				when datediff(month, #sea.ScheduleStartDate, dateadd(day, 1, #sea.ScheduleEndDate)) = 12 then 'Year' 
				when datediff(month, #sea.ScheduleStartDate, dateadd(day, 1, #sea.ScheduleEndDate)) = 6 then 'BiAnnual'
				when datediff(month, #sea.ScheduleStartDate, dateadd(day, 1, #sea.ScheduleEndDate)) = 3 then 'Qtr' 
				else 'Month' 
			end,
			datediff(month, #sea.ScheduleStartDate, dateadd(day, 1, #sea.ScheduleEndDate)),
			#sea.CreatedDatetime,
			#sea.UpdatedDatetime,
			#sea.CreatedBy,
			#sea.UpdatedBy,
			0,
			0,
			#sea.ScheduleStartDate,
			#sea.ScheduleEndDate
		)
	when matched then update 
		set tgt.ServiceEventSK = #sea.ServiceEventSK,
			tgt.ServiceEventID = #sea.ServiceEventID,
			tgt.FunderSK = #sea.FunderSK,
			tgt.FunderID = #sea.FunderID,
			tgt.FunderDepartmentSK = #sea.FunderDepartmentSK,
			tgt.FunderDepartmentID = #sea.FunderDepartmentID,
			tgt.CaseSK = #sea.CaseSK,
			tgt.CaseID = #sea.CaseID,
			tgt.ServiceFileSK = #sea.ServiceFileSK,
			tgt.ServiceFileID = #sea.ServiceFileID,
			tgt.Quantity = 0,
			tgt.UnitOfMeasurementClass = 'Unit',
			tgt.UnitOfMeasurementIsTime = '0',
			tgt.UnitOfMeasurementIsSchedule = 'month',
			tgt.UnitOfMeasurementIsName = case 
				when datediff(month, #sea.ScheduleStartDate, dateadd(day, 1, #sea.ScheduleEndDate)) = 12 then 'Year' 
				when datediff(month, #sea.ScheduleStartDate, dateadd(day, 1, #sea.ScheduleEndDate)) = 6 then 'BiAnnual'
				when datediff(month, #sea.ScheduleStartDate, dateadd(day, 1, #sea.ScheduleEndDate)) = 3 then 'Qtr' 
				else 'Month' 
			end,
			tgt.UnitOfMeasurementIsEquivalent = datediff(month, #sea.ScheduleStartDate, dateadd(day, 1, #sea.ScheduleEndDate)),
			tgt.CreatedDatetime = #sea.CreatedDatetime,
			tgt.UpdatedDatetime = #sea.UpdatedDatetime,
			tgt.CreatedBy = #sea.CreatedBy,
			tgt.UpdatedBy = #sea.UpdatedBy,
			tgt.Fee = 0,
			tgt.Total = 0,
			tgt.ScheduleStartDate = #sea.ScheduleStartDate,
			tgt.ScheduleEndDate = #sea.ScheduleEndDate
	;


	if object_id('tempdb..#il1') is not null drop table #il1 
	select 
		sea.ServiceEventActivitySK,
		sea.PolicyCoverageSK,
		#ffil.*
	into 
		#il1
	from 
		#ffil 
		outer apply (
			select top 1 
				sea.ServiceEventActivitySK,
				pc.PolicyCoverageSK
			from 
				[db-au-dtc]..pnpServiceEventActivity sea 
				join [db-au-dtc]..pnpServiceFile sf on sf.ServiceFileSK = sea.ServiceFileSK 
				join [db-au-stage]..dtc_cli_job j on j.Job_Num = sf.ClienteleJobNumber 
				join [db-au-dtc]..pnpPolicyCoverage pc on pc.PolicyCoverageID = 'CLI_CSV_' + j.ContractService_ID 
			where 
				sea.ServiceEventActivityID = #ffil.ServiceEventID
		) sea 


	-- create invoice line record for each FF invioce 
	merge [db-au-dtc]..pnpInvoiceLine tgt 
	using #il1 on #il1.InvoiceLineID = tgt.InvoiceLineID 
	when not matched by target then 
	insert (
		InvoiceSK,
		ServiceEventActivitySK,
		FunderSK,
		FunderDepartmentSK,
		IndividualSK,
		PatientIndividualSK,
		InvoiceLineID,
		InvoiceID,
		PatientIndividualID,
		IndividualID,
		InvoiceLineType,
		InvoiceLineTypeShort,
		Amount,
		TaxAmount,
		TotalAmount,
		NonChargeable,
		[Service]
	) 
	values (
		#il1.InvoiceSK,
		#il1.ServiceEventActivitySK,
		#il1.FunderSK,
		#il1.FunderDepartmentSK,
		#il1.IndividualSK,
		#il1.PatientIndividualSK,
		#il1.InvoiceLineID,
		#il1.InvoiceID,
		#il1.PatientIndividualID,
		#il1.IndividualID,
		#il1.InvoiceLineType,
		#il1.InvoiceLineTypeShort,
		#il1.Amount,
		#il1.TaxAmount,
		#il1.TotalAmount,
		#il1.NonChargeable,
		#il1.[Service]
	)
	when matched then update set 
		tgt.InvoiceSK = #il1.InvoiceSK,
		tgt.ServiceEventActivitySK = #il1.ServiceEventActivitySK,
		tgt.FunderSK = #il1.FunderSK,
		tgt.FunderDepartmentSK = #il1.FunderDepartmentSK,
		tgt.IndividualSK = #il1.IndividualSK,
		tgt.PatientIndividualSK = #il1.PatientIndividualSK,
		tgt.InvoiceID = #il1.InvoiceID,
		tgt.PatientIndividualID = #il1.PatientIndividualID,
		tgt.IndividualID = #il1.IndividualID,
		tgt.InvoiceLineType = #il1.InvoiceLineType,
		tgt.InvoiceLineTypeShort = #il1.InvoiceLineTypeShort,
		tgt.Amount = #il1.Amount,
		tgt.TaxAmount = #il1.TaxAmount,
		tgt.TotalAmount = #il1.TotalAmount,
		tgt.NonChargeable = #il1.NonChargeable,
		tgt.[Service] = #il1.[Service]
	;

	---------------------------------------------------------------------

	update il 
	set PolicyCoverageSK = pc.PolicyCoverageSK 
	from 
		[db-au-dtc]..pnpInvoiceLine il 
		join [db-au-stage]..dtc_cli_patrx trx on 'CLI_INV_' + trx.trx_ctrl_num = il.InvoiceLineID 
		join [db-au-stage]..dtc_cli_Job j on j.Job_Num = trx.project_code 
		join [db-au-dtc]..pnpPolicyCoverage pc on pc.PolicyCoverageID = 'CLI_CSV_' + j.ContractService_ID 
	where 
		InvoiceLineID like 'CLI_INV%' 
		and il.PolicyCoverageSK is null 

	UPDATE I
	SET invoiceReleaseDate = I.InvoiceDate
	--select InvoiceDate, InvoiceReleaseDate, *
	from [db-au-dtc]..pnpInvoice I
	where left(invoiceid,3) = 'CLI'
	and InvoiceDate <> isnull(InvoiceReleaseDate,getdate())
	and InvoicePosted = 1
END
GO
