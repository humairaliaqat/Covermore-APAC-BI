USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimEntity]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimEntity]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbEntities', '',0,0, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbEntities', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Employee', 'Insert', 0, 0, 2, 1, NULL, NULL, NULL

	if object_id('dbo.trwdimEntity') is null
	BEGIN
    
		create table dbo.trwdimEntity
		(
			EntityIDSK						int identity(1,1) not null,
			EntityID						int not null,
			EntityTypeID					int null,
			Name							nvarchar(500) null,
			Status							nvarchar(50) null,
			InsertDate						datetime null,
			updateDate						datetime null,
			HashKey							varbinary(50) null
		)
        
		create clustered index idx_dimEntity_EntitySK on dbo.trwdimEntity(EntityIDSK)
		create nonclustered index idx_dimEntity_EntityID on dbo.trwdimEntity(EntityID)
		create nonclustered index idx_dimEntity_EntityTypeID on dbo.trwdimEntity(EntityTypeID)
		create nonclustered index idx_dimEntity_HashKey on trwdimEntity(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwEntities
	set 
		HashKey = binary_checksum(EntityID, EntityTypeID, Name, Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwEntities


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimEntity as DST
	using ETL_trwEntities as SRC
	on (src.EntityID = DST.EntityID)

	when not matched by target then
	insert
	(
	EntityID,
	EntityTypeID,
	Name,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.EntityID,
	SRC.EntityTypeID,
	SRC.Name,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.EntityTypeID = SRC.EntityTypeID,
		DST.Name = SRC.Name,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbEntities', '',@insertcount, @updatecount, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbEntities', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Employee', 'Update', @insertcount, @updatecount, 2, 1, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbEntities', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimEntity', 'Process_StarDimension_Entity', 'Package_Error_Log', 'Failed', 'Star Dimension - Employee', '', 0, 0, 2, 1, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			


--exec [etlsp_dimEntity] '1558484B-BDFF-437F-A12B-F7CAEEE49BC5', '{14B94763-72D4-4B9C-BB80-B7CC835A88EC}' ,'fghdfg', '33d', 'StarDimension'
GO
