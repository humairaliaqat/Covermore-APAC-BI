USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimArea]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimArea]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbAreas', '',0,0, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAreas', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Employee', 'Insert', 0, 0, 2, 1, NULL, NULL, NULL


	if object_id('dbo.trwdimArea') is null
	BEGIN
    
		create table dbo.trwdimArea
		(
			AreaSK				int identity(1,1) not null,
			AreaID				int not null,
			Name				nvarchar(50) null,
			RegionID			int null,
			ManagerEmployeeID	int null,
			EntityID			int null,
			Status				nvarchar(50) null,
			InsertDate			datetime null,
			updateDate			datetime null,
			HashKey				varbinary(30) null
		)
        
		create clustered index idx_dimArea_AreaSK on dbo.trwdimArea(AreaSK)
		create nonclustered index idx_dimArea_AreaID on dbo.trwdimArea(AreaID)
		create nonclustered index idx_dimArea_RegionID on dbo.trwdimArea(RegionID)
		create nonclustered index idx_dimArea_ManagerEmployeeID on trwdimArea(ManagerEmployeeID)
		create nonclustered index idx_dimArea_EntityID on dbo.trwdimArea(EntityID)
		create nonclustered index idx_dimArea_HashKey on trwdimArea(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwAreas
	set 
		HashKey = binary_checksum(AreaID, Name, RegionID, ManagerEmployeeID, EntityID, Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwAreas


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimArea as DST
	using ETL_trwAreas as SRC
	on (src.AreaID = DST.AreaID)

	when not matched by target then
	insert
	(
	AreaID,
	Name,
	RegionID,
	ManagerEmployeeID,
	EntityID,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.AreaID,
	SRC.Name,
	SRC.RegionID,
	SRC.ManagerEmployeeID,
	SRC.EntityID,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.Name = SRC.Name,
	DST.RegionID = SRC.RegionID,
	DST.ManagerEmployeeID = SRC.ManagerEmployeeID,
	DST.EntityID = SRC.EntityID,
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
	
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbAreas', '',@insertcount, @updatecount, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAreas', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Employee', 'Update', @insertcount, @updatecount, 2, 1, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAreas', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimArea', 'Process_StarDimension_Area', 'Package_Error_Log', 'Failed', 'Star Dimension - Employee', '', 0, 0, 2, 1, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 1, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			


--exec [etlsp_dimArea] '1558484B-BDFF-437F-A12B-F7CAEEE49BC5', '{14B94763-72D4-4B9C-BB80-B7CC835A88EC}' ,'fghdfg', '33d', 'StarDimension'
GO
