USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwPolicyRider]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwPolicyRider]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

SET NOCOUNT ON

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'trwPolicyRider', '',0,0
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicyRider', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Process Dimension Facts - Policy', 'Insert', 0, 0, 3, 1, NULL, NULL, NULL

	if object_id('[db-au-stage].dbo.trwPolicyRiderTemp') is not null
	BEGIN
		DROP TABLE [db-au-stage].dbo.trwPolicyRiderTemp

		CREATE TABLE [db-au-stage].dbo.[trwPolicyRiderTemp] (
					[PolicyRiderID]					int,
					[PolicyDetailID]				int,
					[SellingPlanRiderID]			int,
					[SellingPlanID]					int,
					[CostPlanID]					int,
					[CostPlanRiderID]				int,
					[Name]							nvarchar(500) null,
					[PremiumPercent]				numeric(22, 2) null,
					[hashkey]						varbinary(50)
				)
	END
	ELSE
	BEGIN
			CREATE TABLE [db-au-stage].dbo.[trwPolicyRiderTemp] (
					[PolicyRiderID]					int,
					[PolicyDetailID]				int,
					[SellingPlanRiderID]			int,
					[SellingPlanID]					int,
					[CostPlanID]					int,
					[CostPlanRiderID]				int,
					[Name]							nvarchar(500) null,
					[PremiumPercent]				numeric(22, 2) null,
					[hashkey]						varbinary(50)
				)

	END

	create clustered index idx_trwPolicyRiderTemp_PolicyRiderID on [db-au-stage].dbo.trwPolicyRiderTemp(PolicyRiderID)
	create nonclustered index idx_trwPolicyRiderTemp_PolicyDetailID on [db-au-stage].dbo.trwPolicyRiderTemp(PolicyDetailID)
	create nonclustered index idx_trwPolicyRiderTemp_SellingPlanRiderID on [db-au-stage].dbo.trwPolicyRiderTemp(SellingPlanRiderID)
	create nonclustered index idx_trwPolicyRiderTemp_SellingPlanID on [db-au-stage].dbo.trwPolicyRiderTemp(SellingPlanID)
	create nonclustered index idx_trwPolicyRiderTemp_CostPlanID on [db-au-stage].dbo.trwPolicyRiderTemp(CostPlanID)
	create nonclustered index idx_trwPolicyRiderTemp_CostPlanRiderID on [db-au-stage].dbo.trwPolicyRiderTemp(CostPlanRiderID)
	create nonclustered index idx_trwPolicyRiderTemp_HashKey on [db-au-stage].dbo.trwPolicyRiderTemp(HashKey)

	insert into [db-au-stage].dbo.trwPolicyRiderTemp
		(PolicyRiderID, PolicyDetailID, SellingPlanRiderID, SellingPlanID, CostPlanID, CostPlanRiderID, Name, PremiumPercent)
	select a.PolicyRiderID, a.PolicyDetailID, a.SellingPlanRiderID,
		b.SellingPlanID, c.CostPlanID, b.CostPlanRiderID, e.Name, e.PremiumPercent
	from [db-au-stage].dbo.trwdimPolicyRider a
	inner join [db-au-stage].dbo.trwdimSellingPlanRider b
	on a.SellingPlanRiderID = b.SellingPlanRiderID
	inner join [db-au-stage].dbo.trwdimSellingPlan c
	on c.SellingPlanID = b.SellingPlanID
	inner join [db-au-stage].dbo.trwdimCostPlan d
	on d.CostPlanID = c.CostPlanID
	inner join [db-au-stage].dbo.trwdimCostPlanRider e
	on e.CostPlanID = c.CostPlanID
		and e.CostPlanRiderID = b.CostPlanRiderID
	order by 1

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update [db-au-stage].dbo.trwPolicyRiderTemp
	set 
		HashKey = binary_checksum(PolicyRiderID, PolicyDetailID, SellingPlanRiderID, SellingPlanID, CostPlanID, CostPlanRiderID, Name, PremiumPercent)

--select * from [db-au-stage].dbo.trwPolicyRiderTemp

	select
		@sourcecount = count(*)
	from
		[db-au-stage].dbo.trwPolicyRiderTemp

	if object_id('[db-au-cmdwh].dbo.trwPolicyRider') is null
	BEGIN

		CREATE TABLE [db-au-cmdwh].dbo.[trwPolicyRider] (
		[PolicyRiderSK]					int identity(1,1) not null,
		[PolicyRiderID]					int,
		[PolicyDetailID]				int,
		[SellingPlanRiderID]			int,
		[SellingPlanID]					int,
		[CostPlanID]					int,
		[CostPlanRiderID]				int,
		[Name]							nvarchar(500) null,
		[PremiumPercent]				numeric(22, 2) null,
		[InsertDate]					datetime null,
		[updateDate]					datetime null,
		[hashkey]						varbinary(50) null
	)

	create nonclustered index idx_trwPolicyRider_PolicyRiderSK on [db-au-cmdwh].dbo.trwPolicyRider(PolicyRiderSK)
	create nonclustered index idx_trwPolicyRider_PolicyRiderID on [db-au-cmdwh].dbo.trwPolicyRider(PolicyRiderID)
	create nonclustered index idx_trwPolicyRider_PolicyDetailID on [db-au-cmdwh].dbo.trwPolicyRider(PolicyDetailID)
	create nonclustered index idx_trwPolicyRider_SellingPlanRiderID on [db-au-cmdwh].dbo.trwPolicyRider(SellingPlanRiderID)
	create nonclustered index idx_trwPolicyRider_SellingPlanID on [db-au-cmdwh].dbo.trwPolicyRider(SellingPlanID)
	create nonclustered index idx_trwPolicyRider_CostPlanID on [db-au-cmdwh].dbo.trwPolicyRider(CostPlanID)
	create nonclustered index idx_trwPolicyRider_CostPlanRiderID on [db-au-cmdwh].dbo.trwPolicyRider(CostPlanRiderID)
	create nonclustered index idx_trwPolicyRider_HashKey on [db-au-cmdwh].dbo.trwPolicyRider(HashKey)

	END

BEGIN TRANSACTION;

BEGIN TRY

	merge into [db-au-cmdwh].dbo.trwPolicyRider as DST
	using [db-au-stage].dbo.trwPolicyRiderTemp as SRC
	on (src.PolicyRiderID = DST.PolicyRiderID)

	when not matched by target then
	insert
	(
	PolicyRiderID,
	PolicyDetailID,
	SellingPlanRiderID,
	SellingPlanID,
	CostPlanID,
	CostPlanRiderID,
	Name,
	PremiumPercent,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.PolicyRiderID,
	SRC.PolicyDetailID,
	SRC.SellingPlanRiderID,
	SRC.SellingPlanID,
	SRC.CostPlanID,
	SRC.CostPlanRiderID,
	SRC.Name,
	SRC.PremiumPercent,
	getdate(),
	null,
	SRC.HashKey
	)

	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PolicyDetailID = SRC.PolicyDetailID,
		DST.SellingPlanRiderID = SRC.SellingPlanRiderID,
		DST.SellingPlanID = SRC.SellingPlanID,
		DST.CostPlanID = SRC.CostPlanID,
		DST.CostPlanRiderID = SRC.CostPlanRiderID,
		DST.Name = SRC.Name,
		DST.PremiumPercent = SRC.PremiumPercent,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'trwPolicyRider', '',@insertcount, @updatecount
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicyRider', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Process Dimension Facts - Policy', 'Update', @insertcount, @updatecount, 3, 1, NULL, NULL, NULL

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

	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicyRider', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwPolicyRider', 'Process_etlsp_trwPolicyRider_DWH', 'Package_Error_Log', 'Failed', 'Process Dimension Facts - Policy', '', 0, 0, 3, 1, NULL, NULL, NULL

	exec [db-au-stage].dbo.etlsp_trwPackageStatus  'END', 3, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
GO
