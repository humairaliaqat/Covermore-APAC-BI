USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimSellingPlan]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimSellingPlan]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbSellingPlans', '',0,0, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbSellingPlans', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - SellingCostPlan', 'Insert', 0, 0, 2, 3, NULL, NULL, NULL


	if object_id('dbo.trwdimSellingPlan') is null
	BEGIN
    
		create table dbo.trwdimSellingPlan
		(
			SellingPlanSK						int identity(1,1) not null,
			SellingPlanID						int not null,
			CostPlanID							int null,
			Name								nvarchar(100) null,
			ShortName							nvarchar(50) null,
			DayPlan								bit null,
			TAPlanTypeID						int null,
			TrawellTagOption					bit null,
			Annualplan							bit null,
			Status								nvarchar(50) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimSellingPlan_SellingPlanSK on dbo.trwdimSellingPlan(SellingPlanSK)
		create nonclustered index idx_dimSellingPlan_SellingPlanID on dbo.trwdimSellingPlan(SellingPlanID)
		create nonclustered index idx_dimSellingPlan_CostPlanID on dbo.trwdimSellingPlan(CostPlanID)
		create nonclustered index idx_dimSellingPlan_TAPlanTypeID on dbo.trwdimSellingPlan(TAPlanTypeID)
		create nonclustered index idx_dimSellingPlan_HashKey on trwdimSellingPlan(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwSellingPlans
	set 
		HashKey = binary_checksum(SellingPlanID, CostPlanID, Name, ShortName, DayPlan, TAPlanTypeID, TrawellTagOption, Annualplan, Status)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwSellingPlans


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimSellingPlan as DST
	using ETL_trwSellingPlans as SRC
	on (src.SellingPlanID = DST.SellingPlanID)

	when not matched by target then
	insert
	(
	SellingPlanID,
	CostPlanID,
	Name,
	ShortName,
	DayPlan,
	TAPlanTypeID,
	TrawellTagOption,
	Annualplan,
	Status,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.SellingPlanID,
	SRC.CostPlanID,
	SRC.Name,
	SRC.ShortName,
	SRC.DayPlan,
	SRC.TAPlanTypeID,
	SRC.TrawellTagOption,
	SRC.Annualplan,
	SRC.Status,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.CostPlanID = SRC.CostPlanID,
		DST.Name = SRC.Name,
		DST.ShortName = SRC.ShortName,
		DST.DayPlan = SRC.DayPlan,
		DST.TAPlanTypeID = SRC.TAPlanTypeID,
		DST.TrawellTagOption = SRC.TrawellTagOption,
		DST.Annualplan = SRC.Annualplan,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbSellingPlans', '',@insertcount, @updatecount, 2, 3, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbSellingPlans', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - SellingCostPlan', 'Update', @insertcount, @updatecount, 2, 3, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbSellingPlans', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimSellingPlan', 'Process_StarDimension_SellingPlan', 'Package_Error_Log', 'Failed', 'Star Dimension - SellingCostPlan', '', 0, 0, 2, 3, NULL, NULL, NULL


	exec etlsp_trwPackageStatus  'END', 2, 3, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
