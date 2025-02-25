USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimBranch]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimBranch]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbBranches', '',0,0, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbBranches', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Employee', 'Insert', 0, 0, 2, 1, NULL, NULL, NULL


	if object_id('dbo.trwdimBranch') is null
	BEGIN
    
		create table dbo.trwdimBranch
		(
			BranchSK						int identity(1,1) not null,
			BranchID						int not null,
			Name							nvarchar(50) null,
			DOC								datetime null,
			Address1						nvarchar(500) null,
			Address2						nvarchar(500) null,
			City							nvarchar(50) null,
			District						nvarchar(50) null,
			State							nvarchar(50) null,
			PinCode							nvarchar(10) null,
			Country							nvarchar(100) null,
			BillingName						nvarchar(50) null,
			ManagerEmployeeID				int null,
			MaxDiscount						numeric(18,2) null,
			AreaID							int null,
			EntityID						int null,
			Status							nvarchar(50) null,
			MasterNumber					nvarchar(50) null,
			InvoiceBankName					nvarchar(500) null,
			AccountNo						nvarchar(200) null,
			IFSCCode						nvarchar(200) null,
			AccountType						nvarchar(200) null,
			bankcity						nvarchar(200) null,
			InsertDate						datetime null,
			updateDate						datetime null,
			HashKey							varbinary(50) null
		)
        
		create clustered index idx_dimBranch_BranchSK on dbo.trwdimBranch(BranchSK)
		create nonclustered index idx_dimBranch_BranchID on dbo.trwdimBranch(BranchID)
		create nonclustered index idx_dimBranch_ManagerEmployeeID on dbo.trwdimBranch(ManagerEmployeeID)
		create nonclustered index idx_dimBranch_AreaID on dbo.trwdimBranch(AreaID)
		create nonclustered index idx_dimBranch_EntityID on dbo.trwdimBranch(EntityID)
		create nonclustered index idx_dimBranch_HashKey on trwdimBranch(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(20))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwBranches
	set 
		HashKey = binary_checksum(BranchID, Name, DOC, Address1, Address2, City, District, State, PinCode, Country, BillingName, ManagerEmployeeID, MaxDiscount, AreaID,
					EntityID, Status, MasterNumber, InvoiceBankName, AccountNo, IFSCCode, AccountType, bankcity)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwBranches


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimBranch as DST
	using ETL_trwBranches as SRC
	on (src.BranchID = DST.BranchID)

	when not matched by target then
	insert
	(
	BranchID,
	Name,
	DOC,
	Address1,
	Address2,
	City,
	District,
	State,
	PinCode,
	Country,
	BillingName,
	ManagerEmployeeID,
	MaxDiscount,
	AreaID,
	EntityID,
	Status,
	MasterNumber,
	InvoiceBankName,
	AccountNo,
	IFSCCode,
	AccountType,
	bankcity,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.BranchID,
	SRC.Name,
	SRC.DOC,
	SRC.Address1,
	SRC.Address2,
	SRC.City,
	SRC.District,
	SRC.State,
	SRC.PinCode,
	SRC.Country,
	SRC.BillingName,
	SRC.ManagerEmployeeID,
	SRC.MaxDiscount,
	SRC.AreaID,
	SRC.EntityID,
	SRC.Status,
	SRC.MasterNumber,
	SRC.InvoiceBankName,
	SRC.AccountNo,
	SRC.IFSCCode,
	SRC.AccountType,
	SRC.bankcity,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.Name = SRC.Name,
		DST.DOC = SRC.DOC,
		DST.Address1 = SRC.Address1,
		DST.Address2 = SRC.Address2,
		DST.City = SRC.City,
		DST.District = SRC.District,
		DST.State = SRC.State,
		DST.PinCode = SRC.PinCode,
		DST.Country = SRC.Country,
		DST.BillingName = SRC.BillingName,
		DST.ManagerEmployeeID = SRC.ManagerEmployeeID,
		DST.MaxDiscount = SRC.MaxDiscount,
		DST.AreaID = SRC.AreaID,
		DST.EntityID = SRC.EntityID,
		DST.Status = SRC.Status,
		DST.MasterNumber = SRC.MasterNumber,
		DST.InvoiceBankName = SRC.InvoiceBankName,
		DST.AccountNo = SRC.AccountNo,
		DST.IFSCCode = SRC.IFSCCode,
		DST.AccountType = SRC.AccountType,
		DST.bankcity = SRC.bankcity,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbBranches', '',@insertcount, @updatecount, 2, 1, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbBranches', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Employee', 'Update', @insertcount, @updatecount, 2, 1, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbBranches', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimBranch', 'Process_StarDimension_Branch', 'Package_Error_Log', 'Failed', 'Star Dimension - Employee', '', 0, 0, 2, 1, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 1, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			


--exec [etlsp_dimBranch] '1558484B-BDFF-437F-A12B-F7CAEEE49BC5', '{14B94763-72D4-4B9C-BB80-B7CC835A88EC}' ,'fghdfg', '33d', 'StarDimension'
GO
