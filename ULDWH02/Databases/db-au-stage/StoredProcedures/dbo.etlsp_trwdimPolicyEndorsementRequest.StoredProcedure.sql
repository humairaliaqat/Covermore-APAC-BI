USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwdimPolicyEndorsementRequest]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_trwdimPolicyEndorsementRequest]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'dbPolicyEndorsementRequests', '',0,0, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyEndorsementRequests', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Star Dimension - PolicyOthers', 'Insert', 0, 0, 2, 4, NULL, NULL, NULL

	if object_id('dbo.trwdimPolicyEndorsementRequest') is null
	BEGIN
    
		create table dbo.trwdimPolicyEndorsementRequest
		(
			PolicyEndorsementRequestSK			int identity(1,1) not null,
			PolicyEndorsementRequestID			int not null,
			PolicyID							int null,
			RequesterEntityID					int null,
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
			NewPassportNumber					nvarchar(50) null,
			NewInsuranceCategoryID				int null,
			NewSellingPlanID					int null,
			NewDepartureDate					datetime null,
			NewDays								numeric(18, 0) null,
			NewArrivalDate						datetime null,
			NewAddress1							nvarchar(500) null,
			NewAddress2							nvarchar(500) null,
			NewCity								nvarchar(50) null,
			NewDistrict							nvarchar(50) null,
			NewState							nvarchar(50) null,
			NewPinCode							nvarchar(10) null,
			NewCountry							nvarchar(100) null,
			NewPhoneNo							nvarchar(50) null,
			NewMobileNo							nvarchar(50) null,
			NewEmailAddress						nvarchar(50) null,
			NewUniversityName					nvarchar(100) null,
			NewUniversityAddress				nvarchar(1000) null,
			NewName								nvarchar(50) null,
			NewDOB								datetime null,
			NewAge								numeric(18, 0) null,
			NewTrawellTagNumber					numeric(18, 0) null,
			NewNominee							nvarchar(50) null,
			NewRelation							nvarchar(50) null,
			NewPastIllness						nvarchar(1000) null,
			NewRestrictedCoverage				bit null,
			OldPremium							numeric(18, 2) null,
			NewPremium							numeric(18, 2) null,
			Reason								nvarchar(1000) null,
			Remarks								nvarchar(1000) null,
			ProcessedByEntityID					int null,
			Status								nvarchar(50) null,
			CreatedDateTime						datetime null,
			CreatedBy							nvarchar(256) null,
			ModifiedDateTime					datetime null,
			ModifiedBy							nvarchar(256) null,							
			Documentfile						nvarchar(400) null,
			pdfreference						nvarchar(300) null,
			Newpdfreference						nvarchar(300) null,
			OldDiscountPercent					numeric(18, 2) null,
			NewDiscountPercent					numeric(18, 2) null,
			AmountDifference					numeric(18, 2) null,
			sponsorname							nvarchar(max) null,
			sponsorrelation						nvarchar(max) null,
			newsponsorname						nvarchar(max) null,	
			newsponsorrelation					nvarchar(max) null,
			InsertDate							datetime null,
			updateDate							datetime null,
			HashKey								varbinary(50) null
		)
        
		create clustered index idx_dimPolicyEndorsementRequest_PolicyEndorsementRequestSK on dbo.trwdimPolicyEndorsementRequest(PolicyEndorsementRequestSK)
		create nonclustered index idx_dimPolicyEndorsementRequest_PolicyEndorsementRequestID on dbo.trwdimPolicyEndorsementRequest(PolicyEndorsementRequestID)
		create nonclustered index idx_dimPolicyEndorsementRequest_PolicyID on dbo.trwdimPolicyEndorsementRequest(PolicyID)
		create nonclustered index idx_dimPolicyEndorsementRequest_RequesterEntityID on dbo.trwdimPolicyEndorsementRequest(RequesterEntityID)
		create nonclustered index idx_dimPolicyEndorsementRequest_InsuranceCategoryID on dbo.trwdimPolicyEndorsementRequest(InsuranceCategoryID)
		create nonclustered index idx_dimPolicyEndorsementRequest_SellingPlanID on dbo.trwdimPolicyEndorsementRequest(SellingPlanID)
		create nonclustered index idx_dimPayment_NewInsuranceCategoryID on dbo.trwdimPolicyEndorsementRequest(NewInsuranceCategoryID)
		create nonclustered index idx_dimPolicyEndorsementRequest_NewSellingPlanID on dbo.trwdimPolicyEndorsementRequest(NewSellingPlanID)
		create nonclustered index idx_dimPolicyEndorsementRequest_HashKey on trwdimPolicyEndorsementRequest(HashKey)

	END

	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update dbo.ETL_trwPolicyEndorsementRequests
	set 
		HashKey = binary_checksum(PolicyEndorsementRequestID,PolicyID,RequesterEntityID,PassportNumber,InsuranceCategoryID,SellingPlanID,DepartureDate,Days,ArrivalDate,Address1,Address2,
					City,District,State,PinCode,Country,PhoneNo,MobileNo,EmailAddress,UniversityName,UniversityAddress,Name,DOB,Age,TrawellTagNumber,Nominee,Relation,PastIllness,RestrictedCoverage,
					NewPassportNumber,NewInsuranceCategoryID,NewSellingPlanID,NewDepartureDate,NewDays,NewArrivalDate,NewAddress1,NewAddress2,NewCity,NewDistrict,NewState,NewPinCode,
					NewCountry,NewPhoneNo,NewMobileNo,NewEmailAddress,NewUniversityName,NewUniversityAddress,NewName,NewDOB,NewAge,NewTrawellTagNumber,NewNominee,NewRelation,NewPastIllness,
					NewRestrictedCoverage,OldPremium,NewPremium,Reason,Remarks,ProcessedByEntityID,Status,CreatedDateTime,CreatedBy,ModifiedDateTime,ModifiedBy,Documentfile,pdfreference,
					Newpdfreference,OldDiscountPercent,NewDiscountPercent,AmountDifference,sponsorname,sponsorrelation,newsponsorname,newsponsorrelation)
	select
		@sourcecount = count(*)
	from
		dbo.ETL_trwPolicyEndorsementRequests


BEGIN TRANSACTION;

BEGIN TRY

	merge into dbo.trwdimPolicyEndorsementRequest as DST
	using ETL_trwPolicyEndorsementRequests as SRC
	on (src.PolicyEndorsementRequestID = DST.PolicyEndorsementRequestID)

	when not matched by target then
	insert
	(
	PolicyEndorsementRequestID,
	PolicyID,
	RequesterEntityID,
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
	NewPassportNumber,
	NewInsuranceCategoryID,
	NewSellingPlanID,
	NewDepartureDate,
	NewDays,
	NewArrivalDate,
	NewAddress1,
	NewAddress2,
	NewCity,
	NewDistrict,
	NewState,
	NewPinCode,
	NewCountry,
	NewPhoneNo,
	NewMobileNo,
	NewEmailAddress,
	NewUniversityName,
	NewUniversityAddress,
	NewName,
	NewDOB,
	NewAge,
	NewTrawellTagNumber,
	NewNominee,
	NewRelation,
	NewPastIllness,
	NewRestrictedCoverage,
	OldPremium,
	NewPremium,
	Reason,
	Remarks,
	ProcessedByEntityID,
	Status,
	CreatedDateTime,
	CreatedBy,
	ModifiedDateTime,
	ModifiedBy,
	Documentfile,
	pdfreference,
	Newpdfreference,
	OldDiscountPercent,
	NewDiscountPercent,
	AmountDifference,
	sponsorname,
	sponsorrelation,
	newsponsorname,
	newsponsorrelation,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.PolicyEndorsementRequestID,
	SRC.PolicyID,
	SRC.RequesterEntityID,
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
	SRC.NewPassportNumber,
	SRC.NewInsuranceCategoryID,
	SRC.NewSellingPlanID,
	SRC.NewDepartureDate,
	SRC.NewDays,
	SRC.NewArrivalDate,
	SRC.NewAddress1,
	SRC.NewAddress2,
	SRC.NewCity,
	SRC.NewDistrict,
	SRC.NewState,
	SRC.NewPinCode,
	SRC.NewCountry,
	SRC.NewPhoneNo,
	SRC.NewMobileNo,
	SRC.NewEmailAddress,
	SRC.NewUniversityName,
	SRC.NewUniversityAddress,
	SRC.NewName,
	SRC.NewDOB,
	SRC.NewAge,
	SRC.NewTrawellTagNumber,
	SRC.NewNominee,
	SRC.NewRelation,
	SRC.NewPastIllness,
	SRC.NewRestrictedCoverage,
	SRC.OldPremium,
	SRC.NewPremium,
	SRC.Reason,
	SRC.Remarks,
	SRC.ProcessedByEntityID,
	SRC.Status,
	SRC.CreatedDateTime,
	SRC.CreatedBy,
	SRC.ModifiedDateTime,
	SRC.ModifiedBy,
	SRC.Documentfile,
	SRC.pdfreference,
	SRC.Newpdfreference,
	SRC.OldDiscountPercent,
	SRC.NewDiscountPercent,
	SRC.AmountDifference,
	SRC.sponsorname,
	SRC.sponsorrelation,
	SRC.newsponsorname,
	SRC.newsponsorrelation,
	getdate(),
	null,
	SRC.HashKey
	)
		-- update existing records where data has changed via HashKey
	when matched and DST.HashKey <> SRC.HashKey then
	update
	set DST.PolicyID = SRC.PolicyID,
		DST.RequesterEntityID = SRC.RequesterEntityID,
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
		DST.NewPassportNumber = SRC.NewPassportNumber,
		DST.NewInsuranceCategoryID = SRC.NewInsuranceCategoryID,
		DST.NewSellingPlanID = SRC.NewSellingPlanID,
		DST.NewDepartureDate = SRC.NewDepartureDate,
		DST.NewDays = SRC.NewDays,
		DST.NewArrivalDate = SRC.NewArrivalDate,
		DST.NewAddress1 = SRC.NewAddress1,
		DST.NewAddress2 = SRC.NewAddress2,
		DST.NewCity = SRC.NewCity,
		DST.NewDistrict = SRC.NewDistrict,
		DST.NewState = SRC.NewState,
		DST.NewPinCode = SRC.NewPinCode,
		DST.NewCountry = SRC.NewCountry,
		DST.NewPhoneNo = SRC.NewPhoneNo,
		DST.NewMobileNo = SRC.NewMobileNo,
		DST.NewEmailAddress = SRC.NewEmailAddress,
		DST.NewUniversityName = SRC.NewUniversityName,
		DST.NewUniversityAddress = SRC.NewUniversityAddress,
		DST.NewName = SRC.NewName,
		DST.NewDOB = SRC.NewDOB,
		DST.NewAge = SRC.NewAge,
		DST.NewTrawellTagNumber = SRC.NewTrawellTagNumber,
		DST.NewNominee = SRC.NewNominee,
		DST.NewRelation = SRC.NewRelation,
		DST.NewPastIllness = SRC.NewPastIllness,
		DST.NewRestrictedCoverage = SRC.NewRestrictedCoverage,
		DST.OldPremium = SRC.OldPremium,
		DST.NewPremium = SRC.NewPremium,
		DST.Reason = SRC.Reason,
		DST.Remarks = SRC.Remarks,
		DST.ProcessedByEntityID = SRC.ProcessedByEntityID,
		DST.Status = SRC.Status,
		DST.CreatedDateTime = SRC.CreatedDateTime,
		DST.CreatedBy = SRC.CreatedBy,
		DST.ModifiedDateTime = SRC.ModifiedDateTime,
		DST.ModifiedBy = SRC.ModifiedBy,
		DST.Documentfile = SRC.Documentfile,
		DST.pdfreference = SRC.pdfreference,
		DST.Newpdfreference = SRC.Newpdfreference,
		DST.OldDiscountPercent = SRC.OldDiscountPercent,
		DST.NewDiscountPercent = SRC.NewDiscountPercent,
		DST.AmountDifference = SRC.AmountDifference,
		DST.sponsorname = SRC.sponsorname,
		DST.sponsorrelation = SRC.sponsorrelation,
		DST.newsponsorname = SRC.newsponsorname,
		DST.newsponsorrelation = SRC.newsponsorrelation,
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
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'dbPolicyEndorsementRequests', '',@insertcount, @updatecount, 2, 4, NULL, NULL, NULL
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyEndorsementRequests', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Star Dimension - PolicyOthers', 'Update', @insertcount, @updatecount, 2, 4, NULL, NULL, NULL

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
	exec etlsp_trwgenerateetllog @Package_ID, 'dbPolicyEndorsementRequests', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwdimPolicyEndorsementRequest', 'Process_StarDimension_EndorsementRequest', 'Package_Error_Log', 'Failed', 'Star Dimension - PolicyOthers', '', 0, 0, 2, 4, NULL, NULL, NULL

	exec etlsp_trwPackageStatus  'END', 2, 4, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
			
GO
