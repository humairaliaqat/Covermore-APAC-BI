USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpPolicyMember]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpPolicyMember
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpPolicyMember] 
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

	if object_id('[db-au-dtc].dbo.pnpPolicyMember') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpPolicyMember](
			PolicyMemberSK int identity(1,1) primary key,
			PolicySK int,
			IndividualSK int,
			FunderSK int,
			FunderDepartmentSK int,
			CoverByPolicyMemberSK int,
			PolicyMemberID varchar(100),
			PolicyID varchar(50),
			IndividualID varchar(50),
			FunderID varchar(50),
			CoverByPolicyMemberID varchar(100),
			Relationship nvarchar(25),
			RelationshipCode nchar(3),
			RelationshipCode2 nvarchar(3),
			[Status] varchar(5),
			MemberNumber nvarchar(20),
			MemberGNumber nvarchar(20),
			Notes nvarchar(4000),
			CreatedDatetime datetime2(7),
			UpdatedDatetime datetime2(7),
			MemberNumberType nvarchar(25),
			PolicyMemberIDPrim int,
			InsranceTypeCode2 nvarchar(5),
			InsranceTypeCode2Description nvarchar(70),
			CreatedBy nvarchar(20),
			UpdatedBy nvarchar(20),
			FunderDepartmentID varchar(50),
			index idx_pnpPolicyMember_PolicyMemberID nonclustered (PolicyMemberID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			p.PolicySK,
			i.IndividualSK,
			--i.FunderSK,--commented and next line added by Ratnesh on 14sep18 for bug fix
			pfd.FunderSK,
			--i.FunderDepartmentSK,--commented and next line added by Ratnesh on 14sep18 for bug fix
			pfd.FunderDepartmentSK,
			convert(varchar, pm.kpolicymemid) as PolicyMemberID,
			convert(varchar, pm.kpolicyid) as PolicyID,
			convert(varchar, pm.kindid) as IndividualID,
			i.FunderID,
			convert(varchar, pm.kpolicycoverbyid) as CoverByPolicyMemberID,
			pr.policyrel as Relationship,
			ltrim(rtrim(pr.relinscode)) as RelationshipCode,
			pr.relinscode2 as RelationshipCode2,
			pm.polmemstatus as [Status],
			pm.polmemno as MemberNumber,
			pm.polmemgno as MemberGNumber,
			pm.polmemnote as Notes,
			pm.slogin as CreatedDatetime,
			pm.slogmod as UpdatedDatetime,
			mnt.memnodesc as MemberNumberType,
			pm.kpolicymemidpirm as PolicyMemberIDPrim,
			itc2.instypecode2 as InsranceTypeCode2,
			itc2.instypecode2desc as InsranceTypeCode2Description,
			pm.sloginby as CreatedBy,
			pm.slogmodby as UpdatedBy,
			convert(varchar, pm.kfunderdeptid) as FunderDepartmentID
		into #src
		from 
			penelope_aifpolicymem_audtc pm
			left join penelope_sspolicyrel_audtc pr on pr.kpolicyrelid = pm.kpolicyrelid
			left join penelope_ssmemnotype_audtc mnt on mnt.kmemnotypeid = pm.kmemnotypeid
			left join penelope_ssinstypecode2_audtc itc2 on itc2.kinstypecode2id = pm.kinstypecode2id
			left join [db-au-dtc]..pnpFunderDepartment pfd on convert(varchar, pm.kfunderdeptid)=pfd.FunderDepartmentID--added by Ratnesh on 14sep18 for bug fix
			outer apply (
				select top 1 PolicySK
				from [db-au-dtc].dbo.pnpPolicy
				where PolicyID = convert(varchar, pm.kpolicyid)
			) p
			outer apply (
				select top 1 IndividualSK, FunderSK, FunderDepartmentSK, FunderID
				from [db-au-dtc].dbo.pnpIndividual
				where IndividualID = convert(varchar, pm.kindid) 
					and IsCurrent = 1
			) i
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpPolicyMember as tgt
		using #src
			on #src.PolicyMemberID = tgt.PolicyMemberID
		when matched then 
			update set 
				tgt.PolicySK = #src.PolicySK,
				tgt.IndividualSK = #src.IndividualSK,
				tgt.FunderSK = #src.FunderSK,
				tgt.FunderDepartmentSK = #src.FunderDepartmentSK,
				tgt.PolicyID = #src.PolicyID,
				tgt.IndividualID = #src.IndividualID,
				tgt.FunderID = #src.FunderID,
				tgt.CoverByPolicyMemberID = #src.CoverByPolicyMemberID,
				tgt.Relationship = #src.Relationship,
				tgt.RelationshipCode = #src.RelationshipCode,
				tgt.RelationshipCode2 = #src.RelationshipCode2,
				tgt.[Status] = #src.[Status],
				tgt.MemberNumber = #src.MemberNumber,
				tgt.MemberGNumber = #src.MemberGNumber,
				tgt.Notes = #src.Notes,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.MemberNumberType = #src.MemberNumberType,
				tgt.PolicyMemberIDPrim = #src.PolicyMemberIDPrim,
				tgt.InsranceTypeCode2 = #src.InsranceTypeCode2,
				tgt.InsranceTypeCode2Description = #src.InsranceTypeCode2Description,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.FunderDepartmentID = #src.FunderDepartmentID
		when not matched by target then 
			insert (
				PolicySK,
				IndividualSK,
				FunderSK,
				FunderDepartmentSK,
				PolicyMemberID,
				PolicyID,
				IndividualID,
				FunderID,
				CoverByPolicyMemberID,
				Relationship,
				RelationshipCode,
				RelationshipCode2,
				[Status],
				MemberNumber,
				MemberGNumber,
				Notes,
				CreatedDatetime,
				UpdatedDatetime,
				MemberNumberType,
				PolicyMemberIDPrim,
				InsranceTypeCode2,
				InsranceTypeCode2Description,
				CreatedBy,
				UpdatedBy,
				FunderDepartmentID
			)
			values (
				#src.PolicySK,
				#src.IndividualSK,
				#src.FunderSK,
				#src.FunderDepartmentSK,
				#src.PolicyMemberID,
				#src.PolicyID,
				#src.IndividualID,
				#src.FunderID,
				#src.CoverByPolicyMemberID,
				#src.Relationship,
				#src.RelationshipCode,
				#src.RelationshipCode2,
				#src.[Status],
				#src.MemberNumber,
				#src.MemberGNumber,
				#src.Notes,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.MemberNumberType,
				#src.PolicyMemberIDPrim,
				#src.InsranceTypeCode2,
				#src.InsranceTypeCode2Description,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.FunderDepartmentID
			)

		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		-- CoverByPolicyMemberSK
		update [db-au-dtc].dbo.pnpPolicyMember
		set CoverByPolicyMemberSK = cbpm.CoverByPolicyMemberSK
		from [db-au-dtc].dbo.pnpPolicyMember pm1
			outer apply (
				select top 1 PolicyMemberSK as CoverByPolicyMemberSK
				from [db-au-dtc].dbo.pnpPolicyMember pm2
				where pm1.CoverByPolicyMemberID = pm2.PolicyMemberID
			) cbpm

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


    --select 
    --    sf.ServiceFileSK,
    --    sf.ServiceFileID,
    --    s.Stream,
    --    old.Department,
    --    new.Department
    update sf
    set
        sf.FunderDepartmentID = new.FunderDepartmentID,
        sf.FunderDepartmentSK = new.FunderDepartmentSK
    from
        [db-au-dtc]..pnpServiceFile sf
        inner join [db-au-dtc]..pnpService s on
            s.ServiceSK = sf.ServiceSK
        cross apply
        (
            select top 1
                bs.BillSeq,
                pm.FunderID,
                pm.FunderSK,
                pm.FunderDepartmentID,
                pm.FunderDepartmentSK
            from
                [db-au-dtc]..pnpBillSeq bs
                inner join [db-au-dtc]..pnpPolicyMember pm on
                    pm.PolicyMemberSK = bs.PolicyMemberSK
            where
                bs.ServiceFileSK = sf.ServiceFileSK and
                bs.BillSeq = 1
        ) bs
        --left join [db-au-dtc]..pnpFunderDepartment old on 
        --    old.FunderDepartmentSK = sf.FunderDepartmentSK
        inner join [db-au-dtc]..pnpFunderDepartment new on 
            new.FunderDepartmentID = bs.FunderDepartmentID
    where
        isnull(sf.FunderDepartmentSK, 0) <> new.FunderDepartmentSK and
        s.Stream not in ('Trauma') and
        sf.ServiceFileID not like 'CLI%'




END


GO
