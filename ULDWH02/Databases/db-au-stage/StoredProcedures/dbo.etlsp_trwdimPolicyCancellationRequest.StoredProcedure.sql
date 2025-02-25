USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimPolicyCancellationRequest]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimPolicyCancellationRequest]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbPolicyCancellationRequests', '',0,0, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyCancellationRequests', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - PolicyOthers', 'Insert', 0, 0, 2, 4, NULL, NULL, NULL

	if object_id('dbo.trwdimPolicyCancellationRequest') is null
	BEGIN
    
		create table dbo.trwdimPolicyCancellationRequest
		(
			PolicyCancellationRequestSK			int identity(1,1) not null,
			PolicyCancellationRequestID			int not null,
			PolicyID							int null,
			RequesterEntityID					int null,
			Documentfile						nvarchar(500) null,
			Reason								nvarchar(1000) null,
			Charges								numeric(18, 2) null,
			Remarks								nvarchar(1000) null,
			ProcessedByEntityID					int null,
			Status								nvarchar(50) null,
			CreatedDateTime						datetime null,
			CreatedBy							nvarchar(256) null,
			ModifiedDateTime					datetime null,
			ModifiedBy							nvarchar(256) null,							
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimPolicyCancellationRequest_PolicyCancellationRequestSK on dbo.trwdimPolicyCancellationRequest(PolicyCancellationRequestSK)
		create nonclustered index idx_dimPolicyCancellationRequest_PolicyCancellationRequestID on dbo.trwdimPolicyCancellationRequest(PolicyCancellationRequestID)
		create nonclustered index idx_dimPolicyCancellationRequest_PolicyID on dbo.trwdimPolicyCancellationRequest(PolicyID)
		create nonclustered index idx_dimPolicyCancellationRequest_RequesterEntityID on dbo.trwdimPolicyCancellationRequest(RequesterEntityID)
		create nonclustered index idx_dimPolicyCancellationRequest_ProcessedByEntityID on dbo.trwdimPolicyCancellationRequest(ProcessedByEntityID)
		create nonclustered index idx_dimPolicyCancellationRequest_HashKey on trwdimPolicyCancellationRequest(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwPolicyCancellationRequests
	set 
		HashKey = binary_checksum(PolicyCancellationRequestID,PolicyID,RequesterEntityID,DocumentFile,Reason,Charges,Remarks,ProcessedByEntityID,Status,CreatedDateTime,CreatedBy,
									ModifiedDateTime,ModifiedBy)
	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwPolicyCancellationRequests


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimPolicyCancellationRequest as DST
	using ETL_trwPolicyCancellationRequests as SRC
	on (src.PolicyCancellationRequestID = DST.PolicyCancellationRequestID)

	when not matched by target then
	insert
	(
	PolicyCancellationRequestID,
	PolicyID,
	RequesterEntityID,
	DocumentFile,
	Reason,
	Charges,
	Remarks,
	ProcessedByEntityID,
	Status,
	CreatedDateTime,
	CreatedBy,
	ModifiedDateTime,
	ModifiedBy,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.PolicyCancellationRequestID,
	SRC.PolicyID,
	SRC.RequesterEntityID,
	SRC.DocumentFile,
	SRC.Reason,
	SRC.Charges,
	SRC.Remarks,
	SRC.ProcessedByEntityID,
	SRC.Status,
	SRC.CreatedDateTime,
	SRC.CreatedBy,
	SRC.ModifiedDateTime,
	SRC.ModifiedBy,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PolicyID = SRC.PolicyID,
		DST.RequesterEntityID = SRC.RequesterEntityID,
		DST.DocumentFile = SRC.DocumentFile,
		DST.Reason = SRC.Reason,
		DST.Charges = SRC.Charges,
		DST.Remarks = SRC.Remarks,
		DST.ProcessedByEntityID = SRC.ProcessedByEntityID,
		DST.Status = SRC.Status,
		DST.CreatedDateTime = SRC.CreatedDateTime,
		DST.CreatedBy = SRC.CreatedBy,
		DST.ModifiedDateTime = SRC.ModifiedDateTime,
		DST.ModifiedBy = SRC.ModifiedBy,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbPolicyCancellationRequests', '',@insertcount, @updatecount, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyCancellationRequests', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - PolicyOthers', 'Update', @insertcount, @updatecount, 2, 4, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyCancellationRequests', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimPolicyCancellationRequest', 'Process_StarDimension_CancellationRequest', 'Package_Error_Log', 'Failed', 'Star Dimension - PolicyOthers', '', 0, 0, 2, 4, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 4, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
