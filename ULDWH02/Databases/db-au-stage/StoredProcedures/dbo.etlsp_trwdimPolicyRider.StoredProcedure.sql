USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimPolicyRider]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimPolicyRider]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbPolicyRiders', '',0,0, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyRiders', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - PolicyRider', 'Insert', 0, 0, 2, 3, NULL, NULL, NULL

	if object_id('dbo.trwdimPolicyRider') is null
	BEGIN
    
		create table dbo.trwdimPolicyRider
		(
			PolicyRiderSK						int identity(1,1) not null,
			PolicyRiderID						int not null,
			SellingPlanRiderID					int null,
			PolicyDetailID						int null,
			PremiumPercent						numeric(18, 2) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimPolicyRider_SellingPlanRiderSK on dbo.trwdimPolicyRider(PolicyRiderSK)
		create nonclustered index idx_dimPolicyRider_SellingPlanRiderID on dbo.trwdimPolicyRider(PolicyRiderID)
		create nonclustered index idx_dimPolicyRider_SellingPlanID on dbo.trwdimPolicyRider(SellingPlanRiderID)
		create nonclustered index idx_dimPolicyRider_CostPlanRiderID on dbo.trwdimPolicyRider(PolicyDetailID)
		create nonclustered index idx_dimPolicyRider_HashKey on trwdimPolicyRider(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwPolicyRiders
	set 
		HashKey = binary_checksum(SellingPlanRiderID,PremiumPercent,PolicyRiderID,PolicyDetailID)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwPolicyRiders


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimPolicyRider as DST
	using ETL_trwPolicyRiders as SRC
	on (src.PolicyRiderID = DST.PolicyRiderID)

	when not matched by target then
	insert
	(
	PolicyRiderID,
	SellingPlanRiderID,
	PolicyDetailID,
	PremiumPercent,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.PolicyRiderID,
	SRC.SellingPlanRiderID,
	SRC.PolicyDetailID,
	SRC.PremiumPercent,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.SellingPlanRiderID = SRC.SellingPlanRiderID,
		DST.PolicyDetailID = SRC.PolicyDetailID,
		DST.PremiumPercent = SRC.PremiumPercent,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbPolicyRiders', '',@insertcount, @updatecount, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyRiders', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - PolicyRider', 'Update', @insertcount, @updatecount, 2, 3, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyRiders', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimPolicyRider', 'Process_StarDimension_PolicyRider', 'Package_Error_Log', 'Failed', 'Star Dimension - PolicyRider', '', 0, 0, 2, 3, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 3, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
