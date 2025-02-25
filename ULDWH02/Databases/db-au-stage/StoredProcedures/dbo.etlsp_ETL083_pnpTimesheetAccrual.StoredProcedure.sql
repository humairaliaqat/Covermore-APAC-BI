USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpTimesheetAccrual]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL083_pnpTimesheetAccrual] 
	@StartDate varchar(10), @EndDate varchar(10) 
as begin 
	/* Updates
- 20180222 - DM - Adjusted the script for the ServiceEventActivityID to be correctly calculated
- 20180227 - DM - Adjusted script to also bring in UserSK and nat_cur_code (natural currency code)
- 20180523 - DM - Adjusted script to reset the finance date if the accrual batch status has changed.
- 20190507 - DM - Adjusted script to bring in new column (Removed_By_Finance) and also changed how to adjust and only bring in new data.
- 20190612 - RS - Server name modified by Ratnesh on 20190612
*/

	declare @SQL varchar(max),
			@batches as Nvarchar(max)


	if @StartDate is null 
		set @StartDate = convert(varchar, dateadd(day, -7, getdate()), 126)

	if @EndDate is null 
		set @EndDate = convert(varchar, dateadd(day, 3, getdate()), 126) 

	if object_id('[db-au-dtc]..pnpTimesheetAccrual') is null 
	begin 
		set @StartDate = '2014-01-01'
		set @EndDate = convert(varchar, dateadd(day, 3, getdate()), 126) 

		create table [db-au-dtc]..pnpTimesheetAccrual (
            TimesheetAccrualSK int identity(1, 1),
			ServiceEventActivitySK int,
			ServiceEventActivityID varchar(50),
			BatchID int,
			trx_ctrl_num varchar(30),
			Source varchar(50),
			Type varchar(100),
			Account varchar(34),
			AccruedAmount money NULL,
			NoChargeFlag int,
			ExchangeRate decimal(18, 4),
			ExchangeDate date,
			ForPeriod int,
			GeneratedAt datetime,
			GeneratedBy varchar(50),
			Company varchar(10),
			IsFinal bit,
            index idx_pnpTimesheetAccrual_TimesheetAccrualSK unique clustered (TimesheetAccrualSK),
			index idx_pnpTimesheetAccrual_ServiceEventActivitySK nonclustered (ServiceEventActivitySK),
			index idx_pnpTimesheetAccrual_ServiceEventActivityID nonclustered (ServiceEventActivityID),
			index idx_pnpTimesheetAccrual_ForPeriod nonclustered (ForPeriod),
			index idx_pnpTimesheetAccrual_GeneratedAt nonclustered (GeneratedAt),
			index idx_pnpTimesheetAccrual_BatchID nonclustered (BatchID),
			index idx_pnpTimesheetAccrual_Company nonclustered (Company)
		)
	end


	if object_id('tempdb..##timesheetaccruals') is not null drop table ##timesheetaccruals 

	select @sql = '
		if object_id(''penelope_DM.dbo.tmp_dwhbatches'') is not null drop table penelope_DM.dbo.tmp_dwhbatches
		
		select batchid 
		into penelope_DM.dbo.tmp_dwhbatches
		from openquery(
		[ULDWH02.AUST.COVERMORE.COM.AU], ''select distinct batchid from [db-au-dtc].dbo.pnpTimesheetAccrual'')'
		--uldwh02 --commented and fully qualified servername added by Ratnesh on 20190612

	exec(@sql) at DTCSYD03CL1

	select @sql = '
	select *
	into ##timesheetaccruals
	from OpenQuery(DTCSYD03CL1, ''
		select 
			null ServiceEventActivitySK,
			CAST(null as varchar(50)) ServiceEventActivityID,
			a.batchid BatchID,
			a.trx_ctrl_num,
			a.Source,
			a.Type,
			a.Account,
			a.AccruedAmount,
			a.no_chargeflag NoChargeFlag,
			a.exchange_rate ExchangeRate,
			a.exchange_date ExchangeDate,
			g.ForPeriod,
			g.GeneratedAt,
			g.GeneratedBy,
			g.Company,
			g.IsFinal,
			IsNull(a.Removed_By_Finance,0) as Removed_By_Finance,
			a.Last_Modified_Date
		from 
			eFrontOfficeDW..timesheetsAccrued a 
		left join eFrontOfficeDW..timesheetGLaccruals g on g.batchid = a.batchid
		where not exists (select 1 from penelope_DM.dbo.tmp_dwhbatches x where g.batchid = x.batchid) 
	UNION
		select 
			null ServiceEventActivitySK,
			CAST(null as varchar(50)) ServiceEventActivityID,
			a.batchid BatchID,
			a.trx_ctrl_num,
			a.Source,
			a.Type,
			a.Account,
			a.AccruedAmount,
			a.no_chargeflag NoChargeFlag,
			a.exchange_rate ExchangeRate,
			a.exchange_date ExchangeDate,
			g.ForPeriod,
			g.GeneratedAt,
			g.GeneratedBy,
			g.Company,
			g.IsFinal,
			IsNull(a.Removed_By_Finance,0) as Removed_By_Finance,
			a.Last_Modified_Date
		from 
			eFrontOfficeDW..timesheetsAccrued a 
		left join eFrontOfficeDW..timesheetGLaccruals g on g.batchid = a.batchid
		where a.Last_Modified_Date between ''''' + @StartDate + ''''' AND ''''' + @EndDate + '''''
		'')
	'

	exec(@sql)

	update ##timesheetaccruals
	set ServiceEventActivityID = dbo.fn_DTCServiceEventActivityID(trx_ctrl_num)

	create nonclustered index idx_gtemp_timesheetaccrual_ServiceEventActivityID
	on ##timesheetaccruals ([ServiceEventActivityID])

	update t 
	set ServiceEventActivitySK = sea.ServiceEventActivitySK 
	--select t.serviceEventActivityID, T.ServiceEventActivitySK, sea.ServiceEventActivitySK
	from 
		##timesheetaccruals t 
		join [db-au-dtc]..pnpServiceEventActivity sea with (NOLOCK) on sea.ServiceEventActivityID = t.ServiceEventActivityID 

	merge [db-au-dtc]..pnpTimesheetAccrual tgt 
	using ##timesheetaccruals src 
		on src.ServiceEventActivityID = tgt.ServiceEventActivityID 
			and src.BatchID = tgt.BatchID 
			and src.trx_ctrl_num = tgt.trx_ctrl_num 
			and src.Account = tgt.Account 
			and src.GeneratedAt = tgt.GeneratedAt 
	when not matched by target then 
		insert (
			ServiceEventActivitySK,
			ServiceEventActivityID,
			BatchID,
			trx_ctrl_num,
			Source,
			Type,
			Account,
			AccruedAmount,
			NoChargeFlag,
			ExchangeRate,
			ExchangeDate,
			ForPeriod,
			GeneratedAt,
			GeneratedBy,
			Company,
			IsFinal,
			Removed_By_Finance
		) 
		values (
			src.ServiceEventActivitySK,
			src.ServiceEventActivityID,
			src.BatchID,
			src.trx_ctrl_num,
			src.Source,
			src.Type,
			src.Account,
			src.AccruedAmount,
			src.NoChargeFlag,
			src.ExchangeRate,
			src.ExchangeDate,
			src.ForPeriod,
			src.GeneratedAt,
			src.GeneratedBy,
			src.Company,
			src.IsFinal,
			src.Removed_By_Finance
		)
	when matched then update set 
		tgt.ServiceEventActivitySK = src.ServiceEventActivitySK,
		tgt.ServiceEventActivityID = src.ServiceEventActivityID,
		tgt.BatchID = src.BatchID,
		tgt.trx_ctrl_num = src.trx_ctrl_num,
		tgt.Source = src.Source,
		tgt.Type = src.Type,
		tgt.Account = src.Account,
		tgt.AccruedAmount = src.AccruedAmount,
		tgt.NoChargeFlag = src.NoChargeFlag,
		tgt.ExchangeRate = src.ExchangeRate,
		tgt.ExchangeDate = src.ExchangeDate,
		tgt.ForPeriod = src.ForPeriod,
		tgt.GeneratedAt = src.GeneratedAt,
		tgt.GeneratedBy = src.GeneratedBy,
		tgt.Company = src.Company,
		tgt.IsFinal = src.IsFinal,
		tgt.Removed_By_Finance = src.Removed_By_Finance
	;

	update t 
	set ServiceEventActivitySK = sea.ServiceEventActivitySK 
	from 
		[db-au-dtc]..pnpTimesheetAccrual t 
		join [db-au-dtc]..pnpServiceEventActivity sea with (NOLOCK) on sea.ServiceEventActivityID = t.ServiceEventActivityID 
	where t.ServiceEventActivitySK is null

	if object_id('tempdb..#DefaultCurrencies') is not null drop table #DefaultCurrencies 

	UPDATE t
	set InvoiceLineID = t.ServiceEventActivityID
	--select *
	from [db-au-dtc]..pnpTimesheetAccrual t
	where left(t.ServiceEventActivityID,3) = 'CLI'
	and t.InvoiceLineID is null
	
	UPDATE t
	set InvoiceLineID = G.ServiceEventActivityInvID
	from [db-au-dtc]..pnpTimesheetAccrual t
	join [db-au-stage].[dbo].[eFrontOfficeDW_timesheetGLdetailPenelope_audtc] G ON T.trx_ctrl_num = G.trx_ctrl_num
	where t.InvoiceLineID is null

	update t
	set InvoiceLineSK = L.InvoiceLineSK
	--select *
	from [db-au-dtc]..pnpTimesheetAccrual t
	join [db-au-dtc]..pnpInvoiceLine L ON t.InvoiceLineID = L.InvoiceLineID
	where T.InvoiceLineSK is null

	create table #DefaultCurrencies (
		resource_code varchar(20),
		default_currency varchar(10),
		company varchar(10)
	)

	set @SQL = 
	'INSERT into #DefaultCurrencies 
	select * 
	from openquery(DTCSYD03CL1, ''
		select 
			resource_code,
			default_currency,
			company
		from 
			eFrontOfficeDW..dtVendorDefaultCurrency a 
		''
	)'

	exec(@SQL) 

	UPDATE t
	SET UserSK = U.UserSK,
		DefaultCurrencyCode = coalesce(C.default_currency, C1.default_currency, C2.default_currency,'AUD')
	from [db-au-dtc].dbo.pnpTimesheetAccrual t
	cross apply (
			select REPLACE(REPLACE(value,'_SB',''), 'U','')as value
			from STRING_SPLIT(t.trx_ctrl_num,'-') 
			where RTRIM(value) like 'U%'
			and t.trx_ctrl_num like 'S%A%U%'
		) X
	JOIN [db-au-dtc].dbo.pnpUser U ON X.value = U.UserID AND U.IsCurrent = 1
	left JOIN #DefaultCurrencies C ON U.ClienteleResourceCode = C.resource_code
	left JOIN #DefaultCurrencies C1 ON U.UserID = C1.resource_code
	left JOIN #DefaultCurrencies C2 ON RIGHT('000000' + CAST(U.UserID as varchar), 6) = C2.resource_code
	where (t.userSK IS NULL OR T.DefaultCurrencyCode IS NULL)

	UPDATE t
	SET UserSK = U.UserSK,
		DefaultCurrencyCode = coalesce(C.default_currency, C1.default_currency, C2.default_currency,'AUD')
	from [db-au-dtc].dbo.pnpTimesheetAccrual t
	LEFT join [db-au-dtc].dbo.usrServiceEventActivityAllocated seaa ON t.ServiceEventActivitySK = seaa.ServiceEventActivitySK
	LEFT JOIN [db-au-dtc].dbo.pnpUser U ON seaa.AllocatedUser = U.UserSK
	left JOIN #DefaultCurrencies C ON U.ClienteleResourceCode = C.resource_code
	left JOIN #DefaultCurrencies C1 ON U.UserID = C1.resource_code
	left JOIN #DefaultCurrencies C2 ON RIGHT('000000' + CAST(U.UserID as varchar), 6) = C2.resource_code
	where (t.userSK IS NULL OR T.DefaultCurrencyCode IS NULL)

	create table #UpdatedBatches (
		batchID int
	)

	select * 
	INTO #BatchStatus
	from OpenQuery(DTCSYD03Cl1, 'select batchid, isfinal from eFrontOfficeDW..timesheetGLaccruals')

	UPDATE A
	SET isFinal = B.IsFinal
	output inserted.batchID into #UpdatedBatches
	from [db-au-dtc].dbo.pnpTimesheetAccrual A
	JOIN #BatchStatus B ON A.batchid = B.batchid
	where isNull(A.isFinal,0) <> isNull(B.IsFinal,0)

	--Reset Finance Date if the Timesheet Accrual batch status has changed.

	UPDATE L
	SET FinanceDate = null,
		FinMonthAC = null,
		FinYearAC = null,
		FinMonthACDate = null
	--select *
	from [db-au-dtc].dbo.pnpTimesheetAccrual A
	JOIN (select distinct batchID from #UpdatedBatches) B ON A.batchID = B.BatchID
	JOIN [db-au-dtc].dbo.pnpinvoiceLine L ON A.invoicelineSK = L.invoiceLineSK

end 
GO
