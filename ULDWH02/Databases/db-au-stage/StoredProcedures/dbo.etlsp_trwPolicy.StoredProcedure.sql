USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwPolicy]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [db-au-stage]

CREATE procedure [dbo].[etlsp_trwPolicy]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

SET NOCOUNT ON

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'trwPolicy', '',0,0
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicy', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Process Dimension Facts - Policy', 'Insert', 0, 0, 3, 1, NULL, NULL, NULL

	if object_id('[db-au-stage].dbo.trwPolicyTemp') is not null 
	BEGIN
		DROP TABLE [db-au-stage].dbo.trwPolicyTemp 

		CREATE TABLE [db-au-stage].dbo.[trwPolicyTemp] (
					[PolicyID]						int,
					[PolicyNumber]					numeric(22, 0),
					[MasterPolicyNumber]			nvarchar(50),
					[DateOfPolicy]					datetime null,
					[OldPolicyReferenceNo]			numeric(22, 0),
					[ReferralCommissionPercent]		numeric(18, 2),
					[DiscountPercent]				numeric(18, 2),
					[CurrentPolicyDetailID]			int,
					[RefNo]							nvarchar(100),
					[AuthenticationCode]			nvarchar(50),
					[Remarks]						nvarchar(500),
					[MasterNumber]					nvarchar(100),
					[CancellationCharges]			numeric(18, 2),
					[TrawellAssistNumber]			nvarchar(100),
					[EarlyArrivalRefund]			numeric(18, 2),
					[ReferenceNumber]				nvarchar(200),
					[PolicyCommencts]				nvarchar(max),
					[Status]						nvarchar(50),
					[CreatedDateTime]				datetime,
					[CreatedBy]						nvarchar(256),
					[ModifiedDateTime]				datetime,
					[ModifiedBy]					nvarchar(256),
					[ContinentName]					nvarchar(1000),
					[EmployeeID]					int null,
					[AgentEmployeeID]				int null,
					[BranchCode]					int null,
					[Branch]						nvarchar(256),
					[AreaCode]						int null,
					[Area]							nvarchar(256),
					[RegionCode]					int null,
					[Region]						nvarchar(256),
					[hashkey]						varbinary(50)
				)
	END
	ELSE
	BEGIN
			CREATE TABLE [db-au-stage].dbo.[trwPolicyTemp] (
					[PolicyID]						int,
					[PolicyNumber]					numeric(22, 0),
					[MasterPolicyNumber]			nvarchar(50),
					[DateOfPolicy]					datetime null,
					[OldPolicyReferenceNo]			numeric(22, 0),
					[ReferralCommissionPercent]		numeric(18, 2),
					[DiscountPercent]				numeric(18, 2),
					[CurrentPolicyDetailID]			int,
					[RefNo]							nvarchar(100),
					[AuthenticationCode]			nvarchar(50),
					[Remarks]						nvarchar(500),
					[MasterNumber]					nvarchar(100),
					[CancellationCharges]			numeric(18, 2),
					[TrawellAssistNumber]			nvarchar(100),
					[EarlyArrivalRefund]			numeric(18, 2),
					[ReferenceNumber]				nvarchar(200),
					[PolicyCommencts]				nvarchar(max),
					[Status]						nvarchar(50),
					[CreatedDateTime]				datetime,
					[CreatedBy]						nvarchar(256),
					[ModifiedDateTime]				datetime,
					[ModifiedBy]					nvarchar(256),
					[ContinentName]					nvarchar(1000),
					[EmployeeID]					int null,
					[AgentEmployeeID]				int null,
					[BranchCode]					int null,
					[Branch]						nvarchar(256),
					[AreaCode]						int null,
					[Area]							nvarchar(256),
					[RegionCode]					int null,
					[Region]						nvarchar(256),
					[hashkey]						varbinary(50)
				)
	END

	create clustered index idx_trwPolicyTemp_PolicyID on [db-au-stage].dbo.trwPolicyTemp(PolicyID)
	create nonclustered index idx_trwPolicyTemp_CurrentPolicyDetailID on [db-au-stage].dbo.trwPolicyTemp(CurrentPolicyDetailID)
	create nonclustered index idx_trwPolicyTemp_HashKey on [db-au-stage].dbo.trwPolicyTemp(HashKey)

	insert into [db-au-stage].dbo.trwPolicyTemp
		(PolicyID,PolicyNumber,MasterPolicyNumber,DateOfPolicy,OldPolicyReferenceNo,ReferralCommissionPercent,DiscountPercent,CurrentPolicyDetailID,RefNo,AuthenticationCode,
			Remarks,MasterNumber,CancellationCharges,TrawellAssistNumber,EarlyArrivalRefund,ReferenceNumber,PolicyCommencts,Status,CreatedDateTime,CreatedBy,ModifiedDateTime,
			ModifiedBy,ContinentName,EmployeeID,AgentEmployeeID,BranchCode,Branch,AreaCode,Area,RegionCode,Region)
	select PolicyID,PolicyNumber,MasterPolicyNumber,DateOfPolicy,OldPolicyReferenceNo,ReferralCommissionPercent,DiscountPercent,CurrentPolicyDetailID,RefNo,AuthenticationCode,
			Remarks,ply.MasterNumber,CancellationCharges,TrawellAssistNumber,EarlyArrivalRefund,ReferenceNumber,PolicyCommencts,ply.Status,CreatedDateTime,CreatedBy,ModifiedDateTime,
			ModifiedBy,ContinentName,EmployeeID,AgentEmployeeID,br.BranchID,br.Name,ar.AreaID,ar.name,rg.RegionID,rg.Name
	from [db-au-stage].dbo.trwdimPolicy ply
	left outer join [db-au-stage].dbo.trwdimBranch br with (nolock)
	on ply.BranchID = br.BranchID
	left outer join [db-au-stage].dbo.trwdimArea ar with (nolock)
	on br.AreaID = ar.AreaID
	left outer join [db-au-stage].dbo.trwdimRegion rg with (nolock)
	on rg.RegionID = ar.RegionID
	order by 1

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update [db-au-stage].dbo.trwPolicyTemp
	set 
		HashKey = binary_checksum(PolicyID,PolicyNumber,MasterPolicyNumber,DateOfPolicy,OldPolicyReferenceNo,ReferralCommissionPercent,DiscountPercent,CurrentPolicyDetailID,
							RefNo,AuthenticationCode,Remarks,MasterNumber,CancellationCharges,TrawellAssistNumber,EarlyArrivalRefund,ReferenceNumber,PolicyCommencts,
							Status,CreatedDateTime,CreatedBy,ModifiedDateTime,ModifiedBy,ContinentName,EmployeeID,AgentEmployeeID,BranchCode,Branch,AreaCode,Area,RegionCode,Region)


	select
		@sourcecount = count(*)
	from
		[db-au-stage].dbo.trwPolicyTemp

	if object_id('[db-au-cmdwh].dbo.trwPolicy') is null
	BEGIN

		CREATE TABLE [db-au-cmdwh].dbo.[trwPolicy] (
		[PolicySK]						int identity(1,1) not null,
		[PolicyID]						int,
		[PolicyNumber]					numeric(22, 0),
		[MasterPolicyNumber]			nvarchar(50),
		[DateOfPolicy]					datetime null,
		[OldPolicyReferenceNo]			numeric(22, 0),
		[ReferralCommissionPercent]		numeric(18, 2),
		[DiscountPercent]				numeric(18, 2),
		[CurrentPolicyDetailID]			int,
		[RefNo]							nvarchar(100),
		[AuthenticationCode]			nvarchar(50),
		[Remarks]						nvarchar(500),
		[MasterNumber]					nvarchar(100),
		[CancellationCharges]			numeric(18, 2),
		[TrawellAssistNumber]			nvarchar(100),
		[EarlyArrivalRefund]			numeric(18, 2),
		[ReferenceNumber]				nvarchar(200),
		[PolicyCommencts]				nvarchar(max),
		[Status]						nvarchar(50),
		[CreatedDateTime]				datetime,
		[CreatedBy]						nvarchar(256),
		[ModifiedDateTime]				datetime,
		[ModifiedBy]					nvarchar(256),
		[ContinentName]					nvarchar(1000),
		[EmployeeID]					int null,
		[AgentEmployeeID]				int null,
		[BranchCode]					int null,
		[Branch]						nvarchar(256),
		[AreaCode]						int null,
		[Area]							nvarchar(256),
		[RegionCode]					int null,
		[Region]						nvarchar(256),
		[InsertDate]					datetime null,
		[updateDate]					datetime null,
		[hashkey]						varbinary(50) null
	)

	create clustered index idx_trwPolicy_PolicySK on [db-au-cmdwh].dbo.trwPolicy(PolicySK)
	create nonclustered index idx_trwPolicy_PolicyID on [db-au-cmdwh].dbo.trwPolicy(PolicyID)
	create nonclustered index idx_trwPolicy_HashKey on [db-au-cmdwh].dbo.trwPolicy(HashKey)

	END

BEGIN TRANSACTION;

BEGIN TRY

	merge into [db-au-cmdwh].dbo.trwPolicy as DST
	using [db-au-stage].dbo.trwPolicyTemp as SRC
	on (src.PolicyID = DST.PolicyID)

	when not matched by target then
	insert
	(
	PolicyID,
	PolicyNumber,
	MasterPolicyNumber,
	DateOfPolicy,
	OldPolicyReferenceNo,
	ReferralCommissionPercent,
	DiscountPercent,
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
	CreatedDateTime,
	CreatedBy,
	ModifiedDateTime,
	ModifiedBy,
	ContinentName,
	InsertDate,
	updateDate,
	EmployeeID,
	AgentEmployeeID,
	BranchCode,
	Branch,
	AreaCode,
	Area,
	RegionCode,
	Region,
	HashKey
	)
	values
	(
	SRC.PolicyID,
	SRC.PolicyNumber,
	SRC.MasterPolicyNumber,
	SRC.DateOfPolicy,
	SRC.OldPolicyReferenceNo,
	SRC.ReferralCommissionPercent,
	SRC.DiscountPercent,
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
	SRC.CreatedDateTime,
	SRC.CreatedBy,
	SRC.ModifiedDateTime,
	SRC.ModifiedBy,
	SRC.ContinentName,
	getdate(),
	null,
	SRC.EmployeeID,
	SRC.AgentEmployeeID,
	SRC.BranchCode,
	SRC.Branch,
	SRC.AreaCode,
	SRC.Area,
	SRC.RegionCode,
	SRC.Region,
	SRC.HashKey
	)

	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PolicyNumber = SRC.PolicyNumber,
		DST.MasterPolicyNumber = SRC.MasterPolicyNumber,
		DST.DateOfPolicy = SRC.DateOfPolicy,
		DST.OldPolicyReferenceNo = SRC.OldPolicyReferenceNo,
		DST.ReferralCommissionPercent = SRC.ReferralCommissionPercent,
		DST.DiscountPercent = SRC.DiscountPercent,
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
		DST.CreatedDateTime = SRC.CreatedDateTime,
		DST.CreatedBy = SRC.CreatedBy,
		DST.ModifiedDateTime = SRC.ModifiedDateTime,
		DST.ModifiedBy = SRC.ModifiedBy,
		DST.ContinentName = SRC.ContinentName,
		DST.EmployeeID = SRC.EmployeeID,
		DST.AgentEmployeeID = SRC.AgentEmployeeID,
		DST.BranchCode = SRC.BranchCode,
		DST.Branch = SRC.Branch,
		DST.AreaCode = SRC.AreaCode,
		DST.Area = SRC.Area,
		DST.RegionCode = SRC.RegionCode,
		DST.Region = SRC.Region,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'trwPolicy', '',@insertcount, @updatecount
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicy', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Process Dimension Facts - Policy', 'Update', @insertcount, @updatecount, 3, 1, NULL, NULL, NULL

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

	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicy', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwPolicy', 'Process_etlsp_trwEmployee_DWH', 'Package_Error_Log', 'Failed', 'Process Dimension Facts - Policy', '', 0, 0, 3, 1, NULL, NULL, NULL

	exec [db-au-stage].dbo.etlsp_trwPackageStatus  'END', 3, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END



GO
