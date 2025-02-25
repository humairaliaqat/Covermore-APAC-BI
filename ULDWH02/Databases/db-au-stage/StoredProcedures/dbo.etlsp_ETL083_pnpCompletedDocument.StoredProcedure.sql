USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpCompletedDocument]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpCompletedDocument
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpCompletedDocument] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpCompletedDocument') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpCompletedDocument](
			CompletedDocumentSK int identity(1,1) primary key,
			DocumentSK int,
			CaseSK int,
			ServiceFileSK int,
			ServiceEventSK int,
			BookItemSK int,
			CompletedDocumentRevisionSK int,
			CreateUserSK int,
			UpdateUserSK int,
			CompletedByBookItemSK int,
			CreateBookItemSK int,
			UpdateBookItemSK int,
			CompletedDocumentID int,
			CaseID varchar(50),
			Title nvarchar(max),
			[Description] nvarchar(50),
			DocumentDate datetime2,
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreatedBy nvarchar(10),
			UpdatedBy nvarchar(10),
			ServiceFileID varchar(50),
			Lock varchar(5),
			OriginalCompletedDocumentID int,
			ServiceEventID int,
			DocumentID int,
			Stage nvarchar(100),
			TitleStage nvarchar(max),
			BookItemID int,
			CompletedDocumentRevisionID int,
			CompletedDocumentRevisionState nvarchar(20),
			CreateUserID varchar(50),
			UpdateUserID varchar(50),
			CompletedByBookItemID int,
			kiocrossid int,
			CreateBookItemID int,
			UpdateBookItemID int,
			CompletionTime int,
			RelationType varchar(50),
			RelatedAnonymousServiceID int,
			RelatedFunderID varchar(50),
			RelatedFunderSK int,
			RelatedInformalSeriesID int,
			RelatedServiceID varchar(50),	-- informal service & case service
			RelatedServiceSK int,	-- informal service & case service
			RelatedEventID varchar(50),	--service event & indirect event & informal event
			RelatedEventSK int,	--service event & indirect event & informal event
			RelatedGroupEventID int,
			RelatedGroupMasterID int,
			RelatedCaseID varchar(50),
			RelatedCaseSK int,
			RelatedServiceFileID varchar(50), 
			RelatedServiceFileCompletedAtServiceEventID varchar(50),
			RelatedServiceFileSK int,
			RelatedIndividualID varchar(50),
			RelatedIndividualSK int,
			RelatedBlueBookID int,
			RelatedBlueBookSK int,
			RelatedReferralID int,
			RelatedReferralSK int,
			RelatedFlatTreeID int, 
			index idx_pnpCompletedDocument_CaseSK nonclustered (CaseSK),
			index idx_pnpCompletedDocument_ServiceFileSK nonclustered (ServiceFileSK),
			index idx_pnpCompletedDocument_ServiceEventSK nonclustered (ServiceEventSK),
			index idx_pnpCompletedDocument_BookItemSK nonclustered (BookItemSK),
			index idx_pnpCompletedDocument_CompletedDocumentRevisionSK nonclustered (CompletedDocumentRevisionSK),
			index idx_pnpCompletedDocument_CreateUserSK nonclustered (CreateUserSK),
			index idx_pnpCompletedDocument_UpdateUserSK nonclustered (UpdateUserSK),
			index idx_pnpCompletedDocument_CompletedByBookItemSK nonclustered (CompletedByBookItemSK),
			index idx_pnpCompletedDocument_CreateBookItemSK nonclustered (CreateBookItemSK),
			index idx_pnpCompletedDocument_UpdateBookItemSK nonclustered (UpdateBookItemSK),
			index idx_pnpCompletedDocument_CompletedDocumentID nonclustered (CompletedDocumentID),
			index idx_pnpCompletedDocument_ServiceFileID nonclustered (ServiceFileID),
			index idx_pnpCompletedDocument_ServiceEventID nonclustered (ServiceEventID),
			index idx_pnpCompletedDocument_DocumentID nonclustered (DocumentID),
			index idx_pnpCompletedDocument_BookItemID nonclustered (BookItemID),
			index idx_pnpCompletedDocument_CompletedDocumentRevisionID nonclustered (CompletedDocumentRevisionID),
			index idx_pnpCompletedDocument_CompletedByBookItemID nonclustered (CompletedByBookItemID),
			index idx_pnpCompletedDocument_CreateBookItemID nonclustered (CreateBookItemID),
			index idx_pnpCompletedDocument_UpdateBookItemID nonclustered (UpdateBookItemID),
			index idx_pnpCompletedDocument_RelatedFunderSK nonclustered (RelatedFunderSK),
			index idx_pnpCompletedDocument_RelatedServiceSK nonclustered (RelatedServiceSK),
			index idx_pnpCompletedDocument_RelatedEventSK nonclustered (RelatedEventSK),
			index idx_pnpCompletedDocument_RelatedCaseSK nonclustered (RelatedCaseSK),
			index idx_pnpCompletedDocument_RelatedServiceFileSK nonclustered (RelatedServiceFileSK),
			index idx_pnpCompletedDocument_RelatedIndividualSK nonclustered (RelatedIndividualSK),
			index idx_pnpCompletedDocument_RelatedBlueBookSK nonclustered (RelatedBlueBookSK),
			index idx_pnpCompletedDocument_RelatedReferralSK nonclustered (RelatedReferralSK)
	)
	end;

	if object_id('[db-au-stage].dbo.penelope_dtcomdoc_audtc') is null
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
			d.DocumentSK,
			c.CaseSK,
			sf.ServiceFileSK,
			se.ServiceEventSK,
			bi.BookItemSK,
			cu.CreateUserSK,
			uu.UpdateUserSK,
			cbbi.CompletedByBookItemSK,
			cbi.CreateBookItemSK,
			ubi.UpdateBookItemSK,
			cd.kcomdocid as CompletedDocumentID,
			convert(varchar, cd.kcaseid) as CaseID,
			cd.cdoctitle as Title,
			cd.cdocdesciption as [Description],
			cd.cdocdate as DocumentDate,
			cd.slogin as CreatedDatetime,
			cd.slogmod as UpdatedDatetime,
			cd.sloginby as CreatedBy,
			cd.slogmodby as UpdatedBy,
			convert(varchar, cd.kprogprovid) as ServiceFileID,
			cd.doclock as Lock,
			cd.korigcomdocid as OriginalCompletedDocumentID,
			cd.kactid as ServiceEventID,
			cd.kdocid as DocumentID,
			ds.docstage as Stage,
			dsn.docstagename as TitleStage,
			cd.kbookitemid as BookItemID,
			cd.kcomdocrevid as CompletedDocumentRevisionID,
			cdrs.comdocrevstate as CompletedDocumentRevisionState,
			convert(varchar, cd.kuseridlogin) as CreateUserID,
			convert(varchar, cd.kuseridlogmod) as UpdateUserID,
			cd.iocompletedby as CompletedByBookItemID,
			cd.kiocrossid as kiocrossid,
			cd.kbookitemidlogin as CreateBookItemID,
			cd.kbookitemidlogmod as UpdateBookItemID,
			cd.completiontime as CompletionTime,
			coalesce(
				ranonymousservice.RelationType, 
				rfunder.RelationType, 
				rinformalseries.RelationType, 
				rinformalservice.RelationType, 
				rserviceevent.RelationType, 
				rindirectevent.RelationType, 
				rinformalevent.RelationType, 
				rgroupevent.RelationType, 
				rcaseservice.RelationType, 
				rgroupmaster.RelationType, 
				rcase.RelationType, 
				rservicefile.RelationType, 
				rindividual.RelationType, 
				rbluebook.RelationType, 
				rreferral.RelationType, 
				rflattree.RelationType) as RelationType,
			ranonymousservice.kbriefserprovid as RelatedAnonymousServiceID,
			convert(varchar, rfunder.kfunderid) as RelatedFunderID,
			rfundersk.FunderSK as RelatedFunderSK,
			rinformalseries.kncaseserid as RelatedInformalSeriesID,
			convert(varchar, rinformalservice.kagserid) as RelatedInformalServiceID,
			rinformalservicesk.ServiceSK as RelatedInformalServiceSK,
			convert(varchar, rserviceevent.kactid) as RelatedServiceEventID, 
			rserviceeventsk.ServiceEventSK as RelatedServiceEventSK,
			convert(varchar, rindirectevent.kactid) as RelatedIndirectEventID,
			rindirecteventsk.ServiceEventSK as RelatedIndirectEventSK,
			convert(varchar, rinformalevent.kactid) as RelatedInformalEventID,
			rinformaleventsk.ServiceEventSK as RelatedInformalEventSK,
			rgroupevent.kworkshopsessionid as RelatedGroupEventID,
			convert(varchar, rcaseservice.kagserid) as RelatedCaseServiceID,
			rcaseservicesk.ServiceSK as RelatedCaseServiceSK,
			rgroupmaster.kcworkshopid as RelatedGroupMasterID,
			convert(varchar, rcase.kcaseid) as RelatedCaseID,
			rcasesk.CaseSK as RelatedCaseSK,
			convert(varchar, rservicefile.kprogprovid) as RelatedServiceFileID,
			rservicefile.kactidcomat as RelatedServiceFileCompletedAtServiceEventID,
			rservicefilesk.ServiceFileSK as RelatedServiceFileSK,
			convert(varchar, rindividual.kindid) as RelatedIndividualID,
			rindividualsk.IndividualSK as RelatedIndividualSK,
			rbluebook.kbluebookid as RelatedBlueBookID,
			rbluebooksk.BlueBookSK as RelatedBlueBookSK,
			rreferral.kreferralentryid as RelatedReferralID,
			rreferralsk.ReferralSK as RelatedReferralSK,
			rflattree.kdocpartflattreeid as RelatedFlatTreeID  
		into #src
		from 
			penelope_dtcomdoc_audtc cd 
			left join penelope_drdocstagename_audtc dsn on dsn.kdocstagenameid = cd.kdocstagenameid
			left join penelope_ssdocstage_audtc ds on ds.kdocstageid = dsn.kdocstageid
			left join penelope_sscomdocrevstate_audtc cdrs on cdrs.kcomdocrevstateid = cd.kcomdocrevstateid
			outer apply (
				select top 1 DocumentSK
				from [db-au-dtc]..pnpDocument
				where DocumentID = cd.kdocid
			) d
			outer apply (
				select top 1 CaseSK
				from [db-au-dtc]..pnpCase
				where CaseID = convert(varchar, cd.kcaseid)
			) c
			outer apply (
				select top 1 ServiceFileSK
				from [db-au-dtc]..pnpServiceFile
				where ServiceFileID = convert(varchar, cd.kprogprovid)
			) sf
			outer apply (
				select top 1 ServiceEventSK
				from [db-au-dtc]..pnpServiceEvent
				where ServiceEventID = convert(varchar, cd.kactid)
			) se
			outer apply (
				select top 1 BookItemSK
				from [db-au-dtc]..pnpBookItem
				where BookItemID = cd.kbookitemid
			) bi
			outer apply (
				select top 1 UserSK as CreateUserSK
				from [db-au-dtc]..pnpUser
				where UserId = convert(varchar(50), cd.kuseridlogin)
					and IsCurrent = 1
			) cu
			outer apply (
				select top 1 UserSK as UpdateUserSK
				from [db-au-dtc]..pnpUser
				where UserID = convert(varchar(50), cd.kuseridlogmod)
					and IsCurrent = 1
			) uu
			outer apply (
				select top 1 BookItemSK as CompletedByBookItemSK
				from [db-au-dtc]..pnpBookItem
				where BookItemID = cd.iocompletedby
			) cbbi
			outer apply (
				select top 1 BookItemSK as CreateBookItemSK
				from [db-au-dtc]..pnpBookItem
				where BookItemID = cd.kbookitemidlogin
			) cbi
			outer apply (
				select top 1 BookItemSK as UpdateBookItemSK
				from [db-au-dtc]..pnpBookItem
				where BookItemID = cd.kbookitemidlogmod
			) ubi
			-- completed document relations
			outer apply (select 'Anonymous Service' as RelationType, * from penelope_adpanonymousserviceassign_audtc where kcomdocid = cd.kcomdocid) ranonymousservice 
			outer apply (select 'Funder' as RelationType, * from penelope_adffunderassign_audtc where kcomdocid = cd.kcomdocid) rfunder
			outer apply (select top 1 FunderSK from [db-au-dtc]..pnpFunder where FunderID = convert(varchar, rfunder.kfunderid) and IsCurrent = 1) rfundersk
			outer apply (select 'Informal Series' as RelationType, * from penelope_adpinfseriesassign_audtc where kcomdocid = cd.kcomdocid) rinformalseries
			outer apply (select 'Informal Service' as RelationType, b.kagserid from penelope_adpinfserviceassign_audtc a inner join penelope_prncaseprog_audtc b on a.kncaseprogid = b.kncaseprogid where kcomdocid = cd.kcomdocid) rinformalservice
			outer apply (select top 1 ServiceSK from [db-au-dtc]..pnpService where ServiceID = convert(varchar(50), rinformalservice.kagserid)) rinformalservicesk
			outer apply (select 'Service Event' as RelationType, * from penelope_adeserveventassign_audtc where kcomdocid = cd.kcomdocid) rserviceevent
			outer apply (select top 1 ServiceEventSK from [db-au-dtc]..pnpServiceEvent where ServiceEventID = convert(varchar, rserviceevent.kactid)) rserviceeventsk
			outer apply (select 'Indirect Event' as RelationType, * from penelope_adeindirecteventassign_audtc where kcomdocid = cd.kcomdocid) rindirectevent
			outer apply (select top 1 ServiceEventSK from [db-au-dtc]..pnpServiceEvent where ServiceEventID = convert(varchar, rindirectevent.kactid)) rindirecteventsk
			outer apply (select 'Informal Event' as RelationType, * from penelope_adeinformaleventassign_audtc where kcomdocid = cd.kcomdocid) rinformalevent
			outer apply (select top 1 ServiceEventSK from [db-au-dtc]..pnpServiceEvent where ServiceEventID = convert(varchar, rinformalevent.kactid)) rinformaleventsk
			outer apply (select 'Group Event' as RelationType, * from penelope_adpgroupeventassign_audtc where kcomdocid = cd.kcomdocid) rgroupevent
			outer apply (select 'Case Service' as RelationType, b.kagserid from penelope_adpcaseserviceassign_audtc a inner join penelope_prcaseprog_audtc b on a.kcaseprogid = b.kcaseprogid where a.kcomdocid = cd.kcomdocid) rcaseservice
			outer apply (select top 1 ServiceSK from [db-au-dtc]..pnpService where ServiceID = convert(varchar(50), rcaseservice.kagserid)) rcaseservicesk 
			outer apply (select 'Group Master' as RelationType, * from penelope_adpgroupmasterassign_audtc where kcomdocid = cd.kcomdocid) rgroupmaster 
			outer apply (select 'Case' as RelationType, * from penelope_adccaseassign_audtc where kcomdocid = cd.kcomdocid) rcase
			outer apply (select top 1 CaseSK from [db-au-dtc]..pnpCase where CaseID = convert(varchar, rcase.kcaseid)) rcasesk 
			outer apply (select 'Service File' as RelationType, * from penelope_adcservfileassign_audtc where kcomdocid = cd.kcomdocid) rservicefile
			outer apply (select top 1 ServiceFileSK from [db-au-dtc]..pnpServiceFile where ServiceFileID = convert(varchar, rservicefile.kprogprovid)) rservicefilesk 
			outer apply (select 'Individual' as RelationType, * from penelope_adiindivassign_audtc where kcomdocid = cd.kcomdocid) rindividual
			outer apply (select top 1 IndividualSK from [db-au-dtc]..pnpIndividual where IndividualID = convert(varchar, rindividual.kindid) and IsCurrent = 1) rindividualsk 
			outer apply (select 'Bluebook' as RelationType, * from penelope_adgbluebookassign_audtc where kcomdocid = cd.kcomdocid) rbluebook 
			outer apply (select top 1 BlueBookSK from [db-au-dtc]..pnpBlueBook where BlueBookID = rbluebook.kbluebookid) rbluebooksk 
			outer apply (select 'Referral Entry' as RelationType, * from penelope_adireferralentryassign_audtc where kcomdocid = cd.kcomdocid) rreferral
			outer apply (select top 1 ReferralSK from [db-au-dtc]..pnpReferral where ReferralID = rreferral.kreferralentryid) rreferralsk 
			outer apply (select 'Flat Tree' as RelationType, * from penelope_addpvassign_audtc where kcomdocid = cd.kcomdocid) rflattree



		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpCompletedDocument as tgt
		using #src
			on #src.CompletedDocumentID = tgt.CompletedDocumentID
		when matched then 
			update set 
				tgt.DocumentSK = #src.DocumentSK,
				tgt.CaseSK = #src.CaseSK,
				tgt.ServiceFileSK = #src.ServiceFileSK,
				tgt.ServiceEventSK = #src.ServiceEventSK,
				tgt.BookItemSK = #src.BookItemSK,
				tgt.CreateUserSK = #src.CreateUserSK,
				tgt.UpdateUserSK = #src.UpdateUserSK,
				tgt.CompletedByBookItemSK = #src.CompletedByBookItemSK,
				tgt.CreateBookItemSK = #src.CreateBookItemSK,
				tgt.UpdateBookItemSK = #src.UpdateBookItemSK,				
				tgt.CaseID = #src.CaseID,
				tgt.Title = #src.Title,
				tgt.[Description] = #src.[Description],
				tgt.DocumentDate = #src.DocumentDate,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.ServiceFileID = #src.ServiceFileID,
				tgt.Lock = #src.Lock,
				tgt.OriginalCompletedDocumentID = #src.OriginalCompletedDocumentID,
				tgt.ServiceEventID = #src.ServiceEventID,
				tgt.DocumentID = #src.DocumentID,
				tgt.Stage = #src.Stage,
				tgt.TitleStage = #src.TitleStage,
				tgt.BookItemID = #src.BookItemID,
				tgt.CompletedDocumentRevisionID = #src.CompletedDocumentRevisionID,
				tgt.CompletedDocumentRevisionState = #src.CompletedDocumentRevisionState,
				tgt.CreateUserID = #src.CreateUserID,
				tgt.UpdateUserID = #src.UpdateUserID,
				tgt.CompletedByBookItemID = #src.CompletedByBookItemID,
				tgt.kiocrossid = #src.kiocrossid,
				tgt.CreateBookItemID = #src.CreateBookItemID,
				tgt.UpdateBookItemID = #src.UpdateBookItemID,
				tgt.CompletionTime = #src.CompletionTime,
				tgt.RelationType = #src.RelationType,
				tgt.RelatedAnonymousServiceID = #src.RelatedAnonymousServiceID,
				tgt.RelatedFunderID = #src.RelatedFunderID,
				tgt.RelatedFunderSK = #src.RelatedFunderSK,
				tgt.RelatedInformalSeriesID = #src.RelatedInformalSeriesID,
				tgt.RelatedServiceID = coalesce(#src.RelatedInformalServiceID, #src.RelatedCaseServiceID),
				tgt.RelatedServiceSK = coalesce(#src.RelatedInformalServiceSK, #src.RelatedCaseServiceSK),
				tgt.RelatedEventID = coalesce(#src.RelatedServiceEventID, #src.RelatedIndirectEventID, #src.RelatedInformalEventID),
				tgt.RelatedEventSK = coalesce(#src.RelatedServiceEventSK, #src.RelatedIndirectEventSK, #src.RelatedInformalEventSK),
				tgt.RelatedGroupEventID = #src.RelatedGroupEventID,
				tgt.RelatedGroupMasterID = #src.RelatedGroupMasterID,
				tgt.RelatedCaseID = #src.RelatedCaseID,
				tgt.RelatedCaseSK = #src.RelatedCaseSK,
				tgt.RelatedServiceFileID = #src.RelatedServiceFileID,
				tgt.RelatedServiceFileCompletedAtServiceEventID = #src.RelatedServiceFileCompletedAtServiceEventID,
				tgt.RelatedServiceFileSK = #src.RelatedServiceFileSK,
				tgt.RelatedIndividualID = #src.RelatedIndividualID,
				tgt.RelatedIndividualSK = #src.RelatedIndividualSK,
				tgt.RelatedBlueBookID = #src.RelatedBlueBookID,
				tgt.RelatedBlueBookSK = #src.RelatedBlueBookSK,
				tgt.RelatedReferralID = #src.RelatedReferralID,
				tgt.RelatedReferralSK = #src.RelatedReferralSK,
				tgt.RelatedFlatTreeID = #src.RelatedFlatTreeID 
		when not matched by target then 
			insert (
				DocumentSK,
				CaseSK,
				ServiceFileSK,
				ServiceEventSK,
				BookItemSK,
				CreateUserSK,
				UpdateUserSK,
				CompletedByBookItemSK,
				CreateBookItemSK,
				UpdateBookItemSK,
				CompletedDocumentID,
				CaseID,
				Title,
				[Description],
				DocumentDate,
				CreatedDatetime,
				UpdatedDatetime,
				CreatedBy,
				UpdatedBy,
				ServiceFileID,
				Lock,
				OriginalCompletedDocumentID,
				ServiceEventID,
				DocumentID,
				Stage,
				TitleStage,
				BookItemID,
				CompletedDocumentRevisionID,
				CompletedDocumentRevisionState,
				CreateUserID,
				UpdateUserID,
				CompletedByBookItemID,
				kiocrossid,
				CreateBookItemID,
				UpdateBookItemID,
				CompletionTime,
				RelationType,
				RelatedAnonymousServiceID,
				RelatedFunderID,
				RelatedFunderSK,
				RelatedInformalSeriesID,
				RelatedServiceID,
				RelatedServiceSK,
				RelatedEventID,
				RelatedEventSK,
				RelatedGroupEventID,
				RelatedGroupMasterID,
				RelatedCaseID,
				RelatedCaseSK,
				RelatedServiceFileID,
				RelatedServiceFileCompletedAtServiceEventID,
				RelatedServiceFileSK,
				RelatedIndividualID,
				RelatedIndividualSK,
				RelatedBlueBookID,
				RelatedBlueBookSK,
				RelatedReferralID,
				RelatedReferralSK,
				RelatedFlatTreeID 
			)
			values (
				#src.DocumentSK,
				#src.CaseSK,
				#src.ServiceFileSK,
				#src.ServiceEventSK,
				#src.BookItemSK,
				#src.CreateUserSK,
				#src.UpdateUserSK,
				#src.CompletedByBookItemSK,
				#src.CreateBookItemSK,
				#src.UpdateBookItemSK,
				#src.CompletedDocumentID,
				#src.CaseID,
				#src.Title,
				#src.[Description],
				#src.DocumentDate,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.ServiceFileID,
				#src.Lock,
				#src.OriginalCompletedDocumentID,
				#src.ServiceEventID,
				#src.DocumentID,
				#src.Stage,
				#src.TitleStage,
				#src.BookItemID,
				#src.CompletedDocumentRevisionID,
				#src.CompletedDocumentRevisionState,
				#src.CreateUserID,
				#src.UpdateUserID,
				#src.CompletedByBookItemID,
				#src.kiocrossid,
				#src.CreateBookItemID,
				#src.UpdateBookItemID,
				#src.CompletionTime,
				#src.RelationType,
				#src.RelatedAnonymousServiceID,
				#src.RelatedFunderID,
				#src.RelatedFunderSK,
				#src.RelatedInformalSeriesID,
				coalesce(#src.RelatedInformalServiceID, #src.RelatedCaseServiceID),
				coalesce(#src.RelatedInformalServiceSK, #src.RelatedCaseServiceSK),
				coalesce(#src.RelatedServiceEventID, #src.RelatedIndirectEventID, #src.RelatedInformalEventID),
				coalesce(#src.RelatedServiceEventSK, #src.RelatedIndirectEventSK, #src.RelatedInformalEventSK),
				#src.RelatedGroupEventID,
				#src.RelatedGroupMasterID,
				#src.RelatedCaseID,
				#src.RelatedCaseSK,
				#src.RelatedServiceFileID,
				#src.RelatedServiceFileCompletedAtServiceEventID,
				#src.RelatedServiceFileSK,
				#src.RelatedIndividualID,
				#src.RelatedIndividualSK,
				#src.RelatedBlueBookID,
				#src.RelatedBlueBookSK,
				#src.RelatedReferralID,
				#src.RelatedReferralSK,
				#src.RelatedFlatTreeID 
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
