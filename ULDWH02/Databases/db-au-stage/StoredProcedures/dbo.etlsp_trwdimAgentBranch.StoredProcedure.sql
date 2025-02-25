USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimAgentBranch]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_trwdimAgentBranch]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbAgentBranches', '',0,0, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentBranches', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Agent', 'Insert', 0, 0, 2, 2, NULL, NULL, NULL

	if object_id('dbo.trwdimAgentBranch') is null
	BEGIN
    
		create table dbo.trwdimAgentBranch
		(
			AgentBranchSK						int identity(1,1) not null,
			AgentBranchID						int not null,
			AgentID								int null,
			Name								nvarchar(500) null,
			DateofCreation						datetime null,
			ContactPerson						nvarchar(50) null,
			Address1							nvarchar(500) null,
			Address2							nvarchar(500) null,
			City								nvarchar(50) null,
			District							nvarchar(50) null,
			State								nvarchar(50) null,
			PinCode								nvarchar(10) null,
			Country								nvarchar(100) null,
			PhoneNo								nvarchar(50) null,
			MobileNo							nvarchar(50) null,
			EmailAddress						nvarchar(50) null,
			BranchID							int null,
			ImplantEmployeeID					int null,
			AgentEmployeeID						int null,
			Status								nvarchar(50) null,
			BankName							nvarchar(500) null,
			BankAddress							nvarchar(1000) null,
			BankAccountType						nvarchar(50) null,
			BankAccountNo						nvarchar(50) null,
			BankMICR							nvarchar(50) null,
			BankIFSCCode						nvarchar(50) null,
			MarketingExecutiveEmployeeID		int null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimAgentBranch_AgentBranchSK on dbo.trwdimAgentBranch(AgentBranchSK)
		create nonclustered index idx_dimAgentBranch_AgentID on dbo.trwdimAgentBranch(AgentBranchID)
		create nonclustered index idx_dimAgentBranch_ImplantEmployeeID on dbo.trwdimAgentBranch(ImplantEmployeeID)
		create nonclustered index idx_dimAgentBranch_AgentEmployeeID on trwdimAgentBranch(AgentEmployeeID)
		create nonclustered index idx_dimAgentBranch_MarketingExecutiveEmployeeID on dbo.trwdimAgentBranch(MarketingExecutiveEmployeeID)
		create nonclustered index idx_dimAgentBranch_HashKey on trwdimAgentBranch(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwAgentBranches
	set 
		HashKey = binary_checksum(AgentBranchID,AgentID,Name,DateofCreation,ContactPerson,Address1,Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,
					BranchID,ImplantEmployeeID,AgentEmployeeID,Status,BankName,BankAddress,BankAccountType,BankAccountNo,BankMICR,BankIFSCCode,MarketingExecutiveEmployeeID)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwAgentBranches


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimAgentBranch as DST
	using ETL_trwAgentBranches as SRC
	on (src.AgentBranchID = DST.AgentBranchID)

	when not matched by target then
	insert
	(
	AgentBranchID,
	AgentID,
	Name,
	DateofCreation,
	ContactPerson,
	Address1,
	Address2,
	City,
	District,
	State,
	PinCode,
	Country,
	PhoneNo,
	MobileNo,
	EmailAddress,
	BranchID,
	ImplantEmployeeID,
	AgentEmployeeID,
	Status,
	BankName,
	BankAddress,
	BankAccountType,
	BankAccountNo,
	BankMICR,
	BankIFSCCode,
	MarketingExecutiveEmployeeID,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.AgentBranchID,
	SRC.AgentID,
	SRC.Name,
	SRC.DateofCreation,
	SRC.ContactPerson,
	SRC.Address1,
	SRC.Address2,
	SRC.City,
	SRC.District,
	SRC.State,
	SRC.PinCode,
	SRC.Country,
	SRC.PhoneNo,
	SRC.MobileNo,
	SRC.EmailAddress,
	SRC.BranchID,
	SRC.ImplantEmployeeID,
	SRC.AgentEmployeeID,
	SRC.Status,
	SRC.BankName,
	SRC.BankAddress,
	SRC.BankAccountType,
	SRC.BankAccountNo,
	SRC.BankMICR,
	SRC.BankIFSCCode,
	SRC.MarketingExecutiveEmployeeID,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.AgentID = SRC.AgentID,
		DST.Name = SRC.Name,
		DST.DateofCreation = SRC.DateofCreation,
		DST.ContactPerson = SRC.ContactPerson,
		DST.Address1 = SRC.Address1,
		DST.Address2 = SRC.Address2,
		DST.City = SRC.City,
		DST.District = SRC.District,
		DST.State = SRC.State,
		DST.PinCode = SRC.PinCode,
		DST.Country = SRC.Country,
		DST.PhoneNo = SRC.PhoneNo,
		DST.MobileNo = SRC.MobileNo,
		DST.EmailAddress = SRC.EmailAddress,
		DST.BranchID = SRC.BranchID,
		DST.ImplantEmployeeID = SRC.ImplantEmployeeID,
		DST.AgentEmployeeID = SRC.AgentEmployeeID,
		DST.Status = SRC.Status,
		DST.BankName = SRC.BankName,
		DST.BankAddress = SRC.BankAddress,
		DST.BankAccountType = SRC.BankAccountType,
		DST.BankAccountNo = SRC.BankAccountNo,
		DST.BankMICR = SRC.BankMICR,
		DST.BankIFSCCode = SRC.BankIFSCCode,
		DST.MarketingExecutiveEmployeeID = SRC.MarketingExecutiveEmployeeID,
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

	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbAgentBranches', '',@insertcount, @updatecount, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentBranches', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Agent', 'Update', @insertcount, @updatecount, 2, 2, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentBranches', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimAgentBranch', 'Process_StarDimension_AgentBranch', 'Package_Error_Log', 'Failed', 'Star Dimension - Agent', '', 0, 0, 2, 2, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 2, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
