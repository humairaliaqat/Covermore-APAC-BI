USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpDeposit]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpDeposit
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpDeposit] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpDeposit') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpDeposit](
			DepositSK int identity(1,1) primary key,
			SiteSK int,
			CreateUserSK int,
			UpdateUserSK int,
			DepositID int,
			DepositDate date,
			DepositStatus varchar(5),
			BankAccountID int,
			SiteID int,
			Notes nvarchar(max),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreateUserID int,
			UpdateUserID int,
			DepositType int,
			index idx_pnpDeposit_SiteSK nonclustered (SiteSK),
			index idx_pnpDeposit_CreateUserSK nonclustered (CreateUserSK),
			index idx_pnpDeposit_UpdateUserSK nonclustered (UpdateUserSK),
			index idx_pnpDeposit_DepositID nonclustered (DepositID),
			index idx_pnpDeposit_SiteID nonclustered (SiteID),
			index idx_pnpDeposit_CreateUserID nonclustered (CreateUserID),
			index idx_pnpDeposit_UpdateUserID nonclustered (UpdateUserID)
	)
	end;

	if object_id('[db-au-dtc].dbo.penelope_btdeposit_audtc') is null
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
			s.SiteSK,
			cu.CreateUserSK,
			uu.UpdateUserSK,
			d.kdepositid as DepositID,
			d.depositdate as DepositDate,
			d.depositstatus as DepositStatus,
			d.kbankaccountid as BankAccountID,
			d.ksiteid as SiteID,
			d.depositnotes as Notes,
			d.slogin as CreatedDatetime,
			d.slogmod as UpdatedDatetime,
			d.kuseridlogin as CreateUserID,
			d.kuseridlogmod as UpdateUserID,
			dt.deposittype as DepositType
		into #src
		from 
			penelope_btdeposit_audtc d 
			left join penelope_sadeposittype_audtc dt on dt.kdeposittypeid = d.kdeposittypeid
			outer apply (
				select top 1 SiteSK
				from [db-au-dtc].dbo.pnpSite
				where SiteID = d.ksiteid
			) s
			outer apply (
				select top 1 UserSK as CreateUserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = d.kuseridlogin
					and IsCurrent = 1
			) cu
			outer apply (
				select top 1 UserSK as UpdateUserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = d.kuseridlogmod
					and IsCurrent = 1
			) uu

		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpDeposit as tgt
		using #src
			on #src.DepositID = tgt.DepositID
		when matched then 
			update set 
				tgt.SiteSK = #src.SiteSK,
				tgt.CreateUserSK = #src.CreateUserSK,
				tgt.UpdateUserSK = #src.UpdateUserSK,
				tgt.DepositDate = #src.DepositDate,
				tgt.DepositStatus = #src.DepositStatus,
				tgt.BankAccountID = #src.BankAccountID,
				tgt.SiteID = #src.SiteID,
				tgt.Notes = #src.Notes,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdateUserID = #src.UpdateUserID,
				tgt.DepositType = #src.DepositType
		when not matched by target then 
			insert (
				SiteSK,
				CreateUserSK,
				UpdateUserSK,
				DepositID,
				DepositDate,
				DepositStatus,
				BankAccountID,
				SiteID,
				Notes,
				CreatedDatetime,
				UpdatedDatetime,
				CreateUserID,
				UpdateUserID,
				DepositType
			)
			values (
				#src.SiteSK,
				#src.CreateUserSK,
				#src.UpdateUserSK,
				#src.DepositID,
				#src.DepositDate,
				#src.DepositStatus,
				#src.BankAccountID,
				#src.SiteID,
				#src.Notes,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreateUserID,
				#src.UpdateUserID,
				#src.DepositType
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
