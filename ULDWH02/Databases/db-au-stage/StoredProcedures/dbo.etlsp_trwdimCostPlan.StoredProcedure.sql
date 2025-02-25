USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimCostPlan]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimCostPlan]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbCostPlans', '',0,0, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbCostPlans', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - SellingCostPlan', 'Insert', 0, 0, 2, 3, NULL, NULL, NULL

	if object_id('dbo.trwdimCostPlan') is null
	BEGIN
    
		create table dbo.trwdimCostPlan
		(
			CostPlanSK							int identity(1,1) not null,
			CostPlanID							int not null,
			Name								nvarchar(100) null,
			ShortName							nvarchar(50) null,
			InsuranceProviderID					int null,
			InsuranceCategoryID					int null,
			MasterPolicyNumber					nvarchar(50) null,
			DayPlan								bit null,
			TAProviderID						int null,
			TAPlanID							int null,
			TANumber							nvarchar(50) null,
			VisitingCountryID					int null,
			Annualplan							bit null,
			Status								nvarchar(50) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimCostPlan_CostPlanSK on dbo.trwdimCostPlan(CostPlanSK)
		create nonclustered index idx_dimCostPlan_CostPlanID on dbo.trwdimCostPlan(CostPlanID)
		create nonclustered index idx_dimCostPlan_InsuranceProviderID on dbo.trwdimCostPlan(InsuranceProviderID)
		create nonclustered index idx_dimCostPlan_InsuranceCategoryID on dbo.trwdimCostPlan(InsuranceCategoryID)
		create nonclustered index idx_dimCostPlan_TAProviderID on dbo.trwdimCostPlan(TAProviderID)
		create nonclustered index idx_dimCostPlan_TAPlanID on dbo.trwdimCostPlan(TAPlanID)
		create nonclustered index idx_dimCostPlan_VisitingCountryID on dbo.trwdimCostPlan(VisitingCountryID)
		create nonclustered index idx_dimCostPlan_HashKey on trwdimCostPlan(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwCostPlans
	set 
		HashKey = binary_checksum(CostPlanID,Name,ShortName,InsuranceProviderID,InsuranceCategoryID,MasterPolicyNumber,DayPlan,TAProviderID,TAPlanID,TANumber,VisitingCountryID,
					Annualplan,Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwCostPlans


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimCostPlan as DST
	using ETL_trwCostPlans as SRC
	on (src.CostPlanID = DST.CostPlanID)

	when not matched by target then
	insert
	(
	CostPlanID,
	Name,
	ShortName,
	InsuranceProviderID,
	InsuranceCategoryID,
	MasterPolicyNumber,
	DayPlan,
	TAProviderID,
	TAPlanID,
	TANumber,
	VisitingCountryID,
	Annualplan,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.CostPlanID,
	SRC.Name,
	SRC.ShortName,
	SRC.InsuranceProviderID,
	SRC.InsuranceCategoryID,
	SRC.MasterPolicyNumber,
	SRC.DayPlan,
	SRC.TAProviderID,
	SRC.TAPlanID,
	SRC.TANumber,
	SRC.VisitingCountryID,
	SRC.Annualplan,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.Name = SRC.Name,
		DST.ShortName = SRC.ShortName,
		DST.InsuranceProviderID = SRC.InsuranceProviderID,
		DST.InsuranceCategoryID = SRC.InsuranceCategoryID,
		DST.MasterPolicyNumber = SRC.MasterPolicyNumber,
		DST.DayPlan = SRC.DayPlan,
		DST.TAProviderID = SRC.TAProviderID,
		DST.TAPlanID = SRC.TAPlanID,
		DST.TANumber = SRC.TANumber,
		DST.VisitingCountryID = SRC.VisitingCountryID,
		DST.Annualplan = SRC.Annualplan,
		DST.Status = SRC.Status,
		DST.UpdateDate = getdate(),
		DST.HashKey = SRC.HashKey
            
	output $action into @mergeoutput;


		select
			@insertcount =
				sum(
					case
						when MergeAction = 'insert' then 1
						else 0
					end
				),
			@updatecount =
				sum(
					case
						when MergeAction = 'update' then 1
						else 0
					end
				)
		from
			@mergeoutput
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbCostPlans', '',@insertcount, @updatecount, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbCostPlans', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - SellingCostPlan', 'Update', @insertcount, @updatecount, 2, 3, NULL, NULL, NULL

END TRY
BEGIN CATCH
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
	DECLARE @insert_date	Datetime

	SET @insert_date = getdate()

	SET @ErrorMessage = 'Error Line: ' + convert(varchar, @ErrorLine) + ', Error Message: ' + @ErrorMessage + ', Error Severity: ' + convert(varchar, @ErrorSeverity) + ', Error State: ' + convert(varchar, @ErrorState)

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	--exec sp_generateerrorhandling @EIGUID, @Package_ID, @Package_Name, @ErrorNumber, @ErrorMessage, '', '', @Category, '', '', @insert_date
	exec etlsp_trwgenerateetllog @Package_ID, 'dbCostPlans', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimCostPlan', 'Process_StarDimension_SellingPlan', 'Package_Error_Log', 'Failed', 'Star Dimension - SellingCostPlan', '', 0, 0, 2, 3, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 3, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
