USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimDesignation]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimDesignation]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbDesignations', '',0,0, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbDesignations', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Employee', 'Insert', 0, 0, 2, 1, NULL, NULL, NULL

	if object_id('dbo.trwdimDesignation') is null
	BEGIN
    
		create table dbo.trwdimDesignation
		(
			DesignationSK						int identity(1,1) not null,
			DesignationID						int not null,
			Designation							nvarchar(50) null,
			SeqNo								int null,
			IncentiveStructureAID				int null,
			IncentiveStuctureBID				int null,
			EmployeeIncentiveStructureCPercent	numeric(18,2),
			Status								nvarchar(50) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimDesignation_DesignationSK on dbo.trwdimDesignation(DesignationSK)
		create nonclustered index idx_dimDesignation_DesignationID on dbo.trwdimDesignation(DesignationID)
		create nonclustered index idx_dimDesignation_IncentiveStructureAID on dbo.trwdimDesignation(IncentiveStructureAID)
		create nonclustered index idx_dimDesignation_IncentiveStuctureBID on trwdimDesignation(IncentiveStuctureBID)
		create nonclustered index idx_dimDesignation_HashKey on trwdimDesignation(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwDesignations
	set 
		HashKey = binary_checksum(DesignationID, Designation, SeqNo, IncentiveStructureAID, IncentiveStuctureBID, EmployeeIncentiveStructureCPercent, Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwDesignations


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimDesignation as DST
	using ETL_trwDesignations as SRC
	on (src.DesignationID = DST.DesignationID)

	when not matched by target then
	insert
	(
	DesignationID,
	Designation,
	SeqNo,
	IncentiveStructureAID,
	IncentiveStuctureBID,
	EmployeeIncentiveStructureCPercent,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.DesignationID,
	SRC.Designation,
	SRC.SeqNo,
	SRC.IncentiveStructureAID,
	SRC.IncentiveStuctureBID,
	SRC.EmployeeIncentiveStructureCPercent,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.Designation = SRC.Designation,
	DST.SeqNo = SRC.SeqNo,
	DST.IncentiveStructureAID = SRC.IncentiveStructureAID,
	DST.IncentiveStuctureBID = SRC.IncentiveStuctureBID,
	DST.EmployeeIncentiveStructureCPercent = SRC.EmployeeIncentiveStructureCPercent,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbDesignations', '',@insertcount, @updatecount, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbDesignations', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Employee', 'Update', @insertcount, @updatecount, 2, 1, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbDesignations', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimDesignation', 'Process_StarDimension_Designation', 'Package_Error_Log', 'Failed', 'Star Dimension - Employee', '', 0, 0, 2, 1, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			


--exec [etlsp_dimDesignation] '1558484B-BDFF-437F-A12B-F7CAEEE49BC5', '{14B94763-72D4-4B9C-BB80-B7CC835A88EC}' ,'fghdfg', '33d', 'StarDimension'
GO
