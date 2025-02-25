USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpInvoiceDebitReceipt]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpInvoiceDebitReceipt
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpInvoiceDebitReceipt] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpInvoiceDebitReceipt') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpInvoiceDebitReceipt](
			InvoiceDebitReceiptSK int identity(1,1) primary key,
			ReceiptSK int,
			InvoiceLineSK int,
			DebitSK int,
			InvoiceDebitReceiptID int,
			ReceiptID int,
			InvoiceLineID int,
			Amount numeric(10,2),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			DebitID int,
			keoblnid int,
			index idx_pnpInvoiceDebitReceipt_ReceiptSK nonclustered (ReceiptSK),
			index idx_pnpInvoiceDebitReceipt_InvoiceLineSK nonclustered (InvoiceLineSK),
			index idx_pnpInvoiceDebitReceipt_DebitSK nonclustered (DebitSK)
		)
	end;

	if object_id('[db-au-stage].dbo.penelope_abbappline_audtc') is null
		goto Finish

	declare
		@batchid int,
		@start date,
		@end date,
		@name varchar(100),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Penelope',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			r.ReceiptSK,
			il.InvoiceLineSK,
			d.DebitSK,
			idr.kapplineid as InvoiceDebitReceiptID,
			idr.kreceiptid as ReceiptID,
			idr.kinvlineid as InvoiceLineID,
			idr.amount as Amount,
			idr.slogin as CreatedDatetime,
			idr.slogmod as UpdatedDatetime,
			idr.kdebitid as DebitID,
			idr.keoblnid as keoblnid
		into #src
		from 
			penelope_abbappline_audtc idr
			outer apply (
				select top 1 ReceiptSK
				from [db-au-dtc].dbo.pnpReceipt
				where ReceiptID = idr.kreceiptid
			) r
			outer apply (
				select top 1 InvoiceLineSK
				from [db-au-dtc].dbo.pnpInvoiceLine
				where InvoiceLineID = idr.kinvlineid
			) il
			outer apply (
				select top 1 DebitSK
				from [db-au-dtc].dbo.pnpDebit
				where DebitID = idr.kdebitid
			) d
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpInvoiceDebitReceipt as tgt
		using #src
			on #src.InvoiceDebitReceiptID = tgt.InvoiceDebitReceiptID
		when matched then 
			update set 
				tgt.ReceiptSK = #src.ReceiptSK,
				tgt.InvoiceLineSK = #src.InvoiceLineSK,
				tgt.DebitSK = #src.DebitSK,
				tgt.ReceiptID = #src.ReceiptID,
				tgt.InvoiceLineID = #src.InvoiceLineID,
				tgt.Amount = #src.Amount,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.DebitID = #src.DebitID,
				tgt.keoblnid = #src.keoblnid
		when not matched by target then 
			insert (
				ReceiptSK,
				InvoiceLineSK,
				DebitSK,
				InvoiceDebitReceiptID,
				ReceiptID,
				InvoiceLineID,
				Amount,
				CreatedDatetime,
				UpdatedDatetime,
				DebitID,
				keoblnid
			)
			values (
				#src.ReceiptSK,
				#src.InvoiceLineSK,
				#src.DebitSK,
				#src.InvoiceDebitReceiptID,
				#src.ReceiptID,
				#src.InvoiceLineID,
				#src.Amount,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.DebitID,
				#src.keoblnid
			)

		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

	end try

	begin catch

		if @@trancount > 0
			rollback transaction

		exec syssp_genericerrorhandler
			@SourceInfo = 'data refresh failed',
			@LogToTable = 1,
			@ErrorCode = '-100',
			@BatchID = @batchid,
			@PackageID = @name

	end catch

	if @@trancount > 0
		commit transaction

Finish:
END

GO
