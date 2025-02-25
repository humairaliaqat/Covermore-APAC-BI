USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimInvoice]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimInvoice]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbInvoices', '',0,0, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbInvoices', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - PolicyOthers', 'Insert', 0, 0, 2, 4, NULL, NULL, NULL

	if object_id('dbo.trwdimInvoice') is null
	BEGIN
    
		create table dbo.trwdimInvoice
		(
			InvoiceSK							int identity(1,1) not null,
			InvoiceID							numeric(18, 0) not null,
			InvoiceNo							numeric(18, 0) null,
			InvoiceDate							datetime null,
			BranchID							int null,
			ByName								nvarchar(50) null,
			ByAddress1							nvarchar(500) null,
			ByAddress2							nvarchar(500) null,
			ByCity								nvarchar(50) null,
			ByDistrict							nvarchar(50) null,
			ByState								nvarchar(50) null,
			ByPinCode							nvarchar(10) null,
			ByCountry							nvarchar(100) null,
			AgentID								int null,
			AgentPanDetailID					int null,
			ToCompanyName						nvarchar(250) null,
			ToContactPerson						nvarchar(50) null,
			ToAddress1							nvarchar(500) null,
			ToAddress2							nvarchar(500) null,
			ToCity								nvarchar(50) null,
			ToDistrict							nvarchar(50) null,
			ToState								nvarchar(50) null,
			ToPinCode							nvarchar(10) null,
			ToCountry							nvarchar(100) null,
			ToPhoneNo							nvarchar(50) null,
			ToMobileNo							nvarchar(50) null,
			ToEmailAddress						nvarchar(50) null,
			EntityID							int null,
			DocumentID							int null,
			TotalAmount							numeric(18, 2) null,
			ServiceTaxRate						numeric(18, 2) null,
			CESS1Rate							numeric(18, 2) null,
			CESS2Rate							numeric(18, 2) null,
			ServiceTax							numeric(18, 2) null,
			CESS1								numeric(18, 2) null,
			CESS2								numeric(18, 2) null,
			GrossAmount							numeric(18, 2) null,
			DiscountAmount						numeric(18, 2) null,
			DiscountServiceTax					numeric(18, 2) null,
			DiscountCESS1						numeric(18, 2) null,
			DiscountCESS2						numeric(18, 2) null,
			NetServiceTax						numeric(18, 2) null,
			NetCESS1							numeric(18, 2) null,
			NetCESS2							numeric(18, 2) null,
			NetAmount							numeric(18, 2) null,
			CommissionAmount					numeric(18, 2) null,
			TDSAmount							numeric(18, 2) null,
			Status								nvarchar(50) null,
			CreatedDateTime						datetime null,
			CreatedBy							nvarchar(256) null,
			ModifiedDateTime					datetime null,
			ModifiedBy							nvarchar(256) null,
			AgentReferenceName					nvarchar(1000) null,
			ManualPremiumTotal					numeric(18, 2) null,
			ManualPremiumBasic					numeric(18, 2) null,
			ManualPremiumServiceTax				numeric(18, 2) null,						
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimInvoice_InvoiceSK on dbo.trwdimInvoice(InvoiceSK)
		create nonclustered index idx_dimInvoice_InvoiceID on dbo.trwdimInvoice(InvoiceID)
		create nonclustered index idx_dimInvoice_BranchID on dbo.trwdimInvoice(BranchID)
		create nonclustered index idx_dimInvoice_EntityID on dbo.trwdimInvoice(EntityID)
		create nonclustered index idx_dimInvoice_DocumentID on dbo.trwdimInvoice(DocumentID)
		create nonclustered index idx_dimInvoice_HashKey on trwdimInvoice(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwInvoices
	set 
		HashKey = binary_checksum(InvoiceID,InvoiceNo,InvoiceDate,BranchID,ByName,ByAddress1,ByAddress2,ByCity,ByDistrict,ByState,ByPinCode,ByCountry,AgentID,AgentPanDetailID,ToCompanyName,
							ToContactPerson,ToAddress1,ToAddress2,ToCity,ToDistrict,ToState,ToPinCode,ToCountry,ToPhoneNo,ToMobileNo,ToEmailAddress,EntityID,DocumentID,TotalAmount,
							ServiceTaxRate,CESS1Rate,CESS2Rate,ServiceTax,CESS1,CESS2,GrossAmount,DiscountAmount,DiscountServiceTax,DiscountCESS1,DiscountCESS2,NetServiceTax,NetCESS1,
							NetCESS2,NetAmount,CommissionAmount,TDSAmount,Status,CreatedDateTime,CreatedBy,ModifiedDateTime,ModifiedBy,AgentReferenceName,ManualPremiumTotal,
							ManualPremiumBasic,ManualPremiumServiceTax)
	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwInvoices


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimInvoice as DST
	using ETL_trwInvoices as SRC
	on (src.InvoiceID = DST.InvoiceID)

	when not matched by target then
	insert
	(
	InvoiceID,
	InvoiceNo,
	InvoiceDate,
	BranchID,
	ByName,
	ByAddress1,
	ByAddress2,
	ByCity,
	ByDistrict,
	ByState,
	ByPinCode,
	ByCountry,
	AgentID,
	AgentPanDetailID,
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
	EntityID,
	DocumentID,
	TotalAmount,
	ServiceTaxRate,
	CESS1Rate,
	CESS2Rate,
	ServiceTax,
	CESS1,
	CESS2,
	GrossAmount,
	DiscountAmount,
	DiscountServiceTax,
	DiscountCESS1,
	DiscountCESS2,
	NetServiceTax,
	NetCESS1,
	NetCESS2,
	NetAmount,
	CommissionAmount,
	TDSAmount,
	Status,
	CreatedDateTime,
	CreatedBy,
	ModifiedDateTime,
	ModifiedBy,
	AgentReferenceName,
	ManualPremiumTotal,
	ManualPremiumBasic,
	ManualPremiumServiceTax,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.InvoiceID,
	SRC.InvoiceNo,
	SRC.InvoiceDate,
	SRC.BranchID,
	SRC.ByName,
	SRC.ByAddress1,
	SRC.ByAddress2,
	SRC.ByCity,
	SRC.ByDistrict,
	SRC.ByState,
	SRC.ByPinCode,
	SRC.ByCountry,
	SRC.AgentID,
	SRC.AgentPanDetailID,
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
	SRC.EntityID,
	SRC.DocumentID,
	SRC.TotalAmount,
	SRC.ServiceTaxRate,
	SRC.CESS1Rate,
	SRC.CESS2Rate,
	SRC.ServiceTax,
	SRC.CESS1,
	SRC.CESS2,
	SRC.GrossAmount,
	SRC.DiscountAmount,
	SRC.DiscountServiceTax,
	SRC.DiscountCESS1,
	SRC.DiscountCESS2,
	SRC.NetServiceTax,
	SRC.NetCESS1,
	SRC.NetCESS2,
	SRC.NetAmount,
	SRC.CommissionAmount,
	SRC.TDSAmount,
	SRC.Status,
	SRC.CreatedDateTime,
	SRC.CreatedBy,
	SRC.ModifiedDateTime,
	SRC.ModifiedBy,
	SRC.AgentReferenceName,
	SRC.ManualPremiumTotal,
	SRC.ManualPremiumBasic,
	SRC.ManualPremiumServiceTax,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.InvoiceNo = SRC.InvoiceNo,
		DST.InvoiceDate = SRC.InvoiceDate,
		DST.BranchID = SRC.BranchID,
		DST.ByName = SRC.ByName,
		DST.ByAddress1 = SRC.ByAddress1,
		DST.ByAddress2 = SRC.ByAddress2,
		DST.ByCity = SRC.ByCity,
		DST.ByDistrict = SRC.ByDistrict,
		DST.ByState = SRC.ByState,
		DST.ByPinCode = SRC.ByPinCode,
		DST.ByCountry = SRC.ByCountry,
		DST.AgentID = SRC.AgentID,
		DST.AgentPanDetailID = SRC.AgentPanDetailID,
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
		DST.EntityID = SRC.EntityID,
		DST.DocumentID = SRC.DocumentID,
		DST.TotalAmount = SRC.TotalAmount,
		DST.ServiceTaxRate = SRC.ServiceTaxRate,
		DST.CESS1Rate = SRC.CESS1Rate,
		DST.CESS2Rate = SRC.CESS2Rate,
		DST.ServiceTax = SRC.ServiceTax,
		DST.CESS1 = SRC.CESS1,
		DST.CESS2 = SRC.CESS2,
		DST.GrossAmount = SRC.GrossAmount,
		DST.DiscountAmount = SRC.DiscountAmount,
		DST.DiscountServiceTax = SRC.DiscountServiceTax,
		DST.DiscountCESS1 = SRC.DiscountCESS1,
		DST.DiscountCESS2 = SRC.DiscountCESS2,
		DST.NetServiceTax = SRC.NetServiceTax,
		DST.NetCESS1 = SRC.NetCESS1,
		DST.NetCESS2 = SRC.NetCESS2,
		DST.NetAmount = SRC.NetAmount,
		DST.CommissionAmount = SRC.CommissionAmount,
		DST.TDSAmount = SRC.TDSAmount,
		DST.Status = SRC.Status,
		DST.CreatedDateTime = SRC.CreatedDateTime,
		DST.CreatedBy = SRC.CreatedBy,
		DST.ModifiedDateTime = SRC.ModifiedDateTime,
		DST.ModifiedBy = SRC.ModifiedBy,
		DST.AgentReferenceName = SRC.AgentReferenceName,
		DST.ManualPremiumTotal = SRC.ManualPremiumTotal,
		DST.ManualPremiumBasic = SRC.ManualPremiumBasic,
		DST.ManualPremiumServiceTax = SRC.ManualPremiumServiceTax,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbInvoices', '',@insertcount, @updatecount, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbInvoices', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - PolicyOthers', 'Update', @insertcount, @updatecount, 2, 4, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbInvoices', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimInvoice', 'Process_StarDimension_Invoice', 'Package_Error_Log', 'Failed', 'Star Dimension - PolicyOthers', '', 0, 0, 2, 4, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 4, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
