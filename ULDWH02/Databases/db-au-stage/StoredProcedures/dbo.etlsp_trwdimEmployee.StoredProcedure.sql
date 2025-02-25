USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimEmployee]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimEmployee]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbEmployees', '',0,0, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbEmployees', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Employee', 'Insert', 0, 0, 2, 1, NULL, NULL, NULL

	if object_id('dbo.trwdimEmployee') is null
	BEGIN
    
		create table dbo.trwdimEmployee
		(
			EmployeeSK					int identity(1,1) not null,
			EmployeeID					int not null,
			EmployeeCode				nvarchar(50) null,
			FirstName					nvarchar(50) null,
			MiddleName					nvarchar(50) null,
			LastName					nvarchar(50) null,
			DesignationID				int null,
			DepartmentID				int null,
			BranchID					int null,
			AreaID						int null,
			RegionID					int null,
			ReportingEmployeeID			int null,
			UserName					nvarchar(256) null,
			SecurityAnswer				nvarchar(50) null,
			DateofJoining				datetime null,
			DateofBirth					datetime null,
			AnniversaryDate				datetime null,
			SalaryGrossSalary			numeric(18, 0) null,
			SalaryConveyance			numeric(18, 0) null,
			SalaryMobileExpenses		numeric(18, 0) null,
			SalaryPFContribution		numeric(18, 0) null,
			SalaryBonus					numeric(18, 0) null,
			EmailAddress				nvarchar(100) null,
			EntityID					int null,
			Status						nvarchar(50) null,
			InsertDate					datetime null,
			updateDate					datetime null,
			HashKey						varbinary(50) null
		)
        
		create clustered index idx_dimEmployee_EmployeeSK on dbo.trwdimEmployee(EmployeeSK)
		create nonclustered index idx_dimEmployee_EmployeeID on dbo.trwdimEmployee(EmployeeID)
		create nonclustered index idx_dimEmployee_HashKey on trwdimEmployee(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwEmployees
	set 
		HashKey = binary_checksum(EmployeeID, EmployeeCode, FirstName, MiddleName, LastName, DesignationID, DepartmentID, BranchID, AreaID, RegionID, ReportingEmployeeID,
				UserName, SecurityAnswer, DateofJoining, DateofBirth, AnniversaryDate, SalaryGrossSalary, SalaryConveyance, SalaryMobileExpenses, SalaryPFContribution,
				SalaryBonus, EmailAddress, EntityID, Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwEmployees


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimEmployee as DST
	using ETL_trwEmployees as SRC
	on (src.EmployeeID = DST.EmployeeID)

	when not matched by target then
	insert
	(
	EmployeeID,
	EmployeeCode,
	FirstName,
	MiddleName,
	LastName,
	DesignationID,
	DepartmentID,
	BranchID,
	AreaID,
	RegionID,
	ReportingEmployeeID,
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
	EntityID,
	Status,
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
	SRC.DesignationID,
	SRC.DepartmentID,
	SRC.BranchID,
	SRC.AreaID,
	SRC.RegionID,
	SRC.ReportingEmployeeID,
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
	SRC.EntityID,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.EmployeeCode = SRC.EmployeeCode,
		DST.FirstName = SRC.FirstName,
		DST.MiddleName = SRC.MiddleName,
		DST.LastName = SRC.LastName,
		DST.DesignationID = SRC.DesignationID,
		DST.DepartmentID = SRC.DepartmentID,
		DST.BranchID = SRC.BranchID,
		DST.AreaID = SRC.AreaID,
		DST.RegionID = SRC.RegionID,
		DST.ReportingEmployeeID = SRC.ReportingEmployeeID,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbEmployees', '',@insertcount, @updatecount, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbEmployees', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Employee', 'Update', @insertcount, @updatecount, 2, 1, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbEmployees', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimEmployee', 'Process_StarDimension_Employee', 'Package_Error_Log', 'Failed', 'Star Dimension - Employee', '', 0, 0, 2, 1, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			


--exec [etlsp_dimEmployee] '1558484B-BDFF-437F-A12B-F7CAEEE49BC5', '{14B94763-72D4-4B9C-BB80-B7CC835A88EC}' ,'fghdfg', '33d', 'StarDimension'
GO
