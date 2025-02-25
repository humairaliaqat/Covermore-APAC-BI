USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpDebit]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpDebit
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpDebit] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpDebit') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpDebit](
			DebitSK int identity(1,1) primary key,
			IndividualSK int,
			FunderSK int,
			SiteSK int,
			ServiceSK int,
			DebitID int,
			IndividualID int,
			FunderID int,
			[Description] nvarchar(75),
			RefNumber nvarchar(15),
			Amount numeric(10,2),
			DebitReason nvarchar(60),
			DebitGLCode nvarchar(10),
			Paid varchar(5),
			PartPaid varchar(5),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreatedBy nvarchar(10),
			UpdatedBy nvarchar(10),
			SiteID int,
			FullyAppliedDate date,
			ServiceID int,
			Region nvarchar(100),
			RegionCode nvarchar(15),
			TaxAmount numeric(10,2),
			SubAmount numeric(10,2),
			CreditCardRefundTransactionID nvarchar(max),
			index idx_pnpDebit_IndividualSK nonclustered (IndividualSK),
			index idx_pnpDebit_FunderSK nonclustered (FunderSK),
			index idx_pnpDebit_SiteSK nonclustered (SiteSK),
			index idx_pnpDebit_ServiceSK nonclustered (ServiceSK),
			index idx_pnpDebit_DebitID nonclustered (DebitID),
			index idx_pnpDebit_FunderID nonclustered (FunderID),
			index idx_pnpDebit_SiteID nonclustered (SiteID),
			index idx_pnpDebit_ServiceID nonclustered (ServiceID)
	)
	end;

	if object_id('[db-au-stage].dbo.penelope_btdebit_audtc') is null
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
			sv.ServiceSK,
			d.kdebitid as DebitID,
			d.kindid as IndividualID,
			d.kfunderid as FunderID,
			d.debitdesc as [Description],
			d.debitrefno as RefNumber,
			d.debitamount as Amount,
			dr.debitreason as DebitReason,
			dr.debitreason as DebitGLCode,
			d.debitpaid as Paid,
			d.debitpartpaid as PartPaid,
			d.slogin as CreatedDatetime,
			d.slogmod as UpdatedDatetime,
			d.sloginby as CreatedBy,
			d.slogmodby as UpdatedBy,
			d.ksiteid as SiteID,
			d.fullyapplieddate as FullyAppliedDate,
			d.kagserid as ServiceID,
			sr.siteregion as Region,
			sr.siteregionglcode as RegionCode,
			d.debittaxamt as TaxAmount,
			d.debitsubamt as SubAmount,
			d.ccrefundtransid as CreditCardRefundTransactionID
		into #src
		from 
			penelope_btdebit_audtc d 
			left join penelope_ludebitreason_audtc dr on dr.ludebitreasonid = d.ludebitreasonid
			left join penelope_lusiteregion_audtc sr on sr.lusiteregionid = d.lusiteregionid
			outer apply (
				select top 1 IndividualSK
				from [db-au-dtc].dbo.pnpIndividual
				where IndividualID = d.kindid
					and IsCurrent = 1
			) i
			outer apply (
				select top 1 FunderSK
				from [db-au-dtc].dbo.pnpFunder
				where FunderID = d.kfunderid and IsCurrent = 1
			) f
			outer apply (
				select top 1 SiteSK
				from [db-au-dtc].dbo.pnpSite
				where SiteID = d.ksiteid
			) s
			outer apply (
				select top 1 ServiceSK
				from [db-au-dtc].dbo.pnpService
				where ServiceID = d.kagserid
			) sv
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpDebit as tgt
		using #src
			on #src.DebitID = tgt.DebitID
		when matched then 
			update set 
				tgt.IndividualSK = #src.IndividualSK,
				tgt.FunderSK = #src.FunderSK,
				tgt.SiteSK = #src.SiteSK,
				tgt.ServiceSK = #src.ServiceSK,				
				tgt.IndividualID = #src.IndividualID,
				tgt.FunderID = #src.FunderID,
				tgt.[Description] = #src.[Description],
				tgt.RefNumber = #src.RefNumber,
				tgt.Amount = #src.Amount,
				tgt.DebitReason = #src.DebitReason,
				tgt.DebitGLCode = #src.DebitGLCode,
				tgt.Paid = #src.Paid,
				tgt.PartPaid = #src.PartPaid,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.SiteID = #src.SiteID,
				tgt.FullyAppliedDate = #src.FullyAppliedDate,
				tgt.ServiceID = #src.ServiceID,
				tgt.Region = #src.Region,
				tgt.RegionCode = #src.RegionCode,
				tgt.TaxAmount = #src.TaxAmount,
				tgt.SubAmount = #src.SubAmount,
				tgt.CreditCardRefundTransactionID = #src.CreditCardRefundTransactionID
		when not matched by target then 
			insert (
				IndividualSK,
				FunderSK,
				SiteSK,
				ServiceSK,
				DebitID,
				IndividualID,
				FunderID,
				[Description],
				RefNumber,
				Amount,
				DebitReason,
				DebitGLCode,
				Paid,
				PartPaid,
				CreatedDatetime,
				UpdatedDatetime,
				CreatedBy,
				UpdatedBy,
				SiteID,
				FullyAppliedDate,
				ServiceID,
				Region,
				RegionCode,
				TaxAmount,
				SubAmount,
				CreditCardRefundTransactionID
			)
			values (
				#src.IndividualSK,
				#src.FunderSK,
				#src.SiteSK,
				#src.ServiceSK,
				#src.DebitID,
				#src.IndividualID,
				#src.FunderID,
				#src.[Description],
				#src.RefNumber,
				#src.Amount,
				#src.DebitReason,
				#src.DebitGLCode,
				#src.Paid,
				#src.PartPaid,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.SiteID,
				#src.FullyAppliedDate,
				#src.ServiceID,
				#src.Region,
				#src.RegionCode,
				#src.TaxAmount,
				#src.SubAmount,
				#src.CreditCardRefundTransactionID
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
