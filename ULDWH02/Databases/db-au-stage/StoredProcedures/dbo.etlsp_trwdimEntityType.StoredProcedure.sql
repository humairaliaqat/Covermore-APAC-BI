USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimEntityType]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimEntityType]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbEntityTypes', '',0,0, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbEntityTypes', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Employee', 'Insert', 0, 0, 2, 1, NULL, NULL, NULL


	if object_id('dbo.trwdimEntityType') is null
	BEGIN
    
		create table dbo.trwdimEntityType
		(
			EntityTypeSK					int identity(1,1) not null,
			EntityTypeID					int not null,
			EntityType						nvarchar(50) null,
			InsertDate						datetime null,
			updateDate						datetime null,
			HashKey							varbinary(50) null
		)
        
		create clustered index idx_dimEntityType_EntityTypeSK on dbo.trwdimEntityType(EntityTypeSK)
		create nonclustered index idx_dimEntityType_EntityTypeID on dbo.trwdimEntityType(EntityTypeID)
		create nonclustered index idx_dimEntityType_HashKey on trwdimEntityType(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwEntityTypes
	set 
		HashKey = binary_checksum(EntityTypeID, EntityType)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwEntityTypes


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimEntityType as DST
	using ETL_trwEntityTypes as SRC
	on (src.EntityTypeID = DST.EntityTypeID)

	when not matched by target then
	insert
	(
	EntityTypeID,
	EntityType,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.EntityTypeID,
	SRC.EntityType,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.EntityType = SRC.EntityType,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbEntityTypes', '',@insertcount, @updatecount, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbEntityTypes', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Employee', 'Update', @insertcount, @updatecount, 2, 1, NULL, NULL, NULL

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

	exec etlsp_trwgenerateetllog @Package_ID, 'dbEntityTypes', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimEntityType', 'Process_StarDimension_EntityType', 'Package_Error_Log', 'Failed', 'Star Dimension - Employee', '', 0, 0, 2, 1, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 1, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			


--exec [etlsp_dimEntityType] '1558484B-BDFF-437F-A12B-F7CAEEE49BC5', '{14B94763-72D4-4B9C-BB80-B7CC835A88EC}' ,'fghdfg', '33d', 'StarDimension'
GO
