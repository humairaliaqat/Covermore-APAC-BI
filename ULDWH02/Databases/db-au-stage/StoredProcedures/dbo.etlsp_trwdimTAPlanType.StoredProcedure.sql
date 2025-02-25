USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimTAPlanType]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimTAPlanType]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbTAPlanTypes', '',0,0, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbTAPlanTypes', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - SellingCostPlan', 'Insert', 0, 0, 2, 3, NULL, NULL, NULL

	if object_id('dbo.trwdimTAPlanType') is null
	BEGIN
    
		create table dbo.trwdimTAPlanType
		(
			TAPlanTypeSK						int identity(1,1) not null,
			TAPlanTypeID						int not null,
			PlanType							nvarchar(50) null,
			CardImage							nvarchar(500) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimTAPlanType_TAPlanTypeSK on dbo.trwdimTAPlanType(TAPlanTypeSK)
		create nonclustered index idx_dimTAPlanType_TAPlanTypeID on dbo.trwdimTAPlanType(TAPlanTypeID)
		create nonclustered index idx_dimTAPlanType_HashKey on trwdimTAPlanType(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwTAPlanTypes
	set 
		HashKey = binary_checksum(TAPlanTypeID, PlanType, CardImage)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwTAPlanTypes


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimTAPlanType as DST
	using ETL_trwTAPlanTypes as SRC
	on (src.TAPlanTypeID = DST.TAPlanTypeID)

	when not matched by target then
	insert
	(
	TAPlanTypeID,
	PlanType,
	CardImage,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.TAPlanTypeID,
	SRC.PlanType,
	SRC.CardImage,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PlanType = SRC.PlanType,
		DST.CardImage = SRC.CardImage,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbTAPlanTypes', '',@insertcount, @updatecount, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbTAPlanTypes', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - SellingCostPlan', 'Update', @insertcount, @updatecount, 2, 3, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbTAPlanTypes', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimTAPlanType', 'Process_StarDimension_TAPlanType', 'Package_Error_Log', 'Failed', 'Star Dimension - SellingCostPlan', '', 0, 0, 2, 3, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 3, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
