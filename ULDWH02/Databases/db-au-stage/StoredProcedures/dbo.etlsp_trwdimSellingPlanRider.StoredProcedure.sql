USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimSellingPlanRider]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimSellingPlanRider]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbSellingPlanRiders', '',0,0, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbSellingPlanRiders', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - SellingCostPlan', 'Insert', 0, 0, 2, 3, NULL, NULL, NULL

	if object_id('dbo.trwdimSellingPlanRider') is null
	BEGIN
    
		create table dbo.trwdimSellingPlanRider
		(
			SellingPlanRiderSK					int identity(1,1) not null,
			SellingPlanRiderID					int not null,
			SellingPlanID						int null,
			CostPlanRiderID						int null,
			PremiumPercent						numeric(18, 2) null,
			Preexistingridercoverage			bit null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimSellingPlanRider_SellingPlanRiderSK on dbo.trwdimSellingPlanRider(SellingPlanRiderSK)
		create nonclustered index idx_dimSellingPlanRider_SellingPlanRiderID on dbo.trwdimSellingPlanRider(SellingPlanRiderID)
		create nonclustered index idx_dimSellingPlanRider_SellingPlanID on dbo.trwdimSellingPlanRider(SellingPlanID)
		create nonclustered index idx_dimSellingPlanRider_CostPlanRiderID on dbo.trwdimSellingPlanRider(CostPlanRiderID)
		create nonclustered index idx_dimSellingPlanRider_HashKey on trwdimSellingPlanRider(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwSellingPlanRiders
	set 
		HashKey = binary_checksum(SellingPlanRiderID,SellingPlanID,CostPlanRiderID,PremiumPercent,Preexistingridercoverage)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwSellingPlanRiders


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimSellingPlanRider as DST
	using ETL_trwSellingPlanRiders as SRC
	on (src.SellingPlanRiderID = DST.SellingPlanRiderID)

	when not matched by target then
	insert
	(
	SellingPlanRiderID,
	SellingPlanID,
	CostPlanRiderID,
	PremiumPercent,
	Preexistingridercoverage,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.SellingPlanRiderID,
	SRC.SellingPlanID,
	SRC.CostPlanRiderID,
	SRC.PremiumPercent,
	SRC.Preexistingridercoverage,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.SellingPlanID = SRC.SellingPlanID,
		DST.CostPlanRiderID = SRC.CostPlanRiderID,
		DST.PremiumPercent = SRC.PremiumPercent,
		DST.Preexistingridercoverage = SRC.Preexistingridercoverage,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbSellingPlanRiders', '',@insertcount, @updatecount, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbSellingPlanRiders', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - SellingCostPlan', 'Update', @insertcount, @updatecount, 2, 3, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbSellingPlanRiders', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimSellingPlanRider', 'Process_StarDimension_SellingPlan', 'Package_Error_Log', 'Failed', 'Star Dimension - SellingCostPlan', '', 0, 0, 2, 3, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 3, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
