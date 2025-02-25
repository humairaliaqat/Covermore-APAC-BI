USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_209_Item]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_209_Item] 
AS
BEGIN

	SET NOCOUNT ON;

	-- ServiceTypeActivity => Item

	/*
	stage tables:
		[db-au-stage]..dtc_cli_ServiceTypeActivity 
	
	pnpItem
		ItemSK
		ItemID							'CLI_ACD_' + ActivityCode
		Type							'Service'
		Name							Description
		UnitOfMeasurementClass
		UnitOfMeasurementIsTime
		UnitOfMeasurementIsSchedule
		UnitOfMeasurementIsName
		UnitOfMeasurementIsEquivalent
		ItemFee
		ProcedureCode
		Active
		Class
		itemuserdef1
		itemuserdef2
		CreatedDatetime					
		UpdatedDatetime					
		CreatedBy							
		UpdatedBy						
		NameShort						ActivityCode
		ItemFeeLL
		ItemDisabless
		TaxSched		
		TaxSchedShort					
		TaxSchedNotes
		Notes
		modifier1
		modifier2
		modifier3
		modifier4
		ItemContact
	*/

	-- 1. transform 
	if object_id('tempdb..#src') is not null drop table #src 

	select 
		'CLI_ACD_' + Activity_Code ItemID,
		'Service' Type,
		Activity_Desc Name,
		Activity_Code NameShort 
	into #src 	
	from [db-au-stage]..dtc_cli_paactvty 	
	
	
	-- 2. load 
	merge [db-au-dtc]..pnpItem as tgt
	using #src
		on #src.ItemID = tgt.ItemID 
	when not matched by target then 
		insert (
			ItemID,
			Type,
			Name,
			NameShort
		)
		values (
			#src.ItemID,
			#src.Type,
			#src.Name,
			#src.NameShort
		)
	when matched then update set 
		tgt.ItemID = #src.ItemID,
		tgt.Type = #src.Type,
		tgt.Name = #src.Name,
		tgt.NameShort = #src.NameShort
	;

	--update to correct class - set mainly for disbursements (recharges)
	UPDATE I
	SET Class = CASE WHEN NameShort = 'DISBURSEME' THEN 'Disbursement' END
	--select *
	from [db-au-dtc]..pnpItem I
	where class is null

END

GO
