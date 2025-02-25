USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [COVERMORE\dmurray].[etlsp_etl083_DTCMarginAnalysis_Revenue]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [COVERMORE\dmurray].[etlsp_etl083_DTCMarginAnalysis_Revenue]
as
BEGIN

	--IF OBJECT_ID('tempdb..[db-au-workspace].dbo.DTNSWDW_vwRevenueAUD_audtc') IS NOT NULL DROP TABLE [db-au-workspace].dbo.DTNSWDW_vwRevenueAUD_audtc
	IF OBJECT_ID('tempdb..#FunderMatching') IS NOT NULL DROP TABLE #FunderMatching
	IF OBJECT_ID('tempdb..#src') IS NOT NULL DROP TABLE #src


	;with CurrentFunder as (
		select F.FunderSK, isNull(F2.FunderSK, F.FunderSK) as CurrentFunderSK, F.FunderID, F.DebtorCode
		from [db-au-dtc]..pnpFunder F
		Left JOIN [db-au-dtc]..pnpFunder F2 ON F.FunderID = F2.FunderID AND F2.IsCurrent = 1
	)
	select DISTINCT identity(int,1,1) as BIRowID, CurrentFunderSK as FunderSK, FunderID, OrgDebtor, CustomerDebtorCode
	INTO #FunderMatching
	--select DISTINCT CurrentFunderSK as FunderSK, FunderID, OrgDebtor, CustomerDebtorCode
	from (select DISTINCT F.CurrentFunderSK, F.FunderID, F.DebtorCode as OrgDebtor,
			CAST(Nullif(F.DebtorCode,'') + 
				CASE S.SiteName 
					WHEN '[1] DTC EES' THEN 'EES'
					WHEN '[1] DTC Mental Wellbeing' THEN 'MW'
					WHEN '[1] DTC EAP' THEN 'EAP'
					WHEN '[1] DTC Performance' THEN 'PER'
					WHEN '[1] DTC Remote Sites' THEN 'DC'
					WHEN 'DTC Singapore' THEN 'SNG'
					WHEN 'DTC Health and Performance' THEN 'SHP'
					else S.StateShort END as varchar(20)) as CalcDebtorCode,
			CAST('P' + format(CASE WHEN isNumeric(F.FunderID) = 1 THEN CAST(F.FunderID as int) else NULL END,'000000') as varchar(20)) as PenelopeFunderDebtor, 
			CAST(p.ClienteleDebtorCode as varchar(20)) ClienteleDebtorCode
		from [db-au-dtc]..pnpPolicy P
		LEFT JOIN [db-au-dtc]..pnpSite S ON isNull(P.PublicPolicyPayableToSiteSK,P.PayableToSiteSK) = S.SiteSK 
		JOIN CurrentFunder F ON P.FunderSK = F.FunderSK
		) as src
		unpivot (
			CustomerDebtorCode FOR Detail IN (PenelopeFunderDebtor, ClienteleDebtorCode, CalcDebtorCode)
		) pvt
	where IsNull(CustomerDebtorCode,'') NOT IN ('')

	;with CurrentFunder as (
		select F.FunderSK, isNull(F2.FunderSK, F.FunderSK) as CurrentFunderSK, F.FunderID, F.DebtorCode
		from [db-au-dtc]..pnpFunder F
		Left JOIN [db-au-dtc]..pnpFunder F2 ON F.FunderID = F2.FunderID AND F2.IsCurrent = 1
	)
	insert into #FunderMatching (FunderSK, FunderID, OrgDebtor, CustomerDebtorCode)
	SELECT DISTINCT CurrentFunderSK, FunderID, OrgDebtor, CustomerDebtorCode
	FROM (select DISTINCT F.CurrentFunderSK, F.funderID, F.DebtorCode as OrgDebtor, 
			CAST(SF.ClienteleJobNumber as varchar(20)) ClienteleJobNumber, 
			CASE WHEN SF.ServiceFileID LIKE 'CLI%' THEN NULL ELSE CAST(SF.ServiceFileID as varchar(20)) END ServiceFileID
		from [db-au-dtc]..pnpServiceFile SF
		JOIN CurrentFunder F ON SF.FunderSK = F.FunderSK
		) as src
		unpivot (
			CustomerDebtorCode FOR Detail IN (ClienteleJobNumber, ServiceFileID)
		) pvt

	CREATE NONCLUSTERED INDEX TMPIDX_Code
	ON [dbo].[#FunderMatching] ([CustomerDebtorCode])
	INCLUDE ([FunderSK])

	;with temp as (
		select BIRowID, CustomerDebtorCode, COUNT(*) over(partition by CustomerDebtorCode) as cnt
		from #FunderMatching)
	delete f--select * 
	from temp t
	join #FunderMatching F ON t.BIRowID = F.BIRowID
	where cnt > 1
	AND t.CustomerDebtorCode not like IsNull(F.OrgDebtor,'') + '%'

	;with [Data] as (
		select 
			G.DateApplied, 
			F.FunderSK, 
			S.ServiceSK, 
			G.AUDBalance, 
			G.journal_ctrl_num, 
			G.sequence_id, 
			G.Description, 
			G.Document_1, 
			G.CompanyID, 
			--1 as src, 
			G.seg1_code, 
			G.seg2_code, 
			G.seg3_code,
			CASE 
				WHEN G.seg1_code IN (4110,4112) then 'Post Cutoff Accruals'
				WHEN G.Description LIKE 'SUSPENSE%' THEN 'SUSPENSE'
				WHEN G.description LIKE 'ACCURAL%' THEN 'ACCRUAL'
				WHEN G.CompanyID = 23 AND F.FunderSK IS NULL then 'PrimeXL Unknown'
			END as AllocatedName,
			G.Account_Code,
			G.Balance,
			G.nat_cur_code,
			G.nat_balance,
			G.AUDConversionRate,
			G.Document_2,
			G.CompanyName
		from [db-au-workspace].dbo.DTNSWDW_vwRevenueAUD_audtc G
		JOIN #FunderMatching F  ON (G.DebtorCode = F.CustomerDebtorCode)
		LEFT JOIN [db-au-workspace].dbo.usr_DTCServiceGLMapping S ON G.seg2_code = S.GLSeg2Code
	),
	dataDocument as (
		select 
			G.DateApplied, 
			F.FunderSK, 
			S.ServiceSK, 
			G.AUDBalance, 
			G.journal_ctrl_num, 
			G.sequence_id, 
			G.Description, 
			G.Document_1, 
			G.CompanyID, 
			--2 as src, 
			G.seg1_code, 
			G.seg2_code, 
			G.seg3_code,
			CASE 
				WHEN G.seg1_code IN (4110,4112) then 'Post Cutoff Accruals'
				WHEN G.Description LIKE 'SUSPENSE%' THEN 'SUSPENSE'
				WHEN G.description LIKE 'ACCURAL%' THEN 'ACCRUAL'
				WHEN G.CompanyID = 23 AND F.FunderSK IS NULL then 'PrimeXL Unknown'
			END as AllocatedName,
			G.Account_Code,
			G.Balance,
			G.nat_cur_code,
			G.nat_balance,
			G.AUDConversionRate,
			G.Document_2,
			G.CompanyName
		from [db-au-workspace].dbo.DTNSWDW_vwRevenueAUD_audtc G
		LEFT JOIN #FunderMatching F  ON (G.Document_1 = F.CustomerDebtorCode)
		LEFT JOIN [db-au-workspace].dbo.usr_DTCServiceGLMapping S ON G.seg2_code = S.GLSeg2Code
		where not exists (select 1 from [Data] D where G.Journal_ctrl_num = D.journal_ctrl_num AND G.sequence_id = D.sequence_id AND D.CompanyID = G.CompanyID)
	)
	select * 
	into #src
	from [Data]
	UNION ALL
	select * from dataDocument

	merge into [db-au-dtc].dbo.[pnpFinancialRevenue] as tgt
	using #src as src
	on tgt.GLJournalID = src.journal_ctrl_num AND tgt.GLSequenceID = src.sequence_id AND tgt.GLCompanyID = src.CompanyID
	WHEN NOT MATCHED THEN
		INSERT(
			[Date],
			FunderSK,
			AllocatedName,
			ServiceSK,
			Revenue,
			GLJournalID,
			GLSequenceID,
			GLJournalDesc,
			GLCompanyID,
			[Type],
			GLAccountCode,
			NatAmount,
			CurrencyCode,
			VoucherNo,
			OriginalCost,
			AdjustmentDailyRate,
			AUDExchangeRate,
			InvoiceID,
			BatchID,
			Company,
			MarginLevel
		)
		values (
			src.[DateApplied],
			src.FunderSK,
			src.AllocatedName,
			src.ServiceSk,
			src.AUDBalance,
			src.journal_ctrl_num,
			src.sequence_id,
			src.Description,
			src.CompanyID,
			'Revenue',
			src.account_code,
			src.balance,
			src.nat_cur_code,
			null,
			src.nat_balance,
			null,
			src.AUDConversionRate,
			src.document_2,
			null,
			src.CompanyName,
			0
		)
	when MATCHED then
		UPDATE
			SET tgt.[Date] = src.DateApplied,
				tgt.FunderSK = src.FunderSK, -- (-1) Represents After-cutoff Accruals
				tgt.AllocatedName = src.AllocatedName,
				tgt.ServiceSK = src.ServiceSK,
				tgt.Revenue = src.AUDBalance,
				tgt.GLJournalDesc = src.Description,
				tgt.GLCompanyID = src.CompanyID,
				tgt.[Type] = 'Revenue',
				tgt.GLAccountCode = src.account_code,
				tgt.NatAmount = src.balance,
				tgt.CurrencyCode = src.nat_cur_code,
				tgt.VoucherNo = null,
				tgt.OriginalCost = src.nat_balance,
				tgt.AdjustmentDailyRate = null,
				tgt.AUDExchangeRate = src.AUDConversionRate,
				tgt.InvoiceID = src.document_2,
				tgt.BatchID = null,
				tgt.Company = src.CompanyName,
				tgt.MarginLevel = 0
	WHEN NOT MATCHED BY SOURCE AND tgt.GLJournalID IS NOT NULL
		THEN delete
	;
	ALTER INDEX [IDX_usrDTCFinancial_Date] ON [dbo].[usr_DTCFinancial] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
END
GO
