USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwEmployee]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [db-au-stage]

CREATE procedure [dbo].[etlsp_trwEmployee]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

SET NOCOUNT ON

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'trwEmployee', '',0,0
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwEmployee', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Process Dimension Facts - Policy', 'Insert', 0, 0, 3, 1, NULL, NULL, NULL

	if object_id('[db-au-stage].dbo.trwEmployeeTemp') is not null
	BEGIN
		DROP TABLE [db-au-stage].dbo.trwEmployeeTemp

		CREATE TABLE [db-au-stage].dbo.[trwEmployeeTemp] (
		[EmployeeID]							int,
		[EmployeeCode]							nvarchar(50),
		[FirstName]								nvarchar(50),
		[MiddleName]							nvarchar(50),
		[LastName]								nvarchar(50),
		[ReportingManager]						nvarchar(500),
		[UserName]								nvarchar(256),
		[SecurityAnswer]						nvarchar(50),
		[DateofJoining]							datetime,
		[DateofBirth]							datetime,
		[AnniversaryDate]						datetime,
		[SalaryGrossSalary]						numeric(18,0),
		[SalaryConveyance]						numeric(18,0),
		[SalaryMobileExpenses]					numeric(18,0),
		[SalaryPFContribution]					numeric(18,0),
		[SalaryBonus]							numeric(18,0),
		[EmailAddress]							nvarchar(100),
		[Status]								nvarchar(50),
		[DesignationID]							int,
		[Designation]							nvarchar(50),
		[SeqNo]									int,
		[EmployeeIncentiveStructureCPercent]	numeric(18,2),
		[DepartmentID]							int,
		[Department]							nvarchar(50),
		[BranchID]								int,
		[Branch]								nvarchar(50),
		[DOC]									datetime,
		[Address1]								nvarchar(500),
		[Address2]								nvarchar(500),
		[City]									nvarchar(50),
		[District]								nvarchar(50),
		[State]									nvarchar(50),
		[PinCode]								nvarchar(10),
		[Country]								nvarchar(100),
		[BillingName]							nvarchar(50),
		[BranManager]							nvarchar(152),
		[MaxDiscount]							numeric(18,2),
		[AreaID]								int,
		[Area]									nvarchar(50),
		[AreaManager]							nvarchar(255),
		[RegionID]								int,
		[Region]								nvarchar(50),
		[RegionManager]							nvarchar(255),
		[EntityID]								int,
		[Entity]								nvarchar(500),
		[EntityType]							nvarchar(50),
		[hashkey]								varbinary(50)
	)
	END
	ELSE
	BEGIN
		CREATE TABLE [db-au-stage].dbo.[trwEmployeeTemp] (
		[EmployeeID]							int,
		[EmployeeCode]							nvarchar(50),
		[FirstName]								nvarchar(50),
		[MiddleName]							nvarchar(50),
		[LastName]								nvarchar(50),
		[ReportingManager]						nvarchar(500),
		[UserName]								nvarchar(256),
		[SecurityAnswer]						nvarchar(50),
		[DateofJoining]							datetime,
		[DateofBirth]							datetime,
		[AnniversaryDate]						datetime,
		[SalaryGrossSalary]						numeric(18,0),
		[SalaryConveyance]						numeric(18,0),
		[SalaryMobileExpenses]					numeric(18,0),
		[SalaryPFContribution]					numeric(18,0),
		[SalaryBonus]							numeric(18,0),
		[EmailAddress]							nvarchar(100),
		[Status]								nvarchar(50),
		[DesignationID]							int,
		[Designation]							nvarchar(50),
		[SeqNo]									int,
		[EmployeeIncentiveStructureCPercent]	numeric(18,2),
		[DepartmentID]							int,
		[Department]							nvarchar(50),
		[BranchID]								int,
		[Branch]								nvarchar(50),
		[DOC]									datetime,
		[Address1]								nvarchar(500),
		[Address2]								nvarchar(500),
		[City]									nvarchar(50),
		[District]								nvarchar(50),
		[State]									nvarchar(50),
		[PinCode]								nvarchar(10),
		[Country]								nvarchar(100),
		[BillingName]							nvarchar(50),
		[BranManager]							nvarchar(152),
		[MaxDiscount]							numeric(18,2),
		[AreaID]								int,
		[Area]									nvarchar(50),
		[AreaManager]							nvarchar(255),
		[RegionID]								int,
		[Region]								nvarchar(50),
		[RegionManager]							nvarchar(255),
		[EntityID]								int,
		[Entity]								nvarchar(500),
		[EntityType]							nvarchar(50),
		[hashkey]								varbinary(50)
	)

	END

	create clustered index idx_trwEmployeeTemp_EmployeeID on [db-au-stage].dbo.trwEmployeeTemp(EmployeeID)
	create nonclustered index idx_trwEmployeeTemp_DesignationID on [db-au-stage].dbo.trwEmployeeTemp(DesignationID)
	create nonclustered index idx_trwEmployeeTemp_DepartmentID on [db-au-stage].dbo.trwEmployeeTemp(DepartmentID)
	create nonclustered index idx_trwEmployeeTemp_BranchID on [db-au-stage].dbo.trwEmployeeTemp(BranchID)
	create nonclustered index idx_trwEmployeeTemp_RegionID on [db-au-stage].dbo.trwEmployeeTemp(RegionID)
	create nonclustered index idx_trwEmployeeTemp_EntityID on [db-au-stage].dbo.trwEmployeeTemp(EntityID)
	create nonclustered index idx_trwEmployeeTemp_HashKey on [db-au-stage].dbo.trwEmployeeTemp(HashKey)

	insert into [db-au-stage].dbo.trwEmployeeTemp
		(EmployeeID, EmployeeCode, FirstName, MiddleName, LastName, ReportingManager, UserName, SecurityAnswer, DateofJoining, DateofBirth ,AnniversaryDate, SalaryGrossSalary,
		SalaryConveyance, SalaryMobileExpenses, SalaryPFContribution, SalaryBonus, EmailAddress, Status, DesignationID, Designation, SeqNo, EmployeeIncentiveStructureCPercent,
		DepartmentID, Department, BranchID, Branch, DOC, Address1,Address2, City, District, State, PinCode, Country ,BillingName, BranManager, MaxDiscount, AreaID, Area, AreaManager,
		RegionID, Region, RegionManager, EntityID, Entity, EntityType)
	select Emp.EmployeeID, Emp.EmployeeCode, Emp.FirstName, Emp.MiddleName, Emp.LastName,
		isnull(EmpRepo.FirstName, '') + ' ' + isnull(EmpRepo.MiddleName, '') + ' ' + isnull(EmpRepo.LastName, '') ReportingManager, Emp.UserName, Emp.SecurityAnswer,
		Emp.DateofJoining, Emp.DateofBirth, Emp.AnniversaryDate, Emp.SalaryGrossSalary, Emp.SalaryConveyance, Emp.SalaryMobileExpenses, Emp.SalaryPFContribution, Emp.SalaryBonus, Emp.EmailAddress,
		Emp.Status,
		Desg.DesignationID, Desg.Designation, SeqNo, EmployeeIncentiveStructureCPercent, Dept.DepartmentID, Dept.Department,
		Bran.BranchID, Bran.Name Branch, Bran.DOC, Bran.Address1, Bran.Address2, Bran.City, Bran.District, Bran.State, Bran.PinCode, Bran.Country, Bran.BillingName,
		isnull(EmpBran.FirstName, '') + ' ' + isnull(EmpBran.MiddleName, '') + ' ' + isnull(EmpBran.LastName, '') BranManager, Bran.MaxDiscount,
		Area.AreaID, Area.Name Area, isnull(EmpArea.FirstName, '') + ' ' + isnull(EmpArea.MiddleName, '') + ' ' + isnull(EmpArea.LastName, '') AreaManager,
		Regi.RegionID, Regi.Name Region, isnull(EmpArea.FirstName, '') + ' ' + isnull(EmpArea.MiddleName, '') + ' ' + isnull(EmpArea.LastName, '') RegionManager,
		Ent.EntityID, Ent.Name Entity, EntityType
	from [db-au-stage].[dbo].[trwdimEmployee] Emp
	inner join [db-au-stage].[dbo].[trwdimDesignation] Desg
	on Emp.DesignationID = Desg.DesignationID
	inner join [db-au-stage].[dbo].[trwdimDepartment] Dept
	on Emp.DepartmentID = Dept.DepartmentID
	left outer join [db-au-stage].[dbo].[trwdimBranch] Bran
	on Emp.BranchID = Bran.BranchID
	left outer join [db-au-stage].[dbo].[trwdimArea] Area
	on Bran.AreaID = Area.AreaID
	left outer join [db-au-stage].[dbo].[trwdimRegion] Regi
	on Area.RegionID = Regi.RegionID
	left outer join [db-au-stage].[dbo].[trwdimEntity] Ent
	on Emp.EntityID = Ent.EntityID
	inner join [db-au-stage].[dbo].[trwdimEntityType] Enty
	on Ent.EntityTypeID = Enty.EntityTypeID
	left outer join [db-au-stage].[dbo].[trwdimEmployee] EmpRepo
	on EmpRepo.EmployeeID = Emp.ReportingEmployeeID
	left outer join [db-au-stage].[dbo].[trwdimEmployee] EmpBran
	on Bran.ManagerEmployeeID = EmpBran.EmployeeID
	left outer join [db-au-stage].[dbo].[trwdimEmployee] EmpArea
	on Area.ManagerEmployeeID = EmpArea.EmployeeID
	left outer join [db-au-stage].[dbo].[trwdimEmployee] EmpReg
	on Regi.ManagerEmployeeID = EmpReg.EmployeeID
	order by 1

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update [db-au-stage].dbo.trwEmployeeTemp
	set 
		HashKey = binary_checksum(EmployeeID, EmployeeCode, FirstName, MiddleName, LastName, ReportingManager, UserName, SecurityAnswer, DateofJoining, DateofBirth ,AnniversaryDate, SalaryGrossSalary,
					SalaryConveyance, SalaryMobileExpenses, SalaryPFContribution, SalaryBonus, EmailAddress, Status, DesignationID, Designation, SeqNo, EmployeeIncentiveStructureCPercent,
					DepartmentID, Department, BranchID, Branch, DOC, Address1,Address2, City, District, State, PinCode, Country ,BillingName, BranManager, MaxDiscount, AreaID, Area, AreaManager,
					RegionID, Region, RegionManager, EntityID, Entity, EntityType)

--select * from [db-au-stage].dbo.trwEmployeeTemp

	select
		@sourcecount = count(*)
	from
		[db-au-stage].dbo.trwEmployeeTemp

	if object_id('[db-au-cmdwh].dbo.trwEmployee') is null
	BEGIN

		CREATE TABLE [db-au-cmdwh].dbo.[trwEmployee] (
		[EmployeeSK]							int identity(1,1) not null,
		[EmployeeID]							int not null,
		[EmployeeCode]							nvarchar(50) null,
		[FirstName]								nvarchar(50) null,
		[MiddleName]							nvarchar(50) null,
		[LastName]								nvarchar(50) null,
		[ReportingManager]						nvarchar(500) null,
		[UserName]								nvarchar(256) null,
		[SecurityAnswer]						nvarchar(50) null,
		[DateofJoining]							datetime null,
		[DateofBirth]							datetime null,
		[AnniversaryDate]						datetime null,
		[SalaryGrossSalary]						numeric(18,0) null,
		[SalaryConveyance]						numeric(18,0) null,
		[SalaryMobileExpenses]					numeric(18,0) null,
		[SalaryPFContribution]					numeric(18,0) null,
		[SalaryBonus]							numeric(18,0) null,
		[EmailAddress]							nvarchar(100) null,
		[Status]								nvarchar(50) null,
		[DesignationID]							int null,
		[Designation]							nvarchar(50) null,
		[SeqNo]									int null,
		[EmployeeIncentiveStructureCPercent]	numeric(18,2) null,
		[DepartmentID]							int null,
		[Department]							nvarchar(50) null,
		[BranchID]								int null,
		[Branch]								nvarchar(50) null,
		[DOC]									datetime null,
		[Address1]								nvarchar(500) null,
		[Address2]								nvarchar(500) null,
		[City]									nvarchar(50) null,
		[District]								nvarchar(50) null,
		[State]									nvarchar(50) null,
		[PinCode]								nvarchar(10) null,
		[Country]								nvarchar(100) null,
		[BillingName]							nvarchar(50) null,
		[BranManager]							nvarchar(152) null,
		[MaxDiscount]							numeric(18,2) null,
		[AreaID]								int null,
		[Area]									nvarchar(50) null,
		[AreaManager]							nvarchar(255) null,
		[RegionID]								int null,
		[Region]								nvarchar(50) null,
		[RegionManager]							nvarchar(255) null,
		[EntityID]								int null,
		[Entity]								nvarchar(500) null,
		[EntityType]							nvarchar(50) null,
		[InsertDate]							datetime null,
		[updateDate]							datetime null,
		[hashkey]								varbinary(50) null
	)

	create clustered index idx_trwEmployee_EmployeeSK on [db-au-cmdwh].dbo.trwEmployee(EmployeeSK)
	create nonclustered index idx_trwEmployee_EmployeeID on [db-au-cmdwh].dbo.trwEmployee(EmployeeID)
	create nonclustered index idx_trwEmployee_DesignationID on [db-au-cmdwh].dbo.trwEmployee(DesignationID)
	create nonclustered index idx_trwEmployee_DepartmentID on [db-au-cmdwh].dbo.trwEmployee(DepartmentID)
	create nonclustered index idx_trwEmployee_BranchID on [db-au-cmdwh].dbo.trwEmployee(BranchID)
	create nonclustered index idx_trwEmployee_RegionID on [db-au-cmdwh].dbo.trwEmployee(RegionID)
	create nonclustered index idx_trwEmployee_EntityID on [db-au-cmdwh].dbo.trwEmployee(EntityID)
	create nonclustered index idx_trwEmployee_HashKey on [db-au-cmdwh].dbo.trwEmployee(HashKey)

	END

BEGIN TRANSACTION;

BEGIN TRY

	merge into [db-au-cmdwh].dbo.trwEmployee as DST
	using [db-au-stage].dbo.trwEmployeeTemp as SRC
	on (src.EmployeeID = DST.EmployeeID)

	when not matched by target then
	insert
	(
	EmployeeID,
	EmployeeCode,
	FirstName,
	MiddleName,
	LastName,
	ReportingManager,
	UserName,
	SecurityAnswer,
	DateofJoining,
	DateofBirth,
	AnniversaryDate,
	SalaryGrossSalary,
	SalaryConveyance,
	SalaryMobileExpenses,
	SalaryPFContribution,
	SalaryBonus,
	EmailAddress,
	Status,
	DesignationID,
	Designation,
	SeqNo,
	EmployeeIncentiveStructureCPercent,
	DepartmentID,
	Department,
	BranchID,
	Branch,
	DOC,
	Address1,
	Address2,
	City,
	District,
	State,
	PinCode,
	Country,
	BillingName,
	BranManager,
	MaxDiscount,
	AreaID,
	Area,
	AreaManager,
	RegionID,
	Region,
	RegionManager,
	EntityID,
	Entity,
	EntityType,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.EmployeeID,
	SRC.EmployeeCode,
	SRC.FirstName,
	SRC.MiddleName,
	SRC.LastName,
	SRC.ReportingManager,
	SRC.UserName,
	SRC.SecurityAnswer,
	SRC.DateofJoining,
	SRC.DateofBirth,
	SRC.AnniversaryDate,
	SRC.SalaryGrossSalary,
	SRC.SalaryConveyance,
	SRC.SalaryMobileExpenses,
	SRC.SalaryPFContribution,
	SRC.SalaryBonus,
	SRC.EmailAddress,
	SRC.Status,
	SRC.DesignationID,
	SRC.Designation,
	SRC.SeqNo,
	SRC.EmployeeIncentiveStructureCPercent,
	SRC.DepartmentID,
	SRC.Department,
	SRC.BranchID,
	SRC.Branch,
	SRC.DOC,
	SRC.Address1,
	SRC.Address2,
	SRC.City,
	SRC.District,
	SRC.State,
	SRC.PinCode,
	SRC.Country,
	SRC.BillingName,
	SRC.BranManager,
	SRC.MaxDiscount,
	SRC.AreaID,
	SRC.Area,
	SRC.AreaManager,
	SRC.RegionID,
	SRC.Region,
	SRC.RegionManager,
	SRC.EntityID,
	SRC.Entity,
	SRC.EntityType,
	getdate(),
	null,
	SRC.HashKey
	)

	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.EmployeeCode = SRC.EmployeeCode,
		DST.FirstName = SRC.FirstName,
		DST.MiddleName = SRC.MiddleName,
		DST.LastName = SRC.LastName,
		DST.ReportingManager = SRC.ReportingManager,
		DST.UserName = SRC.UserName,
		DST.SecurityAnswer = SRC.SecurityAnswer,
		DST.DateofJoining = SRC.DateofJoining,
		DST.DateofBirth = SRC.DateofBirth,
		DST.AnniversaryDate = SRC.AnniversaryDate,
		DST.SalaryGrossSalary = SRC.SalaryGrossSalary,
		DST.SalaryConveyance = SRC.SalaryConveyance,
		DST.SalaryMobileExpenses = SRC.SalaryMobileExpenses,
		DST.SalaryPFContribution = SRC.SalaryPFContribution,
		DST.SalaryBonus = SRC.SalaryBonus,
		DST.EmailAddress = SRC.EmailAddress,
		DST.Status = SRC.Status,
		DST.DesignationID = SRC.DesignationID,
		DST.Designation = SRC.Designation,
		DST.SeqNo = SRC.SeqNo,
		DST.EmployeeIncentiveStructureCPercent = SRC.EmployeeIncentiveStructureCPercent,
		DST.DepartmentID = SRC.DepartmentID,
		DST.Department = SRC.Department,
		DST.BranchID = SRC.BranchID,
		DST.Branch = SRC.Branch,
		DST.DOC = SRC.DOC,
		DST.Address1 = SRC.Address1,
		DST.Address2 = SRC.Address2,
		DST.City = SRC.City,
		DST.District = SRC.District,
		DST.State = SRC.State,
		DST.PinCode = SRC.PinCode,
		DST.Country = SRC.Country,
		DST.BillingName = SRC.BillingName,
		DST.BranManager = SRC.BranManager,
		DST.MaxDiscount = SRC.MaxDiscount,
		DST.AreaID = SRC.AreaID,
		DST.Area = SRC.Area,
		DST.AreaManager = SRC.AreaManager,
		DST.RegionID = SRC.RegionID,
		DST.Region = SRC.Region,
		DST.RegionManager = SRC.RegionManager,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'trwEmployee', '',@insertcount, @updatecount
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwEmployee', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Process Dimension Facts - Policy', 'Update', @insertcount, @updatecount, 3, 1, NULL, NULL, NULL

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

	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwEmployee', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwEmployee', 'Process_etlsp_trwEmployee_DWH', 'Package_Error_Log', 'Failed', 'Process Dimension Facts - Policy', '', 0, 0, 3, 1, NULL, NULL, NULL

	exec [db-au-stage].dbo.etlsp_trwPackageStatus  'END', 3, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
GO
