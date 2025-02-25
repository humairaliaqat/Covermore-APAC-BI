USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_FinanceDate]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[etlsp_ETL083_FinanceDate] as
BEGIN
	TRUNCATE TABLE [db-au-dtc].dbo.usrBankofHourDetail

	INSERT INTO [db-au-dtc].dbo.usrBankofHourDetail (GLApplyDate, ServiceEventActivityID, InvoiceLineID, ItemDeletedDate, ServiceEventActivitySK, InvoiceLineSK, [Sign], BankHours, Amount, Billable_Qty, RateID)
	select	GLApplyDate, 
			CASE WHEN BH.ServiceEventActivityID IS NULL then [dbo].[fn_DTCServiceEventActivityID](BH.trx_ctrl_num) ELSE CAST(BH.ServiceEventActivityID as varchar(50)) END, 
			CASE WHEN BH.ServiceEventActivityInvID IS NULL then [dbo].[fn_DTCServiceEventActivityID](BH.trx_ctrl_num) ELSE CAST(BH.ServiceEventActivityInvID as varchar(50)) END,
			ItemDeleted,
			sea.ServiceEventActivitySK,
			Il.InvoiceLineSK,
			BH.[Sign], 
			BH.BankHours, 
			BH.Amount, 
			BH.Billable_Qty,
			Bh.RateID
	from [db-au-stage].dbo.eFrontOfficeDW_vwBankOfHours_audtc BH
	left join [db-au-dtc].dbo.pnpServiceEventActivity sea ON CASE WHEN BH.ServiceEventActivityID IS NULL then [dbo].[fn_DTCServiceEventActivityID](BH.trx_ctrl_num) ELSE CAST(BH.ServiceEventActivityID as varchar(50)) END = sea.ServiceEventActivityID
	left join [db-au-dtc].dbo.pnpInvoiceLine IL ON CASE WHEN BH.ServiceEventActivityInvID IS NULL then [dbo].[fn_DTCServiceEventActivityID](BH.trx_ctrl_num) ELSE CAST(BH.ServiceEventActivityInvID as varchar(50)) END = IL.InvoiceLineID

	select *
	into #src
	from [db-au-stage].[dbo].[eFrontOfficeDW_vwBankOfHoursMatrix_audtc]

	Merge into [db-au-dtc].dbo.usrBOHRateMatrix as tgt
	using #src as src
	on tgt.RateID = src.RateID
	when matched THEN 
		update
			SET Customer = src.Customer,
				Service = src.Service,
				Country = src.Country,
				RateName = src.RateName,
				Method = src.Method,
				Rate = src.Rate,
				RateExtra = src.RateExtra,
				equivalentEAPHours = src.equivalentEAPHours,
				ReportingDisplayService = src.ReportingDisplayService,
				ReportOrdering = src.ReportOrdering
	WHEN NOT MATCHED THEN 
		INSERT ([RateID],[Customer],[Service],[Country],[RateName],[Method],[Rate],[RateExtra],[equivalentEAPHours],[ReportingDisplayService],[ReportOrdering])
		values (src.[RateID],src.[Customer],src.[Service],src.[Country],src.[RateName],src.[Method],src.[Rate],src.[RateExtra],src.[equivalentEAPHours],src.[ReportingDisplayService],src.[ReportOrdering])
	;

	update sea 
	set 
		FinanceDate = fd.FinanceDate,
		FinMonthAC = fm.FinMonthAC,
		FinYearAC = fm.FinYearAC,
		FinMonthACDate = convert(date, fm.FinMonthAC + '01') 
	from
		[db-au-dtc]..pnpServiceEventActivity sea with(nolock)
		inner join [db-au-dtc]..pnpServiceEvent se with(nolock) on
			se.ServiceEventSK = sea.ServiceEventSK
		inner join [db-au-dtc]..pnpItem it with(nolock) on
			it.ItemSK = sea.ItemSK
		outer apply
		(
			select 
				--i.InvoiceID,
				min(i.InvoiceDate) InvoiceDate
				--,
				--i.InvoiceFullAppliedDate,
				--il.NonChargeable
			from
				[db-au-dtc]..pnpInvoiceLine il 
				inner join [db-au-dtc]..pnpInvoice i on
					i.InvoiceSK = il.InvoiceSK
			where
				il.ServiceEventActivitySK = sea.ServiceEventActivitySK and
				il.DeletedDatetime is null and
				i.InvoicePosted = 1
		) i
		outer apply
		(
			select 
				min(ri.InvoiceDate) RCTIDate
			from
				[db-au-dtc]..pnpRCTI ri with(nolock)
			where
				ri.ServiceEventActivitySK = sea.ServiceEventActivitySK
				--ri.TimesheetControlID = replace(sea.ServiceEventActivityID, 'CLI_TSH_', '') or
				--ri.TimesheetControlID = 'S' + se.ServiceEventID + '-A' + sea.ServiceEventActivityID + '-U' + se.PrimaryWorkerUserID
		) ri    
		--DM - Accural Dates using old data
		outer apply
		(
			select 
				min(convert(date, convert(varchar, ta.ForPeriod) + '01')) AccrualDate
				--min(a.AccrualDate) as AccrualDate
			from 
				[db-au-dtc]..pnpTimesheetAccrual ta with(nolock)
			 --   cross apply 
	   --         (
			 --       select 
	   --                 max(d.[date]) AccrualDate
				--    from
				--	    [db-au-cmdwh]..Calendar d
				--	    left join usrFinancePeriod p on 
				--		    d.[Date] between p.StartPeriod and p.EndPeriod
				--	    left join [db-au-cmdwh]..Calendar rd on
				--		    rd.[Date] = p.FinancePeriod
				--	where 
                    
	   --                 ta.forperiod = replace(convert(varchar(7), isnull(rd.CurMonthStart, d.CurMonthStart), 120), '-', '')
				--) a
			where 
				isfinal = 1 and 
				ta.ServiceEventActivitySK = sea.ServiceEventActivitySK
		) ta
		outer apply
		--MOD: 20180327 Adjusted to recognise the BoH date from previous system
		(
			select MIN(GLApplyDate) as BoHAppliedDate
			from [db-au-dtc].dbo.usrBankofHourDetail A
			where A.ServiceEventActivityID = sea.ServiceEventActivityID
		) BoH --Bank of hours applied Dates
		outer apply
		(
			select 
				min(id.InvoiceDate) FirstInvoiceDate
			from
				(
					select i.InvoiceDate
					union
					select ri.RCTIDate
					union 
					select ta.AccrualDate
				) id
		) fid
		outer apply
		(
			select
				case
					--MOD: 20180327 Adjusted to recognise the BoH date from previous system
					WHEN BoH.BoHAppliedDate is not null then BoH.BoHAppliedDate
					when fid.FirstInvoiceDate is null and getdate() >= dateadd(month, 1, convert(date, convert(varchar(8), StartDatetime, 120) + '01')) then dateadd(day, -1, dateadd(month, 1, convert(date, convert(varchar(8), StartDatetime, 120) + '01')))
					--when fid.FirstInvoiceDate >= dateadd(month, 1, convert(date, convert(varchar(8), StartDatetime, 120) + '01')) then dateadd(day, -1, dateadd(month, 1, convert(date, convert(varchar(8), StartDatetime, 120) + '01')))
					else fid.FirstInvoiceDate
				end FinanceDate
		) fd
		outer apply
		(
			select 
				replace(convert(varchar(7), isnull(rd.CurMonthStart, d.CurMonthStart), 120), '-', '') FinMonthAC,
				convert(varchar(4), isnull(rd.CurFiscalYearStart, d.CurFiscalYearStart), 120) FinYearAC
			from
				[db-au-cmdwh]..Calendar d
				left join [db-au-dtc]..usrFinancePeriod p on 
					d.[Date] between p.StartPeriod and p.EndPeriod
				left join [db-au-cmdwh]..Calendar rd on
					rd.[Date] = p.FinancePeriod
			where
				d.[Date] = convert(date, fd.FinanceDate)
		) fm
    where
        sea.FinanceDate is null

	update il 
	set 
		FinanceDate = fd.FinanceDate,
		FinMonthAC = fm.FinMonthAC,
		FinYearAC = fm.FinYearAC,
		FinMonthACDate = convert(date, fm.FinMonthAC + '01') 
	--select il.invoicelineid, fd.financedate
	from
		[db-au-dtc]..pnpInvoiceLine il with(nolock)
		inner join [db-au-dtc]..pnpServiceEventActivity sea with(nolock) on il.ServiceEventActivitySK = sea.ServiceEventActivitySK
		inner join [db-au-dtc]..pnpServiceEvent se with(nolock) on se.ServiceEventSK = sea.ServiceEventSK
		inner join [db-au-dtc]..pnpItem it with(nolock) on it.ItemSK = sea.ItemSK
		outer apply
		(
			select 
				min(i.InvoiceDate) InvoiceDate
			from
				[db-au-dtc]..pnpInvoice i 
			where
				il.InvoiceSK = i.InvoiceSK and
				i.InvoicePosted = 1
		) i
		outer apply
		(
			select 
				min(ri.InvoiceDate) RCTIDate
			from
				[db-au-dtc]..pnpRCTI ri with(nolock)
			where
				ri.ServiceEventActivitySK = sea.ServiceEventActivitySK
		) ri    
		--DM - Accural Dates using old data
		outer apply
		(
			select 
				--min(convert(datetime, convert(varchar, ta.ForPeriod) + '01')) AccrualDate
				cast(convert(varchar, ta.ForPeriod) + '01' as date) AccrualDate
				--min(a.AccrualDate) as AccrualDate
			from 
				[db-au-dtc]..pnpTimesheetAccrual ta with(nolock)
			where 
				isfinal = 1 and 
				ta.InvoiceLineSK = il.InvoiceLineSK
		) ta
		outer apply
		--MOD: 20180327 Adjusted to recognise the BoH date from previous system
		(
			select MIN(GLApplyDate) as BoHAppliedDate
			from [db-au-dtc].dbo.usrBankofHourDetail A
			where A.InvoiceLineSK = il.InvoiceLineSK
		) BoH --Bank of hours applied Dates
		outer apply
		(
			select 
				min(id.InvoiceDate) FirstInvoiceDate
			from
				(
					select i.InvoiceDate
					union
					select ri.RCTIDate
					union 
					select ta.AccrualDate
				) id
		) fid
		outer apply
		(
			select
				case
					--MOD: 20180327 Adjusted to recognise the BoH date from previous system
					WHEN BoH.BoHAppliedDate is not null then BoH.BoHAppliedDate
					--when fid.FirstInvoiceDate is null and getdate() >= dateadd(month, 1, convert(date, convert(varchar(8), StartDatetime, 120) + '01')) then dateadd(day, -1, dateadd(month, 1, convert(date, convert(varchar(8), StartDatetime, 120) + '01')))
					--when fid.FirstInvoiceDate >= dateadd(month, 1, convert(date, convert(varchar(8), StartDatetime, 120) + '01')) then dateadd(day, -1, dateadd(month, 1, convert(date, convert(varchar(8), StartDatetime, 120) + '01')))
					else fid.FirstInvoiceDate
				end FinanceDate
		) fd
		outer apply
		(
			select 
				replace(convert(varchar(7), isnull(rd.CurMonthStart, d.CurMonthStart), 120), '-', '') FinMonthAC,
				convert(varchar(4), isnull(rd.CurFiscalYearStart, d.CurFiscalYearStart), 120) FinYearAC
			from
				[db-au-cmdwh]..Calendar d
				left join [db-au-dtc]..usrFinancePeriod p on 
					d.[Date] between p.StartPeriod and p.EndPeriod
				left join [db-au-cmdwh]..Calendar rd on
					rd.[Date] = p.FinancePeriod
			where
				d.[Date] = convert(date, fd.FinanceDate)
		) fm
    where
        il.financeDate is null
END

GO
