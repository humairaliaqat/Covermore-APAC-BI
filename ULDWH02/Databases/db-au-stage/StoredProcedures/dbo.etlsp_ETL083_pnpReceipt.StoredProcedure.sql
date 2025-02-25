USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpReceipt]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpReceipt
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpReceipt] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpReceipt') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpReceipt](
			ReceiptSK int identity(1,1) primary key,
			IndividualSK int,
			FunderSK int,
			SiteSK int,
			DepositSK int,
			ServiceSK int,
			ReceiptID int,
			[Type] nvarchar(10),
			IndividualID int,
			FunderID int,
			Name nvarchar(75),
			ChequeNumber nvarchar(15),
			Amount numeric(10,2),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreatedBy nvarchar(10),
			UpdatedBy nvarchar(10),
			ReceiptP nvarchar(60),
			ReceiptType nvarchar(10),
			ReceiptPIsCreditCardType varchar(5),
			DepositType nvarchar(50),
			ReasonGLCode nvarchar(10),
			FullyApplied varchar(5),
			FullyAppliedDate date,
			Lock varchar(5),
			SiteID int,
			DepositID int,
			ServiceID int,
			SiteRegion nvarchar(100),
			SiteRegionCode nvarchar(15),
			CreditCardTransactionID nvarchar(max),
			CreditCardPenRefNumber nvarchar(max),
			index idx_pnpReceipt_IndividualSK nonclustered (IndividualSK),
			index idx_pnpReceipt_FunderSK nonclustered (FunderSK),
			index idx_pnpReceipt_SiteSK nonclustered (SiteSK),
			index idx_pnpReceipt_DepositSK nonclustered (DepositSK),
			index idx_pnpReceipt_ServiceSK nonclustered (ServiceSK),
			index idx_pnpReceipt_ReceiptID nonclustered (ReceiptID),
			index idx_pnpReceipt_IndividualID nonclustered (IndividualID),
			index idx_pnpReceipt_FunderID nonclustered (FunderID),
			index idx_pnpReceipt_SiteID nonclustered (SiteID),
			index idx_pnpReceipt_DepositID nonclustered (DepositID),
			index idx_pnpReceipt_ServiceID nonclustered (ServiceID)
		)
	end;

	if object_id('[db-au-dtc].dbo.penelope_btreceipts_audtc') is null
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
			i.IndividualSK,
			f.FunderSK,
			s.SiteSK,
			d.DepositSK,
			sv.ServiceSK,
			r.kreceiptid as ReceiptID,
			rt.receipttype as [Type],
			r.kindid as IndividualID,
			r.kfunderid as FunderID,
			r.recname as Name,
			r.recchequeno as ChequeNumber,
			r.recamount as Amount,
			r.slogin as CreatedDatetime,
			r.slogmod as UpdatedDatetime,
			r.sloginby as CreatedBy,
			r.slogmodby as UpdatedBy,
			lur.recp as ReceiptP,
			srt.receipttype as ReceiptType,
			lur.iscctype as ReceiptPIsCreditCardType,
			sdt.deposittype as DepositType,
			lur.reasonglcode as ReasonGLCode,
			r.fullyapplied as FullyApplied,
			r.fullyapplieddate as FullyAppliedDate,
			r.reclock as Lock,
			r.ksiteid as SiteID,
			r.kdepositid as DepositID,
			r.kagserid as ServiceID,
			lusr.siteregion as SiteRegion,
			lusr.siteregionglcode as SiteRegionCode,
			r.cctransid as CreditCardTransactionID,
			r.ccpenrefno as CreditCardPenRefNumber
		into #src
		from 
			penelope_btreceipts_audtc r 
			left join penelope_ssreceipttype_audtc rt on rt.kreceipttypeid = r.kreceipttypeid
			left join penelope_lurecp_audtc lur on lur.lurecpid = r.lurecpid
			left join penelope_ssreceipttype_audtc srt on srt.kreceipttypeid = lur.kreceipttypeid
			left join penelope_sadeposittype_audtc sdt on sdt.kdeposittypeid = lur.kdeposittypeid
			left join penelope_lusiteregion_audtc lusr on lusr.lusiteregionid = r.lusiteregionid
			outer apply (
				select top 1 IndividualSK
				from [db-au-dtc].dbo.pnpIndividual
				where IndividualID = r.kindid
					and IsCurrent = 1
			) i
			outer apply (
				select top 1 FunderSK
				from [db-au-dtc].dbo.pnpFunder
				where FunderID = r.kfunderid and IsCurrent = 1
			) f
			outer apply (
				select top 1 SiteSK
				from [db-au-dtc].dbo.pnpSite
				where SiteID = r.ksiteid
			) s
			outer apply (
				select top 1 DepositSK
				from [db-au-dtc].dbo.pnpDeposit
				where DepositID = r.kdepositid
			) d
			outer apply (
				select top 1 ServiceSK
				from [db-au-dtc].dbo.pnpService
				where ServiceID = r.kagserid
			) sv
		
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpReceipt as tgt
		using #src
			on #src.ReceiptID = tgt.ReceiptID
		when matched then 
			update set 
				tgt.IndividualSK = #src.IndividualSK,
				tgt.FunderSK = #src.FunderSK,
				tgt.SiteSK = #src.SiteSK,
				tgt.DepositSK = #src.DepositSK,
				tgt.ServiceSK = #src.ServiceSK,
				tgt.[Type] = #src.[Type],
				tgt.IndividualID = #src.IndividualID,
				tgt.FunderID = #src.FunderID,
				tgt.Name = #src.Name,
				tgt.ChequeNumber = #src.ChequeNumber,
				tgt.Amount = #src.Amount,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.ReceiptP = #src.ReceiptP,
				tgt.ReceiptType = #src.ReceiptType,
				tgt.ReceiptPIsCreditCardType = #src.ReceiptPIsCreditCardType,
				tgt.DepositType = #src.DepositType,
				tgt.ReasonGLCode = #src.ReasonGLCode,
				tgt.FullyApplied = #src.FullyApplied,
				tgt.FullyAppliedDate = #src.FullyAppliedDate,
				tgt.Lock = #src.Lock,
				tgt.SiteID = #src.SiteID,
				tgt.DepositID = #src.DepositID,
				tgt.ServiceID = #src.ServiceID,
				tgt.SiteRegion = #src.SiteRegion,
				tgt.SiteRegionCode = #src.SiteRegionCode,
				tgt.CreditCardTransactionID = #src.CreditCardTransactionID,
				tgt.CreditCardPenRefNumber = #src.CreditCardPenRefNumber
		when not matched by target then 
			insert (
				IndividualSK,
				FunderSK,
				SiteSK,
				DepositSK,
				ServiceSK,
				ReceiptID,
				[Type],
				IndividualID,
				FunderID,
				Name,
				ChequeNumber,
				Amount,
				CreatedDatetime,
				UpdatedDatetime,
				CreatedBy,
				UpdatedBy,
				ReceiptP,
				ReceiptType,
				ReceiptPIsCreditCardType,
				DepositType,
				ReasonGLCode,
				FullyApplied,
				FullyAppliedDate,
				Lock,
				SiteID,
				DepositID,
				ServiceID,
				SiteRegion,
				SiteRegionCode,
				CreditCardTransactionID,
				CreditCardPenRefNumber
			)
			values (
				#src.IndividualSK,
				#src.FunderSK,
				#src.SiteSK,
				#src.DepositSK,
				#src.ServiceSK,
				#src.ReceiptID,
				#src.[Type],
				#src.IndividualID,
				#src.FunderID,
				#src.Name,
				#src.ChequeNumber,
				#src.Amount,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.ReceiptP,
				#src.ReceiptType,
				#src.ReceiptPIsCreditCardType,
				#src.DepositType,
				#src.ReasonGLCode,
				#src.FullyApplied,
				#src.FullyAppliedDate,
				#src.Lock,
				#src.SiteID,
				#src.DepositID,
				#src.ServiceID,
				#src.SiteRegion,
				#src.SiteRegionCode,
				#src.CreditCardTransactionID,
				#src.CreditCardPenRefNumber
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
