USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl083_DTCMarginAnalysis_Payments_v2]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[etlsp_etl083_DTCMarginAnalysis_Payments_v2]
as 
BEGIN
	set nocount on

	-------------------------------------------------------------------

	IF OBJECT_ID('tempdb..#OldTimesheetAttendees') IS NOT NULL DROP TABLE #OldTimesheetAttendees

	SELECT SEA.ServiceEventActivityID, SEAA.UserSK, SEAA.DeletedDatetime, row_number() over(partition by SEA.ServiceEventActivityID order by SEAA.DeletedDatetime DESC) as rnk
	INTO #OldTimesheetAttendees
	from [db-au-dtc].dbo.pnpServiceEventActivity SEA
	JOIN [db-au-dtc].dbo.pnpServiceEventAttendee SEAA ON sea.ServiceEventSK = SEAA.ServiceEventSK
	where SEAA.UserSK IS NOT NULL
	and SEA.ServiceEventActivityID like 'CLI_%'

	IF OBJECT_ID('tempdb..#PaymentDetails') IS NOT NULL 
		DROP TABLE #PaymentDetails

	declare @Benestar int
	select @Benestar = FunderSK
	from [db-au-dtc].dbo.pnpFunder
	where FunderID = '1078'
	and IsCurrent = 1

	create table #PaymentDetails(
		RCTIInvoiceID varchar(20),
		RCTIAmount float,
		RCTIdate date,
		Voucherid varchar(16),
		directCostAccount varchar(4),
		source varchar(20),
		resource_currency varchar(8),
		journal_ctrl_num varchar(16),
		sequence_id int,
		ServiceEventActivityID varchar(100),
		UserSK int,
		ServiceEventActivitySK int,
		QTY float,
		Cost float,
		Include int,
		ServiceFileSK int,
		FunderSK int,
		ServiceSK int,
		CostGLRowID int,
		unitType varchar(20),
		AdjustedAmount float,
		tranDate date,
		AUDExchangeRate float,
		QtySign int,
		MarginLevel int)
	
	--Get All timesheets lines which have been paid via Voucher imports
	insert into #PaymentDetails
	select
		RCTIInvoiceID=aph.apply_to_num,
		RCTIAmount = 
			CASE A.tax_included_flag 
				WHEN 0 THEN (apd.amt_extended)
				WHEN 1 THEN (apd.amt_extended - COALESCE(apd.calc_tax,0)) 
			ELSE apd.amt_extended END ,--* aph.rate_home,
		RCTIdate = IsNUll(VA.AdjustedDate, D.date),
		Voucherid	 = aph.apply_to_num,
		directCostAccount = LEFT(apd.gl_exp_acct,4),
		source = 'Voucher',
		resource_currency = aph.currency_code,
		aph.journal_ctrl_num,
		apd.sequence_id,
		[db-au-workspace].dbo.fn_DTCServiceEventActivityID(V.TimesheetControlID) ServiceEventActivityID,
		IsNull(u1.UserSK,U2.UserSK) UserSK,
		CAST(null as int) as ServiceEventActivitySK,
		null as QTY,
		apd.amt_extended - apd.calc_tax as Cost,
		1 as Include,
		null as ServiceFileSK,
		null as FunderSK,
		null as ServiceSK,
		null as CostGLRowID,
		'hourly' as unitType,
		0,
		null,
		null,
		null,
		0 as MarginLevel
	from 
		DTNSWDW_DTC_VoucherLineTimesheetDetails_audtc V
		LEFT JOIN DTNSWDW_apvodet_audtc apd ON 
			V.voucherNO = apd.trx_Ctrl_num  AND 
			V.LineNum = apd.sequence_id
		LEFT JOIN DTNSWDW_apvohdr_all_audtc aph ON apd.trx_ctrl_num = aph.trx_ctrl_num 
		LEFT JOIN DTNSWDW_DimDate_audtc D ON aph.date_applied between D.epicorStartDate AND D.epicorEndDate
		LEFT JOIN DTNSWDW_artax_audtc A ON apd.tax_code = A.tax_code
		LEFT JOIN eFrontOfficeDW_DTC_VoucherDateAdjustments_audtc VA ON aph.apply_to_num = VA.VoucherNo
		outer apply (
			select REPLACE(REPLACE(value,'_SB',''), 'U','')as value
			from STRING_SPLIT(V.TimeSheetControlID,'-') 
			where RTRIM(value) like 'U%'
			and V.TimeSheetControlID like 'S%A%U%'
		) X
		LEFT JOIN [db-au-dtc].dbo.pnpUser U1 ON X.value = U1.UserID AND U1.IsCurrent = 1
		left join #OldTimesheetAttendees U2 ON 'CLI_TSH_' + V.TimesheetControlID = U2.ServiceEventActivityID AND U2.rnk = 1

	--Get All timesheets lines which have been paid via RCI/RCTI
	INSERT INTO #PaymentDetails
	select 
		RCTIInvoiceID=V.InvoiceID,
		RCTIAmount = 
			CASE 
				WHEN A.tax_included_flag = 0 THEN (apd.amt_extended)
				WHEN A.tax_included_flag = 1 THEN (apd.amt_extended - COALESCE(apd.calc_tax,0)) 
				WHEN Try_CAST(V.InvoiceID as int) > 0 THEN apd.amt_extended
			ELSE V.AmtExGST END ,--* aph.rate_home,
		RCTIdate = CASE WHEN TRY_CAST(V.InvoiceID as int) < 0 THEN DATEADD(d, 1, EOMONTH(IsNUll(VA.AdjustedDate, V.InvoiceDate)))
					ELSE IsNUll(VA.AdjustedDate, V.InvoiceDate) END,
		Voucherid	 = isNull(aph.apply_to_num, V.EpicorVoucherNo),
		directCostAccount = IsNull(LEFT(apd.gl_exp_acct,4), V.AccountCodeSegment1 + '-' + V.AccountCodeSegment2 + '-' + V.AccountCodeSegment3),
		source = CASE WHEN Try_CAST(V.InvoiceID as int) < 0 THEN 'CASUAL RCTI' ELSE IsNull(V.Source,'RCTI') END,
		resource_currency = aph.currency_code,
		aph.journal_ctrl_num,
		apd.sequence_id,
		V.ServiceEventActivityID,
		V.UserSK,
		V.ServiceEventActivitySK,
		V.Qty,
		V.AmtExGST as Cost,
		1 as Include,
		null as ServiceFileSK,
		null as FunderSK,
		null as ServiceSK,
		null as CostGLRowID,
		V.Unit,
		0,
		null,
		null,
		null,
		CASE WHEN TRY_CAST(V.InvoiceID as int) < 0 AND x.department_code = 'CASB' THEN 2 else 0 END as MarginLevel
	from 
		[db-au-dtc].dbo.pnpRCTI V
		LEFT JOIN DTNSWDW_apvodet_audtc apd ON 
			V.EpicorVoucherNo = apd.trx_Ctrl_num  AND 
			V.LineNum = apd.sequence_id
		LEFT JOIN DTNSWDW_apvohdr_all_audtc aph ON apd.trx_ctrl_num = aph.trx_ctrl_num 
		--LEFT JOIN DTNSWDW_DimDate_audtc D ON aph.date_applied between D.epicorStartDate AND D.epicorEndDate
		LEFT JOIN DTNSWDW_artax_audtc A ON apd.tax_code = A.tax_code
		LEFT JOIN eFrontOfficeDW_DTC_VoucherDateAdjustments_audtc VA ON aph.apply_to_num = VA.VoucherNo
		left join [db-au-stage].dbo.dtc_cli_PaResrce x on V.ResourceCode = x.resource_code
	where IsNull(V.LineCPFNotCompleted,0) = 0
	AND IsNull(V.OldTimesheetEntryFlag,0) = 0
	AND IsNull(V.OverSessionLimitFlag,0) = 0
	AND V.Qty <> 0
	and IsNUll(v.source,'') <> 'Voucher Import'

	--CREATE NONCLUSTERED INDEX tmpIDX_GLAssCost
	--ON DTNSWDW_vwCostGLlinesAUD_audtc ([journal_ctrl_num],[seq_ref_id])
	--INCLUDE ([BIRowID],[sequence_id],[account_code],[seg1_code],[seg2_code],[seg3_code],[balance],[AUDbalance],[DateApplied],[DebtorCode],[Description],[Document_1],[Document_2],[CompanyID])

	--CREATE NONCLUSTERED INDEX tmpIDX_GLCost2
	--ON [dbo].[DTNSWDW_vwCostGLlinesAUD_audtc] ([Document_2],[calc_seq_id])
	--INCLUDE ([BIRowID])
	
	CREATE NONCLUSTERED INDEX TMPIDX_SEA_SK
	ON [dbo].[#PaymentDetails] ([ServiceEventActivitySK])

	--Match the SK's
	UPDATE V
	SET ServiceEventActivitySK = SEA.ServiceEventActivitySK,
		ServiceFileSK = SF.ServiceFileSK,
		FunderSK = IsNull(il.FunderSK, SF.FunderSK),
		ServiceSK = SF.ServiceSK,
		tranDate = CAST(se.StartDatetime as Date),
		Qty = sea.Quantity--IsNull(V.QTY, sea.Quantity)
	--select *
	from #PaymentDetails V
	JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea on V.ServiceEventActivityID = SEA.ServiceEventActivityID
	LEFT JOIN [db-au-dtc].dbo.pnpInvoiceLine il ON sea.ServiceEventActivitySK = il.ServiceEventActivitySK AND il.DeletedDatetime is null
	LEFT JOIN [db-au-dtc].dbo.pnpServiceFile sf ON SEA.ServiceFileSK = SF.ServiceFileSK
	LEFT JOIN [db-au-dtc].dbo.pnpServiceEvent se on sea.ServiceEventSK = se.ServiceEventSK

	--Match the SK's
	UPDATE V
	SET ServiceEventActivitySK = RSEA.ServiceEventActivitySK * -1,
		ServiceFileSK = SF.ServiceFileSK,
		FunderSK = SF.FunderSK,
		ServiceSK = SF.ServiceSK
	--select *
	from #PaymentDetails V
	JOIN [db-au-workspace].dbo.usr_DTCRemovedServiceEventActivities RSEA on V.ServiceEventActivityID = RSEA.ServiceEventActivityID
	LEFT JOIN [db-au-dtc].dbo.pnpServiceFile SF ON RSEA.ServiceFileID = SF.ServiceFileID
	where V.ServiceEventActivitySK IS NULL

	update #PaymentDetails
	set FunderSK = @Benestar
	where ServiceEventActivityID like '%dummy%'	

	DECLARE @DailyRateHours float = 8;
	
	--Make adjustments for Daily Rate. Assign the Rates to the work done on the day.
	UPDATE V
	SET	AdjustedAmount=	CASE 
				WHEN unitType = 'Hours' AND dr.DailyAmount <> 0 THEN IsNull((v.qty *  (dr.DailyAmount / HoursCalc)) + Cost, Cost) 
				WHEN unitType = 'Days' AND DailyHours < @DailyRateHours THEN (@DailyRateHours - DailyHours) * (dr.DailyAmount / HoursCalc)
				WHEN unitType = 'Days' AND DailyHours >= @DailyRateHours THEN 0
				END
	from #PaymentDetails V
	cross apply (
		select SUM(Cost) DailyAmount
		from #PaymentDetails PD
		where unittype = 'Days'
		AND V.RCTIInvoiceID = PD.RCTIInvoiceID
		AND CAST(V.tranDate as Date) = CAST(PD.tranDate as Date)
	) dr
	outer apply (
		select SUM(Qty) DailyHours
		from #PaymentDetails PD
		where unittype = 'Hours'
		AND V.RCTIInvoiceID = PD.RCTIInvoiceID
		AND CAST(V.tranDate as Date) = CAST(PD.tranDate as date)
	) hr
	outer apply (
		select 
			IsNull(case 
				when DailyHours < @DailyRateHours THEN @DailyRateHours
				else DailyHours
			END,0) HoursCalc
	) useHours

	--Match to the GL sequence
	update DTNSWDW_vwCostGLlinesAUD_audtc
	set calc_seq_id = seq_ref_id
	where left(Document_1,4) <> 'JRNL'

	IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='tmpIDX_GLCost_Seq' 
		AND object_id = OBJECT_ID('[dbo].[DTNSWDW_vwCostGLlinesAUD_audtc]'))
	begin
		DROP INDEX [tmpIDX_GLCost_Seq] ON [dbo].[DTNSWDW_vwCostGLlinesAUD_audtc];
	end

	CREATE NONCLUSTERED INDEX tmpIDX_GLCost_Seq
	ON [dbo].[DTNSWDW_vwCostGLlinesAUD_audtc] ([calc_seq_id])
	INCLUDE ([BIRowID],[sequence_id],[Document_2])

	--Fix anything else which does not have a GL sequence
	;with missingSeq as (
		select Voucherid,sequence_id, row_number() over(partition by Voucherid order by sequence_id) as rnk
		from #PaymentDetails V
		where not exists (select 1 from DTNSWDW_vwCostGLlinesAUD_audtc G WHERE G.document_2 = V.VoucherId AND V.sequence_id = G.calc_seq_id)),
	missingCostSeq as (
		select BIRowID, sequence_id, seq_ref_id, row_number() over(partition by Document_2 order by sequence_id) as rnk
		from DTNSWDW_vwCostGLlinesAUD_audtc
		where calc_seq_id is null
	)
	UPDATE G
	SET calc_seq_id = MS.sequence_id
	--select *
	from DTNSWDW_vwCostGLlinesAUD_audtc G
	JOIN missingCostSeq MCS ON G.BIRowID = MCS.BIRowID
	JOIN missingSeq MS ON MCS.rnk = MS .rnk AND G.Document_2 = MS.Voucherid

	/* Accrual Engine 
		Add any cost line which appears in the Accural Engine
		Positive the 1st month, negative the month after (automatic reversal)
	*/
	IF OBJECT_ID('tempdb..#AccrualSrc') IS NOT NULL 
		DROP TABLE #AccrualSrc

	IF OBJECT_ID('tempdb..#EOMCurrencyRates') IS NOT NULL 
		DROP TABLE #EOMCurrencyRates

	;with data as (
		select mc.from_currency, mc.to_currency, buy_rate, c.date, c.CurMonthStart, row_number() over(partition by mc.from_currency, mc.to_currency, c.CurMonthStart order by c.Date desc) as rnk
		from [db-au-workspace].dbo.DTNSW_mccurtdt_audtc mc
		join [db-au-cmdwh].dbo.Calendar c on mc.ConvertedDate = c.Date
	)
	select *
	into #EOMCurrencyRates
	from data
	where rnk = 1

	--	declare @Benestar int
	--select @Benestar = FunderSK
	--from [db-au-dtc].dbo.pnpFunder
	--where FunderID = '1078'
	--and IsCurrent = 1

	;with AccrualData as (
		select C.CurMonthStart as [Date], 
				FunderSK=coalesce(case when A.ServiceEventActivityID like '%dummy%' then @Benestar end, il.FunderSK, sf.FunderSK), 
				f.FunderID,
				F.DebtorCode,
				A.Type as AllocatedName, 
				sf.ServiceSK, 
				sea.ServiceEventActivitySK, 
				IsNull(AccruedAmount,0) AccruedAmount, 
				A.UserSK,
				null as [Type], 
				A.ServiceEventActivityID, 
				SF.ClienteleJobNumber, 
				SF.ServiceFileID, 
				REPLACE(A.Account, '-','') as  AccountCode,
				A.DefaultCurrencyCode,
				eommc.buy_rate,
				eommcr.buy_rate as AccrualReversal_Buy_rate,
				A.BatchID,
				A.Company,
				CASE WHEN A.Type = 'Indirect cost accruals - business casuals' THEN 2 ELSE 0 END as MarginLevel,
				row_number() over(order by A.BatchID) as ID				
		from [db-au-dtc].dbo.pnpTimesheetAccrual A
		LEFT JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea on A.ServiceEventActivitySK = sea.ServiceEventActivitySK
		LEFT JOIN [db-au-dtc].dbo.pnpServiceFile sf on sea.ServiceFileSK = sf.ServiceFileSK
		LEFT JOIN [db-au-dtc].dbo.pnpInvoiceLine il ON sea.ServiceEventActivitySK = il.ServiceEventActivitySK AND il.DeletedDatetime is null
		JOIN [db-au-cmdwh].dbo.Calendar C ON CAST(CAST(A.ForPeriod as varchar(6))+ '01' as date) = C.date
		left join #EOMCurrencyRates eommc on A.DefaultCurrencyCode = eommc.from_currency AND eommc.to_currency = 'AUD' AND C.Date = eommc.CurMonthStart
		left join #EOMCurrencyRates eommcr on A.DefaultCurrencyCode = eommcr.from_currency AND eommcr.to_currency = 'AUD' AND Dateadd(month,1,C.[Date]) = eommcr.CurMonthStart
		left join [db-au-dtc].dbo.pnpFunder f on IsNull(il.FunderSK, sf.FunderSK) = f.FunderSK
		where A.Source NOT IN ('Revenue','Revenue - Penelope')
		and A.IsFinal = 1
		and A.AccruedAmount IS NOT NULL
		AND IsNUll(A.Removed_By_Finance,0) = 0
	)
	select A.batchID, A.ID, A.Company, A.[Date], A.FunderSK, A.AllocatedName, A.ServiceSK, A.ServiceEventActivitySK, AccruedAmount * IsNUll(buy_rate,1) as AUDAmount, A.UserSK, 'Cost - Accrual Engine' as [Type],
			A.ServiceEventActivityID, A.AccountCode, A.AccruedAmount, A.DefaultCurrencyCode, A.ClienteleJobNumber, A.ServiceFileID, buy_rate as ExchangeRate, FunderID, DebtorCode, 1 as QtySign, A.MarginLevel
	into #AccrualSrc
	from AccrualData A
	UNION ALL
	select A.batchID, A.ID, A.Company, Dateadd(month,1,A.[Date]), A.FunderSK, A.AllocatedName, A.ServiceSK, A.ServiceEventActivitySK, AccruedAmount * IsNUll(AccrualReversal_Buy_rate,1) * -1 as AUDAmount, A.UserSK, 'Cost - Accrual Engine Reversal',
			A.ServiceEventActivityID, A.AccountCode, A.AccruedAmount * -1,  a.DefaultCurrencyCode, A.ClienteleJobNumber, A.ServiceFileID, AccrualReversal_Buy_rate as ExchangeRate, FunderID, DebtorCode, -1 as QtySign, A.MarginLevel
	from AccrualData A

	update #PaymentDetails
	set QtySign = 
		CASE WHEN sign(qty) = sign(IsNull(Nullif(AdjustedAmount,0),cost)) then 1
			WHEN IsNull(Nullif(AdjustedAmount,0),cost) = 0 then sign(qty)
			WHEN sign(qty) <> sign(IsNull(Nullif(AdjustedAmount,0),cost)) then -1
			end

	truncate table [db-au-dtc].dbo.[pnpFinancialCost] 

	/* Vouchers & RCTI */
	INSERT INTO [db-au-dtc].dbo.[pnpFinancialCost] (Date, FunderSK, AllocatedName, ServiceSK, ServiceEventActivitySK, Cost, GLCompanyID, GLJournalID, GLSequenceID, GLJournalDesc, UserSK, [Type], ServiceEventActivityID, GLAccountCode,NatAmount, CurrencyCode, VoucherNo, OriginalCost,AdjustmentDailyRate,AUDExchangeRate, InvoiceID, Company, QtySign, MarginLevel)
	select	V.RCTIdate, 
			V.FunderSK, 
			V.source, 
			V.ServiceSK, 
			V.ServiceEventActivitySK, 
			CASE WHEN v.Source = 'Casual RCTI' THEN IsNull(v.AdjustedAmount, V.Cost) ELSE IsNull(v.AdjustedAmount, A.AUDbalance) END, 
			A.CompanyID, 
			V.journal_ctrl_num, 
			V.sequence_id, 
			A.Description, 
			V.userSK, 
			'Cost - ' + V.Source, 
			V.ServiceEventActivityID, 
			A.Account_Code, 
			IsNull(v.AdjustedAmount, A.nat_balance), 
			A.nat_cur_code,
			V.Voucherid,
			V.Cost,
			CASE WHEN v.AdjustedAmount is null then 0 else 1 end,
			A.AUDConversionRate,
			V.RCTIInvoiceID,
			A.CompanyName, 
			V.QtySign,
			V.MarginLevel
	from #PaymentDetails V 
	LEFT JOIN DTNSWDW_vwCostGLlinesAUD_audtc A ON A.calc_seq_id = V.sequence_id AND A.document_2 = V.Voucherid


	--select distinct allocatedname from [db-au-dtc].dbo.[pnpFinancialCost]
	/* Cost Accrual Engine */
	INSERT INTO [db-au-dtc].dbo.[pnpFinancialCost] (Date, FunderSK, AllocatedName, ServiceSK, ServiceEventActivitySK, Cost, GLCompanyID, GLJournalID, GLSequenceID, GLJournalDesc, UserSK, [Type], ServiceEventActivityID, GLAccountCode,NatAmount, CurrencyCode, AUDExchangeRate, BatchID, InvoiceID, Company, QtySign, MarginLevel)
	select	A.[Date], 
			A.FunderSK, 
			A.AllocatedName, 
			A.ServiceSK, 
			A.ServiceEventActivitySK, 
			A.AUDAmount, 
			null, 
			null, 
			null, 
			CASE WHEN FunderID like 'CLI%' THEN '' ELSE CAST(FunderID as varchar) + '/' END  + IsNUll(DebtorCode,'') as GLJournalDesc, 
			A.UserSK, 
			A.Type, 
			A.ServiceEventActivityID, 
			A.AccountCode, 
			A.AccruedAmount, 
			A.DefaultCurrencyCode,
			CASE WHEN A.DefaultCurrencyCode = 'AUD' THEN 1 ELSE A.ExchangeRate END,
			A.BatchID,
			A.ID,
			A.Company, 
			A.QtySign,
			A.MarginLevel
	from #AccrualSrc A


	/* Other Costs - Contractors & Associates */
	INSERT INTO [db-au-dtc].dbo.[pnpFinancialCost] (Date, FunderSK, AllocatedName, ServiceSK, ServiceEventActivitySK, Cost, GLCompanyID, GLJournalID, GLSequenceID, GLJournalDesc, UserSK, [Type], ServiceEventActivityID, GLAccountCode,NatAmount, CurrencyCode, AUDExchangeRate, Company, MarginLevel)
	select	A.DateApplied, 
			null as FunderSK, 
			'Journal' as AllocatedName, 
			null as ServiceSK,
			NULL,
			A.AUDbalance, 
			A.CompanyID, 
			A.journal_ctrl_num, 
			A.sequence_id, 
			A.Description, 
			null, 
			CASE WHEN seg1_code = 6862 THEN 'Payroll tax - Contractors'
				 WHEN seg1_code = 5105 THEN 'Interpreter and after hours'
				 WHEN seg1_code IN (5110,5111,5112,5113,5114,5115,6910,6911,6912,6913,6914,6915) THEN 'Post-Cutoff Accrual'
			END as [Type],
			null,
			A.Account_code,
			A.nat_balance,
			A.nat_cur_code,
			A.AUDConversionRate,
			A.companyName,
			2 as MarginLevel
	from DTNSWDW_vwCostGLlinesAUD_audtc A 
	WHERE
		CASE 
			WHEN seg1_code = 6862 THEN 1 --Payroll tax - Contractors
			WHEN seg1_code = 5105 THEN 1 --Interpreter and after hours
			WHEN seg1_code IN (5110,5111,5112,5113,5114,5115,6910,6911,6912,6913,6914,6915) THEN 1 --Post-Cutoff Accrual Accoiunts
			ELSE 0
		END = 1


	/* STAFF COSTS */
																		 
	IF OBJECT_ID('tempdb..#StaffHours') IS NOT NULL DROP TABLE #StaffHours
	IF OBJECT_ID('tempdb..#HourlyRates') IS NOT NULL DROP TABLE #HourlyRates
	IF OBJECT_ID('tempdb..#StaffUsers') IS NOT NULL DROP TABLE #StaffUsers

	select	U.UserSK, 
			U.EmployerIdentificationNumber, 
			SL.HireDate, 
			DateAdd(day,1,SL.ChangeDate) as ChangeDate, 
			SL.[Type], 
			U.FirstName, 
			U.LastName, 
			SL.EpicorSegment2
	into #StaffUsers
	from [db-au-dtc].dbo.pnpUser U			   
	JOIN [db-au-dtc].dbo.usrMarginAnalysisStaffList SL ON CAST(U.EmployerIdentificationNumber as int) = SL.IDNumber
	WHERE SL.[Type] = 'Staff'

	;with AllStaffHours as (
		select	sea.ServiceEventActivitySK, 
				X.FinanceDate, 
				X.FunderSK, 
				sea.Quantity, 
				IsNull(SU.Type,'') ResourceType, 
				U.UserSK, 
				SU.EpicorSegment2, 
				sea.ServiceEventSK, 
				sea.DeletedDatetime
		from [db-au-dtc].dbo.pnpServiceEventActivity sea																												   
		cross apply (select top 1 X.FunderSK, 
						MIN(FinanceDate) over() as FinanceDate
					FROM [db-au-dtc].dbo.pnpInvoiceLine X
					where sea.ServiceEventActivitySK = X.ServiceEventActivitySK
					ORDER BY IsNull(X.FinanceDate,GetDate()) DESC) X
		JOIN [db-au-dtc].dbo.pnpItem I ON sea.ItemSK = I.ItemSK
		join [db-au-dtc].dbo.usrServiceEventActivityAllocated eaa on sea.ServiceEventActivitySK = eaa.ServiceEventActivitySK
		JOIN #StaffUsers SU ON eaa.AllocatedUser = SU.UserSK
		JOIN [db-au-dtc].dbo.pnpUser u on su.UserSK = u.UserSK
		join [db-au-dtc].dbo.pnpServiceEvent se on sea.ServiceEventSK = se.ServiceEventSK
		where IsNull(I.Class,'') NOT IN ('Fee Only','Assessment Fee Only','Disbursement')
		AND isNull(I.UnitOfMeasurementClass,'') NOT IN ('Unit','')
		and X.FinanceDate  >= '20170701'
		and CAST(se.StartDatetime as Date) >= SU.Hiredate
		AND CAST(se.StartDatetime as Date) < IsNull(SU.ChangeDate, Dateadd(day,1,se.StartDatetime))
		and sea.DeletedDatetime is null
	)
	select DATEADD(mm, DATEDIFF(mm, 0,sea.FinanceDate), 0) as CalcFinanceDate,
			sea.FinanceDate, 
			sea.ResourceType as ResourceType, 
			F.FunderSK, 
			IsNull(F.DisplayName,F.Funder) as Funder, 
			sea.ServiceEventActivitySK,
			SF.ServiceSK,
			cast(null as money) as Cost,
			sea.UserSK,
			sea.Quantity,
			sea.EpicorSegment2,
			CASE EpicorSegment2
				WHEN 25 THEN 0
				WHEN 75 THEN 0
				WHEN 79 THEN 1
				WHEN 86 THEN 2
				ELSE 3
			END as MarginLevel
	INTO #StaffHours
	from AllStaffHours sea
	join [db-au-dtc].dbo.pnpServiceEvent se on sea.ServiceEventSK = se.ServiceEventSK
	JOIN [db-au-dtc].dbo.pnpServiceFile SF ON se.ServiceFileSK = SF.ServiceFileSK
	LEFT JOIN [db-au-dtc].dbo.pnpFunder F ON Sea.FunderSK = F.FunderSK

	--select *
	--from #StaffHours

	;with TotalMonthlyCost as (
		select	DateApplied, 
				seg2_code as seg2_code,
				CASE 
					WHEN seg2_code IN (75,25) THEN 0
					WHEN seg2_code IN (79) THEN 1
					WHEN seg2_code IN (86) THEN 2
				END as MarginLevel,
				CASE 
					WHEN seg1_code in ('6820') THEN 'Casual'
					ELSE 'Staff'					   
				END as [Type],
				SUM(AUDbalance) Balance
		from DTNSWDW_vwStaffCostGLlinesAUD_audtc
		WHERE seg1_code not in ('6820') -- Casuals
		GROUP By DateApplied, 
				seg2_code,
				CASE 
					WHEN seg2_code IN (75,25) THEN 0
					WHEN seg2_code IN (79) THEN 1
					WHEN seg2_code IN (86) THEN 2
				END,
				CASE 
					WHEN seg1_code in ('6820') THEN 'Casual'			   
					ELSE 'Staff'
				END
				
		),
	TotalMonthlyHours as (
		select CalcFinanceDate, ResourceType, MarginLevel, SUM(quantity) Qty
		from #StaffHours
		GROUP BY CalcFinanceDate, ResourceType, MarginLevel
		--order by 1,2
	)
	select C.DateApplied, C.Type, C.MarginLevel,SUM(Balance) as Balance,SUM(Qty) as Qty ,SUM(Balance) / Nullif(SUM(Qty),0) as hourlyRate
	into #HourlyRates
	from (SELECT MarginLevel, DateApplied, [Type], SUM(balance) as Balance
			FROM TotalMonthlyCost 
			GROUP BY MarginLevel, DateApplied,[Type]) C
	LEFT JOIN TotalMonthlyHours H ON C.DateApplied = H.CalcFinanceDate 
				AND H.MarginLevel = C.MarginLevel 
			
				AND H.ResourceType = C.Type								 
	GROUP BY C.DateApplied,C.Type, C.MarginLevel

	--
	
	UPDATE S
	SET Cost = H.hourlyRate * S.Quantity
	--select *
	from #StaffHours S
	JOIN #HourlyRates H ON S.CalcFinanceDate = H.DateApplied 
		AND S.ResourceType = H.[Type]
		AND S.MarginLevel = H.MarginLevel


	insert into [db-au-dtc].dbo.[pnpFinancialCost] (date, FunderSK, AllocatedName, ServiceSK, ServiceEventActivitySK, Cost, UserSK, [Type], QtySign, MarginLevel)
	select FinanceDate, FunderSK, ResourceType + ' - Margin ' + CAST(marginLevel as varchar), ServiceSK, ServiceEventActivitySK, isNull(Cost,0), UserSK, 'Cost - Staff', 1, MarginLevel
	from #StaffHours
	where ResourceType = 'Staff'


	ALTER INDEX [IDX_usrDTCFinancial_Date] ON [db-au-dtc].dbo.[usr_DTCFinancial] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ALTER INDEX [IDX_usrDTCFinancial_Cost] ON [db-au-dtc].dbo.[usr_DTCFinancial] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

	--select sea.FinanceDate, null as FunderSK, 'Unknown' ResourceType, sf.ServiceSK, sea.ServiceEventActivitySK, 0 as Cost, null as UserSK, 'Cost - Not Allocated'
	--from [db-au-dtc].dbo.pnpServiceEventActivity sea
	--JOIN [db-au-dtc].dbo.pnpServiceEvent se ON sea.ServiceEventSK = se.ServiceEventSK
	--LEFT JOIN [db-au-dtc].dbo.pnpServiceFile SF ON se.ServiceFileSK = SF.ServiceFileSK
	--LEFT JOIN [db-au-dtc].dbo.pnpItem I ON sea.ItemSK = I.ItemSK
	--where not exists (select 1 from [db-au-dtc].dbo.usr_DTCFinancial F where sea.ServiceEventActivitySK = F.ServiceEventActivitySK and F.[Type] <> 'Revenue')
	--and se.Status IN ('No Show', 'Show', 'Booked', 'Late Cn; Billed As NoShow')
	--AND isNull(I.Class,'') NOT IN ('Assessment Fee Only','Fee Only','Disbursement')
	--and sea.DeletedDatetime is null
end


GO
