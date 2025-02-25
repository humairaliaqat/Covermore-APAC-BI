USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwInvoice]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [db-au-stage]

CREATE procedure [dbo].[etlsp_trwInvoice]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

SET NOCOUNT ON

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'trwInvoice', '',0,0
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwInvoice', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Process Dimension Facts - Policy', 'Insert', 0, 0, 3, 1, NULL, NULL, NULL

	if object_id('[db-au-stage].dbo.trwInvoiceTemp') is not null 
	BEGIN
		DROP TABLE [db-au-stage].dbo.trwInvoiceTemp 

		CREATE TABLE [db-au-stage].dbo.[trwInvoiceTemp] (
					[InvoiceID]							int,
					[InvoiceNo]							numeric(18, 0),
					[InvoiceDate]						Datetime,
					[ByName]							nvarchar(100) null,
					[ByAddress1]						nvarchar(500) null,
					[ByAddress2]						nvarchar(500) null,
					[ByCity]							nvarchar(50) null,
					[ByDistrict]						nvarchar(50) null,
					[ByState]							nvarchar(50) null,
					[ByPinCode]							nvarchar(10) null,
					[ByCountry]							nvarchar(100) null,
					[ToCompanyName]						nvarchar(250) null,
					[ToContactPerson]					nvarchar(50) null,
					[ToAddress1]						nvarchar(500) null,
					[ToAddress2]						nvarchar(500) null,
					[ToCity]							nvarchar(50) null,
					[ToDistrict]						nvarchar(50) null,
					[ToState]							nvarchar(50) null,
					[ToPinCode]							nvarchar(10) null,
					[ToCountry]							nvarchar(100) null,
					[ToPhoneNo]							nvarchar(50) null,
					[ToMobileNo]						nvarchar(50) null,
					[ToEmailAddress]					nvarchar(50) null,
					[Status]							nvarchar(50) null,
					[CreatedDateTime]					datetime null,
					[CreatedBy]							nvarchar(256) null,
					[ModifiedDateTime]					datetime null,
					[ModifiedBy]						nvarchar(256) null,
					[AgentReferenceName]				nvarchar(1000) null,
					[BranchID]							int null,
					[hashkey]							varbinary(50)
				)
	END
	ELSE
	BEGIN
			CREATE TABLE [db-au-stage].dbo.[trwInvoiceTemp] (
					[InvoiceID]							int,
					[InvoiceNo]							numeric(18, 0),
					[InvoiceDate]						Datetime,
					[ByName]							nvarchar(100) null,
					[ByAddress1]						nvarchar(500) null,
					[ByAddress2]						nvarchar(500) null,
					[ByCity]							nvarchar(50) null,
					[ByDistrict]						nvarchar(50) null,
					[ByState]							nvarchar(50) null,
					[ByPinCode]							nvarchar(10) null,
					[ByCountry]							nvarchar(100) null,
					[ToCompanyName]						nvarchar(250) null,
					[ToContactPerson]					nvarchar(50) null,
					[ToAddress1]						nvarchar(500) null,
					[ToAddress2]						nvarchar(500) null,
					[ToCity]							nvarchar(50) null,
					[ToDistrict]						nvarchar(50) null,
					[ToState]							nvarchar(50) null,
					[ToPinCode]							nvarchar(10) null,
					[ToCountry]							nvarchar(100) null,
					[ToPhoneNo]							nvarchar(50) null,
					[ToMobileNo]						nvarchar(50) null,
					[ToEmailAddress]					nvarchar(50) null,
					[Status]							nvarchar(50) null,
					[CreatedDateTime]					datetime null,
					[CreatedBy]							nvarchar(256) null,
					[ModifiedDateTime]					datetime null,
					[ModifiedBy]						nvarchar(256) null,
					[AgentReferenceName]				nvarchar(1000) null,
					[BranchID]							int null,
					[hashkey]							varbinary(50)
				)
	END

	create clustered index idx_trwInvoiceTemp_InvoiceID on [db-au-stage].dbo.trwInvoiceTemp(InvoiceID)
	create nonclustered index idx_trwInvoiceTemp_BranchID on [db-au-stage].dbo.trwInvoiceTemp(BranchID)
	create nonclustered index idx_trwInvoiceTemp_HashKey on [db-au-stage].dbo.trwInvoiceTemp(HashKey)

	insert into [db-au-stage].dbo.trwInvoiceTemp
		(InvoiceID,InvoiceNo,InvoiceDate,ByName,ByAddress1,ByAddress2,ByCity,ByDistrict,ByState,ByPinCode,ByCountry,ToCompanyName,ToContactPerson,ToAddress1,ToAddress2,ToCity,ToDistrict,
			ToState,ToPinCode,ToCountry,ToPhoneNo,ToMobileNo,ToEmailAddress,Status,CreatedDateTime,CreatedBy,ModifiedDateTime,ModifiedBy,AgentReferenceName,BranchID)
	select InvoiceID,InvoiceNo,InvoiceDate,ByName,ByAddress1,ByAddress2,ByCity,ByDistrict,ByState,ByPinCode,ByCountry,ToCompanyName,ToContactPerson,ToAddress1,ToAddress2,ToCity,ToDistrict,
			ToState,ToPinCode,ToCountry,ToPhoneNo,ToMobileNo,ToEmailAddress,Status,CreatedDateTime,CreatedBy,ModifiedDateTime,ModifiedBy,AgentReferenceName,BranchID
	from [db-au-stage].dbo.trwdimInvoice
	order by 1

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update [db-au-stage].dbo.trwInvoiceTemp
	set 
		HashKey = binary_checksum(InvoiceID,InvoiceNo,InvoiceDate,ByName,ByAddress1,ByAddress2,ByCity,ByDistrict,ByState,ByPinCode,ByCountry,ToCompanyName,ToContactPerson,ToAddress1,ToAddress2,ToCity,ToDistrict,
						ToState,ToPinCode,ToCountry,ToPhoneNo,ToMobileNo,ToEmailAddress,Status,CreatedDateTime,CreatedBy,ModifiedDateTime,ModifiedBy,AgentReferenceName,BranchID)


	select
		@sourcecount = count(*)
	from
		[db-au-stage].dbo.trwInvoiceTemp

	if object_id('[db-au-cmdwh].dbo.trwInvoice') is null
	BEGIN

		CREATE TABLE [db-au-cmdwh].dbo.[trwInvoice] (
		[InvoiceSK]							int identity(1,1) not null,
		[InvoiceID]							int,
		[InvoiceNo]							numeric(18, 0),
		[InvoiceDate]						Datetime,
		[ByName]							nvarchar(100) null,
		[ByAddress1]						nvarchar(500) null,
		[ByAddress2]						nvarchar(500) null,
		[ByCity]							nvarchar(50) null,
		[ByDistrict]						nvarchar(50) null,
		[ByState]							nvarchar(50) null,
		[ByPinCode]							nvarchar(10) null,
		[ByCountry]							nvarchar(100) null,
		[ToCompanyName]						nvarchar(250) null,
		[ToContactPerson]					nvarchar(50) null,
		[ToAddress1]						nvarchar(500) null,
		[ToAddress2]						nvarchar(500) null,
		[ToCity]							nvarchar(50) null,
		[ToDistrict]						nvarchar(50) null,
		[ToState]							nvarchar(50) null,
		[ToPinCode]							nvarchar(10) null,
		[ToCountry]							nvarchar(100) null,
		[ToPhoneNo]							nvarchar(50) null,
		[ToMobileNo]						nvarchar(50) null,
		[ToEmailAddress]					nvarchar(50) null,
		[Status]							nvarchar(50) null,
		[CreatedDateTime]					datetime null,
		[CreatedBy]							nvarchar(256) null,
		[ModifiedDateTime]					datetime null,
		[ModifiedBy]						nvarchar(256) null,
		[AgentReferenceName]				nvarchar(1000) null,
		[BranchID]							int null,
		[InsertDate]					datetime null,
		[updateDate]					datetime null,
		[hashkey]						varbinary(50) null
	)

	create clustered index idx_trwInvoice_InvoiceSK on [db-au-cmdwh].dbo.trwInvoice(InvoiceSK)
	create nonclustered index idx_trwInvoice_InvoiceID on [db-au-cmdwh].dbo.trwInvoice(InvoiceID)
	create nonclustered index idx_trwInvoice_BranchID on [db-au-cmdwh].dbo.trwInvoice(BranchID)
	create nonclustered index idx_trwInvoice_HashKey on [db-au-cmdwh].dbo.trwInvoice(HashKey)

	END

BEGIN TRANSACTION;

BEGIN TRY

	merge into [db-au-cmdwh].dbo.trwInvoice as DST
	using [db-au-stage].dbo.trwInvoiceTemp as SRC
	on (src.InvoiceID = DST.InvoiceID)

	when not matched by target then
	insert
	(
	InvoiceID,
	InvoiceNo,
	InvoiceDate,
	ByName,
	ByAddress1,
	ByAddress2,
	ByCity,
	ByDistrict,
	ByState,
	ByPinCode,
	ByCountry,
	ToCompanyName,
	ToContactPerson,
	ToAddress1,
	ToAddress2,
	ToCity,
	ToDistrict,
	ToState,
	ToPinCode,
	ToCountry,
	ToPhoneNo,
	ToMobileNo,
	ToEmailAddress,
	Status,
	CreatedDateTime,
	CreatedBy,
	ModifiedDateTime,
	ModifiedBy,
	AgentReferenceName,
	BranchID,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.InvoiceID,
	SRC.InvoiceNo,
	SRC.InvoiceDate,
	SRC.ByName,
	SRC.ByAddress1,
	SRC.ByAddress2,
	SRC.ByCity,
	SRC.ByDistrict,
	SRC.ByState,
	SRC.ByPinCode,
	SRC.ByCountry,
	SRC.ToCompanyName,
	SRC.ToContactPerson,
	SRC.ToAddress1,
	SRC.ToAddress2,
	SRC.ToCity,
	SRC.ToDistrict,
	SRC.ToState,
	SRC.ToPinCode,
	SRC.ToCountry,
	SRC.ToPhoneNo,
	SRC.ToMobileNo,
	SRC.ToEmailAddress,
	SRC.Status,
	SRC.CreatedDateTime,
	SRC.CreatedBy,
	SRC.ModifiedDateTime,
	SRC.ModifiedBy,
	SRC.AgentReferenceName,
	SRC.BranchID,
	getdate(),
	null,
	SRC.HashKey
	)

	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.InvoiceNo = SRC.InvoiceNo,
		DST.InvoiceDate = SRC.InvoiceDate,
		DST.ByName = SRC.ByName,
		DST.ByAddress1 = SRC.ByAddress1,
		DST.ByAddress2 = SRC.ByAddress2,
		DST.ByCity = SRC.ByCity,
		DST.ByDistrict = SRC.ByDistrict,
		DST.ByState = SRC.ByState,
		DST.ByPinCode = SRC.ByPinCode,
		DST.ByCountry = SRC.ByCountry,
		DST.ToCompanyName = SRC.ToCompanyName,
		DST.ToContactPerson = SRC.ToContactPerson,
		DST.ToAddress1 = SRC.ToAddress1,
		DST.ToAddress2 = SRC.ToAddress2,
		DST.ToCity = SRC.ToCity,
		DST.ToDistrict = SRC.ToDistrict,
		DST.ToState = SRC.ToState,
		DST.ToPinCode = SRC.ToPinCode,
		DST.ToCountry = SRC.ToCountry,
		DST.ToPhoneNo = SRC.ToPhoneNo,
		DST.ToMobileNo = SRC.ToMobileNo,
		DST.ToEmailAddress = SRC.ToEmailAddress,
		DST.Status = SRC.Status,
		DST.CreatedDateTime = SRC.CreatedDateTime,
		DST.CreatedBy = SRC.CreatedBy,
		DST.ModifiedDateTime = SRC.ModifiedDateTime,
		DST.ModifiedBy = SRC.ModifiedBy,
		DST.AgentReferenceName = SRC.AgentReferenceName,
		DST.BranchID = SRC.BranchID,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'trwInvoice', '',@insertcount, @updatecount
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwInvoice', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Process Dimension Facts - Policy', 'Update', @insertcount, @updatecount, 3, 1, NULL, NULL, NULL

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

	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwInvoice', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwInvoice', 'Process_etlsp_trwEmployee_DWH', 'Package_Error_Log', 'Failed', 'Process Dimension Facts - Policy', '', 0, 0, 3, 1, NULL, NULL, NULL

	exec [db-au-stage].dbo.etlsp_trwPackageStatus  'END', 3, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END



GO
