USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpBillSeq]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpBillSeq
-- Modification:
--		*20180423 DM - Adjusted code to remove Billing Sequences which no longer exist.
--		*20180809 DM - Add code to update the Funder and Funder Department based upon the Billing Seq from Penelope.
--		*20181108 DM - Moved code to update the Trauma Department overrides from [etlsp_ETL083_pnpServiceFile].
--		*20181115 DM - Added update to Service File Funder & Department from Clientele where exist in Penelope but no Billing Sequence exists. Uses Clientele Data
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpBillSeq] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpBillSeq') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpBillSeq](
			PolicyMemberSK int, 
			ServiceFileSK int, 
			PolicySK int, 
			PolicyMemberID varchar(100), 
			ServiceFileID varchar(50), 
			PolicyID varchar(50), 
			BillSeq int, 
			CreatedDatetime datetime2, 
			UpdatedDatetime datetime2, 
			primary key (PolicyMemberID, ServiceFileID) 
	)
	end;

	if object_id('[db-au-stage].dbo.penelope_btbillseq_audtc') is null
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
			pm.PolicyMemberSK,
			sf.ServiceFileSK,
			pm.PolicySK,
			convert(varchar, kpolicymemid) as PolicyMemberID,
			convert(varchar, kprogprovid) as ServiceFileID,
			convert(varchar, pm.PolicyID) as PolicyID,
			billseq as BillSeq,
			slogin as CreatedDatetime,
			slogmod as UpdatedDatetime
		into #src
		from 
			penelope_btbillseq_audtc bs
			outer apply (
				select top 1 PolicyMemberSK, PolicySK, PolicyID
				from [db-au-dtc]..pnpPolicyMember
				where PolicyMemberID = convert(varchar, bs.kpolicymemid)
			) pm
			outer apply (
				select top 1 ServiceFileSK
				from [db-au-dtc]..pnpServiceFile
				where ServiceFileID = convert(varchar, bs.kprogprovid)
			) sf


		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpBillSeq as tgt
		using #src
			on #src.PolicyMemberID = tgt.PolicyMemberID and #src.ServiceFileID = tgt.ServiceFileID
		when matched then 
			update set 
				tgt.PolicyMemberSK = #src.PolicyMemberSK,
				tgt.ServiceFileSK = #src.ServiceFileSK,
				tgt.PolicySK = #src.PolicySK,
				tgt.PolicyID = #src.PolicyID,
				tgt.BillSeq = #src.BillSeq,
				tgt.UpdatedDatetime = #src.UpdatedDatetime
		when not matched by target then 
			insert (
				PolicyMemberSK,
				ServiceFileSK,
				PolicySK,
				PolicyMemberID,
				ServiceFileID,
				PolicyID,
				BillSeq,
				CreatedDatetime,
				UpdatedDatetime
			)
			values (
				#src.PolicyMemberSK,
				#src.ServiceFileSK,
				#src.PolicySK,
				#src.PolicyMemberID,
				#src.ServiceFileID,
				#src.PolicyID,
				#src.BillSeq,
				#src.CreatedDatetime,
				#src.UpdatedDatetime
			)
		--MOD 20180423
		when not matched by source then delete
			
		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		/* MOD: 20180809 the code below was entered to update all Funders and Departments for ALL Penelope Service files. */
		UPDATE sf
		set FunderSK = bs.FunderSK,
			FunderID = bs.FunderID,
			FunderDepartmentSK = bs.FunderDepartmentSK,
			FunderDepartmentID = bs.FunderDepartmentID
		--select sf.ServiceFileID, sf.FunderSK, bs.FunderSK, sf.FunderDepartmentSK, bs.FunderDepartmentSK, bs.*
		from [db-au-dtc].dbo.pnpServiceFile sf
		left join 
			(select bs.ServiceFileSK, p.FunderSK, p.FunderID, pm.FunderDepartmentSK, pm.FunderDepartmentID, row_number() over(partition by bs.ServiceFileSK order by bs.billseq) rn
				from [db-au-dtc].dbo.pnpBillSeq bs
				LEFT join [db-au-dtc].dbo.pnpPolicy p on bs.PolicySK = p.PolicySK
				LEFT join [db-au-dtc].dbo.pnpPolicyMember pm on bs.PolicyMemberSK = pm.PolicyMemberSK
			) bs on sf.ServiceFileSK = bs.ServiceFileSK and bs.rn = 1
		where sf.ServiceFileID not like 'CLI%'
		and (isNUll(sf.FunderSK,'') <> isNull(bs.FunderSK,'') 
			OR isNull(sf.FunderDepartmentSK,'') <> isNull(bs.FunderDepartmentSK,''))

		--MOD: 20181115 - Update Service File's from Clientele where exist in Penelope but no Billing Sequence exists. Using Clientele Data
		update sf
		set sf.FunderID = F.FunderID,
			sf.FunderSK = F.FunderSK,
			sf.FunderDepartmentID = fd.FunderDepartmentID,
			sf.FunderDepartmentSK = fd.FunderDepartmentSK
		--select sf.Service, J.Job_Num, p.SubLevel_ID, P.Group_ID, gp.*, sfl.kprogprovid, ol.kfunderid, sf.ServiceFileID, sf.FunderID, sf.FunderSK, sf.FunderDepartmentID, Sf.FunderDepartmentSK, f.Funder, fd.Department
		from [db-au-stage].dbo.dtc_cli_Job J
		JOIN [db-au-stage].dbo.dtc_cli_Base_Job bj on J.Job_ID = bj.Job_id
		JOIN [db-au-stage].dbo.dtc_cli_Base_Org bo on J.Org_ID = bo.Org_id
		LEFT JOIN [db-au-stage].dbo.dtc_cli_Person p on J.Per_id = P.Per_id
		left JOIN [db-au-stage].dbo.dtc_cli_Base_Group gp on Nullif(isNull(NUllif(nullif(P.SubLevel_ID,'0z0'),'0'), p.Group_id),'0') = gp.Group_id
		JOIN [db-au-stage].dbo.dtc_cli_ServiceFile_Lookup sfl on bj.Pene_id = sfl.uniquecaseid
		JOIN [db-au-stage].dbo.dtc_cli_Org_Lookup ol on bo.Pene_id = ol.uniquefunderid
		left join [db-au-stage].dbo.dtc_cli_Group_Lookup gl on gp.Pene_id = gl.uniquedepartmentid
		JOIN [db-au-dtc].dbo.pnpServiceFile sf on CAST(sfl.kprogprovid as varchar) = sf.ServiceFileID
		JOIN [db-au-dtc].dbo.pnpFunder F on CAST(ol.kfunderid as varchar) = f.FunderID AND IsCurrent = 1
		left join [db-au-dtc].dbo.pnpFunderDepartment fd on cast(gl.kfunderdeptid as varchar) = fd.FunderDepartmentID AND f.FunderSK = fd.FunderSK
		where not exists (select 1 from [db-au-dtc].dbo.pnpBillSeq bs where sf.ServiceFileSK = bs.ServiceFileSK)


		--20180124, LL, update trauma's business unit based upon overrides
		--20181108, DM, moved from [etlsp_ETL083_pnpServiceFile]
		update sf
		set
			sf.FunderDepartmentSK = d.FunderDepartmentSK,
			sf.FunderDepartmentID = d.FunderDepartmentID
		from
			penelopeDataMart_pen_CaseInvoicePerson_audtc t
			inner join [db-au-dtc]..pnpFunderDepartment d on
				d.FunderDepartmentID = convert(varchar, t.DepartmentID)
			inner join [db-au-dtc]..pnpServiceFile sf on
				sf.CaseID = convert(varchar, t.CaseID)

		update c
		set
			c.FunderDepartmentSK = d.FunderDepartmentSK,
			c.FunderDepartmentID = d.FunderDepartmentID
		from
			penelopeDataMart_pen_CaseInvoicePerson_audtc t
			inner join [db-au-dtc]..pnpFunderDepartment d on
				d.FunderDepartmentID = convert(varchar, t.DepartmentID)
			inner join [db-au-dtc]..pnpCase c on
				c.CaseID = convert(varchar, t.CaseID)


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
