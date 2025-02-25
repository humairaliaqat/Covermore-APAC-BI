USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpReferral]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpReferral
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpReferral] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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

	if object_id('[db-au-dtc].dbo.pnpReferral') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpReferral](
			ReferralSK int identity(1,1) primary key,
			UserSK int,
			BlueBookSK int,
			ReferralID int,
			Class nvarchar(max),
			Reason nvarchar(max),
			ReasonClass nvarchar(20),
			ReferralDate date,
			ClientNeeds nvarchar(max),
			ClientInstructions nvarchar(max),
			ClientConsent varchar(5),
			ReferralCloseDate date,
			ReferralClose varchar(5),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreatedBy nvarchar(10),
			UpdatedBy nvarchar(10),
			IsExit varchar(5),
			lureferralentryuserdef1id int,
			kbbrefavailserid int,
			ReferralOutcomeID int,
			index idx_pnpReferral_UserSK nonclustered (UserSK),
			index idx_pnpReferral_BlueBookSK nonclustered (BlueBookSK)
	)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			u.UserSK,
			bb.BlueBookSK,
			r.kreferralentryid as ReferralID,
			rec.referralentryclass as Class,
			rr.referralreason as Reason,
			rrc.referralreasonclass as ReasonClass,
			r.referraldate as ReferralDate,
			r.clientneeds as ClientNeeds,
			r.clientinstructions as ClientInstructions,
			r.clientconsent as ClientConsent,
			r.referralclosedate as ReferralCloseDate,
			r.referralclose as ReferralClose,
			r.slogin as CreatedDatetime,
			r.slogmod as UpdatedDatetime,
			r.sloginby as CreatedBy,
			r.slogmodby as UpdatedBy,
			r.isexit as IsExit,
			r.lureferralentryuserdef1id as lureferralentryuserdef1id,
			r.kbbrefavailserid as kbbrefavailserid,
			r.kreferraloutcomeid as ReferralOutcomeID
		into #src
		from 
			penelope_itreferralentry_audtc r 
			left join penelope_ssreferralentryclass_audtc rec on rec.kreferralentryclassid = r.kreferralentryclassid
			left join penelope_sareferralreason_audtc rr on rr.kreferralreasonid = r.kreferralreasonid
			left join penelope_ssreferralreasonclass_audtc rrc on rrc.kreferralreasonclassid = rr.kreferralreasonclassid
			outer apply (
				select top 1 UserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = convert(varchar(50), r.kuserid)
					and IsCurrent = 1
			) u
			outer apply (
				select top 1 BlueBookSK
				from [db-au-dtc].dbo.pnpBlueBook
				where BlueBookID = r.kbluebookid
			) bb
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpReferral as tgt
		using #src
			on #src.ReferralID = tgt.ReferralID
		when matched then 
			update set 
				tgt.UserSK = #src.UserSK,
				tgt.BlueBookSK = #src.BlueBookSK,
				tgt.Class = #src.Class,
				tgt.Reason = #src.Reason,
				tgt.ReasonClass = #src.ReasonClass,
				tgt.ReferralDate = #src.ReferralDate,
				tgt.ClientNeeds = #src.ClientNeeds,
				tgt.ClientInstructions = #src.ClientInstructions,
				tgt.ClientConsent = #src.ClientConsent,
				tgt.ReferralCloseDate = #src.ReferralCloseDate,
				tgt.ReferralClose = #src.ReferralClose,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.IsExit = #src.IsExit,
				tgt.lureferralentryuserdef1id = #src.lureferralentryuserdef1id,
				tgt.kbbrefavailserid = #src.kbbrefavailserid,
				tgt.ReferralOutcomeID = #src.ReferralOutcomeID
		when not matched by target then 
			insert (
				UserSK,
				BlueBookSK,
				ReferralID,
				Class,
				Reason,
				ReasonClass,
				ReferralDate,
				ClientNeeds,
				ClientInstructions,
				ClientConsent,
				ReferralCloseDate,
				ReferralClose,
				CreatedDatetime,
				UpdatedDatetime,
				CreatedBy,
				UpdatedBy,
				IsExit,
				lureferralentryuserdef1id,
				kbbrefavailserid,
				ReferralOutcomeID
			)
			values (
				#src.UserSK,
				#src.BlueBookSK,
				#src.ReferralID,
				#src.Class,
				#src.Reason,
				#src.ReasonClass,
				#src.ReferralDate,
				#src.ClientNeeds,
				#src.ClientInstructions,
				#src.ClientConsent,
				#src.ReferralCloseDate,
				#src.ReferralClose,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.IsExit,
				#src.lureferralentryuserdef1id,
				#src.kbbrefavailserid,
				#src.ReferralOutcomeID
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

END

GO
