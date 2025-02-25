USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimPayment]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimPayment]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbPayments', '',0,0, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPayments', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - PolicyOthers', 'Insert', 0, 0, 2, 4, NULL, NULL, NULL

	if object_id('dbo.trwdimPayment') is null
	BEGIN
    
		create table dbo.trwdimPayment
		(
			PaymentSK							int identity(1,1) not null,
			PaymentID							int not null,
			PaymentNo							numeric(18, 0) null,
			PaymentDate							datetime null,
			EntityID							int null,
			Amount								numeric(18, 2) null,
			Narration							nvarchar(max) null,
			DocumentID							int null,
			PaymentType							nvarchar(100) null,
			Drawnon								datetime null,
			ChequeDate							datetime null,
			BankAndBranch						nvarchar(1000) null,
			Status								nvarchar(50) null,
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
			ToCompanyName						nvarchar(500) null,
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
			ReferenceType						nvarchar(100) null,
			ReferenceNo							numeric(18, 0) null,
			TemplateId							int null,
			CollectionEmployeeID				int null,
			DepositBY							nvarchar(200) null,
			DepositDate							datetime null,
			ClearedBy							nvarchar(200) null,
			ClearedDate							datetime null,
			BankID								int null,
			checkno								nvarchar(200) null,
			Agentbranchid						int null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimPayment_PaymentSK on dbo.trwdimPayment(PaymentSK)
		create nonclustered index idx_dimPayment_PaymentID on dbo.trwdimPayment(PaymentID)
		create nonclustered index idx_dimPayment_EntityID on dbo.trwdimPayment(EntityID)
		create nonclustered index idx_dimPayment_DocumentID on dbo.trwdimPayment(DocumentID)
		create nonclustered index idx_dimPayment_BranchID on dbo.trwdimPayment(BranchID)
		create nonclustered index idx_dimPayment_AgentID on dbo.trwdimPayment(AgentID)
		create nonclustered index idx_dimPayment_CollectionEmployeeID on dbo.trwdimPayment(CollectionEmployeeID)
		create nonclustered index idx_dimPayment_Agentbranchid on dbo.trwdimPayment(Agentbranchid)
		create nonclustered index idx_dimPayment_HashKey on trwdimPayment(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwPayments
	set 
		HashKey = binary_checksum(PaymentID,PaymentNo,PaymentDate,EntityID,Amount,Narration,DocumentID,PaymentType,Drawnon,ChequeDate,BankAndBranch,Status,BranchID,ByName,ByAddress1,
					ByAddress2,ByCity,ByDistrict,ByState,ByPinCode,ByCountry,AgentID,ToCompanyName,ToContactPerson,ToAddress1,ToAddress2,ToCity,ToDistrict,ToState,ToPinCode,ToCountry,
					ToPhoneNo,ToMobileNo,ToEmailAddress,ReferenceType,ReferenceNo,TemplateId,CollectionEmployeeID,DepositBY,DepositDate,ClearedBy,ClearedDate,BankID,checkno,Agentbranchid)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwPayments


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimPayment as DST
	using ETL_trwPayments as SRC
	on (src.PaymentID = DST.PaymentID)

	when not matched by target then
	insert
	(
	PaymentID,
	PaymentNo,
	PaymentDate,
	EntityID,
	Amount,
	Narration,
	DocumentID,
	PaymentType,
	Drawnon,
	ChequeDate,
	BankAndBranch,
	Status,
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
	ReferenceType,
	ReferenceNo,
	TemplateId,
	CollectionEmployeeID,
	DepositBY,
	DepositDate,
	ClearedBy,
	ClearedDate,
	BankID,
	checkno,
	Agentbranchid,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.PaymentID,
	SRC.PaymentNo,
	SRC.PaymentDate,
	SRC.EntityID,
	SRC.Amount,
	SRC.Narration,
	SRC.DocumentID,
	SRC.PaymentType,
	SRC.Drawnon,
	SRC.ChequeDate,
	SRC.BankAndBranch,
	SRC.Status,
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
	SRC.ReferenceType,
	SRC.ReferenceNo,
	SRC.TemplateId,
	SRC.CollectionEmployeeID,
	SRC.DepositBY,
	SRC.DepositDate,
	SRC.ClearedBy,
	SRC.ClearedDate,
	SRC.BankID,
	SRC.checkno,
	SRC.Agentbranchid,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PaymentNo = SRC.PaymentNo,
		DST.PaymentDate = SRC.PaymentDate,
		DST.EntityID = SRC.EntityID,
		DST.Amount = SRC.Amount,
		DST.Narration = SRC.Narration,
		DST.DocumentID = SRC.DocumentID,
		DST.PaymentType = SRC.PaymentType,
		DST.Drawnon = SRC.Drawnon,
		DST.ChequeDate = SRC.ChequeDate,
		DST.BankAndBranch = SRC.BankAndBranch,
		DST.Status = SRC.Status,
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
		DST.ReferenceType = SRC.ReferenceType,
		DST.ReferenceNo = SRC.ReferenceNo,
		DST.TemplateId = SRC.TemplateId,
		DST.CollectionEmployeeID = SRC.CollectionEmployeeID,
		DST.DepositBY = SRC.DepositBY,
		DST.DepositDate = SRC.DepositDate,
		DST.ClearedBy = SRC.ClearedBy,
		DST.ClearedDate = SRC.ClearedDate,
		DST.BankID = SRC.BankID,
		DST.checkno = SRC.checkno,
		DST.Agentbranchid = SRC.Agentbranchid,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbPayments', '',@insertcount, @updatecount, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPayments', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - PolicyOthers', 'Update', @insertcount, @updatecount, 2, 4, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPayments', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimPayment', 'Process_StarDimension_Payment', 'Package_Error_Log', 'Failed', 'Star Dimension - PolicyOthers', '', 0, 0, 2, 4, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 4, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
