USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_202_FunderDepartment]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_202_FunderDepartment] 
AS
BEGIN

	SET NOCOUNT ON;

	-- Groups => FunderDepartment

	if object_id('tempdb..#src') is not null drop table #src
	select * into #src 
	from (
		select 
			IsNull(f.FunderSK,f1.funderSK) funderSK,
			'CLI_GRP_' + g.Group_ID FunderDepartmentID,
			'CLI_GRP_' + g.Parent_Group_Id ParentDepartmentID,
			g.GroupName Department,
			g.AddDate CreatedDatetime,
			g.ChangeDate UpdatedDatetime,
			(select * from [db-au-stage]..dtc_cli_group i where i.group_ID = g.group_ID for json path, without_array_wrapper) [Description],
			case when g.Inactive = -1 then 'Inactive' else 'Active' end [State],
			g.Level + 1 DepartmentLevel 
		from 
			[db-au-stage]..dtc_cli_group g 
			left join [db-au-stage]..dtc_cli_base_group bg on bg.group_id = g.group_id 
			left join [db-au-stage]..dtc_cli_group_lookup gl on gl.uniquedepartmentid = bg.pene_id 
			outer apply (
				select top 1 FunderSK
				from [db-au-dtc]..usrClientMapping M
				join [db-au-dtc]..pnpFunder f on M.FunderID = F.FunderID AND F.IsCurrent = 1
				where M.OrganisationID = g.Org_id --FunderID = 'CLI_ORG_' + g.Org_ID and IsCurrent = 1
			) f
			outer apply (
				select top 1 FunderSK
				from [db-au-dtc]..pnpFunder f 
				where f.FunderID = 'CLI_ORG_' + g.Org_ID and IsCurrent = 1
			) f1
		where
			gl.kfunderdeptid is null	-- exclude the ones that have already been imported
	) a

	-- if parent is inactive, then set to inactive
	update c
	set [State] = 'Inactive'
	from #src p
	join #src c on p.FunderDepartmentID = c.ParentDepartmentID
	where p.[State] = 'Inactive'


	merge [db-au-dtc]..pnpFunderDepartment as tgt
	using #src
		on #src.FunderDepartmentID = tgt.FunderDepartmentID
	when not matched then 
		insert (
			FunderSK,
			FunderDepartmentID,
			ParentDepartmentID,
			Department,
			CreatedDatetime,
			UpdatedDatetime,
			[Description],
			[State],
			DepartmentLevel
		)
		values (
			#src.FunderSK,
			#src.FunderDepartmentID,
			#src.ParentDepartmentID,
			#src.Department,
			#src.CreatedDatetime,
			#src.UpdatedDatetime,
			#src.[Description],
			#src.[State],
			#src.DepartmentLevel
		)
	when matched then update set
		tgt.FunderSK = #src.FunderSK,
		tgt.FunderDepartmentID = #src.FunderDepartmentID,
		tgt.ParentDepartmentID = #src.ParentDepartmentID,
		tgt.Department = #src.Department,
		tgt.CreatedDatetime = #src.CreatedDatetime,
		tgt.UpdatedDatetime = #src.UpdatedDatetime,
		tgt.[Description] = #src.[Description],
		tgt.[State] = #src.[State],
		tgt.DepartmentLevel= #src.DepartmentLevel
	;


	-- Lookup ParentDepartmentSK
	update fd
	set ParentDepartmentSK = pd.ParentDepartmentSK
	from [db-au-dtc]..pnpFunderDepartment fd 
		outer apply (
			select top 1 FunderDepartmentSK as ParentDepartmentSK
			from [db-au-dtc].dbo.pnpFunderDepartment
			where FunderDepartmentID = fd.ParentDepartmentID
		) pd
	where ParentDepartmentID is not null


END
GO
