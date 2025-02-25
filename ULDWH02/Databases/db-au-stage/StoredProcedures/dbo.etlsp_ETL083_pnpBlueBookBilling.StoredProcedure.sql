USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpBlueBookBilling]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-09-18
-- Description:	Transformation - pnpBlueBookBilling
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpBlueBookBilling] 
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

	if object_id('[db-au-dtc].dbo.pnpBlueBookBilling') is null
		create table [db-au-dtc].[dbo].[pnpBlueBookBilling](
			BlueBookBillingSK int identity(1,1) primary key,
			BlueBookSK int,
            PolicySK int,
			FunderSK int,
			FunderDepartmentSK int,
            BlueBookID int,
			PolicyID varchar(50),
			PublicPolicyID varchar(50),
			FunderID varchar(50),
			FunderDepartmentID varchar(50),
			UseForBillTo varchar(5),
			UserForCC varchar(5),
			index idx_pnpBlueBookBilling_BlueBookSK nonclustered (BlueBookSK),
			index idx_pnpBlueBookBilling_BlueBookID nonclustered (BlueBookID),
			index idx_pnpBlueBookBilling_PolicySK nonclustered (PolicySK),
			index idx_pnpBlueBookBilling_PolicyID nonclustered (PolicyID),
			index idx_pnpBlueBookBilling_PublicPolicyID nonclustered (PublicPolicyID),
			index idx_pnpBlueBookBilling_FunderSK nonclustered (FunderSK),
			index idx_pnpBlueBookBilling_FunderID nonclustered (FunderID),
			index idx_pnpBlueBookBilling_FunderDepartmentSK nonclustered (FunderDepartmentSK),
			index idx_pnpBlueBookBilling_FunderDepartmentID nonclustered (FunderDepartmentID)			
		)


	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			bb.BlueBookSK,
			p.PolicySK,
			null as FunderSK,
			null as FunderDepartmentSK,
			pb.kbluebookid as BlueBookID,
			convert(varchar, pb.kpolicyid) as PolicyID,
			null as PublicPolicyID,
			null as FunderID,
			null as FunderDepartmentID,
			pb.useforbillto as UseForBillTo,
			pb.useforcc as UserForCC 
		into #src
		from 
			penelope_agibbpolicybilling_audtc pb 
			outer apply (
				select top 1 BlueBookSK 
				from [db-au-dtc]..pnpBlueBook
				where BlueBookID = pb.kbluebookid
			) bb 
			outer apply (
				select top 1 PolicySK 
				from [db-au-dtc]..pnpPolicy 
				where PolicyID = convert(varchar, pb.kpolicyid)
			) p
		union all 
		select 
			bb.BlueBookSK,
			null,
			null,
			null,
			ppb.kbluebookid,
			null,
			convert(varchar, ppb.kpublicpolicyid),
			null,
			null,
			ppb.useforbillto,
			ppb.useforcc
		from 
			penelope_agibbpubpolicybilling_audtc ppb 
			outer apply (
				select top 1 BlueBookSK
				from [db-au-dtc]..pnpBlueBook 
				where BlueBookID = ppb.kbluebookid
			) bb 
		union all
		select 
			bb.BlueBookSK,
			null,
			f.FunderSK,
			null,
			fb.kbluebookid,
			null,
			null,
			convert(varchar, fb.kfunderid),
			null,
			fb.useforbillto,
			fb.useforcc
		from 
			penelope_agibbfunderbilling_audtc fb 
			outer apply (
				select top 1 BlueBookSK
				from [db-au-dtc]..pnpBlueBook 
				where BlueBookID = fb.kbluebookid
			) bb 
			outer apply (
				select top 1 FunderSK 
				from [db-au-dtc]..pnpFunder 
				where FunderID = convert(varchar, fb.kfunderid) and IsCurrent = 1
			) f 
		union all 
		select 
			bb.BlueBookSK,
			null,
			null,
			fd.FunderDepartmentSK,
			fdb.kbluebookid,
			null,
			null,
			null,
			convert(varchar, fdb.kfunderdeptid),
			fdb.useforbillto,
			fdb.useforcc
		from 
			penelope_agibbfunderdeptbilling_audtc fdb 
			outer apply (
				select top 1 BlueBookSK
				from [db-au-dtc]..pnpBlueBook 
				where BlueBookID = fdb.kbluebookid
			) bb 
			outer apply (
				select top 1 FunderDepartmentSK 
				from [db-au-dtc]..pnpFunderDepartment 
				where FunderDepartmentID = convert(varchar, fdb.kfunderdeptid)
			) fd 


		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpBlueBookBilling as tgt
		using #src
			on #src.BlueBookID = tgt.BlueBookID 
				and #src.PolicyID = tgt.PolicyID 
				and #src.PublicPolicyID = tgt.PublicPolicyID
				and #src.FunderID = tgt.FunderID 
				and #src.FunderDepartmentID = tgt.FunderDepartmentID 
		when matched then 
			update set 
				tgt.BlueBookSK = #src.BlueBookSK,
				tgt.PolicySK = #src.PolicySK,
				tgt.FunderSK = #src.FunderSK,
				tgt.FunderDepartmentSK = #src.FunderDepartmentSK,
				tgt.UseForBillTo = #src.UseForBillTo,
				tgt.UserForCC = #src.UserForCC 
		when not matched by target then 
			insert (
				BlueBookSK,
				PolicySK,
				FunderSK,
				FunderDepartmentSK,
				BlueBookID,
				PolicyID,
				PublicPolicyID,
				FunderID,
				FunderDepartmentID,
				UseForBillTo,
				UserForCC
			)
			values (
				#src.BlueBookSK,
				#src.PolicySK,
				#src.FunderSK,
				#src.FunderDepartmentSK,
				#src.BlueBookID,
				#src.PolicyID,
				#src.PublicPolicyID,
				#src.FunderID,
				#src.FunderDepartmentID,
				#src.UseForBillTo,
				#src.UserForCC
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
