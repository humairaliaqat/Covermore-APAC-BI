USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimAgentMe]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimAgentMe]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbAgentMe', '',0,0, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentMe', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Agent', 'Insert', 0, 0, 2, 2, NULL, NULL, NULL

	if object_id('dbo.trwdimAgentMe') is null
	BEGIN
    
		create table dbo.trwdimAgentMe
		(
			AgentMeIdSK							int identity(1,1) not null,
			AgentMeId							int not null,
			AgentId								int null,
			MarketingEmployeeId					int null,
			FromDate							datetime null,
			ToDate								datetime null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimAgentMe_AgentbranchMeSK on dbo.trwdimAgentMe(AgentMeIdSK)
		create nonclustered index idx_dimAgentMe_AgentbranchMeId on dbo.trwdimAgentMe(AgentMeId)
		create nonclustered index idx_dimAgentMe_AgentId on dbo.trwdimAgentMe(AgentId)
		create nonclustered index idx_dimAgentMe_MarketingEmployeeId on dbo.trwdimAgentMe(MarketingEmployeeId)
		create nonclustered index idx_dimAgentMe_HashKey on trwdimAgentMe(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwAgentMe
	set 
		HashKey = binary_checksum(AgentMeId,AgentId,MarketingEmployeeId,FromDate,ToDate)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwAgentMe


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimAgentMe as DST
	using ETL_trwAgentMe as SRC
	on (src.AgentMeId = DST.AgentMeId)

	when not matched by target then
	insert
	(
	AgentMeId,
	AgentId,
	MarketingEmployeeId,
	FromDate,
	ToDate,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.AgentMeId,
	SRC.AgentId,
	SRC.MarketingEmployeeId,
	SRC.FromDate,
	SRC.ToDate,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.AgentId = SRC.AgentId,
		DST.MarketingEmployeeId = SRC.MarketingEmployeeId,
		DST.FromDate = SRC.FromDate,
		DST.ToDate = SRC.ToDate,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbAgentMe', '',@insertcount, @updatecount, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentMe', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Agent', 'Update', @insertcount, @updatecount, 2, 2, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentMe', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimAgentMe', 'Process_StarDimension_AgentMe', 'Package_Error_Log', 'Failed', 'Star Dimension - Agent', '', 0, 0, 2, 2, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 2, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
