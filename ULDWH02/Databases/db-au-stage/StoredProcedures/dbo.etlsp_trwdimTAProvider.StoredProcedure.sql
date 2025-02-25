USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimTAProvider]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimTAProvider]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbTAProviders', '',0,0, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbTAProviders', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - SellingCostPlan', 'Insert', 0, 0, 2, 3, NULL, NULL, NULL

	if object_id('dbo.trwdimTAProvider') is null
	BEGIN
    
		create table dbo.trwdimTAProvider
		(
			TAProviderSK						int identity(1,1) not null,
			TAProviderID						int not null,
			Name								nvarchar(50) null,
			CompanyName							nvarchar(50) null,
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
			EntityID							int null,
			Status								nvarchar(50) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimTAProvider_TAProviderSK on dbo.trwdimTAProvider(TAProviderSK)
		create nonclustered index idx_dimTAProvider_TAProviderID on dbo.trwdimTAProvider(TAProviderID)
		create nonclustered index idx_dimTAProvider_PanDetailID on dbo.trwdimTAProvider(PanDetailID)
		create nonclustered index idx_dimTAProvider_EntityID on dbo.trwdimTAProvider(EntityID)
		create nonclustered index idx_dimTAProvider_HashKey on trwdimTAProvider(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwTAProviders
	set 
		HashKey = binary_checksum(TAProviderID,Name,CompanyName,PanDetailID,ContactPerson,Address1,Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,EntityID,Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwTAProviders


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimTAProvider as DST
	using ETL_trwTAProviders as SRC
	on (src.TAProviderID = DST.TAProviderID)

	when not matched by target then
	insert
	(
	TAProviderID,
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
	EntityID,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.TAProviderID,
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
	SRC.EntityID,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbTAProviders', '',@insertcount, @updatecount, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbTAProviders', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - SellingCostPlan', 'Update', @insertcount, @updatecount, 2, 3, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbTAProviders', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimTAProvider', 'Process_StarDimension_SellingPlan', 'Package_Error_Log', 'Failed', 'Star Dimension - SellingCostPlan', '', 0, 0, 2, 3, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 3, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
