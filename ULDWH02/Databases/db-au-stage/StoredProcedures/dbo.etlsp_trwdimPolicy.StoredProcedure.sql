USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimPolicy]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimPolicy]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbPolicies', '',0,0, 2, 5, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicies', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - Policy', 'Insert', 0, 0, 2, 5, NULL, NULL, NULL

	if object_id('dbo.trwdimPolicy') is null
	BEGIN

   
		create table dbo.trwdimPolicy
		(
			PolicySK							int identity(1,1) not null,
			PolicyID							int not null,
			PolicyNumber						numeric(22, 0) null,
			MasterPolicyNumber					nvarchar(50) null,
			DateOfPolicy						datetime null,
			EmployeeID							int null,
			AgentEmployeeID						int null,
			ReferralAgentID						int null,
			OldPolicyReferenceNo				numeric(22, 0) null,
			ReferralCommissionPercent			numeric(18, 2) null,
			DiscountPercent						numeric(18, 2) null,
			BranchID							int null,
			CurrentPolicyDetailID				int null,
			RefNo								nvarchar(100) null,
			AuthenticationCode					nvarchar(50) null,
			Remarks								nvarchar(500) null,
			MasterNumber						nvarchar(100) null,
			CancellationCharges					numeric(18, 2) null,
			TrawellAssistNumber					nvarchar(100) null,
			EarlyArrivalRefund					numeric(18, 2) null,
			ReferenceNumber						nvarchar(200) null,
			PolicyCommencts						ntext null,
			Status								nvarchar(50) null,
			CreditNoteId						int null,
			ContinentName						nvarchar(1000) null,
			[CreatedDateTime]					datetime,
			[CreatedBy]							nvarchar(256),
			[ModifiedDateTime]					datetime,
			[ModifiedBy]						nvarchar(256),
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimPolicy_PolicySK on dbo.trwdimPolicy(PolicySK)
		create nonclustered index idx_dimPolicy_PolicyID on dbo.trwdimPolicy(PolicyID)
		create nonclustered index idx_dimPolicy_EmployeeID on dbo.trwdimPolicy(EmployeeID)
		create nonclustered index idx_dimPolicy_AgentEmployeeID on dbo.trwdimPolicy(AgentEmployeeID)
		create nonclustered index idx_dimPolicy_ReferralAgentID on dbo.trwdimPolicy(ReferralAgentID)
		create nonclustered index idx_dimPolicy_BranchID on dbo.trwdimPolicy(BranchID)
		create nonclustered index idx_dimPolicy_CurrentPolicyDetailID on dbo.trwdimPolicy(CurrentPolicyDetailID)
		create nonclustered index idx_dimPolicy_CreditNoteId on dbo.trwdimPolicy(CreditNoteId)
		create nonclustered index idx_dimPolicy_HashKey on trwdimPolicy(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwPolicies
	set 
		HashKey = binary_checksum(PolicyID,PolicyNumber,MasterPolicyNumber,DateOfPolicy,EmployeeID,AgentEmployeeID,ReferralAgentID,OldPolicyReferenceNo,ReferralCommissionPercent,
					DiscountPercent,BranchID,CurrentPolicyDetailID,RefNo,AuthenticationCode,Remarks,MasterNumber,CancellationCharges,TrawellAssistNumber,EarlyArrivalRefund,
					ReferenceNumber,PolicyCommencts,Status,CreditNoteId,ContinentName)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwPolicies


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimPolicy as DST
	using ETL_trwPolicies as SRC
	on (src.PolicyID = DST.PolicyID)

	when not matched by target then
	insert
	(
	PolicyID,
	PolicyNumber,
	MasterPolicyNumber,
	DateOfPolicy,
	EmployeeID,
	AgentEmployeeID,
	ReferralAgentID,
	OldPolicyReferenceNo,
	ReferralCommissionPercent,
	DiscountPercent,
	BranchID,
	CurrentPolicyDetailID,
	RefNo,
	AuthenticationCode,
	Remarks,
	MasterNumber,
	CancellationCharges,
	TrawellAssistNumber,
	EarlyArrivalRefund,
	ReferenceNumber,
	PolicyCommencts,
	Status,
	CreditNoteId,
	ContinentName,
	[CreatedDateTime],
	[CreatedBy],
	[ModifiedDateTime],
	[ModifiedBy],
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.PolicyID,
	SRC.PolicyNumber,
	SRC.MasterPolicyNumber,
	SRC.DateOfPolicy,
	SRC.EmployeeID,
	SRC.AgentEmployeeID,
	SRC.ReferralAgentID,
	SRC.OldPolicyReferenceNo,
	SRC.ReferralCommissionPercent,
	SRC.DiscountPercent,
	SRC.BranchID,
	SRC.CurrentPolicyDetailID,
	SRC.RefNo,
	SRC.AuthenticationCode,
	SRC.Remarks,
	SRC.MasterNumber,
	SRC.CancellationCharges,
	SRC.TrawellAssistNumber,
	SRC.EarlyArrivalRefund,
	SRC.ReferenceNumber,
	SRC.PolicyCommencts,
	SRC.Status,
	SRC.CreditNoteId,
	SRC.ContinentName,
	SRC.[CreatedDateTime],
	SRC.[CreatedBy],
	SRC.[ModifiedDateTime],
	SRC.[ModifiedBy],
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PolicyNumber = SRC.PolicyNumber,
		DST.MasterPolicyNumber = SRC.MasterPolicyNumber,
		DST.DateOfPolicy = SRC.DateOfPolicy,
		DST.EmployeeID = SRC.EmployeeID,
		DST.AgentEmployeeID = SRC.AgentEmployeeID,
		DST.ReferralAgentID = SRC.ReferralAgentID,
		DST.OldPolicyReferenceNo = SRC.OldPolicyReferenceNo,
		DST.ReferralCommissionPercent = SRC.ReferralCommissionPercent,
		DST.DiscountPercent = SRC.DiscountPercent,
		DST.BranchID = SRC.BranchID,
		DST.CurrentPolicyDetailID = SRC.CurrentPolicyDetailID,
		DST.RefNo = SRC.RefNo,
		DST.AuthenticationCode = SRC.AuthenticationCode,
		DST.Remarks = SRC.Remarks,
		DST.MasterNumber = SRC.MasterNumber,
		DST.CancellationCharges = SRC.CancellationCharges,
		DST.TrawellAssistNumber = SRC.TrawellAssistNumber,
		DST.EarlyArrivalRefund = SRC.EarlyArrivalRefund,
		DST.ReferenceNumber = SRC.ReferenceNumber,
		DST.PolicyCommencts = SRC.PolicyCommencts,
		DST.Status = SRC.Status,
		DST.CreditNoteId = SRC.CreditNoteId,
		DST.ContinentName = SRC.ContinentName,
		DST.[CreatedDateTime] = SRC.[CreatedDateTime],
		DST.[CreatedBy] = SRC.[CreatedBy],
		DST.[ModifiedDateTime] = SRC.[ModifiedDateTime],
		DST.[ModifiedBy] = SRC.[ModifiedBy],
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbPolicies', '',@insertcount, @updatecount, 2, 5, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicies', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - Policy', 'Update', @insertcount, @updatecount, 2, 5, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicies', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimPolicy', 'Process_StarDimension_Policy', 'Package_Error_Log', 'Failed', 'Star Dimension - Policy', '', 0, 0, 2, 5, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 5, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
