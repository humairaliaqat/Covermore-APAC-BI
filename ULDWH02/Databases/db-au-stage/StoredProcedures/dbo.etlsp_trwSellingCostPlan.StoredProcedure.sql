USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwSellingCostPlan]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [db-au-stage]

CREATE procedure [dbo].[etlsp_trwSellingCostPlan]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

SET NOCOUNT ON

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'trwSellingCostPlan', '',0,0
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwSellingCostPlan', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Process Dimension Facts - Policy', 'Insert', 0, 0, 3, 1, NULL, NULL, NULL

	if object_id('[db-au-stage].dbo.trwSellingCostPlanTemp') is not null
	BEGIN
		DROP TABLE [db-au-stage].dbo.trwSellingCostPlanTemp

		CREATE TABLE [db-au-stage].dbo.[trwSellingCostPlanTemp] (
					[SellingPlanID]				int,
					[SellingPlan]					nvarchar(100),
					[SellingPlanShortName]			nvarchar(50),
					[SellingDayPlan]				bit,
					[TAPlanTypeID]					int,
					[PlanType]						nvarchar(50),
					[TrawellTagOption]				bit,
					[SellingAnnualPlan]				bit,
					[SellingPlanStatus]				nvarchar(50),
					[CostPlanID]					int,
					[CostPlan]						nvarchar(100),
					[CostPlanShortName]				nvarchar(50),
					[InsuranceProviderID]			int,
					[InsuranceProvider]				nvarchar(50),
					[CompanyName]					nvarchar(50),
					[ContactPerson]					nvarchar(50),
					[Address1]						nvarchar(500),
					[Address2]						nvarchar(500),
					[City]							nvarchar(50),
					[District]						nvarchar(50),
					[State]							nvarchar(50),
					[PinCode]						nvarchar(10),
					[Country]						nvarchar(100),
					[PhoneNo]						nvarchar(50),
					[MobileNo]						nvarchar(50),
					[EmailAddress]					nvarchar(50),
					[StudentPolicyText]				nvarchar(1000),
					[AnnualPolicyText]				nvarchar(1000),
					[NextPolicyNumber]				int,
					[InsuranceCategoryID]			int,
					[InsuranceCategory]				nvarchar(100),
					[MasterPolicyNumber]			nvarchar(50),
					[CostDayPlan]					bit,
					[TAProviderID]					int,
					[TAProvider]					nvarchar(50),
					[TAPlanID]						int,
					[PlanName]						nvarchar(50),
					[TANumber]						nvarchar(50),
					[VisitingCountryID]				int,
					[VisitingCountry]				nvarchar(500),
					[CostAnnualPlan]				bit,
					[CostPlanStatus]				nvarchar(50),
					[EntityID]						int,
					[Entity]						nvarchar(500),
					[EntityType]					nvarchar(50),
					[hashkey]						varbinary(50)
				)
	END
	ELSE
	BEGIN
			CREATE TABLE [db-au-stage].dbo.[trwSellingCostPlanTemp] (
					[SellingPlanID]				int,
					[SellingPlan]					nvarchar(100),
					[SellingPlanShortName]			nvarchar(50),
					[SellingDayPlan]				bit,
					[TAPlanTypeID]					int,
					[PlanType]						nvarchar(50),
					[TrawellTagOption]				bit,
					[SellingAnnualPlan]				bit,
					[SellingPlanStatus]				nvarchar(50),
					[CostPlanID]					int,
					[CostPlan]						nvarchar(100),
					[CostPlanShortName]				nvarchar(50),
					[InsuranceProviderID]			int,
					[InsuranceProvider]				nvarchar(50),
					[CompanyName]					nvarchar(50),
					[ContactPerson]					nvarchar(50),
					[Address1]						nvarchar(500),
					[Address2]						nvarchar(500),
					[City]							nvarchar(50),
					[District]						nvarchar(50),
					[State]							nvarchar(50),
					[PinCode]						nvarchar(10),
					[Country]						nvarchar(100),
					[PhoneNo]						nvarchar(50),
					[MobileNo]						nvarchar(50),
					[EmailAddress]					nvarchar(50),
					[StudentPolicyText]				nvarchar(1000),
					[AnnualPolicyText]				nvarchar(1000),
					[NextPolicyNumber]				int,
					[InsuranceCategoryID]			int,
					[InsuranceCategory]				nvarchar(100),
					[MasterPolicyNumber]			nvarchar(50),
					[CostDayPlan]					bit,
					[TAProviderID]					int,
					[TAProvider]					nvarchar(50),
					[TAPlanID]						int,
					[PlanName]						nvarchar(50),
					[TANumber]						nvarchar(50),
					[VisitingCountryID]				int,
					[VisitingCountry]				nvarchar(500),
					[CostAnnualPlan]				bit,
					[CostPlanStatus]				nvarchar(50),
					[EntityID]						int,
					[Entity]						nvarchar(500),
					[EntityType]					nvarchar(50),
					[hashkey]						varbinary(50)
				)

	END

	create clustered index idx_trwSellingCostPlanTemp_SellingCostPlanID on [db-au-stage].dbo.trwSellingCostPlanTemp(SellingPlanID)
	create nonclustered index idx_trwSellingCostPlanTemp_TAPlanTypeID on [db-au-stage].dbo.trwSellingCostPlanTemp(TAPlanTypeID)
	create nonclustered index idx_trwSellingCostPlanTemp_InsuranceProviderID on [db-au-stage].dbo.trwSellingCostPlanTemp(InsuranceProviderID)
	create nonclustered index idx_trwSellingCostPlanTemp_InsuranceCategoryID on [db-au-stage].dbo.trwSellingCostPlanTemp(InsuranceCategoryID)
	create nonclustered index idx_trwSellingCostPlanTemp_TAProviderID on [db-au-stage].dbo.trwSellingCostPlanTemp(TAProviderID)
	create nonclustered index idx_trwSellingCostPlanTemp_VisitingCountryID on [db-au-stage].dbo.trwSellingCostPlanTemp(VisitingCountryID)
	create nonclustered index idx_trwSellingCostPlanTemp_EntityID on [db-au-stage].dbo.trwSellingCostPlanTemp(EntityID)
	create nonclustered index idx_trwSellingCostPlanTemp_HashKey on [db-au-stage].dbo.trwSellingCostPlanTemp(HashKey)

	insert into [db-au-stage].dbo.trwSellingCostPlanTemp
		(SellingPlanID,SellingPlan,SellingPlanShortName,SellingDayPlan,TAPlanTypeID,PlanType,TrawellTagOption,SellingAnnualPlan,SellingPlanStatus,CostPlanID,CostPlan,CostPlanShortName,
		InsuranceProviderID,InsuranceProvider,CompanyName,ContactPerson,Address1,Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,StudentPolicyText,
		AnnualPolicyText,NextPolicyNumber,InsuranceCategoryID,InsuranceCategory,MasterPolicyNumber,CostDayPlan,TAProviderID,TAProvider,TAPlanID,PlanName,TANumber,VisitingCountryID,
		VisitingCountry,CostAnnualPlan,CostPlanStatus,EntityID,Entity,EntityType)
	select
		sp.SellingPlanID PlanID, sp.Name SellingPlan, sp.ShortName SellingPlanShortName, sp.DayPlan SellingDayPlan, sp.TAPlanTypeID, tp.PlanType,
		sp.TrawellTagOption, sp.Annualplan SellingAnnualPlan, sp.Status SellingPlanStatus,
		cp.CostPlanID, cp.Name CostPlan, cp.ShortName CostPlanShortName, cp.InsuranceProviderID,
		ip.Name InsuranceProvider, ip.CompanyName, ip.ContactPerson, ip.Address1, ip.Address2, ip.City, ip.District, ip.State, ip.PinCode, ip.Country, ip.PhoneNo,
		ip.MobileNo, ip.EmailAddress, ip.StudentPolicyText, ip.AnnualPolicyText, ip.NextPolicyNumber,
		cp.InsuranceCategoryID, ic.Description InsuranceCategory, 
		cp.MasterPolicyNumber, cp.DayPlan CostDayPlan,
		cp.TAProviderID, pr.Name TAProvider,
		cp.TAPlanID, pl.PlanName, cp.TANumber,
		cp.VisitingCountryID, vc.Description VisitingCountry,
		cp.Annualplan CostAnnualPlan, cp.Status CostPlanStatus,
		Ent.EntityID, Ent.Name Entity, EntityType--,
		--cpr.Name CostRider, cpr.PremiumPercent CostRiderPremiumPercent, spr.PremiumPercent SellingRiderPremiumPercent
	from [db-au-stage].dbo.[trwdimSellingPlan] sp
	inner join [db-au-stage].dbo.[trwdimTAPlanType] tp
	on sp.TAPlanTypeID = tp.TAPlanTypeID
	inner join [db-au-stage].dbo.[trwdimCostPlan] cp
	on cp.CostPlanID = sp.CostPlanID 
	inner join [db-au-stage].dbo.[trwdimInsuranceProvider] ip
	on ip.InsuranceProviderID = cp.InsuranceProviderID 
	inner join [db-au-stage].dbo.[trwdimInsuranceCategory] ic
	on ic.InsuranceCategoryID = cp.InsuranceCategoryID 
	inner join [db-au-stage].dbo.[trwdimVisitingCountry] vc
	on vc.VisitingCountryID = cp.VisitingCountryID 
	inner join [db-au-stage].dbo.[trwdimTAProvider] pr
	on pr.TAProviderID = cp.TAProviderID 
	inner join [db-au-stage].dbo.[trwdimTAPlan] pl
	on pl.TAPlanID = cp.TAPlanID 
	left outer join [db-au-stage].dbo.[trwdimEntity] Ent
	on ip.EntityID = Ent.EntityID
	left outer join [db-au-stage].dbo.[trwdimEntityType] Enty
	on Ent.EntityTypeID = Enty.EntityTypeID
	--left outer join [dimCostPlanRider] cpr
	--on cpr.CostPlanId = cp.CostPlanId 
	--left outer join [dimSellingPlanRider] spr
	--on spr.SellingPlanID = sp.SellingPlanID 
	--	and cpr.CostPlanRiderID = spr.CostPlanRiderId
	order by 1

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update [db-au-stage].dbo.trwSellingCostPlanTemp
	set 
		HashKey = binary_checksum(SellingPlanID,SellingPlan,SellingPlanShortName,SellingDayPlan,TAPlanTypeID,PlanType,TrawellTagOption,SellingAnnualPlan,SellingPlanStatus,CostPlanID,CostPlan,CostPlanShortName,
				InsuranceProviderID,InsuranceProvider,CompanyName,ContactPerson,Address1,Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,StudentPolicyText,
				AnnualPolicyText,NextPolicyNumber,InsuranceCategoryID,InsuranceCategory,MasterPolicyNumber,CostDayPlan,TAProviderID,TAProvider,TAPlanID,PlanName,TANumber,VisitingCountryID,
				VisitingCountry,CostAnnualPlan,CostPlanStatus,EntityID,Entity,EntityType)

--select * from [db-au-stage].dbo.trwSellingCostPlanTemp

	select
		@sourcecount = count(*)
	from
		[db-au-stage].dbo.trwSellingCostPlanTemp

	if object_id('[db-au-cmdwh].dbo.trwSellingCostPlan') is null
	BEGIN

		CREATE TABLE [db-au-cmdwh].dbo.[trwSellingCostPlan] (
		[SellingPlanSK]							int identity(1,1) not null,
		[SellingPlanID]							int not null,
		[SellingPlan]							nvarchar(500) null,
		[SellingPlanShortName]					nvarchar(500) null,
		[SellingDayPlan]						bit null,
		[TAPlanTypeID]							int null,
		[PlanType]								nvarchar(100) null,
		[TrawellTagOption]						bit null,
		[SellingAnnualPlan]						bit null,
		[SellingPlanStatus]						nvarchar(100) null,
		[CostPlanID]							int null,
		[CostPlan]								nvarchar(200) null,
		[CostPlanShortName]						nvarchar(200) null,
		[InsuranceProviderID]					int null,
		[InsuranceProvider]						nvarchar(100) null,
		[CompanyName]	 						nvarchar(100) null,
		[ContactPerson]							nvarchar(100) null,
		[Address1]								nvarchar(500) null,
		[Address2]								nvarchar(500) null,
		[City]									nvarchar(50) null,
		[District]								nvarchar(50) null,
		[State]									nvarchar(50) null,
		[PinCode]								nvarchar(10) null,
		[Country]								nvarchar(100) null,
		[PhoneNo]								nvarchar(100) null,
		[MobileNo]								nvarchar(100) null,
		[EmailAddress]							nvarchar(100) null,
		[StudentPolicyText]						nvarchar(2000) null,
		[AnnualPolicyText]						nvarchar(2000) null,
		[NextPolicyNumber]						int null,
		[InsuranceCategoryID]					int null,
		[InsuranceCategory]						nvarchar(200) null,
		[MasterPolicyNumber]					nvarchar(100) null,
		[CostDayPlan]							bit null,
		[TAProviderID]							int null,
		[TAProvider]							nvarchar(100) null,
		[TAPlanID]								int null,
		[PlanName]								nvarchar(100) null,
		[TANumber]								nvarchar(100) null,
		[VisitingCountryID]						int null,
		[VisitingCountry]						nvarchar(1000) null,
		[CostAnnualPlan]						bit null,
		[CostPlanStatus]						nvarchar(100) null,
		[EntityID]								int null,
		[Entity]								nvarchar(1000) null,
		[EntityType]							nvarchar(100) null,
		[InsertDate]							datetime null,
		[updateDate]							datetime null,
		[hashkey]								varbinary(50) null
	)

	create clustered index idx_trwSellingCostPlan_SellingCostPlanSK on [db-au-cmdwh].dbo.trwSellingCostPlan(SellingPlanSK)
	create nonclustered index idx_trwSellingCostPlan_SellingCostPlanID on [db-au-cmdwh].dbo.trwSellingCostPlan(SellingPlanID)
	create nonclustered index idx_trwSellingCostPlan_TAPlanTypeID on [db-au-cmdwh].dbo.trwSellingCostPlan(TAPlanTypeID)
	create nonclustered index idx_trwSellingCostPlan_InsuranceProviderID on [db-au-cmdwh].dbo.trwSellingCostPlan(InsuranceProviderID)
	create nonclustered index idx_trwSellingCostPlan_InsuranceCategoryID on [db-au-cmdwh].dbo.trwSellingCostPlan(InsuranceCategoryID)
	create nonclustered index idx_trwSellingCostPlan_TAProviderID on [db-au-cmdwh].dbo.trwSellingCostPlan(TAProviderID)
	create nonclustered index idx_trwSellingCostPlan_TAPlanID on [db-au-cmdwh].dbo.trwSellingCostPlan(TAPlanID)
	create nonclustered index idx_trwSellingCostPlan_VisitingCountryID on [db-au-cmdwh].dbo.trwSellingCostPlan(VisitingCountryID)
	create nonclustered index idx_trwSellingCostPlan_EntityID on [db-au-cmdwh].dbo.trwSellingCostPlan(EntityID)
	create nonclustered index idx_trwSellingCostPlan_HashKey on [db-au-cmdwh].dbo.trwSellingCostPlan(HashKey)

	END

BEGIN TRANSACTION;

BEGIN TRY

	merge into [db-au-cmdwh].dbo.trwSellingCostPlan as DST
	using [db-au-stage].dbo.trwSellingCostPlanTemp as SRC
	on (src.SellingPlanID = DST.SellingPlanID)

	when not matched by target then
	insert
	(
	SellingPlanID,
	SellingPlan,
	SellingPlanShortName,
	SellingDayPlan,
	TAPlanTypeID,
	PlanType,
	TrawellTagOption,
	SellingAnnualPlan,
	SellingPlanStatus,
	CostPlanID,
	CostPlan,
	CostPlanShortName,
	InsuranceProviderID,
	InsuranceProvider,
	CompanyName,
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
	StudentPolicyText,
	AnnualPolicyText,
	NextPolicyNumber,
	InsuranceCategoryID,
	InsuranceCategory,
	MasterPolicyNumber,
	CostDayPlan,
	TAProviderID,
	TAProvider,
	TAPlanID,
	PlanName,
	TANumber,
	VisitingCountryID,
	VisitingCountry,
	CostAnnualPlan,
	CostPlanStatus,
	EntityID,
	Entity,
	EntityType,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.SellingPlanID,
	SRC.SellingPlan,
	SRC.SellingPlanShortName,
	SRC.SellingDayPlan,
	SRC.TAPlanTypeID,
	SRC.PlanType,
	SRC.TrawellTagOption,
	SRC.SellingAnnualPlan,
	SRC.SellingPlanStatus,
	SRC.CostPlanID,
	SRC.CostPlan,
	SRC.CostPlanShortName,
	SRC.InsuranceProviderID,
	SRC.InsuranceProvider,
	SRC.CompanyName,
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
	SRC.StudentPolicyText,
	SRC.AnnualPolicyText,
	SRC.NextPolicyNumber,
	SRC.InsuranceCategoryID,
	SRC.InsuranceCategory,
	SRC.MasterPolicyNumber,
	SRC.CostDayPlan,
	SRC.TAProviderID,
	SRC.TAProvider,
	SRC.TAPlanID,
	SRC.PlanName,
	SRC.TANumber,
	SRC.VisitingCountryID,
	SRC.VisitingCountry,
	SRC.CostAnnualPlan,
	SRC.CostPlanStatus,
	SRC.EntityID,
	SRC.Entity,
	SRC.EntityType,
	getdate(),
	null,
	SRC.HashKey
	)

	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.SellingPlan = SRC.SellingPlan,
		DST.SellingPlanShortName = SRC.SellingPlanShortName,
		DST.SellingDayPlan = SRC.SellingDayPlan,
		DST.TAPlanTypeID = SRC.TAPlanTypeID,
		DST.PlanType = SRC.PlanType,
		DST.TrawellTagOption = SRC.TrawellTagOption,
		DST.SellingAnnualPlan = SRC.SellingAnnualPlan,
		DST.SellingPlanStatus = SRC.SellingPlanStatus,
		DST.CostPlanID = SRC.CostPlanID,
		DST.CostPlan = SRC.CostPlan,
		DST.CostPlanShortName = SRC.CostPlanShortName,
		DST.InsuranceProviderID = SRC.InsuranceProviderID,
		DST.InsuranceProvider = SRC.InsuranceProvider,
		DST.CompanyName = SRC.CompanyName,
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
		DST.StudentPolicyText = SRC.StudentPolicyText,
		DST.AnnualPolicyText = SRC.AnnualPolicyText,
		DST.NextPolicyNumber = SRC.NextPolicyNumber,
		DST.InsuranceCategoryID = SRC.InsuranceCategoryID,
		DST.InsuranceCategory = SRC.InsuranceCategory,
		DST.MasterPolicyNumber = SRC.MasterPolicyNumber,
		DST.CostDayPlan = SRC.CostDayPlan,
		DST.TAProviderID = SRC.TAProviderID,
		DST.TAProvider = SRC.TAProvider,
		DST.TAPlanID = SRC.TAPlanID,
		DST.PlanName = SRC.PlanName,
		DST.TANumber = SRC.TANumber,
		DST.VisitingCountryID = SRC.VisitingCountryID,
		DST.VisitingCountry = SRC.VisitingCountry,
		DST.CostAnnualPlan = SRC.CostAnnualPlan,
		DST.CostPlanStatus = SRC.CostPlanStatus,
		DST.EntityID = SRC.EntityID,
		DST.Entity = SRC.Entity,
		DST.EntityType = SRC.EntityType,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'trwSellingCostPlan', '',@insertcount, @updatecount
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwSellingCostPlan', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Process Dimension Facts - Policy', 'Update', @insertcount, @updatecount, 3, 1, NULL, NULL, NULL

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

	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwSellingCostPlan', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwSellingCostPlan', 'Process_etlsp_trwSellingPlanCost_DWH', 'Package_Error_Log', 'Failed', 'Process Dimension Facts - Policy', '', 0, 0, 3, 1, NULL, NULL, NULL

	exec [db-au-stage].dbo.etlsp_trwPackageStatus  'END', 3, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
GO
