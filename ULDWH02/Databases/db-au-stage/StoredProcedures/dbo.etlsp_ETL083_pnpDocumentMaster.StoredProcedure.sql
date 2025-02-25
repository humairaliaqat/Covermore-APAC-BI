USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpDocumentMaster]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpDocumentMaster
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpDocumentMaster] 
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

	if object_id('[db-au-dtc].dbo.pnpDocumentMaster') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpDocumentMaster](
			DocumentMasterSK int identity(1,1) primary key,
			CurrentRevDocumentSK int,
			CreateUserSK int,
			UpdateUserSK int,
			DocumentMasterID int,
			Title nvarchar(max),
			Code nvarchar(10),
			[Status] varchar(5),
			Class nvarchar(40),
			CurrentRevDocumentID int,
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreateUserID varchar(50),
			UpdateUserID varchar(50),
			DocumentTypeID int,
			DocumentType nvarchar(100),
			ServiceCategoryID int,
			ServiceCategory nvarchar(100),
			[Description] nvarchar(max),
			UseCompletedDocumentRev varchar(5),
			index idx_pnpDocumentMaster_CurrentRevDocumentSK nonclustered (CurrentRevDocumentSK),
			index idx_pnpDocumentMaster_CreateUserSK nonclustered (CreateUserSK),
			index idx_pnpDocumentMaster_UpdateUserSK nonclustered (UpdateUserSK),
			index idx_pnpDocumentMaster_DocumentMasterID nonclustered (DocumentMasterID),
			index idx_pnpDocumentMaster_CurrentRevDocumentID nonclustered (CurrentRevDocumentID),
			index idx_pnpDocumentMaster_CreateUserID nonclustered (CreateUserID),
			index idx_pnpDocumentMaster_UpdateUserID nonclustered (UpdateUserID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			cu.CreateUserSK,
			uu.UpdateUserSK,
			dm.kdocmastid as DocumentMasterID,
			dm.doctitle as Title,
			dm.docshort as Code,
			dm.docstatus as [Status],
			dc.docclassname as Class,
			dm.kdocidcurrev as CurrentRevDocumentID,
			dm.slogin as CreatedDatetime,
			dm.slogmod as UpdatedDatetime,
			convert(varchar(50), dm.kuseridlogin) as CreateUserID,
			convert(varchar(50), dm.kuseridlogmod) as UpdateUserID,
			dm.kdocud1id as DocumentTypeID,
			dt.DocumentType,
			dm.kdocud2id as ServiceCategoryID,
			sc.ServiceCategory,
			dm.docdescription as [Description],
			dm.usecomdocrev as UseCompletedDocumentRev
		into #src
		from 
			penelope_drdocmast_audtc dm 
			left join penelope_ssdocclass_audtc dc on dc.kdocclassid = dm.kdocclassid
			outer apply (
				select top 1 UserSK as CreateUserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = convert(varchar(50), dm.kuseridlogin)
					and IsCurrent = 1
			) cu
			outer apply (
				select top 1 UserSK as UpdateUserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = convert(varchar(50), dm.kuseridlogmod)
					and IsCurrent = 1
			) uu
			outer apply (
				select top 1 docud1 as DocumentType 
				from penelope_drdocud1_audtc 
				where kdocud1id = dm.kdocud1id
			) dt
			outer apply (
				select top 1 docud2 as ServiceCategory 
				from penelope_drdocud2_audtc 
				where kdocud2id = dm.kdocud2id
			) sc

		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpDocumentMaster as tgt
		using #src
			on #src.DocumentMasterID = tgt.DocumentMasterID
		when matched then 
			update set 
				tgt.CreateUserSK = #src.CreateUserSK,
				tgt.UpdateUserSK = #src.UpdateUserSK,
				tgt.Title = #src.Title,
				tgt.Code = #src.Code,
				tgt.[Status] = #src.[Status],
				tgt.Class = #src.Class,
				tgt.CurrentRevDocumentID = #src.CurrentRevDocumentID,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdateUserID = #src.UpdateUserID,
				tgt.DocumentTypeID = #src.DocumentTypeID,
				tgt.DocumentType = #src.DocumentType,
				tgt.ServiceCategoryID = #src.ServiceCategoryID,
				tgt.ServiceCategory = #src.ServiceCategory,
				tgt.[Description] = #src.[Description],
				tgt.UseCompletedDocumentRev = #src.UseCompletedDocumentRev
		when not matched by target then 
			insert (
				CreateUserSK,
				UpdateUserSK,
				DocumentMasterID,
				Title,
				Code,
				[Status],
				Class,
				CurrentRevDocumentID,
				CreatedDatetime,
				UpdatedDatetime,
				CreateUserID,
				UpdateUserID,
				DocumentTypeID,
				DocumentType,
				ServiceCategoryID,
				ServiceCategory,
				[Description],
				UseCompletedDocumentRev
			)
			values (
				#src.CreateUserSK,
				#src.UpdateUserSK,
				#src.DocumentMasterID,
				#src.Title,
				#src.Code,
				#src.[Status],
				#src.Class,
				#src.CurrentRevDocumentID,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreateUserID,
				#src.UpdateUserID,
				#src.DocumentTypeID,
				#src.DocumentType,
				#src.ServiceCategoryID,
				#src.ServiceCategory,
				#src.[Description],
				#src.UseCompletedDocumentRev
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
