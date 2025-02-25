USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpEpicorInvoice]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL083_pnpEpicorInvoice]
as


SET NOCOUNT ON


--20190613 - LT - Created. Based on code from LL


if object_id('[db-au-stage].dbo.etl_ETL083_pnpEpicorInvoice') is not null drop table [db-au-stage].dbo.etl_ETL083_pnpEpicorInvoice

create table [db-au-stage].dbo.etl_ETL083_pnpEpicorInvoice
(
	Company varchar(8) null,
	JournalCtrlNum varchar(16) null,
	DateApplied int null,
	ApplyDate datetime null,
	InvoiceNumber varchar(16) null,
	RCTINumber varchar(50) null,
	VoucherNumber varchar(50) null,
	PreTax float null,
	AmtTaxInc float null,
	Currency varchar(8) null,
	TrxTypeDesc varchar(100) null,
	InvoiceSK int null
)


insert dbo.etl_ETL083_pnpEpicorInvoice
(
	Company,
	JournalCtrlNum,
	DateApplied,
	ApplyDate,
	InvoiceNumber,
	RCTINumber,
	VoucherNumber,
	PreTax,
	AmtTaxInc,
	Currency,
	TrxTypeDesc,
	InvoiceSK
)
select
	Company,
	JournalCtrlNum,
	DateApplied,
	ApplyDate,
	InvoiceNumber,
	RCTINumber,
	VoucherNumber,
	PreTax,
	AmtTaxInc,
	Currency,
	TrxTypeDesc,
	InvoiceSK
from
	openquery([SAEAPSYD03VDB01],
	'
		select 
			''DTNSW'' as Company,
			g.journal_ctrl_num as JournalCtrlNum,
			g.date_applied as DateApplied,
			null as ApplyDate,
			a.Doc_ctrl_num as InvoiceNumber,
			null as RCTINumber,
			null as VoucherNumber,
			a.Amt_Gross as PreTax,
			a.Amt_net as AmtTaxInc,
			a.nat_cur_code as Currency,
			at.trx_type_desc as TrxTypeDesc,
			null as InvoiceSK
		from
			DTNSW.dbo.artrx a
			inner join DTNSW.dbo.gltrx g on a.gl_trx_id = g.journal_ctrl_num
			inner join DTNSW.dbo.artrxtyp at ON a.trx_type = at.trx_type
		where
			at.trx_type_desc in (''Invoice'',''Credit memo'')

		union all

		select 
			''DTSING'' as Company,
			g.journal_ctrl_num as JournalCtrlNum,
			g.date_applied as DateApplied,
			null as ApplyDate,
			a.Doc_ctrl_num as InvoiceNumber,
			null as RCTINumber,
			null as VoucherNumber,
			a.Amt_Gross as PreTax,
			a.Amt_net as AmtTaxInc,
			a.nat_cur_code as Currency,
			at.trx_type_desc as TrxTypeDesc,
			null as InvoiceSK
		from
			DTSING.dbo.artrx a
			inner join DTSING.dbo.gltrx g on a.gl_trx_id = g.journal_ctrl_num
			inner join DTSING.dbo.artrxtyp at ON a.trx_type = at.trx_type
		where
			at.trx_type_desc in (''Invoice'',''Credit memo'')

		union all

		select 
			''DTPRIME'' as Company,
			g.journal_ctrl_num as JournalCtrlNum,
			g.date_applied as DateApplied,
			null as ApplyDate,
			a.Doc_ctrl_num as InvoiceNumber,
			null as RCTINumber,
			null as VoucherNumber,
			a.Amt_Gross as PreTax,
			a.Amt_net as AmtTaxInc,
			a.nat_cur_code as Currency,
			at.trx_type_desc as TrxTypeDesc,
			null as InvoiceSK
		from
			DTPRIME.dbo.artrx a
			inner join DTPRIME.dbo.gltrx g on a.gl_trx_id = g.journal_ctrl_num
			inner join DTPRIME.dbo.artrxtyp at ON a.trx_type = at.trx_type
		where
			at.trx_type_desc in (''Invoice'',''Credit memo'')

		union all

		select 
			''DTSPRING'' as Company,
			g.journal_ctrl_num as JournalCtrlNum,
			g.date_applied as DateApplied,
			null as ApplyDate,
			a.Doc_ctrl_num as InvoiceNumber,
			null as RCTINumber,
			null as VoucherNumber,
			a.Amt_Gross as PreTax,
			a.Amt_net as AmtTaxInc,
			a.nat_cur_code as Currency,
			at.trx_type_desc as TrxTypeDesc,
			null as InvoiceSK
		from
			DTSPRING.dbo.artrx a
			inner join DTSPRING.dbo.gltrx g on a.gl_trx_id = g.journal_ctrl_num
			inner join DTSPRING.dbo.artrxtyp at ON a.trx_type = at.trx_type
		where
			at.trx_type_desc in (''Invoice'',''Credit memo'')

		union all

		select
			''DTNSW'' as Company,
			g.journal_ctrl_num as JournalCtrlNum,
			g.date_applied as DateApplied,
			null as ApplyDate,
			null as InvoiceNumber,
			doc_ctrl_num as RCTINumber,
			trx_ctrl_num as VoucherNumber,
			h.amt_gross as PreTax,
			h.amt_net as AmtTaxInc,
			h.currency_code as Currency,
			ut.[Description] as TrxTypeDesc,
			null as InvoiceSK
		from 
			DTNSW.dbo.apvohdr H
			inner join DTNSW.dbo.gltrx G ON H.journal_ctrl_num = G.journal_ctrl_num
			inner join DTNSW.dbo.apusrtyp UT ON H.[user_trx_type_code] = UT.[user_trx_type_code]
		where
			UT.[user_trx_type_code] IN (''CVI'',''RCI'',''RCTI'')

		union all

		select
			''DTSING'' as Company,
			g.journal_ctrl_num as JournalCtrlNum,
			g.date_applied as DateApplied,
			null as ApplyDate,
			null as InvoiceNumber,
			doc_ctrl_num as RCTINumber,
			trx_ctrl_num as VoucherNumber,
			h.amt_gross as PreTax,
			h.amt_net as AmtTaxInc,
			h.currency_code as Currency,
			ut.[Description] as TrxTypeDesc,
			null as InvoiceSK
		from 
			DTSING.dbo.apvohdr H
			inner join DTSING.dbo.gltrx G ON H.journal_ctrl_num = G.journal_ctrl_num
			inner join DTSING.dbo.apusrtyp UT ON H.[user_trx_type_code] = UT.[user_trx_type_code]
		where
			UT.[user_trx_type_code] IN (''CVI'',''RCI'',''RCTI'')

		union all

			select
			''DTPRIME'' as Company,
			g.journal_ctrl_num as JournalCtrlNum,
			g.date_applied as DateApplied,
			null as ApplyDate,
			null as InvoiceNumber,
			doc_ctrl_num as RCTINumber,
			trx_ctrl_num as VoucherNumber,
			h.amt_gross as PreTax,
			h.amt_net as AmtTaxInc,
			h.currency_code as Currency,
			ut.[Description] as TrxTypeDesc,
			null as InvoiceSK
		from 
			DTPRIME.dbo.apvohdr H
			inner join DTPRIME.dbo.gltrx G ON H.journal_ctrl_num = G.journal_ctrl_num
			inner join DTPRIME.dbo.apusrtyp UT ON H.[user_trx_type_code] = UT.[user_trx_type_code]
		where
			UT.[user_trx_type_code] IN (''CVI'',''RCI'',''RCTI'')

		union all

		select
			''DTSPRING'' as Company,
			g.journal_ctrl_num as JournalCtrlNum,
			g.date_applied as DateApplied,
			null as ApplyDate,
			null as InvoiceNumber,
			doc_ctrl_num as RCTINumber,
			trx_ctrl_num as VoucherNumber,
			h.amt_gross as PreTax,
			h.amt_net as AmtTaxInc,
			h.currency_code as Currency,
			ut.[Description] as TrxTypeDesc,
			null as InvoiceSK
		from 
			DTSPRING.dbo.apvohdr H
			inner join DTSPRING.dbo.gltrx G ON H.journal_ctrl_num = G.journal_ctrl_num
			inner join DTSPRING.dbo.apusrtyp UT ON H.[user_trx_type_code] = UT.[user_trx_type_code]
		where
			UT.[user_trx_type_code] IN (''CVI'',''RCI'',''RCTI'')
	') a



--convert Epicor int date to datetime
update [db-au-stage].dbo.etl_ETL083_pnpEpicorInvoice
set
	ApplyDate = [db-au-dtc].dbo.fnEpicorToSQLdate(DateApplied)

--update InvoiceSK
update g
set InvoiceSK = i.InvoiceSK
from 
	[db-au-stage].dbo.etl_ETL083_pnpEpicorInvoice g
	inner join [db-au-dtc].dbo.pnpInvoice i on g.InvoiceNumber = [db-au-dtc].dbo.fnGetEpicorInvoiceNumber(i.InvoiceID, i.InvoiceNumber, i.Amount)


merge into [db-au-dtc].dbo.epicorGLAppliedDate as tgt
using [db-au-stage].dbo.etl_etl083_pnpEpicorInvoice as src on
	tgt.company = src.company and
	tgt.journal_ctrl_num = src.JournalCtrlNum and
	isNull(tgt.invoiceNumber,'') = isNull(src.invoiceNumber,'') and
	isNull(tgt.VoucherNumber,'') = isNull(src.VoucherNumber,'')

when matched then
	update
		set apply_date = src.ApplyDate,
			preTax = src.preTax,
			amtTaxInc = src.amtTaxInc,
			Currency = src.Currency,
			invoiceSk = src.InvoiceSK,
			TransType = src.TrxTypeDesc

when not matched then
	insert
	(
		Company,
		journal_ctrl_num, 
		apply_date, 
		InvoiceNumber, 
		RCTINumber, 
		VoucherNumber, 
		preTax, 
		AmtTaxinc, 
		Currency, 
		InvoiceSK,
		TransType
	)
	values
	(
		src.Company, 
		src.JournalCtrlNum, 
		src.ApplyDate, 
		src.InvoiceNumber, 
		src.RCTINumber, 
		src.VoucherNumber, 
		src.preTax, 
		src.AmtTaxinc, 
		src.Currency, 
		src.InvoiceSK, 
		src.TrxTypeDesc
	)

when not matched by source then
	delete output $action, inserted.*, deleted.*;

GO
