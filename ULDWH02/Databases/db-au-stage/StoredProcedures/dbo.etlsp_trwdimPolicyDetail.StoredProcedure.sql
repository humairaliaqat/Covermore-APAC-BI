USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimPolicyDetail]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimPolicyDetail]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as


BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbPolicies', '',0,0, 2, 5, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyDetails', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - PolicyDetail', 'Insert', 0, 0, 2, 7, NULL, NULL, NULL

	if object_id('dbo.trwdimPolicyDetail') is null
	BEGIN
    
		create table dbo.trwdimPolicyDetail
		(
			PolicyDetailSK						int identity(1,1) not null,
			PolicyDetailID						int not null,
			PolicyID							numeric(18, 0) null,
			Endorsement							numeric(18, 0) null,
			EndorsementDate						datetime null,
			PassportNumber						nvarchar(50) null,
			InsuranceCategoryID					int null,
			SellingPlanID						int null,
			DepartureDate						datetime null,
			Days								numeric(18, 0) null,
			ArrivalDate							datetime null,
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
			UniversityName						nvarchar(100) null,
			UniversityAddress					nvarchar(1000) null,
			Name								nvarchar(50) null,
			DOB									datetime null,
			Age									numeric(18, 0) null,
			TrawellTagNumber					numeric(18, 0) null,
			Nominee								nvarchar(50) null,
			Relation							nvarchar(50) null,
			PastIllness							nvarchar(1000) null,
			RestrictedCoverage					bit null,
			BasePremium							numeric(18, 2) null,
			Premium								numeric(18, 2) null,							
			RiderPercent						numeric(18, 2) null,
			RiderPremium						numeric(18, 2) null,
			NewPremium							numeric(18, 2) null,
			OldPremium							numeric(18, 2) null,
			TotalAmount							numeric(18, 2) null,
			ServiceTaxRate						numeric(18, 2) null,
			CESS1Rate							numeric(18, 2) null,
			CESS2Rate							numeric(18, 2) null,
			ServiceTax							numeric(18, 2) null,
			CESS1								numeric(18, 2) null,
			CESS2								numeric(18, 2) null,
			GrossAmount							numeric(18, 2) null,
			DiscountPercent						numeric(18, 2) null,
			DiscountAmount						numeric(18, 2) null,
			DiscountServiceTax					numeric(18, 2) null,
			DiscountCESS1						numeric(18, 2) null,
			DiscountCESS2						numeric(18, 2) null,
			NetServiceTax						numeric(18, 2) null,
			NetCESS1							numeric(18, 2) null,
			NetCESS2							numeric(18, 2) null,
			NetAmount							numeric(18, 2) null,
			InvoiceID							int null,
			AgentCommissionDocumentID			int null,
			CreatedDateTime						datetime null,
			CreatedBy							nvarchar(256) null,
			ModifiedDateTime					datetime null,			
			ModifiedBy							nvarchar(256) null,
			OldRiderPremium						numeric(18, 2) null,
			OldTotalAmount						numeric(18, 2) null,
			ActualNewPremium					numeric(18, 2) null,
			ActualOldPremium					numeric(18, 2) null,
			ActualTotalAmount					numeric(18, 2) null,
			ActualServiceTax					numeric(18, 2) null,
			ActualCESS1							numeric(18, 2) null,
			ActualCESS2							numeric(18, 2) null,
			ActualGrossAmount					numeric(18, 2) null,
			ActualDiscountPercent				numeric(18, 2) null,
			ActualDiscountAmount				numeric(18, 2) null,
			ActualDiscountServiceTax			numeric(18, 2) null,
			ActualDiscountCESS1					numeric(18, 2) null,
			ActualDiscountCESS2					numeric(18, 2) null,
			ActualNetServiceTax					numeric(18, 2) null,
			ActualNetCESS1						numeric(18, 2) null,
			ActualNetCESS2						numeric(18, 2) null,
			ActualNetAmount						numeric(18, 2) null,
			Actualoldinsurancecost				numeric(18, 2) null,
			ActualNewinsurancecost				numeric(18, 2) null,
			Actualinsurancecost					numeric(18, 2) null,
			CreditNoteId						numeric(18, 0) null,
			ActualTdsAmount						numeric(18, 2) null,
			ActualComissionAmount				numeric(18, 2) null,
			ActualoldTApremium					numeric(18, 2) null,
			ActualNewTApremium					numeric(18, 2) null,
			ActualTApremim						numeric(18, 2) null,
			Remarks								ntext,
			pdfreference						nvarchar(max),
			DebitNoteId							numeric(18, 0) null,
			ManualPremiumTotal					numeric(18, 2) null,
			ManualPremiumBasic					numeric(18, 2) null,
			ManualPremiumServiceTax				numeric(18, 2) null,
			sponsorname							nvarchar(max),
			sponsorrelation						nvarchar(max),
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimPolicyDetail_PolicyDetailSK on dbo.trwdimPolicyDetail(PolicyDetailSK)
		create nonclustered index idx_dimPolicyDetail_PolicyID on dbo.trwdimPolicyDetail(PolicyDetailID)
		create nonclustered index idx_dimPolicyDetail_EmployeeID on dbo.trwdimPolicyDetail(PolicyID)
		create nonclustered index idx_dimPolicyDetail_AgentEmployeeID on dbo.trwdimPolicyDetail(InsuranceCategoryID)
		create nonclustered index idx_dimPolicyDetail_ReferralAgentID on dbo.trwdimPolicyDetail(SellingPlanID)
		create nonclustered index idx_dimPolicyDetail_CreditNoteId on dbo.trwdimPolicyDetail(CreditNoteId)
		create nonclustered index idx_dimPolicyDetail_HashKey on trwdimPolicyDetail(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwPolicyDetails
	set 
		HashKey = binary_checksum(PolicyDetailID,PolicyID,Endorsement,EndorsementDate,PassportNumber,InsuranceCategoryID,SellingPlanID,DepartureDate,Days,ArrivalDate,Address1,
						Address2,City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,UniversityName,UniversityAddress,Name,DOB,Age,TrawellTagNumber,Nominee,Relation,
						PastIllness,RestrictedCoverage,BasePremium,Premium,RiderPercent,RiderPremium,NewPremium,OldPremium,TotalAmount,ServiceTaxRate,CESS1Rate,CESS2Rate,ServiceTax,
						CESS1,CESS2,GrossAmount,DiscountPercent,DiscountAmount,DiscountServiceTax,DiscountCESS1,DiscountCESS2,NetServiceTax,NetCESS1,NetCESS2,NetAmount,InvoiceID,AgentCommissionDocumentID,
						CreatedDateTime,CreatedBy,ModifiedDateTime,ModifiedBy,OldRiderPremium,OldTotalAmount,ActualNewPremium,ActualOldPremium,ActualTotalAmount,
						ActualServiceTax,ActualCESS1,ActualCESS2,ActualGrossAmount,ActualDiscountPercent,ActualDiscountAmount,ActualDiscountServiceTax,ActualDiscountCESS1,
						ActualDiscountCESS2,ActualNetServiceTax,ActualNetCESS1,ActualNetCESS2,ActualNetAmount,Actualoldinsurancecost,ActualNewinsurancecost,Actualinsurancecost,CreditNoteId,
						ActualTdsAmount,ActualComissionAmount,ActualoldTApremium,ActualNewTApremium,ActualTApremim,Remarks,pdfreference,DebitNoteId,ManualPremiumTotal,ManualPremiumBasic,
						ManualPremiumServiceTax,sponsorname,sponsorrelation)

	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwPolicyDetails


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimPolicyDetail as DST
	using ETL_trwPolicyDetails as SRC
	on (src.PolicyDetailID = DST.PolicyDetailID)

	when not matched by target then
	insert
	(
	PolicyDetailID,
	PolicyID,
	Endorsement,
	EndorsementDate,
	PassportNumber,
	InsuranceCategoryID,
	SellingPlanID,
	DepartureDate,
	Days,
	ArrivalDate,
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
	UniversityName,
	UniversityAddress,
	Name,
	DOB,
	Age,
	TrawellTagNumber,
	Nominee,
	Relation,
	PastIllness,
	RestrictedCoverage,
	BasePremium,
	Premium,
	RiderPercent,
	RiderPremium,
	NewPremium,
	OldPremium,
	TotalAmount,
	ServiceTaxRate,
	CESS1Rate,
	CESS2Rate,
	ServiceTax,
	CESS1,
	CESS2,
	GrossAmount,
	DiscountPercent,
	DiscountAmount,
	DiscountServiceTax,
	DiscountCESS1,
	DiscountCESS2,
	NetServiceTax,
	NetCESS1,
	NetCESS2,
	NetAmount,
	InvoiceID,
	AgentCommissionDocumentID,
	CreatedDateTime,
	CreatedBy,
	ModifiedDateTime,
	ModifiedBy,
	OldRiderPremium,
	OldTotalAmount,
	ActualNewPremium,
	ActualOldPremium,
	ActualTotalAmount,
	ActualServiceTax,
	ActualCESS1,
	ActualCESS2,
	ActualGrossAmount,
	ActualDiscountPercent,
	ActualDiscountAmount,
	ActualDiscountServiceTax,
	ActualDiscountCESS1,
	ActualDiscountCESS2,
	ActualNetServiceTax,
	ActualNetCESS1,
	ActualNetCESS2,
	ActualNetAmount,
	Actualoldinsurancecost,
	ActualNewinsurancecost,
	Actualinsurancecost,
	CreditNoteId,
	ActualTdsAmount,
	ActualComissionAmount,
	ActualoldTApremium,
	ActualNewTApremium,
	ActualTApremim,
	Remarks,
	pdfreference,
	DebitNoteId,
	ManualPremiumTotal,
	ManualPremiumBasic,
	ManualPremiumServiceTax,
	sponsorname,
	sponsorrelation,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.PolicyDetailID,
	SRC.PolicyID,
	SRC.Endorsement,
	SRC.EndorsementDate,
	SRC.PassportNumber,
	SRC.InsuranceCategoryID,
	SRC.SellingPlanID,
	SRC.DepartureDate,
	SRC.Days,
	SRC.ArrivalDate,
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
	SRC.UniversityName,
	SRC.UniversityAddress,
	SRC.Name,
	SRC.DOB,
	SRC.Age,
	SRC.TrawellTagNumber,
	SRC.Nominee,
	SRC.Relation,
	SRC.PastIllness,
	SRC.RestrictedCoverage,
	SRC.BasePremium,
	SRC.Premium,
	SRC.RiderPercent,
	SRC.RiderPremium,
	SRC.NewPremium,
	SRC.OldPremium,
	SRC.TotalAmount,
	SRC.ServiceTaxRate,
	SRC.CESS1Rate,
	SRC.CESS2Rate,
	SRC.ServiceTax,
	SRC.CESS1,
	SRC.CESS2,
	SRC.GrossAmount,
	SRC.DiscountPercent,
	SRC.DiscountAmount,
	SRC.DiscountServiceTax,
	SRC.DiscountCESS1,
	SRC.DiscountCESS2,
	SRC.NetServiceTax,
	SRC.NetCESS1,
	SRC.NetCESS2,
	SRC.NetAmount,
	SRC.InvoiceID,
	SRC.AgentCommissionDocumentID,
	SRC.CreatedDateTime,
	SRC.CreatedBy,
	SRC.ModifiedDateTime,
	SRC.ModifiedBy,
	SRC.OldRiderPremium,
	SRC.OldTotalAmount,
	SRC.ActualNewPremium,
	SRC.ActualOldPremium,
	SRC.ActualTotalAmount,
	SRC.ActualServiceTax,
	SRC.ActualCESS1,
	SRC.ActualCESS2,
	SRC.ActualGrossAmount,
	SRC.ActualDiscountPercent,
	SRC.ActualDiscountAmount,
	SRC.ActualDiscountServiceTax,
	SRC.ActualDiscountCESS1,
	SRC.ActualDiscountCESS2,
	SRC.ActualNetServiceTax,
	SRC.ActualNetCESS1,
	SRC.ActualNetCESS2,
	SRC.ActualNetAmount,
	SRC.Actualoldinsurancecost,
	SRC.ActualNewinsurancecost,
	SRC.Actualinsurancecost,
	SRC.CreditNoteId,
	SRC.ActualTdsAmount,
	SRC.ActualComissionAmount,
	SRC.ActualoldTApremium,
	SRC.ActualNewTApremium,
	SRC.ActualTApremim,
	SRC.Remarks,
	SRC.pdfreference,
	SRC.DebitNoteId,
	SRC.ManualPremiumTotal,
	SRC.ManualPremiumBasic,
	SRC.ManualPremiumServiceTax,
	SRC.sponsorname,
	SRC.sponsorrelation,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PolicyID = SRC.PolicyID,
		DST.Endorsement = SRC.Endorsement,
		DST.EndorsementDate = SRC.EndorsementDate,
		DST.PassportNumber = SRC.PassportNumber,
		DST.InsuranceCategoryID = SRC.InsuranceCategoryID,
		DST.SellingPlanID = SRC.SellingPlanID,
		DST.DepartureDate = SRC.DepartureDate,
		DST.Days = SRC.Days,
		DST.ArrivalDate = SRC.ArrivalDate,
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
		DST.UniversityName = SRC.UniversityName,
		DST.UniversityAddress = SRC.UniversityAddress,
		DST.Name = SRC.Name,
		DST.DOB = SRC.DOB,
		DST.Age = SRC.Age,
		DST.TrawellTagNumber = SRC.TrawellTagNumber,
		DST.Nominee = SRC.Nominee,
		DST.Relation = SRC.Relation,
		DST.PastIllness = SRC.PastIllness,
		DST.RestrictedCoverage = SRC.RestrictedCoverage,
		DST.BasePremium = SRC.BasePremium,
		DST.Premium = SRC.Premium,
		DST.RiderPercent = SRC.RiderPercent,
		DST.RiderPremium = SRC.RiderPremium,
		DST.NewPremium = SRC.NewPremium,
		DST.OldPremium = SRC.OldPremium,
		DST.TotalAmount = SRC.TotalAmount,
		DST.ServiceTaxRate = SRC.ServiceTaxRate,
		DST.CESS1Rate = SRC.CESS1Rate,
		DST.CESS2Rate = SRC.CESS2Rate,
		DST.ServiceTax = SRC.ServiceTax,
		DST.CESS1 = SRC.CESS1,
		DST.CESS2 = SRC.CESS2,
		DST.GrossAmount = SRC.GrossAmount,
		DST.DiscountPercent = SRC.DiscountPercent,
		DST.DiscountAmount = SRC.DiscountAmount,
		DST.DiscountServiceTax = SRC.DiscountServiceTax,
		DST.DiscountCESS1 = SRC.DiscountCESS1,
		DST.DiscountCESS2 = SRC.DiscountCESS2,
		DST.NetServiceTax = SRC.NetServiceTax,
		DST.NetCESS1 = SRC.NetCESS1,
		DST.NetCESS2 = SRC.NetCESS2,
		DST.NetAmount = SRC.NetAmount,
		DST.InvoiceID = SRC.InvoiceID,
		DST.AgentCommissionDocumentID = SRC.AgentCommissionDocumentID,
		DST.CreatedDateTime = SRC.CreatedDateTime,
		DST.CreatedBy = SRC.CreatedBy,
		DST.ModifiedDateTime = SRC.ModifiedDateTime,
		DST.ModifiedBy = SRC.ModifiedBy,
		DST.OldRiderPremium = SRC.OldRiderPremium,
		DST.OldTotalAmount = SRC.OldTotalAmount,
		DST.ActualNewPremium = SRC.ActualNewPremium,
		DST.ActualOldPremium = SRC.ActualOldPremium,
		DST.ActualTotalAmount = SRC.ActualTotalAmount,
		DST.ActualServiceTax = SRC.ActualServiceTax,
		DST.ActualCESS1 = SRC.ActualCESS1,
		DST.ActualCESS2 = SRC.ActualCESS2,
		DST.ActualGrossAmount = SRC.ActualGrossAmount,
		DST.ActualDiscountPercent = SRC.ActualDiscountPercent,
		DST.ActualDiscountAmount = SRC.ActualDiscountAmount,
		DST.ActualDiscountServiceTax = SRC.ActualDiscountServiceTax,
		DST.ActualDiscountCESS1 = SRC.ActualDiscountCESS1,
		DST.ActualDiscountCESS2 = SRC.ActualDiscountCESS2,
		DST.ActualNetServiceTax = SRC.ActualNetServiceTax,
		DST.ActualNetCESS1 = SRC.ActualNetCESS1,
		DST.ActualNetCESS2 = SRC.ActualNetCESS2,
		DST.ActualNetAmount = SRC.ActualNetAmount,
		DST.Actualoldinsurancecost = SRC.Actualoldinsurancecost,
		DST.ActualNewinsurancecost = SRC.ActualNewinsurancecost,
		DST.Actualinsurancecost = SRC.Actualinsurancecost,
		DST.CreditNoteId = SRC.CreditNoteId,
		DST.ActualTdsAmount = SRC.ActualTdsAmount,
		DST.ActualComissionAmount = SRC.ActualComissionAmount,
		DST.ActualoldTApremium = SRC.ActualoldTApremium,
		DST.ActualNewTApremium = SRC.ActualNewTApremium,
		DST.ActualTApremim = SRC.ActualTApremim,
		DST.Remarks = SRC.Remarks,
		DST.pdfreference = SRC.pdfreference,
		DST.DebitNoteId = SRC.DebitNoteId,
		DST.ManualPremiumTotal = SRC.ManualPremiumTotal,
		DST.ManualPremiumBasic = SRC.ManualPremiumBasic,
		DST.ManualPremiumServiceTax = SRC.ManualPremiumServiceTax,
		DST.sponsorname = SRC.sponsorname,
		DST.sponsorrelation = SRC.sponsorrelation,
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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyDetails', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - PolicyDetail', 'Update', @insertcount, @updatecount, 2, 7, NULL, NULL, NULL

	update [db-au-stage].dbo.ETL_trwPackageStatus set DeltaLoadStartDate = convert(date, getdate() - 30), DeltaLoadToDate = convert(date, getdate() + 1)
	where PackageID = 1 and PackageSubGroupID = 7

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyDetails', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimPolicyDetail', 'Process_StarDimension_Policy', 'Package_Error_Log', 'Failed', 'Star Dimension - PolicyDetail', '', 0, 0, 2, 7, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 7, 'FAILED'

END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
