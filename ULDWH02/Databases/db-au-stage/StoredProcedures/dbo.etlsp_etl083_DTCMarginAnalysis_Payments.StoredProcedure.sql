USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl083_DTCMarginAnalysis_Payments]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[etlsp_etl083_DTCMarginAnalysis_Payments]
as 
BEGIN

--20190709 - LT - added division by zero check when inserting records to #HourlyRates

	set nocount on

	IF OBJECT_ID('tempdb..#GLCost') IS NOT NULL DROP TABLE #GLCost
	IF OBJECT_ID('tempdb..#VoucherDetails') IS NOT NULL DROP TABLE #VoucherDetails
	IF OBJECT_ID('tempdb..#OldTimesheetAttendees') IS NOT NULL DROP TABLE #OldTimesheetAttendees
	IF OBJECT_ID('tempdb..#AccrualSrc') IS NOT NULL DROP TABLE #AccrualSrc

	/* Get GL lines from Epicor */
	SELECT  BIRowID=identity(int,1,1),*, 0 as Included
	INTO #GLCost
	FROM [DTCSYD03CL1].[DTNSWDW].[dbo].vwCostGLlinesAUD

	SELECT SEA.ServiceEventActivityID, SEAA.UserSK, SEAA.DeletedDatetime, row_number() over(partition by SEA.ServiceEventActivityID order by SEAA.DeletedDatetime DESC) as rnk
	INTO #OldTimesheetAttendees
	from [db-au-dtc].dbo.pnpServiceEventActivity SEA
	JOIN [db-au-dtc].dbo.pnpServiceEventAttendee SEAA ON sea.ServiceEventSK = SEAA.ServiceEventSK
	where SEAA.UserSK IS NOT NULL
	and SEA.ServiceEventActivityID like 'CLI_%'

	create table #VoucherDetails(
		RCTIInvoiceID int,
		RCTIAmount float,
		RCTIdate date,
		Voucherid varchar(16),
		directCostAccount varchar(4),
		source varchar(8),
		resource_currency varchar(8),
		journal_ctrl_num varchar(16),
		sequence_id int,
		ServiceEventActivityID varchar(100),
		UserSK int,
		ServiceEventActivitySK int,
		QTY int,
		Include int,
		ServiceFileSK int,
		FunderSK int,
		ServiceSK int,
		CostGLRowID int)

	--Get All timesheets lines which have been paid via Voucher imports
	insert into #VoucherDetails
	select
		RCTIInvoiceID=null,
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
		[db-au-stage].dbo.fn_DTCServiceEventActivityID(V.TimesheetControlID) ServiceEventActivityID,
		IsNull(u1.UserSK,U2.UserSK) UserSK,
		CAST(null as int) as ServiceEventActivitySK,
		0 as QTY,
		1 as Include,
		null as ServiceFileSK,
		null as FunderSK,
		null as ServiceSK,
		null as CostGLRowID
	from 
		[DTCSYD03CL1].DTNSWDW.dbo.DTC_VoucherLineTimesheetDetails V
		JOIN [DTCSYD03CL1].DTNSWDW.dbo.apvodet apd ON 
			V.voucherNO = apd.trx_Ctrl_num  AND 
			V.LineNum = apd.sequence_id
		JOIN [DTCSYD03CL1].DTNSWDW.dbo.apvohdr_all aph ON apd.trx_ctrl_num = aph.trx_ctrl_num 
		JOIN [DTCSYD03CL1].[DTNSWDW].[dbo].[DimDate] D ON aph.date_applied between D.epicorStartDate AND D.epicorEndDate
		JOIN [DTCSYD03CL1].DTNSWDW.dbo.artax A ON apd.tax_code = A.tax_code
		LEFT JOIN [DTCSYD03CL1].[eFrontOfficeDW].[dbo].[DTC_VoucherDateAdjustments] VA ON aph.apply_to_num = VA.VoucherNo
		LEFT JOIN [db-au-dtc].dbo.pnpUser U1 ON CASE when V.TimeSheetControlID like 'S%A%U%' then substring(V.TimeSheetControlID, charindex('U', V.TimeSheetControlID) + 1, len(V.TimeSheetControlID)) END = U1.UserID AND U1.IsCurrent = 1
		left join #OldTimesheetAttendees U2 ON 'CLI_TSH_' + TimesheetControlID = U2.ServiceEventActivityID AND U2.rnk = 1
	
	--Get All timesheets lines which have been paid via RCI/RCTI
	INSERT INTO #VoucherDetails
	select 
		RCTIInvoiceID=V.InvoiceID,
		RCTIAmount = 
			CASE A.tax_included_flag 
				WHEN 0 THEN (apd.amt_extended)
				WHEN 1 THEN (apd.amt_extended - COALESCE(apd.calc_tax,0)) 
			ELSE apd.amt_extended END ,--* aph.rate_home,
		RCTIdate = IsNUll(VA.AdjustedDate, D.date),
		Voucherid	 = aph.apply_to_num,
		directCostAccount = LEFT(apd.gl_exp_acct,4),
		source = V.Source,
		resource_currency = aph.currency_code,
		aph.journal_ctrl_num,
		apd.sequence_id,
		V.ServiceEventActivityID,
		V.UserSK,
		V.ServiceEventActivitySK,
		V.Qty,
		1 as Include,
		null as ServiceFileSK,
		null as FunderSK,
		null as ServiceSK,
		null as CostGLRowID
	from 
		[db-au-dtc].dbo.pnpRCTI V
		JOIN [DTCSYD03CL1].DTNSWDW.dbo.apvodet apd ON 
			V.EpicorVoucherNo = apd.trx_Ctrl_num  AND 
			V.LineNum = apd.sequence_id
		JOIN [DTCSYD03CL1].DTNSWDW.dbo.apvohdr_all aph ON apd.trx_ctrl_num = aph.trx_ctrl_num 
		JOIN [DTCSYD03CL1].[DTNSWDW].[dbo].[DimDate] D ON aph.date_applied between D.epicorStartDate AND D.epicorEndDate
		JOIN [DTCSYD03CL1].DTNSWDW.dbo.artax A ON apd.tax_code = A.tax_code
		LEFT JOIN [DTCSYD03CL1].[eFrontOfficeDW].[dbo].[DTC_VoucherDateAdjustments] VA ON aph.apply_to_num = VA.VoucherNo
	where V.LineCPFNotCompleted = 0
	AND V.OldTimesheetEntryFlag = 0
	AND V.OverSessionLimitFlag = 0
	AND V.Qty <> 0
	and IsNUll(v.source,'') <> 'Voucher Import'

	CREATE NONCLUSTERED INDEX tmpIDX_GLAssCost
	ON #GLCost ([journal_ctrl_num],[seq_ref_id])
	INCLUDE ([BIRowID],[sequence_id],[account_code],[seg1_code],[seg2_code],[seg3_code],[balance],[AUDbalance],[DateApplied],[DebtorCode],[Description],[Document_1],[Document_2],[CompanyID])

	CREATE NONCLUSTERED INDEX tmpIDX_GLCost2
	ON [dbo].[#GLCost] ([Document_2],[calc_seq_id])
	INCLUDE ([BIRowID])

	--Match the SK's
	UPDATE V
	SET ServiceEventActivitySK = SEA.ServiceEventActivitySK,
		ServiceFileSK = SF.ServiceFileSK,
		FunderSK = SF.FunderSK,
		ServiceSK = SF.ServiceSK
	--select *
	from #VoucherDetails V
	JOIN [db-au-dtc].dbo.pnpServiceEventActivity SEA on V.ServiceEventActivityID = SEA.ServiceEventActivityID
	LEFT JOIN [db-au-dtc].dbo.pnpServiceFile SF ON SEA.ServiceFileSK = SF.ServiceFileSK

	--Match the SK's
	UPDATE V
	SET ServiceEventActivitySK = RSEA.ServiceEventActivitySK * -1,
		ServiceFileSK = SF.ServiceFileSK,
		FunderSK = SF.FunderSK,
		ServiceSK = SF.ServiceSK
	--select *
	from #VoucherDetails V
	JOIN [db-au-workspace].dbo.usr_DTCRemovedServiceEventActivities RSEA on V.ServiceEventActivityID = RSEA.ServiceEventActivityID
	LEFT JOIN [db-au-dtc].dbo.pnpServiceFile SF ON RSEA.ServiceFileID = SF.ServiceFileID
	where V.ServiceEventActivitySK IS NULL

	--Match to the GL sequence
	update #GLCost
	set calc_seq_id = seq_ref_id
	where left(Document_1,4) <> 'JRNL'

	CREATE NONCLUSTERED INDEX tmpIDX_GLCost_Seq
	ON [dbo].[#GLCost] ([calc_seq_id])
	INCLUDE ([BIRowID],[sequence_id],[Document_2])


	--Fix anything else which does not have a GL sequence
	;with missingSeq as (
		select Voucherid,sequence_id, row_number() over(partition by Voucherid order by sequence_id) as rnk
		from #VoucherDetails V
		where not exists (select 1 from #GLCost G WHERE G.document_2 = V.VoucherId AND V.sequence_id = G.calc_seq_id)),
	missingCostSeq as (
		select BIRowID,sequence_id, seq_ref_id, row_number() over(partition by Document_2 order by sequence_id) as rnk
		from #GLCost
		where calc_seq_id is null
	)
	UPDATE G
	SET calc_seq_id = MS.sequence_id
	--select *
	from #GLCost G
	JOIN missingCostSeq MCS ON G.BIRowID = MCS.BIRowID
	JOIN missingSeq MS ON MCS.rnk = MS .rnk AND G.Document_2 = MS.Voucherid

	--Mark any lines worth $0 as already included
	UPDATE V
	SET [include] = 0
	--select *
	from #VoucherDetails V
	where V.Source = 'RCI/RCTI'
	AND V.RCTIAmount = 0
	AND exists (select 1 from #VoucherDetails V1 WHERE V1.ServiceEventActivitySK = V.ServiceEventActivitySK AND V1.RCTIInvoiceID <> V.RCTIInvoiceID AND V1.RCTIAmount <> 0)


	--Mark any lines worth $0 as already included
	;with temp as (select *, SUM(RCTIAmount) over(partition by ServiceEventActivitySK) as summed, 
				COUNT(*) over(partition by ServiceEventActivitySK) as counted, 
				row_number() over(partition by ServiceEventActivityID, Qty order by RCTIInvoiceID, sequence_id) as rnk
	from #VoucherDetails V
	where V.Source = 'RCI/RCTI'
	AND V.RCTIAmount = 0
	)
	UPDATE D
	SET [include] = 0
	--select * 
	from temp T
	JOIN #VoucherDetails D ON T.RCTIInvoiceID = D.RCTIInvoiceID AND T.sequence_id = D.sequence_id
	where summed = 0
	AND rnk > 1

	ALTER INDEX [IDX_usrDTCFinancial_Date] ON [db-au-dtc].[dbo].[usr_DTCFinancial] DISABLE

	delete from [db-au-dtc].dbo.usr_DTCFinancial
	where Cost is not null

	ALTER INDEX [IDX_usrDTCFinancial_Cost] ON [db-au-dtc].[dbo].[usr_DTCFinancial] DISABLE


	/* Accrual Engine 
		Add any cost line which appears in the Accural Engine
		Positive the 1st month, negative the month after (automatic reversal)
	*/
	;with AccrualData as (
		select  C.CurMonthStart as [Date], 
				sf.FunderSK, 
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
				A.DefaultCurrencyCode
		from [db-au-dtc].dbo.pnpTimesheetAccrual A
		LEFT JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea on A.ServiceEventActivitySK = sea.ServiceEventActivitySK
		LEFT JOIN [db-au-dtc].dbo.pnpServiceFile sf on sea.ServiceFileSK = sf.ServiceFileSK
		JOIN [db-au-cmdwh].dbo.Calendar C ON CAST(CAST(A.ForPeriod as varchar(6))+ '01' as date) = C.date
		where Source NOT IN ('Revenue','Revenue - Penelope')
		and IsFinal = 1
		and AccruedAmount IS NOT NULL
	)
	select A.[Date], A.FunderSK, A.AllocatedName, A.ServiceSK, A.ServiceEventActivitySK, 0 as AUDAmount, A.UserSK, 'Cost - Accrual Engine' as [Type],
			A.ServiceEventActivityID, A.AccountCode, A.AccruedAmount, A.DefaultCurrencyCode, A.ClienteleJobNumber, A.ServiceFileID
	into #AccrualSrc
	from AccrualData A
	UNION ALL
	select Dateadd(month,1,A.[Date]), A.FunderSK, A.AllocatedName, A.ServiceSK, A.ServiceEventActivitySK, 0 as AUDAmount, A.UserSK, 'Cost - Accrual Engine Reversal',
			A.ServiceEventActivityID, A.AccountCode, A.AccruedAmount * -1,  a.DefaultCurrencyCode, A.ClienteleJobNumber, A.ServiceFileID
	from AccrualData A

	UPDATE A
	SET Included = 1
	from #GLCost A 
	where exists (select 1 from #VoucherDetails V WHERE A.calc_seq_id = V.sequence_id AND A.document_2 = V.Voucherid AND V.Include = 1)

	/* Vouchers & RCTI */
	INSERT INTO [db-au-dtc].dbo.usr_DTCFinancial (Date, FunderSK, AllocatedName, ServiceSK, ServiceEventActivitySK, Cost, GLCompanyID, GLJournalID, GLSequenceID, GLJournalDesc, UserSK, [Type], ServiceEventActivityID, GLAccountCode,NatAmount, CurrencyCode)
	select A.DateApplied, V.FunderSK, V.source, V.ServiceSK, V.ServiceEventActivitySK, A.AUDbalance, A.CompanyID, A.journal_ctrl_num, A.sequence_id, A.Description, V.userSK, 'Cost - ' + V.Source, V.ServiceEventActivityID, A.Account_Code, A.nat_balance, A.nat_cur_code
	from #VoucherDetails V 
	JOIN #GLCost A ON A.calc_seq_id = V.sequence_id AND A.document_2 = V.Voucherid
	WHERE V.Include = 1

	/* Cost Accrual Engine */
	INSERT INTO [db-au-dtc].dbo.usr_DTCFinancial (Date, FunderSK, AllocatedName, ServiceSK, ServiceEventActivitySK, Cost, GLCompanyID, GLJournalID, GLSequenceID, GLJournalDesc, UserSK, [Type], ServiceEventActivityID, GLAccountCode,NatAmount, CurrencyCode)
	select A.[Date], A.FunderSK, A.AllocatedName, A.ServiceSK, A.ServiceEventActivitySK, A.AUDAmount, null, null, null, null, A.UserSK, A.Type, A.ServiceEventActivityID, A.AccountCode, A.AccruedAmount, A.DefaultCurrencyCode
	from #AccrualSrc A

	/* Other Costs - Contractors & Associates */
	INSERT INTO [db-au-dtc].dbo.usr_DTCFinancial (Date, FunderSK, AllocatedName, ServiceSK, ServiceEventActivitySK, Cost, GLCompanyID, GLJournalID, GLSequenceID, GLJournalDesc, UserSK, [Type], ServiceEventActivityID, GLAccountCode,NatAmount, CurrencyCode)
	select	A.DateApplied, 
			IsNull(SF.FunderSK, SF1.FunderSK) as FunderSK, 
			CASE 
				WHEN Document_1 LIKE 'RC%' THEN 'RCI/RCTI'
				WHEN Document_2 LIKE 'VO%' THEN 'Voucher'
				ELSE 'Journal' 
			END as AllocatedName, 
			IsNull(SF.ServiceSK, SF1.ServiceSK) as ServiceSK,
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
				 WHEN A.journal_description = 'From Voucher Posting.' THEN 'Unmatched Voucher Posting'
				 WHEN left(A.document_2,4) = 'JRNL' AND A.journal_description like 'Accrl%' AND A.Document_2 = A.journal_ctrl_num THEN 'Cost - Accrual Engine'
				 WHEN left(A.document_2,4) = 'JRNL' AND A.journal_description like 'Accrl%' AND A.Document_2 <> A.journal_ctrl_num THEN 'Cost - Accrual Engine Reversal'
				 ELSE 'Unmatched Cost' END as [Type],
			null,
			A.Account_code,
			A.nat_balance,
			A.nat_cur_code
	from #GLCost A 
	outer apply (
		select top 1 FunderSK, ServiceSK
		from [db-au-dtc].dbo.pnpServiceFile SF 
		where A.Document_1 = SF.ClienteleJobNumber
		order by createdDateTime ASC
	) SF
	outer apply (
		select top 1 FunderSK, ServiceSK
		from [db-au-dtc].dbo.pnpServiceFile SF 
		where A.Document_1 = SF.ServiceFileID
		order by createdDateTime ASC
	) SF1
	where Included = 0

	/* STAFF COSTS */
	IF OBJECT_ID('tempdb..#GLStaffCost') IS NOT NULL DROP TABLE #GLStaffCost
	IF OBJECT_ID('tempdb..#StaffHours') IS NOT NULL DROP TABLE #StaffHours
	IF OBJECT_ID('tempdb..#HourlyRates') IS NOT NULL DROP TABLE #HourlyRates
	IF OBJECT_ID('tempdb..#ResML') IS NOT NULL DROP TABLE #ResML

	select *
	INTO #ResML 
	from [db-au-dtc].dbo.vUserMarginLevel

	SELECT *
	INTO #GLStaffCost
	FROM [DTCSYD03CL1].[DTNSWDW].[dbo].vwStaffCostGLlinesAUD

	select DATEADD(mm, DATEDIFF(mm, 0,sea.FinanceDate), 0) as CalcFinanceDate,
			sea.FinanceDate, 
			U.ResourceType + ' - Margin 0' as ResourceType, 
			F.FunderSK, 
			IsNull(F.DisplayName,F.Funder) as Funder, 
			sea.ServiceEventActivitySK,
			SF.ServiceSK,
			cast(null as money) as Cost,
			U.UserSK,
			sea.Quantity
	INTO #StaffHours
	from [db-au-dtc].dbo.pnpServiceEventActivity sea
	join [db-au-dtc].dbo.pnpServiceEvent se on sea.ServiceEventSK = se.ServiceEventSK
	JOIN [db-au-dtc].dbo.pnpItem I ON sea.ItemSK = I.ItemSK
	JOIN [db-au-dtc].dbo.pnpServiceFile SF ON se.ServiceFileSK = SF.ServiceFileSK
	join [db-au-dtc].dbo.usrServiceEventActivityAllocated eaa on sea.ServiceEventActivitySK = eaa.ServiceEventActivitySK
	JOIN [db-au-dtc].dbo.pnpUser U ON eaa.AllocatedUser = U.UserSK
	LEFT JOIN [db-au-dtc].dbo.pnpFunder F ON Sea.FunderSK = F.FunderSK
	LEFT JOIN #ResML R ON U.ClienteleResourceCode = R.ResourceCode
	WHERE sea.FinanceDate  >= '20170701'
	and U.ResourceType IN ('STAFF','Casual')
	AND (
		--U.SecurityClass IN ('Clinician [Intake+Worker]','Clinician [all + policy]','Clinical Management','Clinicians') OR 
		R.MarginLevel = 0
		)
	AND IsNull(I.Class,'') NOT IN ('Fee Only','Assessment Fee Only','Disbursement')
	AND isNull(I.UnitOfMeasurementClass,'') NOT IN ('Unit','')
	and IsNull(F.DisplayName,F.Funder) NOT LIKE 'Davidson%'
	AND sea.DeletedDatetime is null
	--AND SE.Category <> 'Indirect'
	UNION ALL
	select DATEADD(mm, DATEDIFF(mm, 0,sea.FinanceDate), 0) as CalcFinanceDate,
			sea.FinanceDate, 
			U.ResourceType + ' - Margin 1' as ResourceType, 
			F.FunderSK, 
			IsNull(F.DisplayName,F.Funder) as Funder, 
			sea.ServiceEventActivitySK,
			SF.ServiceSK,
			cast(null as money) as Cost,
			U.UserSK,
			sea.Quantity
	from [db-au-dtc].dbo.pnpServiceEventActivity sea
	join [db-au-dtc].dbo.pnpServiceEvent se on sea.ServiceEventSK = se.ServiceEventSK
	JOIN [db-au-dtc].dbo.pnpItem I ON sea.ItemSK = I.ItemSK
	JOIN [db-au-dtc].dbo.pnpServiceFile SF ON se.ServiceFileSK = SF.ServiceFileSK
	join [db-au-dtc].dbo.usrServiceEventActivityAllocated eaa on sea.ServiceEventActivitySK = eaa.ServiceEventActivitySK
	JOIN [db-au-dtc].dbo.pnpUser U ON eaa.AllocatedUser = U.UserSK
	LEFT JOIN [db-au-dtc].dbo.pnpFunder F ON Sea.FunderSK = F.FunderSK
	LEFT JOIN #ResML R ON U.ClienteleResourceCode = R.ResourceCode
	WHERE sea.FinanceDate >= '20170701'
	and U.ResourceType IN ('STAFF','CASUAL')
	AND (
		--U.SecurityClass IN ('Account Management','Coordinator','Coordinator [w/ Informal]') OR 
		R.MarginLevel = 1
		)
	AND IsNull(I.Class,'') NOT IN ('Fee Only','Assessment Fee Only','Disbursement')
	AND isNull(I.UnitOfMeasurementClass,'') NOT IN ('Unit','')
	and IsNull(F.DisplayName,F.Funder) NOT LIKE 'Davidson%'
	AND sea.DeletedDatetime is null


	;with TotalMonthlyCost as (
		select DateApplied, seg2_code, SUM(AUDbalance) Balance
		from #GLStaffCost
		WHERE seg1_code not in ('6820') -- Casuals
		GROUP By DateApplied, seg2_code
		--order by 1,2
		),
	TotalCasualCost as (
		select DateApplied, seg2_code, SUM(AUDbalance) Balance
		from #GLStaffCost
		WHERE seg1_code in ('6820') -- Casuals
		GROUP By DateApplied, seg2_code
		--order by 1,2
		),
	TotalMonthlyHours as (
		select CalcFinanceDate, ResourceType, SUM(quantity) Qty
		from #StaffHours
		GROUP BY CalcFinanceDate, ResourceType
		--order by 1,2
	)
	select 
		C.DateApplied,H.ResourceType,
		SUM(Balance) as Balance,
		SUM(Qty) as Qty ,
		case when sum(Qty) <> 0 then SUM(Balance) / SUM(Qty) else 0 end as hourlyRate
	into #HourlyRates
	from (SELECT DateApplied, SUM(balance) as Balance
			FROM TotalMonthlyCost 
			WHERE seg2_code IN (75,25)
			GROUP BY DateApplied) 	C
	LEFT JOIN TotalMonthlyHours H ON C.DateApplied = H.CalcFinanceDate AND H.ResourceType = 'Staff - Margin 0'
	GROUP BY C.DateApplied,H.ResourceType
	
	UNION ALL
	select 
		C.DateApplied,H.ResourceType,
		SUM(Balance),
		SUM(Qty),
		case when sum(Qty) <> 0 then SUM(Balance) / SUM(Qty) else 0 end
	from (SELECT DateApplied, SUM(balance) as Balance
			FROM TotalMonthlyCost 
			WHERE seg2_code IN (79)
			GROUP BY DateApplied) 	C
	LEFT JOIN TotalMonthlyHours H ON C.DateApplied = H.CalcFinanceDate AND H.ResourceType = 'Staff - Margin 1'
	GROUP BY C.DateApplied,H.ResourceType
	
	UNION ALL
	
	select 
		C.DateApplied,
		H.ResourceType,
		SUM(Balance),
		SUM(Qty),
		case when Sum(Qty) <> 0 then SUM(Balance) / SUM(Qty) else 0 end
	from (SELECT DateApplied, SUM(balance) as Balance
			FROM TotalCasualCost
			where Seg2_code IN (75,25)
			GROUP BY DateApplied) 	C
	LEFT JOIN TotalMonthlyHours H ON C.DateApplied = H.CalcFinanceDate AND H.ResourceType = 'Casual - Margin 0'
	GROUP BY C.DateApplied,H.ResourceType

	UPDATE S
	SET Cost = H.hourlyRate * S.Quantity
	--select *
	from #StaffHours S
	JOIN #HourlyRates H ON S.CalcFinanceDate = H.DateApplied AND S.ResourceType = H.ResourceType

	insert into [db-au-dtc].dbo.usr_DTCFinancial (date, FunderSK, AllocatedName, ServiceSK, ServiceEventActivitySK, Cost, UserSK, [Type])
	select FinanceDate, FunderSK, ResourceType, ServiceSK, ServiceEventActivitySK, isNull(Cost,0), UserSK, 'Cost - Staff'
	from #StaffHours
	where ResourceType like 'STAFF%'
	UNION ALL
	select FinanceDate, FunderSK, ResourceType, ServiceSK, ServiceEventActivitySK, isNull(Cost,0), UserSK, 'Cost - Casual'
	from #StaffHours
	where ResourceType like 'Casual%'
	UNION ALL
	select DateApplied, null, CASE WHEN seg1_code IN ('6820') then 'Casual' ELSE 'Staff' END + ' - Margin 2', 50, null, IsNull(sum(AUDBalance),0), null, 'Cost - ' + CASE WHEN seg1_code IN ('6820') then 'Casual' ELSE 'Staff' END
	from #GLStaffCost
	where seg2_code = 86
	GROUP BY DateApplied, seg1_code


	ALTER INDEX [IDX_usrDTCFinancial_Date] ON [db-au-dtc].dbo.[usr_DTCFinancial] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ALTER INDEX [IDX_usrDTCFinancial_Cost] ON [db-au-dtc].dbo.[usr_DTCFinancial] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)


end

GO
