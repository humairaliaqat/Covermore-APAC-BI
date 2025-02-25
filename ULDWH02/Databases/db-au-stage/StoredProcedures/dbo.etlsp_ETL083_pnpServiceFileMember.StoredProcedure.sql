USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpServiceFileMember]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpServiceFileMember
-- Changes:
--			20180719 - DM - Changed outer-apply to Cross apply - Only put into #src where the individual and the service file both exist - to fix issue where individualsk was being updated to null
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpServiceFileMember] 
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

	if object_id('[db-au-dtc].dbo.pnpServiceFileMember') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpServiceFileMember](
			ServiceFileMemberSK int identity(1,1) primary key,
			ServiceFileSK int,
			IndividualSK int,
			FunderSK int,
			FunderDepartmentSK int,
			ServiceFileMemberID varchar(50),
			Relationship nvarchar(20),
			SafetyFlag varchar(5),
			IsCaseInitiator varchar(5),
			IsPrimaryClient varchar(5),
			PresentingIssue1 nvarchar(55),
			PresentingIssueGroup1 nvarchar(50),
			PresentingIssueGroupClass1 nvarchar(20),
			PresentingIssue2 nvarchar(55),
			PresentingIssueGroup2 nvarchar(50),
			PresentingIssueGroupClass2 nvarchar(20),
			PresentingIssue3 nvarchar(55),
			PresentingIssueGroup3 nvarchar(50),
			PresentingIssueGroupClass3 nvarchar(20),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			luppmemberud1id int,
			luppmemberud2id int,
			ppmemberud3 varchar(5),
			ppmemberud4 varchar(5),
			consentpcehr varchar(5),
			index idx_pnpServiceFileMember_ServiceFileSK nonclustered (ServiceFileSK),
			index idx_pnpServiceFileMember_IndividualSK nonclustered (IndividualSK),
			index idx_pnpServiceFileMember_FunderSK nonclustered (FunderSK),
			index idx_pnpServiceFileMember_FunderDepartmentSK nonclustered (FunderDepartmentSK),
			index idx_pnpServiceFileMember_ServiceFileMemberID nonclustered (ServiceFileMemberID)
	)
	end;
	
	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			cm.kindid,
			sf.ServiceFileSK,
			i.IndividualSK,
			sf.FunderSK,
			sf.FunderDepartmentSK,
			convert(varchar, sfm.kprogmemid) as ServiceFileMemberID,
			ft.familytreename as Relationship,
			cm.cmemsafety as SafetyFlag,
			cm.cmeminitiator as IsCaseInitiator,
			cm.cmemprimary as IsPrimaryClient,
			pi1.presissue as PresentingIssue1,
			pig1.presissuegroup as PresentingIssueGroup1,
			pigc1.presissuegroupclass as PresentingIssueGroupClass1,
			pi2.presissue as PresentingIssue2,
			pig2.presissuegroup as PresentingIssueGroup2,
			pigc2.presissuegroupclass as PresentingIssueGroupClass2,
			pi3.presissue as PresentingIssue3,
			pig3.presissuegroup as PresentingIssueGroup3,
			pigc3.presissuegroupclass as PresentingIssueGroupClass3,
			sfm.slogin as CreatedDatetime,
			sfm.slogmod as UpdatedDatetime,
			sfm.luppmemberud1id as luppmemberud1id,
			sfm.luppmemberud2id as luppmemberud2id,
			sfm.ppmemberud3 as ppmemberud3,
			sfm.ppmemberud4 as ppmemberud4,
			sfm.consentpcehr as consentpcehr
		into #src
		from 
			penelope_aicprogmem_audtc sfm 
			left join penelope_aiccasemembers_audtc cm on cm.kcasemembersid = sfm.kcasemembersid
			--left join penelope_irindividualsetup_audtc ist on ist.kindid = cm.kindid
			left join penelope_lufamilytree_audtc ft on ft.lufamilytreeid = cm.lucmemfamilytreeid
			left join penelope_sapresentingiss_audtc pi1 on pi1.kpresissueid = sfm.lupresissueid1
			left join penelope_sapresissuegroup_audtc pig1 on pig1.kpresissuegroupid = pi1.kpresissuegroup
			left join penelope_sspresissuegroupclass_audtc pigc1 on pigc1.kpresissuegroupclassid = pig1.kpresissuegroupclassid
			left join penelope_sapresentingiss_audtc pi2 on pi2.kpresissueid = sfm.lupresissueid2
			left join penelope_sapresissuegroup_audtc pig2 on pig2.kpresissuegroupid = pi2.kpresissuegroup
			left join penelope_sspresissuegroupclass_audtc pigc2 on pigc2.kpresissuegroupclassid = pig2.kpresissuegroupclassid
			left join penelope_sapresentingiss_audtc pi3 on pi3.kpresissueid = sfm.lupresissueid3
			left join penelope_sapresissuegroup_audtc pig3 on pig3.kpresissuegroupid = pi3.kpresissuegroup
			left join penelope_sspresissuegroupclass_audtc pigc3 on pigc3.kpresissuegroupclassid = pig3.kpresissuegroupclassid 
			cross apply (
				select top 1 ServiceFileSK, FunderSK, FunderDepartmentSK, FunderID, FunderDepartmentID 
				from [db-au-dtc].dbo.pnpServiceFile
				where ServiceFileID = convert(varchar, sfm.kprogprovid)
			) sf
			cross apply (
				select top 1 IndividualSK
				from [db-au-dtc].dbo.pnpIndividual
				where IndividualID = convert(varchar, cm.kindid) 
					and IsCurrent = 1
			) i


		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpServiceFileMember as tgt
		using #src
			on #src.ServiceFileMemberID = tgt.ServiceFileMemberID
		when matched then 
			update set 
				tgt.ServiceFileSK = #src.ServiceFileSK,
				tgt.IndividualSK = #src.IndividualSK,
				tgt.FunderSK = #src.FunderSK,
				tgt.FunderDepartmentSK = #src.FunderDepartmentSK,
				tgt.Relationship = #src.Relationship,
				tgt.SafetyFlag = #src.SafetyFlag,
				tgt.IsCaseInitiator = #src.IsCaseInitiator,
				tgt.IsPrimaryClient = #src.IsPrimaryClient,
				tgt.PresentingIssue1 = #src.PresentingIssue1,
				tgt.PresentingIssueGroup1 = #src.PresentingIssueGroup1,
				tgt.PresentingIssueGroupClass1 = #src.PresentingIssueGroupClass1,
				tgt.PresentingIssue2 = #src.PresentingIssue2,
				tgt.PresentingIssueGroup2 = #src.PresentingIssueGroup2,
				tgt.PresentingIssueGroupClass2 = #src.PresentingIssueGroupClass2,
				tgt.PresentingIssue3 = #src.PresentingIssue3,
				tgt.PresentingIssueGroup3 = #src.PresentingIssueGroup3,
				tgt.PresentingIssueGroupClass3 = #src.PresentingIssueGroupClass3,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.luppmemberud1id = #src.luppmemberud1id,
				tgt.luppmemberud2id = #src.luppmemberud2id,
				tgt.ppmemberud3 = #src.ppmemberud3,
				tgt.ppmemberud4 = #src.ppmemberud4,
				tgt.consentpcehr = #src.consentpcehr
		when not matched by target then 
			insert (
				ServiceFileSK,
				IndividualSK,
				FunderSK,
				FunderDepartmentSK,
				ServiceFileMemberID,
				Relationship,
				SafetyFlag,
				IsCaseInitiator,
				IsPrimaryClient,
				PresentingIssue1,
				PresentingIssueGroup1,
				PresentingIssueGroupClass1,
				PresentingIssue2,
				PresentingIssueGroup2,
				PresentingIssueGroupClass2,
				PresentingIssue3,
				PresentingIssueGroup3,
				PresentingIssueGroupClass3,
				CreatedDatetime,
				UpdatedDatetime,
				luppmemberud1id,
				luppmemberud2id,
				ppmemberud3,
				ppmemberud4,
				consentpcehr
			)
			values (
				#src.ServiceFileSK,
				#src.IndividualSK,
				#src.FunderSK,
				#src.FunderDepartmentSK,
				#src.ServiceFileMemberID,
				#src.Relationship,
				#src.SafetyFlag,
				#src.IsCaseInitiator,
				#src.IsPrimaryClient,
				#src.PresentingIssue1,
				#src.PresentingIssueGroup1,
				#src.PresentingIssueGroupClass1,
				#src.PresentingIssue2,
				#src.PresentingIssueGroup2,
				#src.PresentingIssueGroupClass2,
				#src.PresentingIssue3,
				#src.PresentingIssueGroup3,
				#src.PresentingIssueGroupClass3,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.luppmemberud1id,
				#src.luppmemberud2id,
				#src.ppmemberud3,
				#src.ppmemberud4,
				#src.consentpcehr
			)
			
		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		-- PresentingServiceFileMemberSK in [db-au-dtc].dbo.pnpServiceFile
		update [db-au-dtc].dbo.pnpServiceFile
		set PresentingServiceFileMemberSK = sfm.ServiceFileMemberSK
		from [db-au-dtc].dbo.pnpServiceFile sf
            --20180321, LL, optimise
			--outer apply (
			cross apply (
				select top 1 ServiceFileMemberSK
				from [db-au-dtc].dbo.pnpServiceFileMember
				where ServiceFileMemberID = sf.PresentingServiceFileMemberID
			) sfm			
		where
            --20180321, LL, optimise, no point on updating the whole records 
            --sf.PresentingServiceFileMemberID is not null
            sf.ServiceFileSK in
            (
                select 
                    ServiceFileSK
                from
                    #src
            ) 

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
