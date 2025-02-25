USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpDocumentDomain]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpDocumentDomain
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpDocumentDomain] 
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

	if object_id('[db-au-dtc].dbo.pnpDocumentDomain') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpDocumentDomain](
			DocumentDomainSK int identity(1,1) primary key,
			DocumentMasterSK int,
			DocumentDomainID int,
			Domain nvarchar(100),
			Comments nvarchar(max),
			AssessmentCalculation nvarchar(100),
			DomainNRLimit int,
			ScoreGroup nvarchar(30),
			ParentDocumentDomainID int,
			Mean numeric(12,4),
			SD numeric(12,4),
			ShowZScore varchar(5),
			StoreZScore varchar(5),
			Threshold numeric(12,4),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreateUserID int,
			UpdateUserID int,
			DocumentMasterID int,
			Class nvarchar(20)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			dm.DocumentMasterSK,
			d.kdomainid as DocumentDomainID,
			d.domain as Domain,
			d.domcomments as Comments,
			ac.assesscalc as AssessmentCalculation,
			d.domnrlimit as DomainNRLimit,
			sg.scoregroup as ScoreGroup,
			d.kdomainidpar as ParentDocumentDomainID,
			d.dommean as Mean,
			d.domsd as SD,
			d.showzscore as ShowZScore,
			d.storezscore as StoreZScore,
			d.domthreshold as Threshold,
			d.slogin as CreatedDatetime,
			d.slogmod as UpdatedDatetime,
			d.kuseridlogin as CreateUserID,
			d.kuseridlogmod as UpdateUserID,
			d.kdocmastid as DocumentMasterID,
			dc.domainclass as Class
		into #src
		from 
			penelope_drdomain_audtc d 
			left join penelope_ssassesscalc_audtc ac on ac.kassesscalcid = d.kassesscalcid
			left join penelope_sascoregroup_audtc sg on sg.kscoregroupid = d.kscoregroupid
			left join penelope_ssdomainclass_audtc dc on dc.kdomainclassid = d.kdomainclassid
			outer apply (
				select top 1 DocumentMasterSK
				from [db-au-dtc].dbo.pnpDocumentMaster
				where DocumentMasterID = d.kdocmastid
			) dm
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpDocumentDomain as tgt
		using #src
			on #src.DocumentDomainID = tgt.DocumentDomainID
		when matched then 
			update set 
				tgt.DocumentMasterSK = #src.DocumentMasterSK,
				tgt.Domain = #src.Domain,
				tgt.Comments = #src.Comments,
				tgt.AssessmentCalculation = #src.AssessmentCalculation,
				tgt.DomainNRLimit = #src.DomainNRLimit,
				tgt.ScoreGroup = #src.ScoreGroup,
				tgt.ParentDocumentDomainID = #src.ParentDocumentDomainID,
				tgt.Mean = #src.Mean,
				tgt.SD = #src.SD,
				tgt.ShowZScore = #src.ShowZScore,
				tgt.StoreZScore = #src.StoreZScore,
				tgt.Threshold = #src.Threshold,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdateUserID = #src.UpdateUserID,
				tgt.DocumentMasterID = #src.DocumentMasterID,
				tgt.Class = #src.Class
		when not matched by target then 
			insert (
				DocumentMasterSK,
				DocumentDomainID,
				Domain,
				Comments,
				AssessmentCalculation,
				DomainNRLimit,
				ScoreGroup,
				ParentDocumentDomainID,
				Mean,
				SD,
				ShowZScore,
				StoreZScore,
				Threshold,
				CreatedDatetime,
				UpdatedDatetime,
				CreateUserID,
				UpdateUserID,
				DocumentMasterID,
				Class
			)
			values (
				#src.DocumentMasterSK,
				#src.DocumentDomainID,
				#src.Domain,
				#src.Comments,
				#src.AssessmentCalculation,
				#src.DomainNRLimit,
				#src.ScoreGroup,
				#src.ParentDocumentDomainID,
				#src.Mean,
				#src.SD,
				#src.ShowZScore,
				#src.StoreZScore,
				#src.Threshold,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreateUserID,
				#src.UpdateUserID,
				#src.DocumentMasterID,
				#src.Class
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
