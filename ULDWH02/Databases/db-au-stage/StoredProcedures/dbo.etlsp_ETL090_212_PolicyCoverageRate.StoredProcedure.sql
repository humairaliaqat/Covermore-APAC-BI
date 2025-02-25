USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_212_PolicyCoverageRate]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_212_PolicyCoverageRate] 
AS
BEGIN

	SET NOCOUNT ON;

	-- ContractServiceActivity => PolicyCoverageRate

	/*
	stage tables:
		[db-au-stage]..dtc_cli_ContractServiceActivity 
	
	pnpPolicyCoverageRate
		PolicyCoverageSK
		ItemSK
		PolicyCoverageID		'CLI_CSV_' + ContractService_id
		ItemID					'CLI_ACD_' + ActivityCode
		PrimaryDP
		PrimaryRate
		PrimaryCP
		subpr
		subdr
		subcp
		CreatedDatetime			AddDate
		UpdatedDatetime			ChangeDate
		SubsequentRatesUsed		
	*/


	-- 1. transform 
	if object_id('tempdb..#src') is not null drop table #src 

	select * 
	into #src	
	from (
		select 
			'CLI_CSV_' + ContractService_ID PolicyCoverageID, 
			'CLI_ACD_' + ActivityCode ItemID,
			AddDate CreatedDatetime,
			ChangeDate UpdatedDatetime,
			row_number() over(partition by ContractService_ID, ActivityCode order by AddDate) rn
		from 
			[db-au-stage]..dtc_cli_ContractServiceActivity 
	) a 
		cross apply (
			select top 1 PolicyCoverageSK from [db-au-dtc].dbo.pnpPolicyCoverage where PolicyCoverageID = a.PolicyCoverageID
		) pc
		cross apply (
			select top 1 ItemSK from [db-au-dtc].dbo.pnpItem where ItemID = a.ItemID
		) i
	where 
		rn = 1
	

	-- 2. load
	merge [db-au-dtc]..pnpPolicyCoverageRate as tgt
	using #src
		on 	#src.PolicyCoverageID = tgt.PolicyCoverageID 
			and #src.ItemID = tgt.ItemID 
	when not matched by target then 
		insert (
			PolicyCoverageSK,
			ItemSK,
			PolicyCoverageID,
			ItemID,
			CreatedDatetime,
			UpdatedDatetime
		)
		values (
			#src.PolicyCoverageSK,
			#src.ItemSK,
			#src.PolicyCoverageID,
			#src.ItemID,
			#src.CreatedDatetime,
			#src.UpdatedDatetime
		)
	when matched then update set 
		tgt.PolicyCoverageSK = #src.PolicyCoverageSK,
		tgt.ItemSK = #src.ItemSK,
		tgt.CreatedDatetime = #src.CreatedDatetime,
		tgt.UpdatedDatetime = #src.UpdatedDatetime
	;

END

GO
