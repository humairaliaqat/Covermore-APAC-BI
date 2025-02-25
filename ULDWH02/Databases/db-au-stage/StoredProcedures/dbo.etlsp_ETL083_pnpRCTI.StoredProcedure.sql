USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpRCTI]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL083_pnpRCTI]
as

SET NOCOUNT ON

begin

--Change History:
--	20170701 - VL - Created
--	20180327 - DM - Adjusted to recognise the BoH date from previous system as the Finance Date
--	20181203 - LT - Refactored for RCTI2


	if object_id('[db-au-stage].dbo.etl_pnpRCTI') is not null drop table [db-au-stage].dbo.etl_pnpRCTI
	select
		h.InvoiceID,
		h.InvoiceDate,
		h.ResourceCode,
		h.RecipientName,
		h.RecipientAddressLine1,
		h.RecipientAddressLine2,
		h.RecipientAddressLine3,
		h.RecipientABN,
		h.EpicorVendorCode,
		h.SupplierName,
		h.SupplierAddressLine1,
		h.SupplierAddressLine2,
		h.SupplierAddressLine3,
		h.SupplierABN,
		h.AmountExGST,
		h.GST HeaderGST,
		h.AmountIncGST,
		h.DateCreated,
		h.IsPrinted,
		h.DatePrinted,
		h.SupplierEmailAddress,
		h.IsRegisteredForGST,
		h.ContainsAdjustment,
		h.DocumentTitle,
		h.CPFNotCompleted HeaderCPFNotCompleted,
		h.CPFCompletedDate,
		h.EpicorVoucherNo,
		h.TimesheetToDate,
		h.IsVoidAndReIssue,
		h.VoidVoucher,
		h.ReIssueVoucher,
		h.BSB,
		h.BankAccount,
		h.EpicorVendorBalance,
		l.LineNum,
		l.PeriodDescription,
		l.LineDescription,
		l.Unit,
		l.Qty,
		l.Rate,
		l.AmtExGST,
		l.GST LineGST,
		l.AmtIncGST,
		l.TimesheetControlID,
		l.CPFNotCompleted LineCPFNotCompleted,
		l.AccountCodeSegment1,
		l.AccountCodeSegment2,
		l.AccountCodeSegment3,
		l.AccountReferenceCode,
		l.TaxCode,
		l.CompanyCode,
		l.CompanyID,
		l.OverSessionLimitFlag,
		l.OldTimesheetEntryFlag,
		l.VoidDontReissue,
		l.PayrollCategory
	into [db-au-stage].dbo.etl_pnpRCTI
	from
		PenelopeDataMart_RCTI_Header_audtc h
		inner join PenelopeDataMart_RCTI_Lines_audtc l on h.InvoiceID = l.InvoiceID


    if object_id('[db-au-dtc].dbo.pnpRCTI') is null
	begin
		create table [db-au-dtc].dbo.pnpRCTI
		(
			[InvoiceID] [varchar](20) NOT NULL,
			[InvoiceDate] [datetime] NULL,
			[ResourceCode] [varchar](10) NULL,
			[RecipientName] [varchar](40) NULL,
			[RecipientAddressLine1] [varchar](40) NULL,
			[RecipientAddressLine2] [varchar](40) NULL,
			[RecipientAddressLine3] [varchar](40) NULL,
			[RecipientABN] [varchar](20) NULL,
			[EpicorVendorCode] [varchar](12) NULL,
			[SupplierName] [varchar](40) NULL,
			[SupplierAddressLine1] [varchar](40) NULL,
			[SupplierAddressLine2] [varchar](40) NULL,
			[SupplierAddressLine3] [varchar](40) NULL,
			[SupplierABN] [varchar](20) NULL,
			[AmountExGST] [money] NULL,
			[HeaderGST] [money] NULL,
			[AmountIncGST] [money] NULL,
			[DateCreated] [datetime] NULL,
			[IsPrinted] [bit] NULL,
			[DatePrinted] [datetime] NULL,
			[SupplierEmailAddress] [varchar](255) NULL,
			[IsRegisteredForGST] [varchar](10) NULL,
			[ContainsAdjustment] [bit] NULL,
			[DocumentTitle] [varchar](200) NULL,
			[HeaderCPFNotCompleted] [bit] NULL,
			[CPFCompletedDate] [datetime] NULL,
			[EpicorVoucherNo] [varchar](16) NULL,
			[TimesheetToDate] [datetime] NULL,
			[IsVoidAndReIssue] [bit] NULL,
			[VoidVoucher] [varchar](16) NULL,
			[ReIssueVoucher] [varchar](16) NULL,
			[BSB] [varchar](10) NULL,
			[BankAccount] [varchar](20) NULL,
			[EpicorVendorBalance] [money] NULL,
			[LineNum] [int] NULL,
			[PeriodDescription] [varchar](10) NULL,
			[LineDescription] [varchar](400) NULL,
			[Unit] [varchar](10) NULL,
			[Qty] [money] NULL,
			[Rate] [money] NULL,
			[AmtExGST] [money] NULL,
			[LineGST] [money] NULL,
			[AmtIncGST] [money] NULL,
			[TimesheetControlID] [varchar](50) NOT NULL,
			[LineCPFNotCompleted] [bit] NULL,
			[AccountCodeSegment1] [varchar](32) NULL,
			[AccountCodeSegment2] [varchar](32) NULL,
			[AccountCodeSegment3] [varchar](32) NULL,
			[AccountReferenceCode] [varchar](32) NULL,
			[TaxCode] [varchar](20) NULL,
			[CompanyCode] [varchar](8) NULL,
			[CompanyID] [smallint] NULL,
			[OverSessionLimitFlag] [int] NULL,
			[OldTimesheetEntryFlag] [int] NULL,
			[VoidDontReissue] [bit] NULL,
			[PayrollCategory] [varchar](50) NULL,
			[PaidCurrency] [varchar](5) NULL,
			[OperatingCurrency] [varchar](5) NULL,
			[OperatingBalance] [money] NULL,
			[AUDAmount] [money] NULL,
			[ServiceEventActivitySK] [int] NULL,
			[ServiceEventActivityID] [varchar](100) NULL,
			[UserSK] [int] NULL,
			[Source] [varchar](20) NULL
		)
		create clustered index idx_pnpRCTI_InvoiceID on [db-au-dtc].dbo.pnpRCTI(InvoiceID)
		create nonclustered index idx_pnpRCTI_ServiceEventActivitySK on [db-au-dtc].dbo.pnpRCTI(ServiceEventActivitySK) include(UserSK,InvoiceDate,DateCreated,Unit,Qty,Rate,AmtIncGST,LineCPFNotCompleted)
	end

	 if object_id('[db-au-stage].dbo.etl_pnpRCTI_Src') is not null drop table [db-au-stage].dbo.etl_pnpRCTI_Src

	select
		convert(varchar(20),InvoiceID) as InvoiceID,
		InvoiceDate,
		ResourceCode,
		RecipientName,
		RecipientAddressLine1,
		RecipientAddressLine2,
		RecipientAddressLine3,
		RecipientABN,
		EpicorVendorCode,
		SupplierName,
		SupplierAddressLine1,
		SupplierAddressLine2,
		SupplierAddressLine3,
		SupplierABN,
		AmountExGST,
		HeaderGST,
		AmountIncGST,
		DateCreated,
		IsPrinted,
		DatePrinted,
		SupplierEmailAddress,
		IsRegisteredForGST,
		ContainsAdjustment,
		DocumentTitle,
		HeaderCPFNotCompleted,
		CPFCompletedDate,
		EpicorVoucherNo,
		TimesheetToDate,
		IsVoidAndReIssue,
		VoidVoucher,
		ReIssueVoucher,
		BSB,
		BankAccount,
		EpicorVendorBalance,
		LineNum,
		PeriodDescription,
		LineDescription,
		Unit,
		Qty,
		Rate,
		AmtExGST,
		LineGST,
		AmtIncGST,
		TimesheetControlID,
		LineCPFNotCompleted,
		AccountCodeSegment1,
		AccountCodeSegment2,
		AccountCodeSegment3,
		AccountReferenceCode,
		TaxCode,
		CompanyCode,
		CompanyID,
		OverSessionLimitFlag,
		OldTimesheetEntryFlag,
		VoidDontReissue,
		PayrollCategory,
		'AUD' as PaidCurrency,
		null as OperatingCurrency,
		null as OperatingBalance,
		null as AUDAmount,
		ServiceEventActivityID=dbo.fn_DTCServiceEventActivityID(TimesheetControlID),
		'RCTI' as [Source]
	into [db-au-stage].dbo.etl_pnpRCTI_Src
	from etl_pnpRCTI

	union all

	select 
		InvoiceID,
		InvoiceDate,
		ResourceCode,
		RecipientName,
		RecipientAddressLine1,
		RecipientAddressLine2,
		RecipientAddressLine3,
		RecipientABN,
		EpicorVendorCode,
		SupplierName,
		SupplierAddressLine1,
		SupplierAddressLine2,
		SupplierAddressLine3,
		SupplierABN,
		AmountExGST,
		HeaderGST,
		AmountIncGST,
		DateCreated,
		IsPrinted,
		DatePrinted,
		SupplierEmailAddress,
		IsRegisteredForGST,
		ContainsAdjustment,
		DocumentTitle,
		HeaderCPFNotCompleted,
		CPFCompletedDate,
		EpicorVoucherNo,
		TimesheetToDate,
		IsVoidAndReIssue,
		VoidVoucher,
		ReIssueVoucher,
		BSB,
		BankAccount,
		EpicorVendorBalance,
		LineNum,
		PeriodDescription=CAST(PeriodDescription as varchar(10)),
		LineDescription,
		Unit,
		Qty,
		Rate,
		AmtExGST,
		LineGST,
		AmtIncGST,
		TimesheetControlID,
		LineCPFNotCompleted,
		AccountCodeSegment1,
		AccountCodeSegment2,
		AccountCodeSegment3,
		AccountReferenceCode,
		TaxCode,
		CompanyCode,
		CompanyID,
		OverSessionLimitFlag,
		OldTimesheetEntryFlag,
		VoidDontReissue,
		PayrollCategory=CAST(PayrollCategory as varchar),
		PaidCurrency,
		OperatingCurrency,
		OperatingBalance,
		AUDAmount,
		ServiceEventActivityID=dbo.fn_DTCServiceEventActivityID(TimesheetControlID),
		[Source]
	from 
		[db-au-stage].dbo.DTNSW_dt_VoucherImportlines_vw_audtc vil

	
	merge into [db-au-dtc].dbo.pnpRCTI as tgt
	using [db-au-stage].dbo.etl_pnpRCTI_Src as src
	on tgt.InvoiceID = src.InvoiceID AND tgt.LineNum = src.LineNum
	when matched then
		UPDATE SET
			InvoiceDate = src.InvoiceDate,
			ResourceCode = src.ResourceCode,
			RecipientName = src.RecipientName,
			RecipientAddressLine1 = src.RecipientAddressLine1,
			RecipientAddressLine2 = src.RecipientAddressLine2,
			RecipientAddressLine3 = src.RecipientAddressLine3,
			RecipientABN = src.RecipientABN,
			EpicorVendorCode = src.EpicorVendorCode,
			SupplierName = src.SupplierName,
			SupplierAddressLine1 = src.SupplierAddressLine1,
			SupplierAddressLine2 = src.SupplierAddressLine2,
			SupplierAddressLine3 = src.SupplierAddressLine3,
			SupplierABN = src.SupplierABN,
			AmountExGST = src.AmountExGST,
			HeaderGST = src.HeaderGST,
			AmountIncGST = src.AmountIncGST,
			DateCreated = src.DateCreated,
			IsPrinted = src.IsPrinted,
			DatePrinted = src.DatePrinted,
			SupplierEmailAddress = src.SupplierEmailAddress,
			IsRegisteredForGST = src.IsRegisteredForGST,
			ContainsAdjustment = src.ContainsAdjustment,
			DocumentTitle = src.DocumentTitle,
			HeaderCPFNotCompleted = src.HeaderCPFNotCompleted,
			CPFCompletedDate = src.CPFCompletedDate,
			EpicorVoucherNo = src.EpicorVoucherNo,
			TimesheetToDate = src.TimesheetToDate,
			IsVoidAndReIssue = src.IsVoidAndReIssue,
			VoidVoucher = src.VoidVoucher,
			ReIssueVoucher = src.ReIssueVoucher,
			BSB = src.BSB,
			BankAccount = src.BankAccount,
			EpicorVendorBalance = src.EpicorVendorBalance,
			PeriodDescription = src.PeriodDescription,
			LineDescription = src.LineDescription,
			Unit = src.Unit,
			Qty = src.Qty,
			Rate = src.Rate,
			AmtExGST = src.AmtExGST,
			LineGST = src.LineGST,
			AmtIncGST = src.AmtIncGST,
			TimesheetControlID = src.TimesheetControlID,
			LineCPFNotCompleted = src.LineCPFNotCompleted,
			AccountCodeSegment1 = src.AccountCodeSegment1,
			AccountCodeSegment2 = src.AccountCodeSegment2,
			AccountCodeSegment3 = src.AccountCodeSegment3,
			AccountReferenceCode = src.AccountReferenceCode,
			TaxCode = src.TaxCode,
			CompanyCode = src.CompanyCode,
			CompanyID = src.CompanyID,
			OverSessionLimitFlag = src.OverSessionLimitFlag,
			OldTimesheetEntryFlag = src.OldTimesheetEntryFlag,
			VoidDontReissue = src.VoidDontReissue,
			PayrollCategory = src.PayrollCategory,
			PaidCurrency = src.PaidCurrency,
			OperatingCurrency = src.OperatingCurrency,
			OperatingBalance = src.OperatingBalance,
			AUDAmount = src.AUDAmount,
			ServiceEventActivityID = src.ServiceEventActivityID,
			[Source] = src.[Source]
	when not matched then
		insert 
		(
			InvoiceID,
			InvoiceDate,
			ResourceCode,
			RecipientName,
			RecipientAddressLine1,
			RecipientAddressLine2,
			RecipientAddressLine3,
			RecipientABN,
			EpicorVendorCode,
			SupplierName,
			SupplierAddressLine1,
			SupplierAddressLine2,
			SupplierAddressLine3,
			SupplierABN,AmountExGST,
			HeaderGST,
			AmountIncGST,
			DateCreated,
			IsPrinted,
			DatePrinted,
			SupplierEmailAddress,
			IsRegisteredForGST,
			ContainsAdjustment,
			DocumentTitle,
			HeaderCPFNotCompleted,
			CPFCompletedDate,
			EpicorVoucherNo,
			TimesheetToDate,
			IsVoidAndReIssue,
			VoidVoucher,
			ReIssueVoucher,
			BSB,
			BankAccount,
			EpicorVendorBalance,
			LineNum,
			PeriodDescription,
			LineDescription,
			Unit,
			Qty,
			Rate,
			AmtExGST,
			LineGST,
			AmtIncGST,
			TimesheetControlID,
			LineCPFNotCompleted,
			AccountCodeSegment1,
			AccountCodeSegment2,
			AccountCodeSegment3,
			AccountReferenceCode,
			TaxCode,CompanyCode,
			CompanyID,
			OverSessionLimitFlag,
			OldTimesheetEntryFlag,
			VoidDontReissue,
			PayrollCategory,
			PaidCurrency,
			OperatingCurrency,
			OperatingBalance,
			AUDAmount,
			ServiceEventActivityID,
			[Source]
		)
		values 
		(
			src.InvoiceID,
			src.InvoiceDate,
			src.ResourceCode,
			src.RecipientName,
			src.RecipientAddressLine1,
			src.RecipientAddressLine2,
			src.RecipientAddressLine3,
			src.RecipientABN,
			src.EpicorVendorCode,
			src.SupplierName,
			src.SupplierAddressLine1,
			src.SupplierAddressLine2,
			src.SupplierAddressLine3,
			src.SupplierABN,
			src.AmountExGST,
			src.HeaderGST,
			src.AmountIncGST,
			src.DateCreated,
			src.IsPrinted,
			src.DatePrinted,
			src.SupplierEmailAddress,
			src.IsRegisteredForGST,
			src.ContainsAdjustment,
			src.DocumentTitle,
			src.HeaderCPFNotCompleted,
			src.CPFCompletedDate,
			src.EpicorVoucherNo,
			src.TimesheetToDate,
			src.IsVoidAndReIssue,
			src.VoidVoucher,
			src.ReIssueVoucher,
			src.BSB,
			src.BankAccount,
			src.EpicorVendorBalance,
			src.LineNum,
			src.PeriodDescription,
			src.LineDescription,
			src.Unit,
			src.Qty,
			src.Rate,
			src.AmtExGST,
			src.LineGST,
			src.AmtIncGST,
			src.TimesheetControlID,
			src.LineCPFNotCompleted,
			src.AccountCodeSegment1,
			src.AccountCodeSegment2,
			src.AccountCodeSegment3,
			src.AccountReferenceCode,
			src.TaxCode,
			src.CompanyCode,
			src.CompanyID,
			src.OverSessionLimitFlag,
			src.OldTimesheetEntryFlag,
			src.VoidDontReissue,
			src.PayrollCategory,
			src.PaidCurrency,
			src.OperatingCurrency,
			src.OperatingBalance,
			src.AUDAmount,
			src.ServiceEventActivityID,
			src.[Source]
		)
	;


    update r set
        ServiceEventActivitySK = s.ServiceEventActivitySK,
        UserSK = coalesce(u1.UserSK, u2.UserSK)
    from
        [db-au-dtc].dbo.pnpRCTI r
        left join [db-au-dtc].dbo.pnpServiceEventActivity s on s.ServiceEventActivityID = r.ServiceEventActivityID
        left join [db-au-stage].dbo.dtc_cli_Worker w on w.userdefinedtext1 = r.resourcecode
        left join [db-au-stage].dbo.dtc_cli_Worker_Lookup wl on wl.uniqueworkerid = w.uniqueworkerid
        outer apply (
            select
                UserSK
            from
                [db-au-dtc].dbo.pnpUser
            where
                UserID = coalesce(convert(varchar, wl.kuserid), 'CLI_USR_' + r.ResourceCode)
                and IsCurrent = 1
        ) u1
        outer apply (
            select
                UserSK
            from
                [db-au-dtc].dbo.pnpUser
            where
                UserID = right(r.ResourceCode, len(r.ResourceCode) - 2)
                and IsCurrent = 1
        ) u2
    where
        r.ServiceEventActivitySK is null
        or r.UserSK is null


    update sea
    set
        RCTIDate = ri.RCTIDate
    from
        [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock)
        cross apply
        (
            select
                min(ri.InvoiceDate) RCTIDate
            from
                [db-au-dtc].dbo.pnpRCTI ri with(nolock)
            where
                ri.ServiceEventActivitySK = sea.ServiceEventActivitySK
        ) ri
    where
        sea.RCTIDate is null and
        ri.RCTIDate is not null

end



GO
