USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwAgentEmployee]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [db-au-stage]

CREATE procedure [dbo].[etlsp_trwAgentEmployee]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

SET NOCOUNT ON

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'trwAgentEmployee', '',0,0
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwAgentEmployee', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Process Dimension Facts - Policy', 'Insert', 0, 0, 3, 1, NULL, NULL, NULL

	if object_id('[db-au-stage].dbo.trwAgentEmployeeTemp') is not null
	BEGIN
		DROP TABLE [db-au-stage].dbo.trwAgentEmployeeTemp

		CREATE TABLE [db-au-stage].dbo.[trwAgentEmployeeTemp] (
				[AgentEmployeeID]							int,
				[UserName]									nvarchar(256),
				[SecurityAnswer]							nvarchar(50),
				[AgentEmployee]								nvarchar(500),
				[BankName]									nvarchar(500),
				[BankAddress]								nvarchar(1000),
				[BankAccountType]							nvarchar(50),
				[BankAccountNo]								nvarchar(50),
				[BankMICR]									nvarchar(50),
				[BankIFSCCode]								nvarchar(50),
				[DateofBirth]								datetime,
				[AnniversaryDate]							datetime,
				[Address1]									nvarchar(500),
				[Address2]									nvarchar(500),
				[City]										nvarchar(50),
				[District]									nvarchar(50),
				[State]										nvarchar(50),
				[PinCode]									nvarchar(10),
				[Country]									nvarchar(100),
				[PhoneNo]									nvarchar(50),
				[MobileNo]									nvarchar(50),
				[EmailAddress]								nvarchar(50),
				[AgentEmployeeStatus]						nvarchar(50),
				[AgentBranchID]								int,
				[AgentBranch]								nvarchar(500),
				[AgentBranchDateofCreation]					datetime,
				[ContactPerson]								nvarchar(50),
				[AgentID]									int,
				[Agent]										nvarchar(500),
				[CompanyName]								nvarchar(250),
				[CentralisedInvoicing]						bit,
				[CommissionType]							nvarchar(50),
				[AgentType]									nvarchar(50),
				[AgentMarketingExecutiveEmployeeID]			int,
				[AgentMarketingExecutive]					nvarchar(500),
				[AgentBranchME]								nvarchar(500),
				[AgentBranchMECode]							nvarchar(50),
				[AgentDateofCreation]						datetime,
				[MasterNumber]								nvarchar(50),
				[SpouseName]								nvarchar(50),
				[SpouseDOB]									datetime,
				[Kid1]										nvarchar(250),
				[Kid1DOB]									datetime,
				[Kid2]										nvarchar(500),
				[Kid2DOB]									datetime,
				[AgentStatus]								nvarchar(50),
				[ExtraComments]								nvarchar(max),
				[NoPANAgent]								bit,
				[Reference]									nvarchar(1000),
				[TypeOfAgent]								nvarchar(100),
				[CreditAmount]								numeric(18,2),
				[EntityID]									int,
				[Entity]									nvarchar(500),
				[EntityType]								nvarchar(50),
				[hashkey]									varbinary(50)
	)
	END
	ELSE
	BEGIN
		CREATE TABLE [db-au-stage].dbo.[trwAgentEmployeeTemp] (
				[AgentEmployeeID]							int,
				[UserName]									nvarchar(256),
				[SecurityAnswer]							nvarchar(50),
				[AgentEmployee]								nvarchar(500),
				[BankName]									nvarchar(500),
				[BankAddress]								nvarchar(1000),
				[BankAccountType]							nvarchar(50),
				[BankAccountNo]								nvarchar(50),
				[BankMICR]									nvarchar(50),
				[BankIFSCCode]								nvarchar(50),
				[DateofBirth]								datetime,
				[AnniversaryDate]							datetime,
				[Address1]									nvarchar(500),
				[Address2]									nvarchar(500),
				[City]										nvarchar(50),
				[District]									nvarchar(50),
				[State]										nvarchar(50),
				[PinCode]									nvarchar(10),
				[Country]									nvarchar(100),
				[PhoneNo]									nvarchar(50),
				[MobileNo]									nvarchar(50),
				[EmailAddress]								nvarchar(50),
				[AgentEmployeeStatus]						nvarchar(50),
				[AgentBranchID]								int,
				[AgentBranch]								nvarchar(500),
				[AgentBranchDateofCreation]					datetime,
				[ContactPerson]								nvarchar(50),
				[AgentID]									int,
				[Agent]										nvarchar(500),
				[CompanyName]								nvarchar(250),
				[CentralisedInvoicing]						bit,
				[CommissionType]							nvarchar(50),
				[AgentType]									nvarchar(50),
				[AgentMarketingExecutiveEmployeeID]			int,
				[AgentMarketingExecutive]					nvarchar(500),
				[AgentBranchME]								nvarchar(500),
				[AgentBranchMECode]							nvarchar(50),
				[AgentDateofCreation]						datetime,
				[MasterNumber]								nvarchar(50),
				[SpouseName]								nvarchar(50),
				[SpouseDOB]									datetime,
				[Kid1]										nvarchar(250),
				[Kid1DOB]									datetime,
				[Kid2]										nvarchar(500),
				[Kid2DOB]									datetime,
				[AgentStatus]								nvarchar(50),
				[ExtraComments]								nvarchar(max),
				[NoPANAgent]								bit,
				[Reference]									nvarchar(1000),
				[TypeOfAgent]								nvarchar(100),
				[CreditAmount]								numeric(18,2),
				[EntityID]									int,
				[Entity]									nvarchar(500),
				[EntityType]								nvarchar(50),
				[hashkey]									varbinary(50)
	)


	END

	create clustered index idx_trwAgentEmployeeTemp_AgentEmployeeID on [db-au-stage].dbo.trwAgentEmployeeTemp(AgentEmployeeID)
	create nonclustered index idx_trwAgentEmployeeTemp_AgentBranchID on [db-au-stage].dbo.trwAgentEmployeeTemp(AgentBranchID)
	create nonclustered index idx_trwAgentEmployeeTemp_AgentMarketingExecutiveEmployeeID on [db-au-stage].dbo.trwAgentEmployeeTemp(AgentMarketingExecutiveEmployeeID)
	create nonclustered index idx_trwAgentEmployeeTemp_EntityID on [db-au-stage].dbo.trwAgentEmployeeTemp(EntityID)
	create nonclustered index idx_trwAgentEmployeeTemp_HashKey on [db-au-stage].dbo.trwAgentEmployeeTemp(HashKey)

	insert into [db-au-stage].dbo.trwAgentEmployeeTemp
		(AgentEmployeeID,UserName,SecurityAnswer,AgentEmployee,BankName,BankAddress,BankAccountType,BankAccountNo,BankMICR,BankIFSCCode,DateofBirth,
			AnniversaryDate,Address1,Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,AgentEmployeeStatus,AgentBranchID,AgentBranch,
			AgentBranchDateofCreation,ContactPerson,AgentID,Agent,CompanyName,CentralisedInvoicing,CommissionType,AgentType,AgentMarketingExecutiveEmployeeID,AgentMarketingExecutive,
			AgentBranchME,AgentBranchMECode,AgentDateofCreation,MasterNumber,SpouseName,SpouseDOB,Kid1,Kid1DOB,Kid2,Kid2DOB,AgentStatus,ExtraComments,NoPANAgent,
			Reference,TypeOfAgent,CreditAmount,EntityID,Entity,EntityType)
	select distinct ae.AgentEmployeeID, ae.UserName, ae.SecurityAnswer, ae.Name AgentEmployee, ae.BankName, ae.BankAddress, ae.BankAccountType, ae.BankAccountNo,
		ae.BankMICR, ae.BankIFSCCode, ae.DateofBirth, ae.AnniversaryDate, ae.Address1, ae.Address2, ae.City, ae.District, ae.State, ae.PinCode, ae.Country,
		ae.PhoneNo, ae.MobileNo, ae.EmailAddress, ae.Status AgentEmployeeStatus,
		ab.AgentBranchID, ab.Name AgentBranch, ab.DateofCreation AgentBranchDateofCreation, ab.ContactPerson,
		ag.AgentID, ag.Name Agent, ag.CompanyName, ag.CentralisedInvoicing, ag.CommissionType, agt.AgentType,
		ag.MarketingExecutiveEmployeeID AgentMarketingExecutiveEmployeeID,
		isnull(emp.FirstName, '') + ' ' + isnull(emp.MiddleName, '') + ' ' + isnull(emp.LastName, '') [Marketing Executive],
		isnull(empme.FirstName, '') + ' ' + isnull(empme.MiddleName, '') + ' ' + isnull(empme.LastName, '') [Agent Branch ME], isnull(empme.EmployeeCode, '') [Agent Branch ME Code],
		ag.DateofCreation AgentDateofCreation, ag.MasterNumber, ag.SpouseName, ag.SpouseDOB, ag.Kid1, ag.Kid1DOB, ag.Kid2, ag.Kid2DOB, ag.Status AgentStatus,
		convert(nvarchar(max), ag.ExtraComments), ag.NoPANAgent, ag.Reference, ag.TypeOfAgent, ag.CreditAmount,
		Ent.EntityID, Ent.Name Entity, EntityType
	from [db-au-stage].dbo.[trwdimAgentEmployee] ae
	left outer join [db-au-stage].dbo.[trwdimAgentBranch] ab
	on ab.AgentBranchID = ae.AgentBranchID
	left outer join [db-au-stage].dbo.[trwdimAgent] ag
	on ag.AgentID = ab.AgentID
	left outer join [db-au-stage].dbo.[trwdimAgentType] agt
	on agt.AgentTypeID = ag.AgentTypeID

	left outer join [db-au-stage].dbo.[trwdimEmployee] emp with (nolock)
	on ag.MarketingExecutiveEmployeeID = emp.EmployeeID

	left outer join [db-au-stage].dbo.[trwdimAgentBranchMe] abme with (nolock)
	on ag.AgentID = abme.AgentID
		and ab.AgentBranchID = abme.AgentBranchID

	left outer join [db-au-stage].dbo.[trwdimEmployee] empme with (nolock)
	on abme.MarketingEmployeeId = empme.EmployeeID

	left outer join [db-au-stage].dbo.[trwdimEntity] Ent
	on ag.EntityID = Ent.EntityID
	left outer join [db-au-stage].dbo.[trwdimEntityType] Enty
	on Ent.EntityTypeID = Enty.EntityTypeID
	order by 1

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update [db-au-stage].dbo.trwAgentEmployeeTemp
	set 
		HashKey = binary_checksum(AgentEmployeeID,UserName,SecurityAnswer,AgentEmployee,BankName,BankAddress,BankAccountType,BankAccountNo,BankMICR,BankIFSCCode,DateofBirth,
									AnniversaryDate,Address1,Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,AgentEmployeeStatus,AgentBranchID,AgentBranch,
									AgentBranchDateofCreation,ContactPerson,AgentID,Agent,CompanyName,CentralisedInvoicing,CommissionType,AgentType,AgentMarketingExecutiveEmployeeID,AgentMarketingExecutive,
									AgentBranchME,AgentBranchMECode,AgentDateofCreation,MasterNumber,SpouseName,SpouseDOB,Kid1,Kid1DOB,Kid2,Kid2DOB,AgentStatus,ExtraComments,NoPANAgent,
									Reference,TypeOfAgent,CreditAmount,EntityID,Entity,EntityType)

--select * from [db-au-stage].dbo.trwAgentEmployeeTemp

	select
		@sourcecount = count(*)
	from
		[db-au-stage].dbo.trwAgentEmployeeTemp

	if object_id('[db-au-cmdwh].dbo.trwAgentEmployee') is null
	BEGIN

		CREATE TABLE [db-au-cmdwh].dbo.[trwAgentEmployee] (
		[AgentEmployeeSK]						int identity(1,1) not null,
		[AgentEmployeeID]						int not null,
		[UserName]									nvarchar(256),
		[SecurityAnswer]							nvarchar(50),
		[AgentEmployee]								nvarchar(500),
		[BankName]									nvarchar(500),
		[BankAddress]								nvarchar(1000),
		[BankAccountType]							nvarchar(50),
		[BankAccountNo]								nvarchar(50),
		[BankMICR]									nvarchar(50),
		[BankIFSCCode]								nvarchar(50),
		[DateofBirth]								datetime,
		[AnniversaryDate]							datetime,
		[Address1]									nvarchar(500),
		[Address2]									nvarchar(500),
		[City]										nvarchar(50),
		[District]									nvarchar(50),
		[State]										nvarchar(50),
		[PinCode]									nvarchar(10),
		[Country]									nvarchar(100),
		[PhoneNo]									nvarchar(50),
		[MobileNo]									nvarchar(50),
		[EmailAddress]								nvarchar(50),
		[AgentEmployeeStatus]						nvarchar(50),
		[AgentBranchID]								int,
		[AgentBranch]								nvarchar(500),
		[AgentBranchDateofCreation]					datetime,
		[ContactPerson]								nvarchar(50),
		[AgentID]									int,
		[Agent]										nvarchar(500),
		[CompanyName]								nvarchar(250),
		[CentralisedInvoicing]						bit,
		[CommissionType]							nvarchar(50),
		[AgentType]									nvarchar(50),
		[AgentMarketingExecutiveEmployeeID]			int,
		[AgentMarketingExecutive]					nvarchar(500),
		[AgentBranchME]								nvarchar(500),
		[AgentBranchMECode]							nvarchar(50),
		[AgentDateofCreation]						datetime,
		[MasterNumber]								nvarchar(50),
		[SpouseName]								nvarchar(50),
		[SpouseDOB]									datetime,
		[Kid1]										nvarchar(250),
		[Kid1DOB]									datetime,
		[Kid2]										nvarchar(500),
		[Kid2DOB]									datetime,
		[AgentStatus]								nvarchar(50),
		[ExtraComments]								nvarchar(max),
		[NoPANAgent]								bit,
		[Reference]									nvarchar(1000),
		[TypeOfAgent]								nvarchar(100),
		[CreditAmount]								numeric(18,2),
		[EntityID]									int,
		[Entity]									nvarchar(500),
		[EntityType]								nvarchar(50),
		[InsertDate]							datetime null,
		[updateDate]							datetime null,
		[hashkey]								varbinary(50) null
	)

	create clustered index idx_trwAgentEmployee_AgentEmployeeSK on [db-au-cmdwh].dbo.trwAgentEmployee(AgentEmployeeSK)
	create nonclustered index idx_trwAgentEmployee_AgentEmployeeID on [db-au-cmdwh].dbo.trwAgentEmployee(AgentEmployeeID)
	create nonclustered index idx_trwAgentEmployee_AgentBranchID on [db-au-cmdwh].dbo.trwAgentEmployee(AgentBranchID)
	create nonclustered index idx_trwAgentEmployee_AgentID on [db-au-cmdwh].dbo.trwAgentEmployee(AgentID)
	create nonclustered index idx_trwAgentEmployee_AgentMarketingExecutiveEmployeeID on [db-au-cmdwh].dbo.trwAgentEmployee(AgentMarketingExecutiveEmployeeID)
	create nonclustered index idx_trwAgentEmployee_EntityID on [db-au-cmdwh].dbo.trwAgentEmployee(EntityID)
	create nonclustered index idx_trwAgentEmployee_HashKey on [db-au-cmdwh].dbo.trwAgentEmployee(HashKey)

	END

BEGIN TRANSACTION;

BEGIN TRY

	merge into [db-au-cmdwh].dbo.trwAgentEmployee as DST
	using [db-au-stage].dbo.trwAgentEmployeeTemp as SRC
	on (src.AgentEmployeeID = DST.AgentEmployeeID)

	when not matched by target then
	insert
	(
	AgentEmployeeID,
	UserName,
	SecurityAnswer,
	AgentEmployee,
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
	AgentEmployeeStatus,
	AgentBranchID,
	AgentBranch,
	AgentBranchDateofCreation,
	ContactPerson,
	AgentID,
	Agent,
	CompanyName,
	CentralisedInvoicing,
	CommissionType,
	AgentType,
	AgentMarketingExecutiveEmployeeID,
	AgentMarketingExecutive,
	AgentBranchME,
	AgentBranchMECode,
	AgentDateofCreation,
	MasterNumber,
	SpouseName,
	SpouseDOB,
	Kid1,
	Kid1DOB,
	Kid2,
	Kid2DOB,
	AgentStatus,
	ExtraComments,
	NoPANAgent,
	Reference,
	TypeOfAgent,
	CreditAmount,
	EntityID,
	Entity,
	EntityType,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.AgentEmployeeID,
	SRC.UserName,
	SRC.SecurityAnswer,
	SRC.AgentEmployee,
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
	SRC.AgentEmployeeStatus,
	SRC.AgentBranchID,
	SRC.AgentBranch,
	SRC.AgentBranchDateofCreation,
	SRC.ContactPerson,
	SRC.AgentID,
	SRC.Agent,
	SRC.CompanyName,
	SRC.CentralisedInvoicing,
	SRC.CommissionType,
	SRC.AgentType,
	SRC.AgentMarketingExecutiveEmployeeID,
	SRC.AgentMarketingExecutive,
	SRC.AgentBranchME,
	SRC.AgentBranchMECode,
	SRC.AgentDateofCreation,
	SRC.MasterNumber,
	SRC.SpouseName,
	SRC.SpouseDOB,
	SRC.Kid1,
	SRC.Kid1DOB,
	SRC.Kid2,
	SRC.Kid2DOB,
	SRC.AgentStatus,
	SRC.ExtraComments,
	SRC.NoPANAgent,
	SRC.Reference,
	SRC.TypeOfAgent,
	SRC.CreditAmount,
	SRC.EntityID,
	SRC.Entity,
	SRC.EntityType,
	getdate(),
	null,
	SRC.HashKey
	)

	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.UserName = SRC.UserName,
		DST.SecurityAnswer = SRC.SecurityAnswer,
		DST.AgentEmployee = SRC.AgentEmployee,
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
		DST.AgentEmployeeStatus = SRC.AgentEmployeeStatus,
		DST.AgentBranchID = SRC.AgentBranchID,
		DST.AgentBranch = SRC.AgentBranch,
		DST.AgentBranchDateofCreation = SRC.AgentBranchDateofCreation,
		DST.ContactPerson = SRC.ContactPerson,
		DST.AgentID = SRC.AgentID,
		DST.Agent = SRC.Agent,
		DST.CompanyName = SRC.CompanyName,
		DST.CentralisedInvoicing = SRC.CentralisedInvoicing,
		DST.CommissionType = SRC.CommissionType,
		DST.AgentType = SRC.AgentType,
		DST.AgentMarketingExecutiveEmployeeID = SRC.AgentMarketingExecutiveEmployeeID,
		DST.AgentMarketingExecutive = SRC.AgentMarketingExecutive,
		DST.AgentBranchME = SRC.AgentBranchME,
		DST.AgentBranchMECode = SRC.AgentBranchMECode,
		DST.AgentDateofCreation = SRC.AgentDateofCreation,
		DST.MasterNumber = SRC.MasterNumber,
		DST.SpouseName = SRC.SpouseName,
		DST.SpouseDOB = SRC.SpouseDOB,
		DST.Kid1 = SRC.Kid1,
		DST.Kid1DOB = SRC.Kid1DOB,
		DST.Kid2 = SRC.Kid2,
		DST.Kid2DOB = SRC.Kid2DOB,
		DST.AgentStatus = SRC.AgentStatus,
		DST.ExtraComments = SRC.ExtraComments,
		DST.NoPANAgent = SRC.NoPANAgent,
		DST.Reference = SRC.Reference,
		DST.TypeOfAgent = SRC.TypeOfAgent,
		DST.CreditAmount = SRC.CreditAmount,
		DST.EntityID = SRC.EntityID,
		DST.Entity = SRC.Entity,
		DST.EntityType = SRC.EntityType,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'trwAgentEmployee', '',@insertcount, @updatecount
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwAgentEmployee', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Process Dimension Facts - Policy', 'Update', @insertcount, @updatecount, 3, 1, NULL, NULL, NULL

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

	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwAgentEmployee', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwAgentEmployee', 'Process_etlsp_trwEmployee_DWH', 'Package_Error_Log', 'Failed', 'Process Dimension Facts - Policy', '', 0, 0, 3, 1, NULL, NULL, NULL

	exec [db-au-stage].dbo.etlsp_trwPackageStatus  'END', 3, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END


select * from ETL_trwPackageStatus order by 1

--update ETL_trwPackageStatus set CurrentRunStartDate = getdate() - 1, CurrentRunEndDate = getdate() - 1
--where PackageID = 3
GO
