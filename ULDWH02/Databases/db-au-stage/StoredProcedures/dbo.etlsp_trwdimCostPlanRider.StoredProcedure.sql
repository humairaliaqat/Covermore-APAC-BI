USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimCostPlanRider]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimCostPlanRider]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbCostPlanRiders', '',0,0, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbCostPlanRiders', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - SellingCostPlan', 'Insert', 0, 0, 2, 3, NULL, NULL, NULL


	if object_id('dbo.trwdimCostPlanRider') is null
	BEGIN
    
		create table dbo.trwdimCostPlanRider
		(
			CostPlanRiderSK						int identity(1,1) not null,
			CostPlanRiderID						int not null,
			CostPlanID							int null,
			RiderID								int null,
			Name								nvarchar(50) null,
			PremiumPercent						numeric(18, 2) null,
			Status								nvarchar(50) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimCostPlanRider_CostPlanRiderSK on dbo.trwdimCostPlanRider(CostPlanRiderSK)
		create nonclustered index idx_dimCostPlanRider_CostPlanRiderID on dbo.trwdimCostPlanRider(CostPlanRiderID)
		create nonclustered index idx_dimCostPlanRider_CostPlanID on dbo.trwdimCostPlanRider(CostPlanID)
		create nonclustered index idx_dimCostPlanRider_RiderID on dbo.trwdimCostPlanRider(RiderID)
		create nonclustered index idx_dimCostPlanRider_HashKey on trwdimCostPlanRider(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwCostPlanRiders
	set 
		HashKey = binary_checksum(CostPlanRiderID,CostPlanID,RiderID,Name,PremiumPercent,Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwCostPlanRiders


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimCostPlanRider as DST
	using ETL_trwCostPlanRiders as SRC
	on (src.CostPlanRiderID = DST.CostPlanRiderID)

	when not matched by target then
	insert
	(
	CostPlanRiderID,
	CostPlanID,
	RiderID,
	Name,
	PremiumPercent,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.CostPlanRiderID,
	SRC.CostPlanID,
	SRC.RiderID,
	SRC.Name,
	SRC.PremiumPercent,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.CostPlanID = SRC.CostPlanID,
		DST.RiderID = SRC.RiderID,
		DST.Name = SRC.Name,
		DST.PremiumPercent = SRC.PremiumPercent,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbCostPlanRiders', '',@insertcount, @updatecount, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbCostPlanRiders', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - SellingCostPlan', 'Update', @insertcount, @updatecount, 2, 3, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbCostPlanRiders', @user_name, 0, @ErrorNumber, @ErrorMessage, 'dimSellingPlan', 'Process_StarDimension_SellingPlan', 'Package_Error_Log', 'Failed', 'Star Dimension - SellingCostPlan', '', 0, 0, 2, 3, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 3, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
