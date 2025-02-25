USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimAgentBranchMe]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimAgentBranchMe]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbAgentbranchMe', '',0,0, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentbranchMe', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Agent', 'Insert', 0, 0, 2, 2, NULL, NULL, NULL

	if object_id('dbo.trwdimAgentBranchMe') is null
	BEGIN
    
		create table dbo.trwdimAgentBranchMe
		(
			AgentbranchMeSK						int identity(1,1) not null,
			AgentbranchMeId						int not null,
			AgentId								int null,
			AgentBranchId						int null,
			BranchId							int null,
			MarketingEmployeeId					int null,
			FromDate							datetime null,
			ToDate								datetime null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimAgentBranchMe_AgentbranchMeSK on dbo.trwdimAgentBranchMe(AgentbranchMeSK)
		create nonclustered index idx_dimAgentBranchMe_AgentbranchMeId on dbo.trwdimAgentBranchMe(AgentbranchMeId)
		create nonclustered index idx_dimAgentBranchMe_AgentId on dbo.trwdimAgentBranchMe(AgentId)
		create nonclustered index idx_dimAgentBranchMe_AgentBranchId on trwdimAgentBranchMe(AgentBranchId)
		create nonclustered index idx_dimAgentBranchMe_BranchId on dbo.trwdimAgentBranchMe(BranchId)
		create nonclustered index idx_dimAgentBranchMe_MarketingEmployeeId on dbo.trwdimAgentBranchMe(MarketingEmployeeId)
		create nonclustered index idx_dimAgentBranchMe_HashKey on trwdimAgentBranchMe(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwAgentbranchMe
	set 
		HashKey = binary_checksum(AgentbranchMeId,AgentId,AgentBranchId,BranchId,MarketingEmployeeId,FromDate,ToDate)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwAgentbranchMe


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimAgentBranchMe as DST
	using ETL_trwAgentbranchMe as SRC
	on (src.AgentbranchMeId = DST.AgentbranchMeId)

	when not matched by target then
	insert
	(
	AgentbranchMeId,
	AgentId,
	AgentBranchId,
	BranchId,
	MarketingEmployeeId,
	FromDate,
	ToDate,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.AgentbranchMeId,
	SRC.AgentId,
	SRC.AgentBranchId,
	SRC.BranchId,
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
		DST.AgentBranchId = SRC.AgentBranchId,
		DST.BranchId = SRC.BranchId,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbAgentbranchMe', '',@insertcount, @updatecount, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentbranchMe', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Agent', 'Update', @insertcount, @updatecount, 2, 2, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentbranchMe', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimAgentBranchMe', 'Process_StarDimension_AgentBranchMe', 'Package_Error_Log', 'Failed', 'Star Dimension - Agent', '', 0, 0, 2, 2, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 2, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
