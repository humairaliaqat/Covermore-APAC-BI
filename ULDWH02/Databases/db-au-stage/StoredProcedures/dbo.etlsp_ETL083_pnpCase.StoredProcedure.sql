USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpCase]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpCase
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpCase] 
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
		@sourcecount int = 0,
		@insertcount int = 0,
		@updatecount int = 0

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

	if object_id('[db-au-dtc].dbo.pnpCase') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpCase](
			CaseSK int identity(1,1) primary key,
			FunderSK int,
			FunderDepartmentSK int,
			CaseID varchar(50),
			FunderID varchar(50),
			FunderDepartmentID varchar(50),
			NickName nvarchar(100),
			[Status] nvarchar(10),
			Setting varchar(5),
			HouseholdIncome numeric(7,0),
			RelationshipStatus nvarchar(20),
			FamilyStatus nvarchar(20),
			casreldate date,
			casblendedf varchar(5),
			casotherinhome varchar(5),
			Accomodations nvarchar(50),
			casneap1 varchar(5),
			JobImpact nvarchar(20),
			ViolenceThreat nvarchar(55),
			FamilySize int,
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreatedBy nvarchar(20),
			UpdatedBy nvarchar(20),
			FileNumber nvarchar(4000),
			UpdatedForRealDatetime datetime2,
			Summary nvarchar(max),
			PresentingIssueGroupClass1 nvarchar(20),
			PresentingIssueGroup1 nvarchar(50),
			PresentingIssue1 nvarchar(55),
			PresentingIssueGroupClass2 nvarchar(20),
			PresentingIssueGroup2 nvarchar(50),
			PresentingIssue2 nvarchar(55),
			PresentingIssueGroupClass3 nvarchar(20),
			PresentingIssueGroup3 nvarchar(50),
			PresentingIssue3 nvarchar(55),
			PresentingIssueGroupClass4 nvarchar(20),
			PresentingIssueGroup4 nvarchar(50),
			PresentingIssue4 nvarchar(55),
			PresentingIssueGroupClass5 nvarchar(20),
			PresentingIssueGroup5 nvarchar(50),
			PresentingIssue5 nvarchar(55),
			Reopen varchar(5),
			ReopenDatetime datetime2,
			FormalRef varchar(5),
			ReferralDatetime datetime2,
			Referral nvarchar(40),
			CaseIntakeCreatedDatetime datetime2,
			CaseIntakeUpdatedDatetime datetime2,
			CaseIntakeCreatedBy nvarchar(10),
			CaseIntakeUpdatedBy nvarchar(10),
			CostCentre nvarchar(100),
			InvoiceText nvarchar(4000),
			[Location] nvarchar(300), 
			FirstEventDatetime datetime2,
			FirstShowEventDatetime datetime2,
			FirstBilledEventDatetime datetime2,
			index idx_pnpCase_FunderSK nonclustered (FunderSK),
			index idx_pnpCase_FunderDepartmentSK nonclustered (FunderDepartmentSK),
			index idx_pnpCase_CaseID nonclustered (CaseID)
		)

		-- create dummy service file for indirect events 
		insert into [db-au-dtc]..pnpCase (
			CaseID 
		)
		values (
			'DUMMY_FOR_INDIRECT_EVENT'
		)

	end;

	begin transaction
    begin try

		if object_id('[db-au-stage].dbo.penelope_crcase_audtc') is not null 
		begin 
			
			-- get funder and funder department from the 1st billing sequence of each service file 
			if object_id('[db-au-stage].dbo.penelope_servicefile_funder_audtc') is not null drop table [db-au-stage].dbo.penelope_servicefile_funder_audtc 
			select 
				kcaseid,
				kprogprovid,
				kfunderid,
				kfunderdeptid,
				kpolicyid
			into [db-au-stage].dbo.penelope_servicefile_funder_audtc 
			from (
				select 
					sf.kcaseid,
					sf.kprogprovid,
					p.kfunderid,
					pm.kfunderdeptid,
					p.kpolicyid,
					row_number() over(partition by sf.kprogprovid order by bs.billseq) rn --53970
				from 
					[db-au-stage].dbo.penelope_btbillseq_audtc bs 
					join [db-au-stage].dbo.penelope_aifpolicymem_audtc pm on pm.kpolicymemid = bs.kpolicymemid 
					join [db-au-stage].dbo.penelope_frpolicy_audtc p on p.kpolicyid = pm.kpolicyid 
					join [db-au-stage].dbo.penelope_ctprogprov_audtc sf on sf.kprogprovid = bs.kprogprovid 
			) a
			where 
				rn = 1

			-- get funder and funder department from the first service file of each case 
			if object_id('[db-au-stage].dbo.penelope_case_funder_audtc') is not null drop table [db-au-stage].dbo.penelope_case_funder_audtc 
			select 
				kcaseid,
				kfunderid,
				kfunderdeptid
			into [db-au-stage].dbo.penelope_case_funder_audtc
			from (
				select 
					kcaseid,
					kfunderid,
					kfunderdeptid,
					row_number() over(partition by kcaseid order by kprogprovid) rn
				from 
					[db-au-stage].dbo.penelope_servicefile_funder_audtc
			) a 
			where rn = 1


			if object_id('tempdb..#src1') is not null drop table #src1

			select 
				f.FunderSK,
				fd.FunderDepartmentSK,
				convert(varchar, c.kcaseid) as CaseID,
				convert(varchar, cf.kfunderid) as FunderID,
				convert(varchar, cf.kfunderdeptid) as FunderDepartmentID,
				c.casnickname as NickName,
				cs.casestatus as [Status],
				c.cassetting as Setting,
				c.cashouseinc as HouseholdIncome,
				rs.relationshipstatus as RelationshipStatus,
				fs.familystatus as FamilyStatus,
				c.casreldate as casreldate,
				c.casblendedf as casblendedf,
				c.casotherinhome as casotherinhome,
				c.casaccomodations as Accomodations,
				c.casneap1 as casneap1,
				ji.jobimpact as JobImpact,
				tv.threatoviolence as ViolenceThreat,
				c.casfamilysize as FamilySize,
				c.slogin as CreatedDatetime,
				c.slogmod as UpdatedDatetime,
				c.sloginby as CreatedBy,
				c.slogmodby as UpdatedBy,
				c.fileno as FileNumber,
				c.slogmodforreal as UpdatedForRealDatetime
			into #src1
			from 
				penelope_crcase_audtc c 
				left join [db-au-stage].dbo.penelope_case_funder_audtc cf 
					on cf.kcaseid = c.kcaseid 
				outer apply (
					select top 1 FunderSK
					from [db-au-dtc].dbo.pnpFunder
					where FunderID = convert(varchar, cf.kfunderid) 
						and IsCurrent = 1
				) f
				outer apply (
					select top 1 FunderDepartmentSK
					from [db-au-dtc].dbo.pnpFunderDepartment
					where FunderDepartmentID = convert(varchar, cf.kfunderdeptid) 
				) fd
				left join penelope_sscasestatus_audtc cs on cs.kcasestatusid = c.kcasestatusid
				left join penelope_lurelationshipstatus_audtc rs on rs.lurelationshipstatusid = c.lucasrelstatusid
				left join penelope_lufamilystatus_audtc fs on fs.lufamilystatusid = c.lucasfamilystatusid
				left join penelope_lujobimpact_audtc ji on ji.lujobimpactid = c.lucasjobimpactid
				left join penelope_luthreatoviolence_audtc tv on tv.luthreatoviolenceid = c.lucasthreatid

			select @sourcecount = count(*) from #src1

			merge [db-au-dtc].dbo.pnpCase as tgt
			using #src1
				on #src1.CaseID = tgt.CaseID
			when matched then 
				update set 
					tgt.FunderSK = #src1.FunderSK,
					tgt.FunderDepartmentSK = #src1.FunderDepartmentSK,
					tgt.FunderID = #src1.FunderID,
					tgt.FunderDepartmentID = #src1.FunderDepartmentID,
					tgt.NickName = #src1.NickName,
					tgt.[Status] = #src1.[Status],
					tgt.Setting = #src1.Setting,
					tgt.HouseholdIncome = #src1.HouseholdIncome,
					tgt.RelationshipStatus = #src1.RelationshipStatus,
					tgt.FamilyStatus = #src1.FamilyStatus,
					tgt.casreldate = #src1.casreldate,
					tgt.casblendedf = #src1.casblendedf,
					tgt.casotherinhome = #src1.casotherinhome,
					tgt.Accomodations = #src1.Accomodations,
					tgt.casneap1 = #src1.casneap1,
					tgt.JobImpact = #src1.JobImpact,
					tgt.ViolenceThreat = #src1.ViolenceThreat,
					tgt.FamilySize = #src1.FamilySize,
					tgt.UpdatedDatetime = #src1.UpdatedDatetime,
					tgt.UpdatedBy = #src1.UpdatedBy,
					tgt.FileNumber = #src1.FileNumber,
					tgt.UpdatedForRealDatetime = #src1.UpdatedForRealDatetime
			when not matched by target then 
				insert (
					FunderSK,
					FunderDepartmentSK,
					CaseID,
					FunderID,
					FunderDepartmentID,
					NickName,
					[Status],
					Setting,
					HouseholdIncome,
					RelationshipStatus,
					FamilyStatus,
					casreldate,
					casblendedf,
					casotherinhome,
					Accomodations,
					casneap1,
					JobImpact,
					ViolenceThreat,
					FamilySize,
					CreatedDatetime,
					UpdatedDatetime,
					CreatedBy,
					UpdatedBy,
					FileNumber,
					UpdatedForRealDatetime
				)
				values (
					#src1.FunderSK,
					#src1.FunderDepartmentSK,
					#src1.CaseID,
					#src1.FunderID,
					#src1.FunderDepartmentID,
					#src1.NickName,
					#src1.[Status],
					#src1.Setting,
					#src1.HouseholdIncome,
					#src1.RelationshipStatus,
					#src1.FamilyStatus,
					#src1.casreldate,
					#src1.casblendedf,
					#src1.casotherinhome,
					#src1.Accomodations,
					#src1.casneap1,
					#src1.JobImpact,
					#src1.ViolenceThreat,
					#src1.FamilySize,
					#src1.CreatedDatetime,
					#src1.UpdatedDatetime,
					#src1.CreatedBy,
					#src1.UpdatedBy,
					#src1.FileNumber,
					#src1.UpdatedForRealDatetime
				)
			output $action into @mergeoutput;

			select
				@insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
				@updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
			from
				@mergeoutput

			delete from @mergeoutput
		end

		
		if object_id('[db-au-stage].dbo.penelope_crintake_audtc') is not null
		begin 
			if object_id('tempdb..#src2') is not null drop table #src2

			select 
				convert(varchar, i.kcaseid) as CaseID,
				i.itsummary as Summary,
				pigc1.presissuegroupclass as PresentingIssueGroupClass1,
				pig1.presissuegroup as PresentingIssueGroup1,
				pi1.presissue as PresentingIssue1,
				pigc2.presissuegroupclass as PresentingIssueGroupClass2,
				pig2.presissuegroup as PresentingIssueGroup2,
				pi2.presissue as PresentingIssue2,
				pigc3.presissuegroupclass as PresentingIssueGroupClass3,
				pig3.presissuegroup as PresentingIssueGroup3,
				pi3.presissue as PresentingIssue3,
				pigc4.presissuegroupclass as PresentingIssueGroupClass4,
				pig4.presissuegroup as PresentingIssueGroup4,
				pi4.presissue as PresentingIssue4,
				pigc5.presissuegroupclass as PresentingIssueGroupClass5,
				pig5.presissuegroup as PresentingIssueGroup5,
				pi5.presissue as PresentingIssue5,
				i.itreopen as Reopen,
				i.itdatereopen as ReopenDatetime,
				i.itformalref as FormalRef,
				i.itreferraldate as ReferralDatetime,
				r.referral as Referral,
				i.slogin as CaseIntakeCreatedDatetime,
				i.slogmod as CaseIntakeUpdatedDatetime,
				i.sloginby as CaseIntakeCreatedBy,
				i.slogmodby as CaseIntakeUpdatedBy
			into #src2
			from
				penelope_crintake_audtc i
				left join penelope_sapresentingiss_audtc pi1 on pi1.kpresissueid = i.luit1presissueid
				left join penelope_sapresissuegroup_audtc pig1 on pig1.kpresissuegroupid = pi1.kpresissuegroup
				left join penelope_sspresissuegroupclass_audtc pigc1 on pigc1.kpresissuegroupclassid = pig1.kpresissuegroupclassid
				left join penelope_sapresentingiss_audtc pi2 on pi2.kpresissueid = i.luit2presissueid
				left join penelope_sapresissuegroup_audtc pig2 on pig2.kpresissuegroupid = pi2.kpresissuegroup
				left join penelope_sspresissuegroupclass_audtc pigc2 on pigc2.kpresissuegroupclassid = pig2.kpresissuegroupclassid
				left join penelope_sapresentingiss_audtc pi3 on pi3.kpresissueid = i.luit3presissueid
				left join penelope_sapresissuegroup_audtc pig3 on pig3.kpresissuegroupid = pi3.kpresissuegroup
				left join penelope_sspresissuegroupclass_audtc pigc3 on pigc3.kpresissuegroupclassid = pig3.kpresissuegroupclassid
				left join penelope_sapresentingiss_audtc pi4 on pi4.kpresissueid = i.luit4presissueid
				left join penelope_sapresissuegroup_audtc pig4 on pig4.kpresissuegroupid = pi4.kpresissuegroup
				left join penelope_sspresissuegroupclass_audtc pigc4 on pigc4.kpresissuegroupclassid = pig4.kpresissuegroupclassid
				left join penelope_sapresentingiss_audtc pi5 on pi5.kpresissueid = i.luit5presissueid
				left join penelope_sapresissuegroup_audtc pig5 on pig5.kpresissuegroupid = pi5.kpresissuegroup
				left join penelope_sspresissuegroupclass_audtc pigc5 on pigc5.kpresissuegroupclassid = pig5.kpresissuegroupclassid
				left join penelope_lureferral_audtc r on r.lureferralid = i.luitreferralid

			select @sourcecount = @sourcecount + count(*) from #src2

			merge [db-au-dtc].dbo.pnpCase as tgt
			using #src2
				on #src2.CaseID = tgt.CaseID
			when matched then 
				update set 
					tgt.Summary = #src2.Summary,
					tgt.PresentingIssueGroupClass1 = #src2.PresentingIssueGroupClass1,
					tgt.PresentingIssueGroup1 = #src2.PresentingIssueGroup1,
					tgt.PresentingIssue1 = #src2.PresentingIssue1,
					tgt.PresentingIssueGroupClass2 = #src2.PresentingIssueGroupClass2,
					tgt.PresentingIssueGroup2 = #src2.PresentingIssueGroup2,
					tgt.PresentingIssue2 = #src2.PresentingIssue2,
					tgt.PresentingIssueGroupClass3 = #src2.PresentingIssueGroupClass3,
					tgt.PresentingIssueGroup3 = #src2.PresentingIssueGroup3,
					tgt.PresentingIssue3 = #src2.PresentingIssue3,
					tgt.PresentingIssueGroupClass4 = #src2.PresentingIssueGroupClass4,
					tgt.PresentingIssueGroup4 = #src2.PresentingIssueGroup4,
					tgt.PresentingIssue4 = #src2.PresentingIssue4,
					tgt.PresentingIssueGroupClass5 = #src2.PresentingIssueGroupClass5,
					tgt.PresentingIssueGroup5 = #src2.PresentingIssueGroup5,
					tgt.PresentingIssue5 = #src2.PresentingIssue5,
					tgt.Reopen = #src2.Reopen,
					tgt.ReopenDatetime = #src2.ReopenDatetime,
					tgt.FormalRef = #src2.FormalRef,
					tgt.ReferralDatetime = #src2.ReferralDatetime,
					tgt.Referral = #src2.Referral,
					tgt.CaseIntakeCreatedDatetime = #src2.CaseIntakeCreatedDatetime,
					tgt.CaseIntakeUpdatedDatetime = #src2.CaseIntakeUpdatedDatetime,
					tgt.CaseIntakeCreatedBy = #src2.CaseIntakeCreatedBy,
					tgt.CaseIntakeUpdatedBy = #src2.CaseIntakeUpdatedBy
			when not matched by target then 
				insert (
					CaseID,
					Summary,
					PresentingIssueGroupClass1,
					PresentingIssueGroup1,
					PresentingIssue1,
					PresentingIssueGroupClass2,
					PresentingIssueGroup2,
					PresentingIssue2,
					PresentingIssueGroupClass3,
					PresentingIssueGroup3,
					PresentingIssue3,
					PresentingIssueGroupClass4,
					PresentingIssueGroup4,
					PresentingIssue4,
					PresentingIssueGroupClass5,
					PresentingIssueGroup5,
					PresentingIssue5,
					Reopen,
					ReopenDatetime,
					FormalRef,
					ReferralDatetime,
					Referral,
					CaseIntakeCreatedDatetime,
					CaseIntakeUpdatedDatetime,
					CaseIntakeCreatedBy,
					CaseIntakeUpdatedBy
				)
				values (
					#src2.CaseID,
					#src2.Summary,
					#src2.PresentingIssueGroupClass1,
					#src2.PresentingIssueGroup1,
					#src2.PresentingIssue1,
					#src2.PresentingIssueGroupClass2,
					#src2.PresentingIssueGroup2,
					#src2.PresentingIssue2,
					#src2.PresentingIssueGroupClass3,
					#src2.PresentingIssueGroup3,
					#src2.PresentingIssue3,
					#src2.PresentingIssueGroupClass4,
					#src2.PresentingIssueGroup4,
					#src2.PresentingIssue4,
					#src2.PresentingIssueGroupClass5,
					#src2.PresentingIssueGroup5,
					#src2.PresentingIssue5,
					#src2.Reopen,
					#src2.ReopenDatetime,
					#src2.FormalRef,
					#src2.ReferralDatetime,
					#src2.Referral,
					#src2.CaseIntakeCreatedDatetime,
					#src2.CaseIntakeUpdatedDatetime,
					#src2.CaseIntakeCreatedBy,
					#src2.CaseIntakeUpdatedBy
				)
			output $action into @mergeoutput;

			select
				@insertcount = @insertcount + sum(case when MergeAction = 'insert' then 1 else 0 end),
				@updatecount = @updatecount + sum(case when MergeAction = 'update' then 1 else 0 end)
			from
				@mergeoutput

			
			-- update CostCentre and InvoiceText
			update c set
				c.CostCentre = e.caseexp1,
                c.InvoiceText = [dbo].xfn_StripHTML(e.caseexp9) 
				--c.InvoiceText = [dbo].[udf_StripHTML](e.caseexp9) 
			from 
				[db-au-dtc].dbo.pnpCase c 
				join penelope_crcaseexp_audtc e on convert(varchar, e.kcaseid) = c.CaseID 

		end

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

		exec syssp_genericerrorhandler
			@SourceInfo = 'data refresh failed',
			@LogToTable = 1,
			@ErrorCode = '-100',
			@BatchID = @batchid,
			@PackageID = @name

		if @@trancount > 0
			rollback transaction

	end catch

	if @@trancount > 0
		commit transaction

END


GO
