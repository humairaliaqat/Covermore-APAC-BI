USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_213_PolicyMember]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- Modifications:
--		20190329 - Adjust logic and remove incorrect CLI_GPR prefix from Department join. Departments were not being matched against imported Departments into Penelope.
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_213_PolicyMember] 
AS
BEGIN

	SET NOCOUNT ON;

	-- Contract => PolicyMember 


	-- 1. transform 
	if object_id('tempdb..#src') is not null drop table #src 	

	select 
		distinct 
		'CLI_CON_' + j.Contract_ID + 'CLI_PER_' + j.Per_ID PolicyMemberID,
		'CLI_CON_' + j.Contract_ID PolicyID, 
		'CLI_PER_' + j.Per_ID IndividualID,
		coalesce(convert(varchar, o.kfunderid), 'CLI_ORG_' + p.Org_ID) FunderID,
		coalesce(convert(varchar, g.kfunderdeptid), 
			'CLI_GRP_'  + case 
				when p.SubLevel_ID <> '0' and p.SubLevel_ID <> '0z0' and p.SubLevel_ID is not null then p.SubLevel_ID 
				else case 
					when p.Group_ID <> '0' and p.Group_ID <> '0z0' and p.Group_ID is not null then p.Group_ID 
					else null 
				end
			end
		) FunderDepartmentID,
		'Holder' Relationship,
		'18' RelationshipCode,
		'G8' RelationshipCode2
	into #src
	from 
		[db-au-stage]..dtc_cli_job j 
		join [db-au-stage]..dtc_cli_Person p 
			on p.Per_ID = j.Per_ID 
		left join [db-au-stage]..dtc_cli_base_org bo -- get funders from custom migration
			on p.Org_ID = bo.Org_ID 
		left join [db-au-stage]..dtc_cli_org_lookup o 
			on o.uniquefunderid = bo.pene_id 
		left join [db-au-stage]..dtc_cli_base_group bg 
			on bg.Group_ID = 
				--mod 20190329: Adjust logic and remove incorrect CLI_GPR prefix from Department join below.
				case 
					when p.SubLevel_ID <> '0' and p.SubLevel_ID <> '0z0' and p.SubLevel_ID is not null then p.SubLevel_ID 
					when p.Group_ID <> '0' and p.Group_ID <> '0z0' and p.Group_ID is not null then p.Group_ID 
					else null 
				end	-- get funder departments from custom migration
		left join [db-au-stage]..dtc_cli_group_lookup g 
			on g.uniquedepartmentid = bg.pene_id 
	where 
		contract_id is not null 
		and j.Per_id is not null 
		and j.Per_id <> '0' 

	-- 2. load
	merge [db-au-dtc].dbo.pnpPolicyMember as tgt
	using (
			select 
				p.PolicySK,
				i.IndividualSK,
				f.FunderSK,
				fd.FunderDepartmentSK,
				s.*
			from 
				#src s 
				outer apply (select top 1 PolicySK from [db-au-dtc].dbo.pnpPolicy where PolicyID = s.PolicyID) p 
				outer apply (select top 1 IndividualSK from [db-au-dtc].dbo.pnpIndividual where IndividualID = s.IndividualID and IsCurrent = 1) i 
				outer apply (select top 1 FunderSK from [db-au-dtc].dbo.pnpFunder where FunderID = s.FunderID and IsCurrent = 1) f 
				outer apply (select top 1 FunderDepartmentSK from [db-au-dtc].dbo.pnpFunderDepartment where FunderDepartmentID = s.FunderDepartmentID) fd
		) s	
		on s.PolicyMemberID = tgt.PolicyMemberID
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
			FunderDepartmentID,
			Relationship,
			RelationshipCode,
			RelationshipCode2
		)
		values (
			s.PolicySK,
			s.IndividualSK,
			s.FunderSK,
			s.FunderDepartmentSK,
			s.PolicyMemberID,
			s.PolicyID, 
			s.IndividualID,
			s.FunderID,
			s.FunderDepartmentID,
			s.Relationship,
			s.RelationshipCode,
			s.RelationshipCode2
		)
	when matched then 
		update set 
			tgt.PolicySK = s.PolicySK,
			tgt.IndividualSK = s.IndividualSK,
			tgt.FunderSK = s.FunderSK,
			tgt.FunderDepartmentSK = s.FunderDepartmentSK,
			tgt.PolicyID = s.PolicyID, 
			tgt.IndividualID = s.IndividualID,
			tgt.FunderID = s.FunderID,
			tgt.FunderDepartmentID = s.FunderDepartmentID,
			tgt.Relationship = s.Relationship,
			tgt.RelationshipCode = s.RelationshipCode,
			tgt.RelationshipCode2 = s.RelationshipCode2
	;

END

GO
