USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpIndividual]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpIndividual
--		20190421 - LT - increased @mergeout table and pnpIndividual column sizes.
--						force pnpIndividual.Notes column to nvarchar(4000)

-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpIndividual] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare
		@batchid int,
		@start date,
		@end date,
		@name varchar(100),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	declare @mergeoutput table (
		BookItemSK int,
		FunderSK int,
		FunderDepartmentSK int,
		IndividualID varchar(50),
		BookItemID int,
		FunderID varchar(50),
		FunderDepartmentID varchar(50),
		FirstName nvarchar(50),
		MiddleNameInitials nchar(2),
		LastName nvarchar(50),
		AddressLine1 nvarchar(100),
		AddressLine2 nvarchar(100),
		City nvarchar(50),
		[State] nvarchar(50),
		StateShort nvarchar(50),
		Country nvarchar(50),
		CountryShort nvarchar(3),
		Country2CharCode nchar(2),
		Postcode nvarchar(50),
		Gender nvarchar(30),
		GenderCode nchar(1),
		DateOfBirth datetime2,
		Referral nvarchar(100),
		Notes nvarchar(4000),
		SpeaksEnglish varchar(5),
		[Language] nvarchar(100),
		CreatedDatetime datetime2,
		UpdatedDatetime datetime2,
		CreatedBy nvarchar(100),
		UpdatedBy nvarchar(100),
		IdentifierOther nvarchar(100),
		IdentifierNII nvarchar(50),
		TaxSched nvarchar(100),
		TaxSchedShort nvarchar(4),
		TaxSchedNotes nvarchar(4000),
		Title nvarchar(150),
		ContactType nvarchar(100),
		ContactClass nvarchar(100),
		PutOnIntakeWizAddIndiv varchar(10),
		IntakeWizPropagate varchar(10),
		UseContactDefault varchar(10),
		HasSMSCapability varchar(10),
		Pin nvarchar(4000),
		SecretQuestion nvarchar(4000),
		SecretAnswer nvarchar(4000),
		DomesticViolenceIssues varchar(10),
		PartnerAwareOfContact varchar(10),
		HomeAwareOfContact varchar(10),
		IndividualAddressCounty nvarchar(100),
		FinancialConcern varchar(10),
		FinancialConcernText nvarchar(4000),
		SafetyConcernText nvarchar(4000),
		MuEthnicity nvarchar(4000),
		MuLanguage nvarchar(4000),
		BirthCountry nvarchar(100),
		Citizenship nvarchar(100),
		CitizenshipDate date,
		NewCanadian varchar(10),
		Education nvarchar(50),
		Occupation nvarchar(50),
		EmploymentStatus nvarchar(50),
		IncomeRange nvarchar(50),
		IncomeSource nvarchar(50),
		BackgroundCreatedDatetime datetime2,
		BackgroundUpdatedDatetime datetime2,
		ibackcom1 nvarchar(150),
		ibackcom2 nvarchar(150),
		DemographicsInterpreterRequired varchar(10),
		DemographicsInterpreterDetails nvarchar(150),
		DemographicsOrganisation varchar(10),
		DemographicsReferralType nvarchar(100),
		WorkFunderID int,
		EmployeeID nvarchar(50),
		EmployerName nvarchar(100),
		WorkContact nvarchar(100),
		WorkAddressLine1 nvarchar(100),
		WorkAddressLine2 nvarchar(100),
		WorkAddressCity nvarchar(150),
		WorkAddressState nvarchar(50),
		WorkAddressCountry nvarchar(100),
		WorkAddressPostcode nvarchar(50),
		WorkURL nvarchar(200),
		WorkComments nvarchar(50),
		WorkCreatedDatetime datetime2,
		WorkUpdatedDatetime datetime2,
		MergeAction varchar(20)
	)

    exec syssp_getrunningbatch
        @SubjectArea = 'Penelope',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

	if object_id('[db-au-dtc].dbo.pnpIndividual') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpIndividual]
		(
			[IndividualSK] [int] IDENTITY(1,1) NOT NULL,
			[IsCurrent] [tinyint] NULL,
			[StartDate] [date] NULL,
			[EndDate] [date] NULL,
			[BookItemSK] [int] NULL,
			[FunderSK] [int] NULL,
			[FunderDepartmentSK] [int] NULL,
			[IndividualID] [varchar](50) NULL,
			[BookItemID] [int] NULL,
			[FunderID] [varchar](50) NULL,
			[FunderDepartmentID] [varchar](50) NULL,
			[FirstName] [nvarchar](50) NULL,
			[MiddleNameInitials] [nchar](2) NULL,
			[LastName] [nvarchar](50) NULL,
			[AddressLine1] [nvarchar](100) NULL,
			[AddressLine2] [nvarchar](100) NULL,
			[City] [nvarchar](50) NULL,
			[State] [nvarchar](50) NULL,
			[StateShort] [nvarchar](50) NULL,
			[Country] [nvarchar](50) NULL,
			[CountryShort] [nvarchar](3) NULL,
			[Country2CharCode] [nchar](2) NULL,
			[Postcode] [nvarchar](50) NULL,
			[Gender] [nvarchar](30) NULL,
			[GenderCode] [nchar](1) NULL,
			[DateOfBirth] [datetime2](7) NULL,
			[Referral] [nvarchar](100) NULL,
			[Notes] [nvarchar](4000) NULL,
			[SpeaksEnglish] [varchar](5) NULL,
			[Language] [nvarchar](100) NULL,
			[CreatedDatetime] [datetime2](7) NULL,
			[UpdatedDatetime] [datetime2](7) NULL,
			[CreatedBy] [nvarchar](100) NULL,
			[UpdatedBy] [nvarchar](100) NULL,
			[IdentifierOther] [nvarchar](100) NULL,
			[IdentifierNII] [nvarchar](50) NULL,
			[TaxSched] [nvarchar](100) NULL,
			[TaxSchedShort] [nvarchar](4) NULL,
			[TaxSchedNotes] [nvarchar](4000) NULL,
			[Title] [nvarchar](150) NULL,
			[ContactType] [nvarchar](100) NULL,
			[ContactClass] [nvarchar](100) NULL,
			[PutOnIntakeWizAddIndiv] [varchar](10) NULL,
			[IntakeWizPropagate] [varchar](10) NULL,
			[UseContactDefault] [varchar](10) NULL,
			[HasSMSCapability] [varchar](10) NULL,
			[Pin] [nvarchar](4000) NULL,
			[SecretQuestion] [nvarchar](4000) NULL,
			[SecretAnswer] [nvarchar](4000) NULL,
			[DomesticViolenceIssues] [varchar](10) NULL,
			[PartnerAwareOfContact] [varchar](10) NULL,
			[HomeAwareOfContact] [varchar](10) NULL,
			[IndividualAddressCounty] [nvarchar](100) NULL,
			[FinancialConcern] [varchar](10) NULL,
			[FinancialConcernText] [nvarchar](4000) NULL,
			[SafetyConcernText] [nvarchar](4000) NULL,
			[MuEthnicity] [nvarchar](4000) NULL,
			[MuLanguage] [nvarchar](4000) NULL,
			[BirthCountry] [nvarchar](100) NULL,
			[Citizenship] [nvarchar](100) NULL,
			[CitizenshipDate] [date] NULL,
			[NewCanadian] [varchar](10) NULL,
			[Education] [nvarchar](50) NULL,
			[Occupation] [nvarchar](50) NULL,
			[EmploymentStatus] [nvarchar](50) NULL,
			[IncomeRange] [nvarchar](50) NULL,
			[IncomeSource] [nvarchar](50) NULL,
			[BackgroundCreatedDatetime] [datetime2](7) NULL,
			[BackgroundUpdatedDatetime] [datetime2](7) NULL,
			[ibackcom1] [nvarchar](150) NULL,
			[ibackcom2] [nvarchar](150) NULL,
			[DemographicsInterpreterRequired] [varchar](10) NULL,
			[DemographicsInterpreterDetails] [nvarchar](150) NULL,
			[DemographicsOrganisation] [varchar](10) NULL,
			[DemographicsReferralType] [nvarchar](100) NULL,
			[WorkFunderID] [int] NULL,
			[EmployeeID] [nvarchar](50) NULL,
			[EmployerName] [nvarchar](100) NULL,
			[WorkContact] [nvarchar](100) NULL,
			[WorkAddressLine1] [nvarchar](100) NULL,
			[WorkAddressLine2] [nvarchar](100) NULL,
			[WorkAddressCity] [nvarchar](150) NULL,
			[WorkAddressState] [nvarchar](50) NULL,
			[WorkAddressCountry] [nvarchar](100) NULL,
			[WorkAddressPostcode] [nvarchar](50) NULL,
			[WorkURL] [nvarchar](200) NULL,
			[WorkComments] [nvarchar](200) NULL,
			[WorkCreatedDatetime] [datetime2](7) NULL,
			[WorkUpdatedDatetime] [datetime2](7) NULL,
			[IndividualName]  AS ((ltrim(rtrim([FirstName]))+' ')+ltrim(rtrim([LastName]))) PERSISTED,
			index idx_pnpIndividual_IndividualID nonclustered (IndividualID),
			index idx_pnpIndividual_FirstName nonclustered (FirstName),
			index idx_pnpIndividual_LastName nonclustered (LastName)
	)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src
		
		select @sourcecount = count(*) from penelope_irindividual_audtc

		select top (@sourcecount)
			bi.BookItemSK,
			f.FunderSK,
			fd.FunderDepartmentSK,
			convert(varchar, i.kindid) as IndividualID,
			i.kbookitemid as BookItemID,
			f.FunderID,
			fd.FunderDepartmentID,
			i.indfirstname as FirstName,
			i.indmidint as MiddleNameInitials,
			i.indlastname as LastName,
			i.indaddress1 as AddressLine1,
			i.indaddress2 as AddressLine2,
			i.indcity as City,
			ps.provstatename as State,
			ps.provstateshort as StateShort,
			c.country as Country,
			c.countryshort as CountryShort,
			c.country2charcode as Country2CharCode,
			i.indpczip as Postcode,
			g.gender as Gender,
			g.pengendercode as GenderCode,
			case
				when i.inddateofbirth < '1910-01-01' then null
				else i.inddateofbirth
			end as DateOfBirth,
			r.referral as Referral,
			left(convert(nvarchar(4000),i.indnotes),4000) as Notes,
			i.indenglish as SpeaksEnglish,
			l.[language] as [Language],
			i.slogin as CreatedDatetime,
			i.slogmod as UpdatedDatetime,
			i.sloginby as CreatedBy,
			i.slogmodby as UpdatedBy,
			i.indssn as IdentifierOther,
			i.indnii as IdentifierNII,
			ts.taxschedname as TaxSched,
			ts.taxschedshort as TaxSchedShort,
			ts.taxschednotes as TaxSchedNotes,
			t.title as Title,
			ct.contacttype as ContactType,
			cc.contactclass as ContactClass,
			ct.putonintakewizaddindiv as PutOnIntakeWizAddIndiv,
			ct.intakewizpropagate as IntakeWizPropagate,
			ct.usecontactdefault as UseContactDefault,
			ct.hassmscapability as HasSMSCapability,
			i.indpin as Pin,
			i.indsecretques as SecretQuestion,
			i.indsecretans as SecretAnswer,
			i.inddvissues as DomesticViolenceIssues,
			i.indpartneraware as PartnerAwareOfContact,
			i.indhomeaware as HomeAwareOfContact,
			i.indcounty as IndividualAddressCounty,
			i.indfinconcern as FinancialConcern,
			i.indfinconcerntext as FinancialConcernText,
			i.inddvissuestext as SafetyConcernText,
			me.ethnicity as MuEthnicity,
			ml.[language] as MuLanguage,
			bc.country as BirthCountry,
			bctz.citizenship as Citizenship,
			ib.ibackcitizendate as CitizenshipDate,
			ib.ibacknewcanadian as NewCanadian,
			be.education as Education,
			bo.occupation as Occupation,
			es.employmentstatus as EmploymentStatus,
			ir.incomerange as IncomeRange,
			incs.incomesource as IncomeSource,
			ib.slogin as BackgroundCreatedDatetime,
			ib.slogmod as BackgroundUpdatedDatetime,
			ib.ibackcom1 as ibackcom1,
			ib.ibackcom2 as ibackcom2,
			iud.indud5 as DemographicsInterpreterRequired,
			iud.indud1 as DemographicsInterpreterDetails,
			iud.indud6 as DemographicsOrganisation,
			i1e4.DemographicsReferralType,
			iw.kfunderid as WorkFunderID,
			iw.indworkidentno as EmployeeID,
			iw.indworkname as EmployerName,
			iw.indworkcontact as WorkContact,
			iw.indworkaddress1 as WorkAddressLine1,
			iw.indworkaddress2 as WorkAddressLine2,
			iw.indworkcity as WorkAddressCity,
			wps.provstatename as WorkAddressState,
			wc.country as WorkAddressCountry,
			iw.indworkpzip as WorkAddressPostcode,
			iw.indworkurl as WorkURL,
			iw.indworkcomments as WorkComments,
			iw.slogin as WorkCreatedDatetime,
			iw.slogmod as WorkUpdatedDatetime
		into #src
		from 
			penelope_irindividual_audtc i
			left join penelope_irindividualsetup_audtc ist on ist.kindid = i.kindid
			left join penelope_luprovstate_audtc ps on ps.luprovstateid = i.luindprovstateid
			left join penelope_lucountry_audtc c on c.lucountryid = i.luindcountryid
			left join penelope_lugender_audtc g on g.lugenderid = i.luindgenderid
			left join penelope_lureferral_audtc r on r.lureferralid = i.lureferralid
			left join penelope_lulanguage_audtc l on l.lulanguageid = i.luindlanguageid
			left join penelope_brtaxsched_audtc ts on ts.ktaxschedid = i.ktaxschedid
			left join penelope_lutitle_audtc t on t.lutitleid = i.lutitleid
			left join penelope_sacontacttype_audtc ct on ct.kcontacttypeid = i.kpmcid
			left join penelope_sscontactclass_audtc cc on cc.kcontactclassid = ct.kcontactclassid
			left join penelope_lumuethnicity_audtc me on me.lumuethnicityid = i.luindmuethnicityid
			left join penelope_lumulanguage_audtc ml on ml.lumulanguageid = i.luindmulanguageid
			left join penelope_irindback_audtc ib on ib.kindid = i.kindid
			left join penelope_lucountry_audtc bc on bc.lucountryid	= ib.luibackbirthplaceid
			left join penelope_lucitizenship_audtc bctz on bctz.lucitizenshipid = ib.luibackcitizenshipid
			left join penelope_lueducation_audtc be on be.lueducationid = ib.luibackeducationid
			left join penelope_luoccupation_audtc bo on bo.luoccupationid = ib.luibackoccupationid
			left join penelope_luemploymentstatus_audtc es on es.luemploymentstatusid = ib.luibackempstatusid
			left join penelope_luincrange_audtc ir on ir.luincrangeid = ib.luibackincrangeid
			left join penelope_luincomesource_audtc incs on incs.luincomesourceid = ib.luibackincsourceid
			left join penelope_irinduserdef_audtc iud on iud.kindid = i.kindid
			left join penelope_irind1exp_audtc i1e on i1e.kindid = i.kindid
			left join penelope_irindwork_audtc iw on iw.kindid = i.kindid
			left join penelope_luprovstate_audtc wps on wps.luprovstateid = iw.luindworkprovstateid
			left join penelope_lucountry_audtc wc on wc.lucountryid = iw.luindworkcountryid
			outer apply (
				select top 1 BookItemSK
				from [db-au-dtc].dbo.pnpBookItem
				where BookItemID = i.kbookitemid
			) bi
			outer apply (
				select top 1 FunderSK, FunderID 
				from [db-au-dtc].dbo.pnpFunder
				where FunderID = convert(varchar, ist.kfunderid)
					and IsCurrent = 1
			) f
			outer apply (
				select top 1 FunderDepartmentSK, FunderDepartmentID 
				from [db-au-dtc].dbo.pnpFunderDepartment
				where FunderDepartmentID = convert(varchar, ist.kfunderdeptid)
			) fd
			outer apply (
				select top 1 luind1exp4 as DemographicsReferralType
				from [db-au-stage].dbo.penelope_luind1exp4_audtc
				where luind1exp4id = i1e.ind1exp4
			) i1e4
	
		select @sourcecount = count(*) from #src

		-- handle type 1 fields
		update [db-au-dtc]..[pnpIndividual]
		set 
			BookItemSK = #src.BookItemSK,
			IndividualID = #src.IndividualID,
			BookItemID = #src.BookItemID,
			FirstName = #src.FirstName,
			MiddleNameInitials = #src.MiddleNameInitials,
			LastName = #src.LastName,
			AddressLine1 = #src.AddressLine1,
			AddressLine2 = #src.AddressLine2,
			City = #src.City,
			[State] = #src.[State],
			StateShort = #src.StateShort,
			Country = #src.Country,
			CountryShort = #src.CountryShort,
			Country2CharCode = #src.Country2CharCode,
			Postcode = #src.Postcode,
			Gender = #src.Gender,
			GenderCode = #src.GenderCode,
			DateOfBirth = #src.DateOfBirth,
			Referral = #src.Referral,
			Notes = #src.Notes,
			SpeaksEnglish = #src.SpeaksEnglish,
			[Language] = #src.[Language],
			CreatedDatetime = #src.CreatedDatetime,
			UpdatedDatetime = #src.UpdatedDatetime,
			CreatedBy = #src.CreatedBy,
			UpdatedBy = #src.UpdatedBy,
			IdentifierOther = #src.IdentifierOther,
			IdentifierNII = #src.IdentifierNII,
			TaxSched = #src.TaxSched,
			TaxSchedShort = #src.TaxSchedShort,
			TaxSchedNotes = #src.TaxSchedNotes,
			Title = #src.Title,
			ContactType = #src.ContactType,
			ContactClass = #src.ContactClass,
			PutOnIntakeWizAddIndiv = #src.PutOnIntakeWizAddIndiv,
			IntakeWizPropagate = #src.IntakeWizPropagate,
			UseContactDefault = #src.UseContactDefault,
			HasSMSCapability = #src.HasSMSCapability,
			Pin = #src.Pin,
			SecretQuestion = #src.SecretQuestion,
			SecretAnswer = #src.SecretAnswer,
			DomesticViolenceIssues = #src.DomesticViolenceIssues,
			PartnerAwareOfContact = #src.PartnerAwareOfContact,
			HomeAwareOfContact = #src.HomeAwareOfContact,
			IndividualAddressCounty = #src.IndividualAddressCounty,
			FinancialConcern = #src.FinancialConcern,
			FinancialConcernText = #src.FinancialConcernText,
			SafetyConcernText = #src.SafetyConcernText,
			MuEthnicity = #src.MuEthnicity,
			MuLanguage = #src.MuLanguage,
			BirthCountry = #src.BirthCountry,
			Citizenship = #src.Citizenship,
			CitizenshipDate = #src.CitizenshipDate,
			NewCanadian = #src.NewCanadian,
			Education = #src.Education,
			Occupation = #src.Occupation,
			EmploymentStatus = #src.EmploymentStatus,
			IncomeRange = #src.IncomeRange,
			IncomeSource = #src.IncomeSource,
			BackgroundCreatedDatetime = #src.BackgroundCreatedDatetime,
			BackgroundUpdatedDatetime = #src.BackgroundUpdatedDatetime,
			ibackcom1 = #src.ibackcom1,
			ibackcom2 = #src.ibackcom2,
			DemographicsInterpreterRequired = #src.DemographicsInterpreterRequired,
			DemographicsInterpreterDetails = #src.DemographicsInterpreterDetails,
			DemographicsOrganisation = #src.DemographicsOrganisation,
			DemographicsReferralType = #src.DemographicsReferralType,
			WorkFunderID = #src.WorkFunderID,
			EmployerName = #src.EmployerName,
			WorkContact = #src.WorkContact,
			WorkAddressLine1 = #src.WorkAddressLine1,
			WorkAddressLine2 = #src.WorkAddressLine2,
			WorkAddressCity = #src.WorkAddressCity,
			WorkAddressState = #src.WorkAddressState,
			WorkAddressCountry = #src.WorkAddressCountry,
			WorkAddressPostcode = #src.WorkAddressPostcode,
			WorkURL = #src.WorkURL,
			WorkComments = #src.WorkComments,
			WorkCreatedDatetime = #src.WorkCreatedDatetime,
			WorkUpdatedDatetime = #src.WorkUpdatedDatetime
		from 
			[db-au-dtc]..pnpIndividual tgt inner join #src 
				on tgt.IndividualID = #src.IndividualID 
					and tgt.FunderID = #src.FunderID 
					and tgt.FunderSK = #src.FunderSK 
					and tgt.FunderDepartmentID = #src.FunderDepartmentID 
					and tgt.FunderDepartmentSK = #src.FunderDepartmentSK 
					and tgt.EmployeeID = #src.EmployeeID
		where 
			IsCurrent = 1 

		select @updatecount = @@ROWCOUNT


		-- handle type 2 fields
		merge [db-au-dtc].dbo.pnpIndividual as tgt
		using #src
			on #src.IndividualID = tgt.IndividualID
		when not matched by target then 
			insert (
				IsCurrent, StartDate, EndDate, 
				BookItemSK, FunderSK, FunderDepartmentSK, IndividualID, BookItemID, FunderID, FunderDepartmentID, 
				FirstName, MiddleNameInitials, LastName, AddressLine1, AddressLine2, City, [State], StateShort, Country, CountryShort, Country2CharCode, Postcode, 
				Gender, GenderCode, DateOfBirth, Referral, Notes, SpeaksEnglish, [Language], 
				CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy, 
				IdentifierOther, IdentifierNII, TaxSched, TaxSchedShort, TaxSchedNotes, Title, ContactType, ContactClass, 
				PutOnIntakeWizAddIndiv, IntakeWizPropagate, UseContactDefault, HasSMSCapability, Pin, SecretQuestion, SecretAnswer, 
				DomesticViolenceIssues, PartnerAwareOfContact, HomeAwareOfContact, IndividualAddressCounty, FinancialConcern, FinancialConcernText, SafetyConcernText, 
				MuEthnicity, MuLanguage, BirthCountry, Citizenship, CitizenshipDate, NewCanadian, Education, 
				Occupation, EmploymentStatus, IncomeRange, IncomeSource, BackgroundCreatedDatetime, BackgroundUpdatedDatetime, 
				ibackcom1, ibackcom2, DemographicsInterpreterRequired, DemographicsInterpreterDetails, DemographicsOrganisation, DemographicsReferralType, 
				WorkFunderID, EmployeeID, EmployerName, WorkContact, WorkAddressLine1, WorkAddressLine2, WorkAddressCity, WorkAddressState, WorkAddressCountry, 
				WorkAddressPostcode, WorkURL, WorkComments, WorkCreatedDatetime, WorkUpdatedDatetime
			)
			values (
				1, '1900-01-01', '9999-12-31', 
				#src.BookItemSK, #src.FunderSK, #src.FunderDepartmentSK, #src.IndividualID, #src.BookItemID, #src.FunderID, #src.FunderDepartmentID,
				#src.FirstName, #src.MiddleNameInitials, #src.LastName, #src.AddressLine1, #src.AddressLine2, #src.City, #src.[State], #src.StateShort, #src.Country, #src.CountryShort, #src.Country2CharCode, #src.Postcode,
				#src.Gender, #src.GenderCode, #src.DateOfBirth, #src.Referral, #src.Notes, #src.SpeaksEnglish, #src.[Language], 
				#src.CreatedDatetime, #src.UpdatedDatetime, #src.CreatedBy, #src.UpdatedBy, 
				#src.IdentifierOther, #src.IdentifierNII, #src.TaxSched, #src.TaxSchedShort, #src.TaxSchedNotes, #src.Title, #src.ContactType, #src.ContactClass, 
				#src.PutOnIntakeWizAddIndiv, #src.IntakeWizPropagate, #src.UseContactDefault, #src.HasSMSCapability, #src.Pin, #src.SecretQuestion, #src.SecretAnswer,
				#src.DomesticViolenceIssues, #src.PartnerAwareOfContact, #src.HomeAwareOfContact, #src.IndividualAddressCounty, #src.FinancialConcern, #src.FinancialConcernText, #src.SafetyConcernText, 
				#src.MuEthnicity, #src.MuLanguage, #src.BirthCountry, #src.Citizenship, #src.CitizenshipDate, #src.NewCanadian, #src.Education, 
				#src.Occupation, #src.EmploymentStatus, #src.IncomeRange, #src.IncomeSource, #src.BackgroundCreatedDatetime, #src.BackgroundUpdatedDatetime,
				#src.ibackcom1, #src.ibackcom2, #src.DemographicsInterpreterRequired, #src.DemographicsInterpreterDetails, #src.DemographicsOrganisation, #src.DemographicsReferralType,
				#src.WorkFunderID, #src.EmployeeID, #src.EmployerName, #src.WorkContact, #src.WorkAddressLine1, #src.WorkAddressLine2, #src.WorkAddressCity, #src.WorkAddressState, #src.WorkAddressCountry,
				#src.WorkAddressPostcode, #src.WorkURL, #src.WorkComments, #src.WorkCreatedDatetime, #src.WorkUpdatedDatetime
			)
		when matched 
			and tgt.IsCurrent = 1 
			and ( 
				isnull(tgt.FunderID, -1)  <> isnull(#src.FunderID, -1) 
				or isnull(tgt.FunderSK, -1) <> isnull(#src.FunderSK, -1) 
				or isnull(tgt.FunderDepartmentID, -1) <> isnull(#src.FunderDepartmentID, -1) 
				or isnull(tgt.FunderDepartmentSK, -1) <> isnull(#src.FunderDepartmentSK, -1) 
				or isnull(tgt.EmployeeID, -1) <> isnull(#src.EmployeeID, -1) 
			) then	-- expire current records
			update set 
				tgt.IsCurrent = 0,
				tgt.EndDate = dateadd(day, -1, getdate())

		output 
			#src.BookItemSK, #src.FunderSK, #src.FunderDepartmentSK, #src.IndividualID, #src.BookItemID, #src.FunderID, #src.FunderDepartmentID,
			#src.FirstName, #src.MiddleNameInitials, #src.LastName, #src.AddressLine1, #src.AddressLine2, #src.City, #src.[State], #src.StateShort, #src.Country, #src.CountryShort, #src.Country2CharCode, #src.Postcode,
			#src.Gender, #src.GenderCode, #src.DateOfBirth, #src.Referral, #src.Notes, #src.SpeaksEnglish, #src.[Language], 
			#src.CreatedDatetime, #src.UpdatedDatetime, #src.CreatedBy, #src.UpdatedBy, 
			#src.IdentifierOther, #src.IdentifierNII, #src.TaxSched, #src.TaxSchedShort, #src.TaxSchedNotes, #src.Title, #src.ContactType, #src.ContactClass, 
			#src.PutOnIntakeWizAddIndiv, #src.IntakeWizPropagate, #src.UseContactDefault, #src.HasSMSCapability, #src.Pin, #src.SecretQuestion, #src.SecretAnswer,
			#src.DomesticViolenceIssues, #src.PartnerAwareOfContact, #src.HomeAwareOfContact, #src.IndividualAddressCounty, #src.FinancialConcern, #src.FinancialConcernText, #src.SafetyConcernText, 
			#src.MuEthnicity, #src.MuLanguage, #src.BirthCountry, #src.Citizenship, #src.CitizenshipDate, #src.NewCanadian, #src.Education, 
			#src.Occupation, #src.EmploymentStatus, #src.IncomeRange, #src.IncomeSource, #src.BackgroundCreatedDatetime, #src.BackgroundUpdatedDatetime,
			#src.ibackcom1, #src.ibackcom2, #src.DemographicsInterpreterRequired, #src.DemographicsInterpreterDetails, #src.DemographicsOrganisation, #src.DemographicsReferralType,
			#src.WorkFunderID, #src.EmployeeID, #src.EmployerName, #src.WorkContact, #src.WorkAddressLine1, #src.WorkAddressLine2, #src.WorkAddressCity, #src.WorkAddressState, #src.WorkAddressCountry,
			#src.WorkAddressPostcode, #src.WorkURL, #src.WorkComments, #src.WorkCreatedDatetime, #src.WorkUpdatedDatetime, 
			$action as MergeAction 		
		into @mergeoutput;

		-- insert current records for type 2 changes
		insert into [db-au-dtc]..pnpIndividual (
			IsCurrent, StartDate, EndDate, 
			BookItemSK, FunderSK, FunderDepartmentSK, IndividualID, BookItemID, FunderID, FunderDepartmentID, 
			FirstName, MiddleNameInitials, LastName, AddressLine1, AddressLine2, City, [State], StateShort, Country, CountryShort, Country2CharCode, Postcode, 
			Gender, GenderCode, DateOfBirth, Referral, Notes, SpeaksEnglish, [Language], 
			CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy, 
			IdentifierOther, IdentifierNII, TaxSched, TaxSchedShort, TaxSchedNotes, Title, ContactType, ContactClass, 
			PutOnIntakeWizAddIndiv, IntakeWizPropagate, UseContactDefault, HasSMSCapability, Pin, SecretQuestion, SecretAnswer, 
			DomesticViolenceIssues, PartnerAwareOfContact, HomeAwareOfContact, IndividualAddressCounty, FinancialConcern, FinancialConcernText, SafetyConcernText, 
			MuEthnicity, MuLanguage, BirthCountry, Citizenship, CitizenshipDate, NewCanadian, Education, 
			Occupation, EmploymentStatus, IncomeRange, IncomeSource, BackgroundCreatedDatetime, BackgroundUpdatedDatetime, 
			ibackcom1, ibackcom2, DemographicsInterpreterRequired, DemographicsInterpreterDetails, DemographicsOrganisation, DemographicsReferralType, 
			WorkFunderID, EmployeeID, EmployerName, WorkContact, WorkAddressLine1, WorkAddressLine2, WorkAddressCity, WorkAddressState, WorkAddressCountry, 
			WorkAddressPostcode, WorkURL, WorkComments, WorkCreatedDatetime, WorkUpdatedDatetime
		)
		select 
			1, getdate(), '9999-12-31',
			BookItemSK, FunderSK, FunderDepartmentSK, IndividualID, BookItemID, FunderID, FunderDepartmentID, 
			FirstName, MiddleNameInitials, LastName, AddressLine1, AddressLine2, City, [State], StateShort, Country, CountryShort, Country2CharCode, Postcode, 
			Gender, GenderCode, DateOfBirth, Referral, Notes, SpeaksEnglish, [Language], 
			CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy, 
			IdentifierOther, IdentifierNII, TaxSched, TaxSchedShort, TaxSchedNotes, Title, ContactType, ContactClass, 
			PutOnIntakeWizAddIndiv, IntakeWizPropagate, UseContactDefault, HasSMSCapability, Pin, SecretQuestion, SecretAnswer, 
			DomesticViolenceIssues, PartnerAwareOfContact, HomeAwareOfContact, IndividualAddressCounty, FinancialConcern, FinancialConcernText, SafetyConcernText, 
			MuEthnicity, MuLanguage, BirthCountry, Citizenship, CitizenshipDate, NewCanadian, Education, 
			Occupation, EmploymentStatus, IncomeRange, IncomeSource, BackgroundCreatedDatetime, BackgroundUpdatedDatetime, 
			ibackcom1, ibackcom2, DemographicsInterpreterRequired, DemographicsInterpreterDetails, DemographicsOrganisation, DemographicsReferralType, 
			WorkFunderID, EmployeeID, EmployerName, WorkContact, WorkAddressLine1, WorkAddressLine2, WorkAddressCity, WorkAddressState, WorkAddressCountry, 
			WorkAddressPostcode, WorkURL, WorkComments, WorkCreatedDatetime, WorkUpdatedDatetime
		from @mergeoutput
		where MergeAction = 'UPDATE'

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = @updatecount + sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

	end try

	begin catch

		if @@trancount > 0
			rollback transaction

		exec syssp_genericerrorhandler
			@SourceInfo = 'data refresh failed',
			@LogToTable = 1,
			@ErrorCode = '-100',
			@BatchID = @batchid,
			@PackageID = @name

	end catch

	if @@trancount > 0
		commit transaction

END


GO
