USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimAgentEmployee]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimAgentEmployee]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbAgentEmployees', '',0,0, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentEmployees', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Agent', 'Insert', 0, 0, 2, 2, NULL, NULL, NULL

	if object_id('dbo.trwdimAgentEmployee') is null
	BEGIN
    
		create table dbo.trwdimAgentEmployee
		(
			AgentEmployeeSK						int identity(1,1) not null,
			AgentEmployeeID						int not null,
			AgentBranchID						int null,
			UserName							nvarchar(256) null,
			SecurityAnswer						nvarchar(50) null,
			Name								nvarchar(500) null,
			PanDetailID							int null,
			BankName							nvarchar(500) null,
			BankAddress							nvarchar(1000) null,
			BankAccountType						nvarchar(50) null,
			BankAccountNo						nvarchar(50) null,
			BankMICR							nvarchar(50) null,
			BankIFSCCode						nvarchar(50) null,
			DateofBirth							datetime null,
			AnniversaryDate						datetime null,
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
			EntityID							int null,
			Status								nvarchar(50) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimAgentEmployee_AgentEmployeeSK on dbo.trwdimAgentEmployee(AgentEmployeeSK)
		create nonclustered index idx_dimAgentEmployee_AgentEmployeeID on dbo.trwdimAgentEmployee(AgentEmployeeID)
		create nonclustered index idx_dimAgentEmployee_AgentBranchID on dbo.trwdimAgentEmployee(AgentBranchID)
		create nonclustered index idx_dimAgentEmployee_PanDetailID on trwdimAgentEmployee(PanDetailID)
		create nonclustered index idx_dimAgentEmployee_EntityID on dbo.trwdimAgentEmployee(EntityID)
		create nonclustered index idx_dimAgentEmployee_HashKey on trwdimAgentEmployee(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwAgentEmployees
	set 
		HashKey = binary_checksum(AgentEmployeeID,AgentBranchID,UserName,SecurityAnswer,Name,PanDetailID,BankName,BankAddress,BankAccountType,BankAccountNo,BankMICR,BankIFSCCode,
					DateofBirth,AnniversaryDate,Address1,Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,EntityID,Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwAgentEmployees


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimAgentEmployee as DST
	using ETL_trwAgentEmployees as SRC
	on (src.AgentEmployeeID = DST.AgentEmployeeID)

	when not matched by target then
	insert
	(
	AgentEmployeeID,
	AgentBranchID,
	UserName,
	SecurityAnswer,
	Name,
	PanDetailID,
	BankName,
	BankAddress,
	BankAccountType,
	BankAccountNo,
	BankMICR,
	BankIFSCCode,
	DateofBirth,
	AnniversaryDate,
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
	EntityID,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.AgentEmployeeID,
	SRC.AgentBranchID,
	SRC.UserName,
	SRC.SecurityAnswer,
	SRC.Name,
	SRC.PanDetailID,
	SRC.BankName,
	SRC.BankAddress,
	SRC.BankAccountType,
	SRC.BankAccountNo,
	SRC.BankMICR,
	SRC.BankIFSCCode,
	SRC.DateofBirth,
	SRC.AnniversaryDate,
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
	SRC.EntityID,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.AgentBranchID = SRC.AgentBranchID,
		DST.UserName = SRC.UserName,
		DST.SecurityAnswer = SRC.SecurityAnswer,
		DST.Name = SRC.Name,
		DST.PanDetailID = SRC.PanDetailID,
		DST.BankName = SRC.BankName,
		DST.BankAddress = SRC.BankAddress,
		DST.BankAccountType = SRC.BankAccountType,
		DST.BankAccountNo = SRC.BankAccountNo,
		DST.BankMICR = SRC.BankMICR,
		DST.BankIFSCCode = SRC.BankIFSCCode,
		DST.DateofBirth = SRC.DateofBirth,
		DST.AnniversaryDate = SRC.AnniversaryDate,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbAgentEmployees', '',@insertcount, @updatecount, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentEmployees', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Agent', 'Update', @insertcount, @updatecount, 2, 2, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgentEmployees', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimAgentEmployee', 'Process_StarDimension_AgentEmployee', 'Package_Error_Log', 'Failed', 'Star Dimension - Agent', '', 0, 0, 2, 2, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 2, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
