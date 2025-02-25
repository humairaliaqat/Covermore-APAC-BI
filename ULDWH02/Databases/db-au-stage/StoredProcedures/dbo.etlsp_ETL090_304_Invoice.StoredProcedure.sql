USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_304_Invoice]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 
-- Description:	
-- Modifications:
--		20180607 - DM - Updated the import to also take into account the Scheduled fixed price invoices from Star Projects (papaysch)
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_304_Invoice] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	pnpInvoice             Table   Column                  
	InvoiceSK                      
	IndividualSK                   
	FunderSK                       
	InvoiceID              patrx   'CLI_INV_' + trx_ctrl_num          	
	IndividualID                   
	kfunagreid                     
	InvoiceDate            patrx   invoice_date            
	BillTo                 patrx   use individual name                  
	Name                   patrx   use funder name                  
	AddressLine1           patrx   use funder address               
	AddressLine2           patrx   use funder address                           
	City                   patrx   use funder address               
	State                  patrx   use funder address               
	Country                patrx   use funder address               
	Postcode               patrx   use funder address        
	CreatedDatetime        patrx   created_date            
	UpdatedDatetime        patrx   last_edit_date          
	CreatedBy              patrx   created_user            
	UpdatedBy              patrx   last_edit_user          
	FunderID               patrx   from project_code 
	InvoicePosted          patrx   posted_state (1=Posted)
	BatchNumber            patrx   batch_ctrl_num          
	PaymentTermsDue        patrx   due_date                
	InvoiceFullApplied             
	InvoicePartApplied             
	InvoiceFullAppliedDate         
	CurrencyCode           patrx   project_currency_code   
	CurrencyCountry        patrx   derive from project_currency_code 
	CurrencySign           patrx   '$'                     
	Properties                     
	BatchName                      
	BatchPosted            patrx   posted_state (1=Posted)
	BatchDate              patrx   invoice_date (not upto_date)
	BatchPostDate          patrx   posting_date            
	BatchCreatedDatetime   pabatch created_date            
	BatchUpdatedDatetime   pabatch last_edit_date          
	BatchCreatedBy         pabatch created_user            
	BatchUpdatedBy         pabatch last_edit_user          
	BatchSite                      
	BatchType              pabatch batch_type              
	InvoiceNumber          patrx   invoice_number          
	OnHold                 patrx   onhold_flag             
	FeeBasisCode           patrx   fee_basis_code
	FeeBasis			
	ApplyTo                patrx   apply_to                
	Amount                 patrx   project_sell_pretax_amt 
	TaxAmount              patrx   project_sell_tax_amt    
	TotalAmount            patrx   project_sell_taxinc_amt 

	void_flag = 0 during stage

	FeeBasis
	FF = Fixed Fee
	FFPD = Fixed Fee Plus Disbursement
	FFS = TM = Time and Materials (FFS = Fee for Service, not the same meaning as in Penelope)
	*/

	-- 1. transform
	if object_id('tempdb..#src') is not null drop table #src
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
		end TotalAmount,
        i.invoice_date InvoiceReleaseDate,
        i.void_flag VoidFlag
	into #src 
	from 
		[db-au-stage]..dtc_cli_patrx i 
		left join [db-au-stage]..dtc_cli_pabatch b on b.batch_ctrl_num = i.batch_ctrl_num 
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
	using #src 
		on #src.InvoiceID = tgt.InvoiceID 
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
			TotalAmount,
            InvoiceReleaseDate,
            VoidFlag
		)
		values (
			#src.InvoiceID,
			#src.FunderSK,
			#src.InvoiceDate,
			#src.BillTo,
			#src.Name,
			#src.AddressLine1,
			#src.AddressLine2,
			#src.City,
			#src.State,
			#src.Country,
			#src.Postcode,
			#src.CreatedDatetime,
			#src.UpdatedDatetime,
			#src.CreatedBy,
			#src.UpdatedBy,
			#src.FunderID,
			#src.InvoicePosted,
			#src.BatchNumber,
			#src.PaymentTermsDue,
			#src.CurrencyCode,
			#src.CurrencyCountry,
			#src.CurrencySign,
			#src.BatchPosted,
			#src.BatchDate,
			#src.BatchPostDate,
			#src.BatchCreatedDatetime,
			#src.BatchUpdatedDatetime,
			#src.BatchCreatedBy,
			#src.BatchUpdatedBy,
			#src.BatchType,
			#src.InvoiceNumber,
			#src.OnHold,
			#src.FeeBasisCode,
			#src.FeeBasis,
			#src.ApplyTo,
			#src.Amount,
			#src.TaxAmount,
			#src.TotalAmount,
            #src.InvoiceReleaseDate,
            #src.VoidFlag
		)
	when matched then update set 
		tgt.FunderSK = #src.FunderSK,
		tgt.InvoiceDate = #src.InvoiceDate,
		tgt.BillTo = #src.BillTo,
		tgt.Name = #src.Name,
		tgt.AddressLine1 = #src.AddressLine1,
		tgt.AddressLine2 = #src.AddressLine2,
		tgt.City = #src.City,
		tgt.State = #src.State,
		tgt.Country = #src.Country,
		tgt.Postcode = #src.Postcode,
		tgt.CreatedDatetime = #src.CreatedDatetime,
		tgt.UpdatedDatetime = #src.UpdatedDatetime,
		tgt.CreatedBy = #src.CreatedBy,
		tgt.UpdatedBy = #src.UpdatedBy,
		tgt.FunderID = #src.FunderID,
		tgt.InvoicePosted = #src.InvoicePosted,
		tgt.BatchNumber = #src.BatchNumber,
		tgt.PaymentTermsDue = #src.PaymentTermsDue,
		tgt.CurrencyCode = #src.CurrencyCode,
		tgt.CurrencyCountry = #src.CurrencyCountry,
		tgt.CurrencySign = #src.CurrencySign,
		tgt.BatchPosted = #src.BatchPosted,
		tgt.BatchDate = #src.BatchDate,
		tgt.BatchPostDate = #src.BatchPostDate,
		tgt.BatchCreatedDatetime = #src.BatchCreatedDatetime,
		tgt.BatchUpdatedDatetime = #src.BatchUpdatedDatetime,
		tgt.BatchCreatedBy = #src.BatchCreatedBy,
		tgt.BatchUpdatedBy = #src.BatchUpdatedBy,
		tgt.BatchType = #src.BatchType,
		tgt.InvoiceNumber = #src.InvoiceNumber,
		tgt.OnHold = #src.OnHold,
		tgt.FeeBasisCode = #src.FeeBasisCode,
		tgt.FeeBasis = #src.FeeBasis,
		tgt.ApplyTo = #src.ApplyTo,
		tgt.Amount = #src.Amount,
		tgt.TaxAmount = #src.TaxAmount,
		tgt.TotalAmount = #src.TotalAmount ,
        tgt.InvoiceReleaseDate = #src.InvoiceReleaseDate,
        tgt.VoidFlag = #src.VoidFlag,
		tgt.DeletedDateTime = null
	;

	
	/*
	pnpInvoiceLine
		InvoiceLineSK
		InvoiceSK					
		ServiceEventActivitySK
		PolicyCoverageSK
		PolicyMemberSK
		FunderSK
		FunderDepartmentSK
		IndividualSK
		PatientIndividualSK
		InvoiceLineID				'CLI_TSH_' + trx_ctrl_num
		InvoiceID					coalesce('CLI_INV_' + inv_ctrl_num, 'CLI_TSH_' + trx_ctrl_num)
		InvoiceLineType				'Primary Funding'
		InvoiceLineTypeShort		'PRI'
		ServiceEventActivityID		'CLI_TSH_' + trx_ctrl_num
		PolicyCoverageID			'CLI_CSV_' + ContractService_ID
		PolicyMemberID				'CLI_CON_' + j.Contract_ID + 'CLI_PER_' + j.Per_ID
		FunderID					'CLI_ORG_' + j.Org_ID
		FunderDepartmentID			'CLI_ORG_' + j.Org_ID
		IndividualID				j.Per_ID
		Fee							project_sell_rate 
		Total						project_sell_amt
		Adjustment					project_sell_nocharge_amt
		AdjustmentID
		AdjustmentName
		AdjustmentCategory
		InvoiceSScale
		Amount						project_sell_amt + project_sell_nocharge_amt
		Seq
		Paid
		PartialPaid
		CreatedDatetime				created_date
		UpdatedDatetime				last_edit_date
		CreatedBy					created_user
		UpdatedBy					last_edit_user
		PolicyAgreementID
		Quantity
		DispAmount
		InvoicePosted
		PatientIndividualID			j.Per_ID
		TaxAmount
		TotalAmount
		TaxAdjustment
		FullyAppliedDate
		ReceiptIDRet
		InvoiceLineIDRet
		NonChargeable
		Service
	*/

	-- 1. transform
	if object_id('tempdb..#il') is not null drop table #il
	select 
		i.InvoiceSK,
		sea.ServiceEventActivitySK,
		pc.PolicyCoverageSK,
		pm.PolicyMemberSK,
		sea.FunderSK,
		sea.FunderDepartmentSK,
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
        id.invoiceDate InvoiceReleaseDate,
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
		sea.FunderID,
		sea.FunderDepartmentID,
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
		[db-au-stage]..dtc_cli_patrxdet il 
		left join [db-au-stage]..dtc_cli_Job j on j.Job_Num = il.project_code 
		left join [db-au-stage]..dtc_cli_Base_Job bj on j.Job_ID = bj.Job_id 
		left join [db-au-stage]..dtc_cli_ServiceFile_Lookup jlu on jlu.uniquecaseid = bj.Pene_id 
		left join [db-au-stage]..dtc_cli_patrx patrx on patrx.trx_ctrl_num = il.inv_ctrl_num 
		left join [db-au-stage]..dtc_cli_paprojct p on p.project_code = il.project_code 
		left join [db-au-stage]..dtc_cli_pataxtypdet t on t.tax_type_code = coalesce(patrx.sell_tax_code, p.project_sell_tax_code) 
		left join [db-au-stage]..dtc_cli_pabatch b on b.batch_ctrl_num = il.batch_ctrl_num 
		left join [db-au-stage]..dtc_cli_DT_StaffAccrualTimesheets s on il.trx_ctrl_num = s.trx_ctrl_num 
		left join [db-au-stage]..dtc_cli_vwTimesheetInvoiceDate id on id.trx_ctrl_num = il.trx_ctrl_num 
		outer apply (
			select top 1 InvoiceSK 
			from [db-au-dtc]..pnpInvoice 
			where InvoiceID = 'CLI_INV_' + il.inv_ctrl_num
		) i 
		outer apply (
			select top 1 ServiceEventActivitySK, FunderSK, FunderDepartmentSK, FunderID, FunderDepartmentID
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
		tgt.NonChargeable = #il.NonChargeable,
		tgt.DeletedDateTime = null
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
            InvoiceReleaseDate,
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
            #inv.InvoiceReleaseDate,
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
        tgt.InvoiceReleaseDate = #inv.InvoiceReleaseDate,
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
		tgt.InvoicePosted = '1',
		tgt.DeletedDateTime = null
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

	-------------------------------------------------------------------------------------------------

	----------------- process contract fee invoices -------------------------

	if object_id('tempdb..#ffil') is not null drop table #ffil 
	select 
		InvoiceSK,
		IndividualSK,
		IndividualSK PatientIndividualSK,
		IsNull('CLI_SCH_' + ps.trx_ctrl_num, InvoiceID) InvoiceLineID,
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
		sf.Service [Service],
		IsNull('CLI_SCH_' + ps.trx_ctrl_num, 'CLI_INV_' + patrx.trx_ctrl_num) ServiceEventID,
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
		psm.Schedule_End_Date ScheduleEndDate,
        ps.schedule_date ScheduleDate
	into #ffil
	from 
		[db-au-dtc]..pnpInvoice i 
		join [db-au-stage]..dtc_cli_patrx patrx on 'CLI_INV_' + patrx.trx_ctrl_num = i.InvoiceID 
		join [db-au-dtc]..pnpServiceFile sf on sf.ClienteleJobNumber = patrx.project_code 
		left join [db-au-stage]..dtc_cli_papaysch ps on patrx.trx_ctrl_num = ps.inv_ctrl_num COLLATE DATABASE_DEFAULT 
		left join [db-au-stage]..dtc_cli_papaysch_more psm on psm.trx_ctrl_num = ps.trx_ctrl_num 
	where 
		FeeBasisCode in ('FF','FFPD') 
		and i.InvoiceID like 'CLI_INV_%' 
		--and not exists (select 1 from [db-au-dtc]..pnpInvoiceLine where InvoiceID = i.InvoiceID and InvoiceLineID like 'CLI_TSH_%')
	UNION ALL
	select 
		null InvoiceSK,
		pind.IndividualSK IndividualSK,
		pind.IndividualSK PatientIndividualSK,
		'CLI_SCH_' + ps.trx_ctrl_num InvoiceLineID,
		null InvoiceID,
		pind.IndividualSK PatientIndividualID,
		pind.IndividualID IndividualID,
		null InvoiceDate,
		'Primary Funding' InvoiceLineType,
		'PRI' InvoiceLineTypeShort,
		ps.project_sell_invoice_amt Amount,
		null TaxAmount,
		ps.project_sell_invoice_amt TotalAmount,
		case 
			when ps.project_sell_invoice_amt = 0 then 1 
			else 0 
		end NonChargeable,
		sf.Service [Service],
		'CLI_SCH_' + ps.trx_ctrl_num ServiceEventID,
		sf.FunderSK,
		sf.FunderID,
		sf.CaseSK,
		sf.CaseID,
		sf.ServiceFileSK,
		sf.ServiceFileID,
		sf.FunderDepartmentSK,
		sf.FunderDepartmentID,
		'Contract Fees' Title,
		ps.schedule_date StartDatetime,
		ps.schedule_date EndDatetime,
		ps.created_date CreatedDatetime,
		ps.last_edit_date UpdatedDatetime,
		ps.created_user CreatedBy,
		ps.last_edit_user UpdatedBy,
		psm.Schedule_Start_Date ScheduleStartDate,
		psm.Schedule_End_Date ScheduleEndDate,
        ps.schedule_date ScheduleDate
	from 
		[db-au-stage]..dtc_cli_papaysch ps 
		left join [db-au-stage]..dtc_cli_papaysch_more psm on psm.trx_ctrl_num = ps.trx_ctrl_num
		join [db-au-dtc]..pnpServiceFile sf on sf.ClienteleJobNumber = ps.project_code 
		outer apply (
				select top 1 i.IndividualSK, i.IndividualID, i.FirstName + ' ' + i.LastName BillTo 
				from [db-au-dtc]..pnpIndividual i join [db-au-dtc]..pnpServiceFileMember sfm on sfm.IndividualSK = i.IndividualSK 
				where sfm.ServiceFileMemberSK = sf.PresentingServiceFileMemberSK and i.IsCurrent = 1
			) pind 
	where
		ps.inv_ctrl_num is null

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
			ScheduleEndDate,
            ScheduleDate
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
			#sea.ScheduleEndDate,
            #sea.ScheduleDate
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
			tgt.ScheduleEndDate = #sea.ScheduleEndDate,
            tgt.ScheduleDate = #sea.ScheduleDate,
			tgt.DeletedDateTime = null
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
		PolicyCoverageSK,
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
		#il1.PolicyCoverageSK,
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
		tgt.PolicyCoverageSK = #il1.PolicyCoverageSK,
		tgt.InvoiceID = #il1.InvoiceID,
		tgt.PatientIndividualID = #il1.PatientIndividualID,
		tgt.IndividualID = #il1.IndividualID,
		tgt.InvoiceLineType = #il1.InvoiceLineType,
		tgt.InvoiceLineTypeShort = #il1.InvoiceLineTypeShort,
		tgt.Amount = #il1.Amount,
		tgt.TaxAmount = #il1.TaxAmount,
		tgt.TotalAmount = #il1.TotalAmount,
		tgt.NonChargeable = #il1.NonChargeable,
		tgt.[Service] = #il1.[Service],
		tgt.DeletedDateTime = null
	;

	---------------------------------------------------------------------

	UPDATE sea
	set DeletedDatetime = Getdate()
	--select *
	from [db-au-dtc].dbo.pnpServiceEventActivity sea
	where sea.ServiceEventActivityID like 'CLI_SCH%'
	AND not exists (select 1 from dtc_cli_papaysch ps where sea.ServiceEventActivityID = 'CLI_SCH_' + ps.trx_ctrl_num)
	AND DeletedDatetime is null

	if object_id('tempdb..#patrx') is not null drop table #patrx
	select trx_ctrl_num, 'CLI_INV_' + trx_ctrl_num as InvoiceID
	into #patrx
	from [SAEAPSYD03VDB01].DTProAccounting.dbo.patrx

	UPDATE sea
	set DeletedDatetime = Getdate()
	--select *
	from [db-au-dtc].dbo.pnpServiceEventActivity sea
	where sea.ServiceEventActivityID like 'CLI_INV%'
	AND not exists (select 1 from #patrx p where sea.ServiceEventActivityID = InvoiceID)
	AND DeletedDatetime is null

	UPDATE i
	set DeletedDatetime = Getdate()
	--select *
	from [db-au-dtc].dbo.pnpInvoice i
	where i.InvoiceID like 'CLI_INV%'
	AND not exists (select 1 from #patrx p where i.InvoiceID = InvoiceID)
	AND DeletedDatetime is null

	update il
	set DeletedDatetime = sea.DeletedDatetime
	--select *
	from [db-au-dtc].dbo.pnpServiceEventActivity sea
	join [db-au-dtc].dbo.pnpInvoiceLine il on sea.ServiceEventActivitySK = il.ServiceEventActivitySK
	where sea.DeletedDatetime is not null
	and il.DeletedDatetime is null

END
GO
