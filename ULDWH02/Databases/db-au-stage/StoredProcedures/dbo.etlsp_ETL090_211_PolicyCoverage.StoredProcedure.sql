USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_211_PolicyCoverage]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_211_PolicyCoverage] 
AS
BEGIN

	SET NOCOUNT ON;

	-- ContractService => PolicyCoverage 

	/*
	stage tables:
		[db-au-stage]..dtc_cli_ContractService 

	pnpPolicyCoverage 
		PolicyCoverageSK
		PolicySK				
		PolicyCoverageID		'CLI_CSV_' + ContractService_id
		PolicyAgreementID
		covulimita
		covulimit
		covnoshow
		covdatea
		StartDate				
		EndDate
		covautha
		covauthno
		covauthconf
		kcovreauthid
		Comments				'Description: ' + Description + ' | Alert: ' + Alert
		covdollara
		DollarLimit
		CreatedDatetime			AddDate
		UpdatedDatetime			ChangeDate
		CreatedBy				AddUser
		UpdatedBy				ChangeUser
		Status					case when Inactive = -1 then '0' else '1' end
		BillType				BillingType
	*/


	-- 1. transform 
	if object_id('tempdb..#src') is not null drop table #src 

	select 
		p.PolicySK,
		'CLI_CSV_' + ContractService_ID PolicyCoverageID,
		'Description: ' + Description + ' | Alert: ' + Alert Comments,
		AddDate CreatedDatetime,
		ChangeDate UpdatedDatetime,
		AddUser CreatedBy,
		ChangeUser UpdatedBy,
		case when Inactive = -1 then '0' else '1' end Status,
		BillingType BillType
	into #src 
	from 
		[db-au-stage].dbo.dtc_cli_ContractService cs 
		cross apply (select top 1 PolicySK from [db-au-dtc].dbo.pnpPolicy where PolicyID = 'CLI_CON_' + cs.Contract_ID) p 


	-- 2. load 
	merge [db-au-dtc].dbo.pnpPolicyCoverage as tgt
	using #src
		on #src.PolicyCoverageID = tgt.PolicyCoverageID
	when not matched by target then 
		insert (
			PolicySK,
			PolicyCoverageID,
			Comments,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,
			UpdatedBy,
			Status,
			BillType
		)
		values (
			#src.PolicySK,
			#src.PolicyCoverageID,
			#src.Comments,
			#src.CreatedDatetime,
			#src.UpdatedDatetime,
			#src.CreatedBy,
			#src.UpdatedBy,
			#src.Status,
			#src.BillType
		)
	when matched then 
		update set 
			tgt.PolicySK = #src.PolicySK,
			tgt.Comments = #src.Comments,
			tgt.CreatedDatetime = #src.CreatedDatetime,
			tgt.UpdatedDatetime = #src.UpdatedDatetime,
			tgt.CreatedBy = #src.CreatedBy,
			tgt.UpdatedBy = #src.UpdatedBy,
			tgt.Status = #src.Status,
			tgt.BillType = #src.BillType
	;

END

GO
