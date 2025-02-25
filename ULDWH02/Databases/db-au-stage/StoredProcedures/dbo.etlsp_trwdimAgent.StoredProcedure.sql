USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimAgent]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimAgent]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbAgents', '',0,0, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgents', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Agent', 'Insert', 0, 0, 2, 2, NULL, NULL, NULL

	if object_id('dbo.trwdimAgent') is null
	BEGIN
    
		create table dbo.trwdimAgent
		(
			AgentSK								int identity(1,1) not null,
			AgentID								int not null,
			Name								nvarchar(500) null,
			CompanyName							nvarchar(250) null,
			PanDetailID							int null,
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
			CentralisedInvoicing				bit null,
			CommissionType						nvarchar(50) null,
			AgentTypeID							int null,
			BankName							nvarchar(500) null,
			BankAddress							nvarchar(1000) null,
			BankAccountType						nvarchar(50) null,
			BankAccountNo						nvarchar(50) null,
			BankMICR							nvarchar(50) null,
			BankIFSCCode						nvarchar(50) null,
			DateofBirth							datetime null,
			AnniversaryDate						datetime null,
			MarketingExecutiveEmployeeID		int null,
			DateofCreation						datetime null,
			AgentEmployeeID						int null,
			EntityID							int null,
			MasterNumber						nvarchar(50) null,
			SpouseName							nvarchar(50) null,
			SpouseDOB							datetime null,
			Kid1								nvarchar(250) null,
			Kid1DOB								datetime null,
			Kid2								nvarchar(500) null,
			Kid2DOB								datetime null,
			Status								nvarchar(50) null,
			ExtraComments						ntext null,
			NoPANAgent							bit null,
			Reference							nvarchar(1000) null,
			TypeOfAgent							nvarchar(100) null,
			CreditAmount						numeric(18,2) null,
			LogoPath							nvarchar(2000) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimAgent_AgentSK on dbo.trwdimAgent(AgentSK)
		create nonclustered index idx_dimAgent_AgentID on dbo.trwdimAgent(AgentID)
		create nonclustered index idx_dimAgent_PanDetailID on dbo.trwdimAgent(PanDetailID)
		create nonclustered index idx_dimAgent_AgentTypeID on trwdimAgent(AgentTypeID)
		create nonclustered index idx_dimAgent_MarketingExecutiveEmployeeID on dbo.trwdimAgent(MarketingExecutiveEmployeeID)
		create nonclustered index idx_dimAgent_AgentEmployeeID on dbo.trwdimAgent(AgentEmployeeID)
		create nonclustered index idx_dimAgent_HashKey on trwdimAgent(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwAgents
	set 
		HashKey = binary_checksum(AgentID,Name,CompanyName,PanDetailID,ContactPerson,Address1,Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,
						CentralisedInvoicing,CommissionType,AgentTypeID,BankName,BankAddress,BankAccountType,BankAccountNo,BankMICR,BankIFSCCode,DateofBirth,AnniversaryDate,
						MarketingExecutiveEmployeeID,DateofCreation,AgentEmployeeID,EntityID,MasterNumber,SpouseName,SpouseDOB,Kid1,Kid1DOB,Kid2,Kid2DOB,Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwAgents


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimAgent as DST
	using ETL_trwAgents as SRC
	on (src.AgentID = DST.AgentID)

	when not matched by target then
	insert
	(
	AgentID,
	Name,
	CompanyName,
	PanDetailID,
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
	CentralisedInvoicing,
	CommissionType,
	AgentTypeID,
	BankName,
	BankAddress,
	BankAccountType,
	BankAccountNo,
	BankMICR,
	BankIFSCCode,
	DateofBirth,
	AnniversaryDate,
	MarketingExecutiveEmployeeID,
	DateofCreation,
	AgentEmployeeID,
	EntityID,
	MasterNumber,
	SpouseName,
	SpouseDOB,
	Kid1,
	Kid1DOB,
	Kid2,
	Kid2DOB,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.AgentID,
	SRC.Name,
	SRC.CompanyName,
	SRC.PanDetailID,
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
	SRC.CentralisedInvoicing,
	SRC.CommissionType,
	SRC.AgentTypeID,
	SRC.BankName,
	SRC.BankAddress,
	SRC.BankAccountType,
	SRC.BankAccountNo,
	SRC.BankMICR,
	SRC.BankIFSCCode,
	SRC.DateofBirth,
	SRC.AnniversaryDate,
	SRC.MarketingExecutiveEmployeeID,
	SRC.DateofCreation,
	SRC.AgentEmployeeID,
	SRC.EntityID,
	SRC.MasterNumber,
	SRC.SpouseName,
	SRC.SpouseDOB,
	SRC.Kid1,
	SRC.Kid1DOB,
	SRC.Kid2,
	SRC.Kid2DOB,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.Name = SRC.Name,
		DST.CompanyName = SRC.CompanyName,
		DST.PanDetailID = SRC.PanDetailID,
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
		DST.CentralisedInvoicing = SRC.CentralisedInvoicing,
		DST.CommissionType = SRC.CommissionType,
		DST.AgentTypeID = SRC.AgentTypeID,
		DST.BankName = SRC.BankName,
		DST.BankAddress = SRC.BankAddress,
		DST.BankAccountType = SRC.BankAccountType,
		DST.BankAccountNo = SRC.BankAccountNo,
		DST.BankMICR = SRC.BankMICR,
		DST.BankIFSCCode = SRC.BankIFSCCode,
		DST.DateofBirth = SRC.DateofBirth,
		DST.AnniversaryDate = SRC.AnniversaryDate,
		DST.MarketingExecutiveEmployeeID = SRC.MarketingExecutiveEmployeeID,
		DST.DateofCreation = SRC.DateofCreation,
		DST.AgentEmployeeID = SRC.AgentEmployeeID,
		DST.EntityID = SRC.EntityID,
		DST.MasterNumber = SRC.MasterNumber,
		DST.SpouseName = SRC.SpouseName,
		DST.SpouseDOB = SRC.SpouseDOB,
		DST.Kid1 = SRC.Kid1,
		DST.Kid1DOB = SRC.Kid1DOB,
		DST.Kid2 = SRC.Kid2,
		DST.Kid2DOB = SRC.Kid2DOB,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbAgents', '',@insertcount, @updatecount, 2, 2, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgents', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Agent', 'Update', @insertcount, @updatecount, 2, 2, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbAgents', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimAgent', 'Process_StarDimension_Agent', 'Package_Error_Log', 'Failed', 'Star Dimension - Agent', '', 0, 0, 2, 2, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 2, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
