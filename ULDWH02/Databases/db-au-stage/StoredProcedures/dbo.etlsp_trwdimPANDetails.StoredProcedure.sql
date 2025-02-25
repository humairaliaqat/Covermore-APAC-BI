USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimPANDetails]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimPANDetails]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbPANDetails', '',0,0, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPANDetails', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - PolicyOthers', 'Insert', 0, 0, 2, 4, NULL, NULL, NULL

	if object_id('dbo.trwdimPANDetails') is null
	BEGIN
    
		create table dbo.trwdimPANDetails
		(
			PANDetailSK							int identity(1,1) not null,
			PANDetailID							int not null,
			PANNo								nvarchar(50) null,
			PANType								nvarchar(50) null,
			DeducteeName						nvarchar(500) null,
			AddressName							nvarchar(500) null,
			AddressFlat							nvarchar(500) null,
			AddressBuilding						nvarchar(500) null,
			AddressStreet						nvarchar(500) null,
			AddressArea							nvarchar(500) null,
			City								nvarchar(50) null,
			District							nvarchar(50) null,
			State								nvarchar(50) null,
			PinCode								nvarchar(10) null,
			Country								nvarchar(100) null,
			PhoneNo								nvarchar(50) null,
			MobileNo							nvarchar(50) null,
			EmailAddress						nvarchar(50) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimPANDetails_PANDetailSK on dbo.trwdimPANDetails(PANDetailSK)
		create nonclustered index idx_dimPANDetails_PANDetailID on dbo.trwdimPANDetails(PANDetailID)
		create nonclustered index idx_dimPANDetails_HashKey on trwdimPANDetails(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwPANDetails
	set 
		HashKey = binary_checksum(PANDetailID,PANNo,PANType,DeducteeName,AddressName,AddressFlat,AddressBuilding,AddressStreet,AddressArea,City,District,State,PinCode,Country,
					PhoneNo,MobileNo,EmailAddress)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwPANDetails


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimPANDetails as DST
	using ETL_trwPANDetails as SRC
	on (src.PANDetailID = DST.PANDetailID)

	when not matched by target then
	insert
	(
	PANDetailID,
	PANNo,
	PANType,
	DeducteeName,
	AddressName,
	AddressFlat,
	AddressBuilding,
	AddressStreet,
	AddressArea,
	City,
	District,
	State,
	PinCode,
	Country,
	PhoneNo,
	MobileNo,
	EmailAddress,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.PANDetailID,
	SRC.PANNo,
	SRC.PANType,
	SRC.DeducteeName,
	SRC.AddressName,
	SRC.AddressFlat,
	SRC.AddressBuilding,
	SRC.AddressStreet,
	SRC.AddressArea,
	SRC.City,
	SRC.District,
	SRC.State,
	SRC.PinCode,
	SRC.Country,
	SRC.PhoneNo,
	SRC.MobileNo,
	SRC.EmailAddress,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PANNo = SRC.PANNo,
		DST.PANType = SRC.PANType,
		DST.DeducteeName = SRC.DeducteeName,
		DST.AddressName = SRC.AddressName,
		DST.AddressFlat = SRC.AddressFlat,
		DST.AddressBuilding = SRC.AddressBuilding,
		DST.AddressStreet = SRC.AddressStreet,
		DST.AddressArea = SRC.AddressArea,
		DST.City = SRC.City,
		DST.District = SRC.District,
		DST.State = SRC.State,
		DST.PinCode = SRC.PinCode,
		DST.Country = SRC.Country,
		DST.PhoneNo = SRC.PhoneNo,
		DST.MobileNo = SRC.MobileNo,
		DST.EmailAddress = SRC.EmailAddress,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbPANDetails', '',@insertcount, @updatecount, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPANDetails', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - PolicyOthers', 'Update', @insertcount, @updatecount, 2, 4, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPANDetails', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimPANDetails', 'Process_StarDimension_PANDetails', 'Package_Error_Log', 'Failed', 'Star Dimension - PolicyOthers', '', 0, 0, 2, 4, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 4, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
