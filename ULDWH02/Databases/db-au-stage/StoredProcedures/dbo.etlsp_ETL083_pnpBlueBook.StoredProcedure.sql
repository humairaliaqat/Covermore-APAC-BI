USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpBlueBook]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpBlueBook
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpBlueBook] 
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

	if object_id('[db-au-dtc].dbo.pnpBlueBook') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpBlueBook](
			BlueBookSK int identity(1,1) primary key,
			ParentBlueBookSK int,
            MasterBlueBookSK int,
			BookItemSK int,
            BlueBookID int,
			ParentBlueBookID int,
            MasterBlueBookID int,
            LastOrgName nvarchar(4000),
            FirstName nvarchar(4000),
            [Role] nvarchar(4000),
            [Private] varchar(5),
            ccuserdef1 nvarchar(50),
            Notes nvarchar(4000),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            CreatedBy nvarchar(10),
            UpdatedBy nvarchar(10),
            BlueBookType nvarchar(50),
            PrimaryContactType nvarchar(50),
            PrimaryContact nvarchar(4000),
            PrimaryContactExtension nvarchar(4000),
            PrimaryContactDesignatedName nvarchar(4000),
            ReferredTo nvarchar(4000),
            fahcsiaid nvarchar(4000),
            AllowForBillingUse varchar(5),
			index idx_pnpBlueBook_BookItemSK nonclustered (BookItemSK),
			index idx_pnpBlueBook_BlueBookID nonclustered (BlueBookID),
			index idx_pnpBlueBook_ParentBlueBookID nonclustered (ParentBlueBookID),
			index idx_pnpBlueBook_MasterBlueBookID nonclustered (MasterBlueBookID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			bi.BookItemSK,
			bb.kbluebookid as BlueBookID,
			bb.kbluebookidparent as ParentBlueBookID,
			bb.kbluebookidmaster as MasterBlueBookID,
			bb.lastorgname as LastOrgName,
			bb.firstname as FirstName,
			bb.[role] as [Role],
			bb.[private] as [Private],
			ud.ccuserdef1 as ccuserdef1,
			bb.notes as Notes,
			bb.slogin as CreatedDatetime,
			bb.slogmod as UpdatedDatetime,
			bb.sloginby as CreatedBy,
			bb.slogmodby as UpdatedBy,
			bbt.bbtype as BlueBookType,
			ct.contacttype as PrimaryContactType,
			bbc.contact as PrimaryContact,
			bbc.contactext as PrimaryContactExtension,
			bbc.designatedname as PrimaryContactDesignatedName,
			rt.referredto as ReferredTo,
			bb.fahcsiaid as fahcsiaid,
			bb.allowforbillinguse as AllowForBillingUse
		into #src
		from 
			penelope_gtbluebook_audtc bb
			left join penelope_luccuserdef1_audtc ud on ud.luccuserdef1id = bb.luccuserdef1id
			left join penelope_sabbtype_audtc bbt on bbt.kbbtypeid = bb.kbbtypeid
			left join penelope_gtbbcontact_audtc bbc on bbc.kbbcontactid = bb.kbbcontactidprim
			left join penelope_sacontacttype_audtc ct on bbc.kcontacttypeid = ct.kcontacttypeid
			left join penelope_lufahcsiareferredto_audtc rt on rt.kreferredtoid = bb.kreferredtoid
			outer apply (
				select top 1 BookItemSK
				from [db-au-dtc].dbo.pnpBookItem
				where BookItemID = bb.kbookitemid
			) bi

		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpBlueBook as tgt
		using #src
			on #src.BlueBookID = tgt.BlueBookID
		when matched then 
			update set 
				tgt.BookItemSK = #src.BookItemSK,
				tgt.ParentBlueBookID = #src.ParentBlueBookID,
				tgt.MasterBlueBookID = #src.MasterBlueBookID,
				tgt.LastOrgName = #src.LastOrgName,
				tgt.FirstName = #src.FirstName,
				tgt.[Role] = #src.[Role],
				tgt.[Private] = #src.[Private],
				tgt.ccuserdef1 = #src.ccuserdef1,
				tgt.Notes = #src.Notes,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.BlueBookType = #src.BlueBookType,
				tgt.PrimaryContactType = #src.PrimaryContactType,
				tgt.PrimaryContact = #src.PrimaryContact,
				tgt.PrimaryContactExtension = #src.PrimaryContactExtension,
				tgt.PrimaryContactDesignatedName = #src.PrimaryContactDesignatedName,
				tgt.ReferredTo = #src.ReferredTo,
				tgt.fahcsiaid = #src.fahcsiaid,
				tgt.AllowForBillingUse = #src.AllowForBillingUse
		when not matched by target then 
			insert (
				BookItemSK,
				BlueBookID,
				ParentBlueBookID,
				MasterBlueBookID,
				LastOrgName,
				FirstName,
				[Role],
				[Private],
				ccuserdef1,
				Notes,
				CreatedDatetime,
				UpdatedDatetime,
				CreatedBy,
				UpdatedBy,
				BlueBookType,
				PrimaryContactType,
				PrimaryContact,
				PrimaryContactExtension,
				PrimaryContactDesignatedName,
				ReferredTo,
				fahcsiaid,
				AllowForBillingUse
			)
			values (
				#src.BookItemSK,
				#src.BlueBookID,
				#src.ParentBlueBookID,
				#src.MasterBlueBookID,
				#src.LastOrgName,
				#src.FirstName,
				#src.[Role],
				#src.[Private],
				#src.ccuserdef1,
				#src.Notes,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.BlueBookType,
				#src.PrimaryContactType,
				#src.PrimaryContact,
				#src.PrimaryContactExtension,
				#src.PrimaryContactDesignatedName,
				#src.ReferredTo,
				#src.fahcsiaid,
				#src.AllowForBillingUse
			)

		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		-- Lookup ParentBlueBookSK and MasterBlueBookSK
		update [db-au-dtc].dbo.pnpBlueBook
		set 
			ParentBlueBookSK = pbb.ParentBlueBookSK,
			MasterBlueBookSK = mbb.MasterBlueBookSK
		from [db-au-dtc].dbo.pnpBlueBook bb
			inner join #src on #src.BlueBookID = bb.BlueBookID
			outer apply (
				select top 1 BlueBookSK as ParentBlueBookSK
				from [db-au-dtc].dbo.pnpBlueBook
				where BlueBookID = bb.ParentBlueBookID
			) pbb
			outer apply (
				select top 1 BlueBookSK as MasterBlueBookSK
				from [db-au-dtc].dbo.pnpBlueBook
				where BlueBookID = bb.MasterBlueBookID
			) mbb
		where 
			bb.ParentBlueBookID is not null
			or bb.MasterBlueBookID is not null


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
