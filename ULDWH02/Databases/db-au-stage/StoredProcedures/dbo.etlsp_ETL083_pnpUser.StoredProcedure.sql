USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpUser]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpUser
-- Modifications: 20181019 - DM - Search: #mod20181019 Commented out due to Server issues. Will need to be uncommented when resolved.
--				  20181030 - DM - Re-instating commented out code as per above
--				  20190628 - LT - Added UserFullName
--				  20190629 - RS - Fixed production issue.
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpUser] 
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
		UserID varchar(50),
		ReportToUserID varchar(50),
		WorkerID varchar(50),
        FirstName nvarchar(100),
        LastName nvarchar(100),
        Title nvarchar(50),
        Extention nvarchar(6),
        Phone1 nvarchar(13),
        Phone2 nvarchar(13),
        Email nvarchar(70),
        UserGroup nvarchar(50),
        UserGroupLevel int,
        LoginName nchar(10),
        [Password] nchar(10),
        AddressLine1 nvarchar(60),
        AddressLine2 nvarchar(60),
        AddressCity nvarchar(20),
        [State] nvarchar(20),
        StateShort nvarchar(10),
        Country nvarchar(30),
        CountryShort nvarchar(3),
        Language1 nvarchar(30),
        Language2 nvarchar(30),
        Language3 nvarchar(30),
        AddressPostcode nvarchar(12),
        [Status] varchar(5),
        Notes nvarchar(max),
        RegistrationNumber nvarchar(50),
        FullTimeEquivalent numeric(10,2),
        MaxCaseLoad int,
        MaxIndividualLoad int,
        CreatedDatetime datetime2,
        UpdatedDatetime datetime2,
        CreatedBy nvarchar(20),
        UpdatedBy nvarchar(20),
        userfahcsiano nvarchar(4000),
        Qualification nvarchar(50),
        WorkerAccept varchar(5),
        WorkerCreatedDatetime datetime2,
        WorkerUpdatedDatetime datetime2,
        SocialSecurityNumber nvarchar(9),
        EmployerIdentificationNumber nvarchar(9),
        NationalProviderID nvarchar(10),
        ProviderSpecialtyTaxonomyCode nvarchar(30),
        DVQualified varchar(5),
        WorkerIDRendering int,
        krenderingproviderid int,
        kreferringphysicianid int,
        kbluebookidrefphys int,
        MedicarePI nvarchar(30),
		SecurityClass nvarchar(25),
		ReportSecurityClass nvarchar(50),
		ClienteleResourceCode varchar(10),
		ResourceType nvarchar(50),
		Gender varchar(20),
		Degree nvarchar(max),
        Team nvarchar(50),
		UserFullName nvarchar(200),
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

	if object_id('[db-au-dtc].dbo.pnpUser') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpUser](
			UserSK int identity(1,1) primary key, 
			IsCurrent tinyint, 
			StartDate date, 
			EndDate date, 
			BookItemSK int, 
			ReportToUserSK int, 
			UserID varchar(50), 
			ReportToUserID varchar(50), 
			WorkerID varchar(50), 
            FirstName nvarchar(100), 
            LastName nvarchar(100), 
            Title nvarchar(50), 
            Extention nvarchar(6), 
            Phone1 nvarchar(13), 
            Phone2 nvarchar(13), 
            Email nvarchar(70), 
            UserGroup nvarchar(50), 
            UserGroupLevel int, 
            LoginName nchar(10), 
            [Password] nchar(10), 
            AddressLine1 nvarchar(60), 
            AddressLine2 nvarchar(60), 
            AddressCity nvarchar(20), 
            [State] nvarchar(20), 
            StateShort nvarchar(10), 
            Country nvarchar(30), 
            CountryShort nvarchar(3), 
            Language1 nvarchar(30), 
            Language2 nvarchar(30), 
            Language3 nvarchar(30), 
            AddressPostcode nvarchar(12), 
            [Status] varchar(5), 
            Notes nvarchar(max), 
            RegistrationNumber nvarchar(50), 
            FullTimeEquivalent numeric(10,2), 
            MaxCaseLoad int, 
            MaxIndividualLoad int, 
            CreatedDatetime datetime2, 
            UpdatedDatetime datetime2, 
            CreatedBy nvarchar(20), 
            UpdatedBy nvarchar(20), 
            userfahcsiano nvarchar(4000), 
            Qualification nvarchar(50), 
            WorkerAccept varchar(5), 
            WorkerCreatedDatetime datetime2, 
            WorkerUpdatedDatetime datetime2, 
            SocialSecurityNumber nvarchar(9), 
            EmployerIdentificationNumber nvarchar(9), 
            NationalProviderID nvarchar(10), 
            ProviderSpecialtyTaxonomyCode nvarchar(30), 
            DVQualified varchar(5), 
            WorkerIDRendering int, 
            krenderingproviderid int, 
            kreferringphysicianid int, 
            kbluebookidrefphys int, 
            MedicarePI nvarchar(30),
			SecurityClass nvarchar(25),
			ReportSecurityClass nvarchar(50),
			ClienteleResourceCode varchar(10),
			ResourceType nvarchar(50),
			Gender varchar(20),
			SectionCode varchar(20),
			Degree nvarchar(max),
            Team nvarchar(50),
			UserFullName nvarchar(200) null,
			index idx_pnpUser_FirstName nonclustered (FirstName),
			index idx_pnpUser_LastName nonclustered (LastName),
			index idx_pnpUser_ClienteleResourceCode nonclustered (ClienteleResourceCode),
			index idx_pnpUserFullName nonclustered (UserFullName,UserSK)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			bi.BookItemSK,
			convert(varchar(50), u.kuserid) as UserID,
			convert(varchar(50), u.krepuserid) as ReportToUserID,
			convert(varchar(50), w.kcworkerid) as WorkerID,
			u.usfirstname as FirstName,
			u.uslastname as LastName,
			u.ustitle as Title,
			u.uswext as Extention,
			u.usphone1 as Phone1,
			u.usphone2 as Phone2,
			u.usemail as Email,
			ug.ugpname as UserGroup,
			ug.ugplevel as UserGroupLevel,
			u.usloginid as LoginName,
			u.usloginpass as [Password],
			u.usaddress1 as AddressLine1,
			u.usaddress2 as AddressLine2,
			u.uscity as AddressCity,
			ps.provstatename as [State],
			ps.provstateshort as StateShort,
			c.country as Country,
			c.countryshort as CountryShort,
			l1.[language] as Language1,
			l2.[language] as Language2,
			l3.[language] as Language3,
			u.uspczip as AddressPostcode,
			u.usstatus as [Status],
			dbo.xfn_StripHTML(u.usnotes) as Notes,
			--dbo.udf_StripHTML(u.usnotes) as Notes,
			u.usregno as RegistrationNumber,
			u.usfulltimeeq as FullTimeEquivalent,
			u.usmaxcaseload as MaxCaseLoad,
			u.usmaxindload as MaxIndividualLoad,
			u.slogin as CreatedDatetime,
			u.slogmod as UpdatedDatetime,
			u.sloginby as CreatedBy,
			u.slogmodby as UpdatedBy,
			u.userfahcsiano as userfahcsiano,
			q.qualification as Qualification,
			w.cworkeraccept as WorkerAccept,
			w.slogin as WorkerCreatedDatetime,
			w.slogmod as WorkerUpdatedDatetime,
			w.cworkerssn as SocialSecurityNumber,
			w.cworkerein as EmployerIdentificationNumber,
			w.cworkernpi as NationalProviderID,
			w.cworkertax as ProviderSpecialtyTaxonomyCode,
			w.dvqual as DVQualified,
			w.kcworkeridrend as WorkerIDRendering,
			w.krenderingproviderid as krenderingproviderid,
			w.kreferringphysicianid as kreferringphysicianid,
			w.kbluebookidrefphys as kbluebookidrefphys,
			w.cworkermedicarepi as MedicarePI,
			sc.scname as SecurityClass,
			rsc.rscname as ReportSecurityClass,
			ud1.user1exp1 as ClienteleResourceCode,
			rt.luuser1exp4 as ResourceType,
			g.luuser1exp3 as Gender,
			ud1.user1exp9 as Degree,
            tt.Team,
			u.usfirstname + ' ' + u.uslastname as UserFullName
		into #src
		from 
			penelope_wruser_audtc u 
			left join penelope_sausergroup_audtc ug on ug.kusergroupid = u.kusergroupid 
			left join penelope_luprovstate_audtc ps on ps.luprovstateid = u.luusprovstateid 
			left join penelope_lucountry_audtc c on c.lucountryid = u.luuscountryid 
			left join penelope_lulanguage_audtc l1 on l1.lulanguageid = u.luuslanguage1 
			left join penelope_lulanguage_audtc l2 on l2.lulanguageid = u.luuslanguage2 
			left join penelope_lulanguage_audtc l3 on l3.lulanguageid = u.luuslanguage3 
			left join penelope_wrcworker_audtc w on w.kuserid = u.kuserid 
			left join penelope_luqualification_audtc q on q.luqualificationid = w.luqualificationid 
			left join penelope_wrsecurityclass_audtc sc on sc.ksecurityclassid = u.ksecurityclassid 
			left join penelope_wrreportsecclass_audtc rsc on rsc.kreportsecclassid = u.kreportsecclassid 
			left join penelope_wruser1exp_audtc ud1 on ud1.kuserid = u.kuserid 
			left join penelope_luuser1exp4_audtc rt on rt.luuser1exp4id = ud1.user1exp4 
			left join penelope_luuser1exp3_audtc g on g.luuser1exp3id = ud1.user1exp3 
			outer apply (
				select top 1 BookItemSK
				from [db-au-dtc].dbo.pnpBookItem
				where BookItemID = u.kbookitemid
			) bi
            outer apply
            (
                select top 1 
                    tt.luuser2exp3 [Team]
                from
                    penelope_wruser2exp_audtc ud2
                    inner join penelope_luuser2exp3_audtc tt on
                        tt.luuser2exp3id = ud2.user2exp3
                where
                    ud2.kuserid = u.kuserid
            ) tt
	
		select @sourcecount = count(*) from #src


		-- Handle Type 1 fields
		update [db-au-dtc]..pnpUser 
		set 
			BookItemSK = #src.BookItemSK,
			ReportToUserID = #src.ReportToUserID,
			WorkerID = #src.WorkerID,
			FirstName = #src.FirstName,
			LastName = #src.LastName,
			Title = #src.Title,
			Extention = #src.Extention,
			Phone1 = #src.Phone1,
			Phone2 = #src.Phone2,
			Email = #src.Email,
			UserGroup = #src.UserGroup,
			UserGroupLevel = #src.UserGroupLevel,
			LoginName = #src.LoginName,
			[Password] = #src.[Password],
			AddressLine1 = #src.AddressLine1,
			AddressLine2 = #src.AddressLine2,
			AddressCity = #src.AddressCity,
			[State] = #src.[State],
			StateShort = #src.StateShort,
			Country = #src.Country,
			CountryShort = #src.CountryShort,
			Language1 = #src.Language1,
			Language2 = #src.Language2,
			Language3 = #src.Language3,
			AddressPostcode = #src.AddressPostcode,
			Notes = #src.Notes,
			RegistrationNumber = #src.RegistrationNumber,
			FullTimeEquivalent = #src.FullTimeEquivalent,
			MaxCaseLoad = #src.MaxCaseLoad,
			MaxIndividualLoad = #src.MaxIndividualLoad,
			UpdatedDatetime = #src.UpdatedDatetime,
			UpdatedBy = #src.UpdatedBy,
			userfahcsiano = #src.userfahcsiano,
			Qualification = #src.Qualification,
			WorkerAccept = #src.WorkerAccept,
			WorkerCreatedDatetime = #src.WorkerCreatedDatetime,
			WorkerUpdatedDatetime = #src.WorkerUpdatedDatetime,
			SocialSecurityNumber = #src.SocialSecurityNumber,
			EmployerIdentificationNumber = #src.EmployerIdentificationNumber,
			NationalProviderID = #src.NationalProviderID,
			ProviderSpecialtyTaxonomyCode = #src.ProviderSpecialtyTaxonomyCode,
			DVQualified = #src.DVQualified,
			WorkerIDRendering = #src.WorkerIDRendering,
			krenderingproviderid = #src.krenderingproviderid,
			kreferringphysicianid = #src.kreferringphysicianid,
			kbluebookidrefphys = #src.kbluebookidrefphys,
			MedicarePI = #src.MedicarePI,
			SecurityClass = #src.SecurityClass,
			ReportSecurityClass = #src.ReportSecurityClass,
			ClienteleResourceCode = #src.ClienteleResourceCode,
			ResourceType = #src.ResourceType,
			Gender = #src.Gender,
			Degree = #src.Degree,
            Team = #src.Team,
			UserFullName = #src.UserFullName
		from 
			[db-au-dtc].dbo.pnpUser tgt inner join #src 
				on tgt.UserID = #src.UserID 
					and tgt.[Status] = #src.[Status]
		where 
			IsCurrent = 1

        create clustered index cidx on #src (UserID)

		select @updatecount = @@ROWCOUNT


		-- Handle Type 2 fields
		merge [db-au-dtc].dbo.pnpUser as tgt
		using #src
			on #src.UserID = tgt.UserID
		when not matched by target and #src.UserID is not null then 
			insert (
				IsCurrent, StartDate, EndDate, 
				BookItemSK, UserID, ReportToUserID, WorkerID, FirstName, LastName, Title,
				Extention, Phone1, Phone2, Email, 
				UserGroup, UserGroupLevel, LoginName, [Password], 
				AddressLine1, AddressLine2, AddressCity, [State], StateShort, Country, CountryShort, 
				Language1, Language2, Language3, AddressPostcode,
				[Status], Notes, RegistrationNumber, FullTimeEquivalent, MaxCaseLoad, MaxIndividualLoad, 
				CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy, 
				userfahcsiano, Qualification, WorkerAccept, WorkerCreatedDatetime, WorkerUpdatedDatetime, 
				SocialSecurityNumber, EmployerIdentificationNumber, NationalProviderID, ProviderSpecialtyTaxonomyCode, 
				DVQualified, WorkerIDRendering, krenderingproviderid, kreferringphysicianid, kbluebookidrefphys, MedicarePI, 
				SecurityClass, ReportSecurityClass, ClienteleResourceCode, ResourceType, Gender, Degree, Team, UserFullName
			)
			values (
				1, '1900-01-01', '9999-12-31', 
				#src.BookItemSK, #src.UserID, #src.ReportToUserID, #src.WorkerID, #src.FirstName, #src.LastName, #src.Title,
				#src.Extention, #src.Phone1, #src.Phone2, #src.Email, 
				#src.UserGroup, #src.UserGroupLevel, #src.LoginName, #src.[Password], 
				#src.AddressLine1, #src.AddressLine2, #src.AddressCity, #src.[State], #src.StateShort, #src.Country, #src.CountryShort, 
				#src.Language1, #src.Language2, #src.Language3, #src.AddressPostcode, 
				#src.[Status], #src.Notes, #src.RegistrationNumber, #src.FullTimeEquivalent, #src.MaxCaseLoad, #src.MaxIndividualLoad, 
				#src.CreatedDatetime, #src.UpdatedDatetime, #src.CreatedBy, #src.UpdatedBy, 
				#src.userfahcsiano, #src.Qualification, #src.WorkerAccept, #src.WorkerCreatedDatetime, #src.WorkerUpdatedDatetime, 
				#src.SocialSecurityNumber, #src.EmployerIdentificationNumber, #src.NationalProviderID, #src.ProviderSpecialtyTaxonomyCode,
				#src.DVQualified, #src.WorkerIDRendering, #src.krenderingproviderid, #src.kreferringphysicianid, #src.kbluebookidrefphys, #src.MedicarePI, 
				#src.SecurityClass, #src.ReportSecurityClass, #src.ClienteleResourceCode, #src.ResourceType, #src.Gender, #src.Degree,
                #src.Team, #src.UserFullName
			)
		when matched 
			and tgt.IsCurrent = 1 
			and tgt.[Status] <> #src.[Status] 
		then 
			update set 
				tgt.IsCurrent = 0,
				tgt.EndDate = dateadd(day, -1, getdate())

		output 
			#src.BookItemSK, #src.UserID, #src.ReportToUserID, #src.WorkerID, #src.FirstName, #src.LastName, #src.Title,
			#src.Extention, #src.Phone1, #src.Phone2, #src.Email, 
			#src.UserGroup, #src.UserGroupLevel, #src.LoginName, #src.[Password], 
			#src.AddressLine1, #src.AddressLine2, #src.AddressCity, #src.[State], #src.StateShort, #src.Country, #src.CountryShort, 
			#src.Language1, #src.Language2, #src.Language3, #src.AddressPostcode, 
			#src.[Status], #src.Notes, #src.RegistrationNumber, #src.FullTimeEquivalent, #src.MaxCaseLoad, #src.MaxIndividualLoad, 
			#src.CreatedDatetime, #src.UpdatedDatetime, #src.CreatedBy, #src.UpdatedBy, 
			#src.userfahcsiano, #src.Qualification, #src.WorkerAccept, #src.WorkerCreatedDatetime, #src.WorkerUpdatedDatetime, 
			#src.SocialSecurityNumber, #src.EmployerIdentificationNumber, #src.NationalProviderID, #src.ProviderSpecialtyTaxonomyCode,
			#src.DVQualified, #src.WorkerIDRendering, #src.krenderingproviderid, #src.kreferringphysicianid, #src.kbluebookidrefphys, #src.MedicarePI, 
			#src.SecurityClass, #src.ReportSecurityClass, #src.ClienteleResourceCode, #src.ResourceType, #src.Gender, #src.Degree,
            #src.Team,#src.UserFullName,
			$action as MergeAction 
		into @mergeoutput;

		-- insert current records for type 2 changes
		insert into [db-au-dtc]..pnpUser (
			IsCurrent, StartDate, EndDate, 
			BookItemSK, UserID, ReportToUserID, WorkerID, FirstName, LastName, Title,
			Extention, Phone1, Phone2, Email, 
			UserGroup, UserGroupLevel, LoginName, [Password], 
			AddressLine1, AddressLine2, AddressCity, [State], StateShort, Country, CountryShort, 
			Language1, Language2, Language3, AddressPostcode,
			[Status], Notes, RegistrationNumber, FullTimeEquivalent, MaxCaseLoad, MaxIndividualLoad, 
			CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy, 
			userfahcsiano, Qualification, WorkerAccept, WorkerCreatedDatetime, WorkerUpdatedDatetime, 
			SocialSecurityNumber, EmployerIdentificationNumber, NationalProviderID, ProviderSpecialtyTaxonomyCode, 
			DVQualified, WorkerIDRendering, krenderingproviderid, kreferringphysicianid, kbluebookidrefphys, MedicarePI, 
			SecurityClass, ReportSecurityClass, ClienteleResourceCode, ResourceType, Gender, Degree, Team, UserFullName
		)
		select 
			1, getdate(), '9999-12-31', 
			BookItemSK, UserID, ReportToUserID, WorkerID, FirstName, LastName, Title,
			Extention, Phone1, Phone2, Email, 
			UserGroup, UserGroupLevel, LoginName, [Password], 
			AddressLine1, AddressLine2, AddressCity, [State], StateShort, Country, CountryShort, 
			Language1, Language2, Language3, AddressPostcode,
			[Status], Notes, RegistrationNumber, FullTimeEquivalent, MaxCaseLoad, MaxIndividualLoad, 
			CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy, 
			userfahcsiano, Qualification, WorkerAccept, WorkerCreatedDatetime, WorkerUpdatedDatetime, 
			SocialSecurityNumber, EmployerIdentificationNumber, NationalProviderID, ProviderSpecialtyTaxonomyCode, 
			DVQualified, WorkerIDRendering, krenderingproviderid, kreferringphysicianid, kbluebookidrefphys, MedicarePI, 
			SecurityClass, ReportSecurityClass, ClienteleResourceCode, ResourceType, Gender, Degree, Team, UserFullName
		from @mergeoutput
		where MergeAction = 'UPDATE'
		
		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = @updatecount + sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput


        update u
        set
            u.Status = 0
        from
            [db-au-dtc]..pnpUser u
        where
            not exists
            (
                select
                    null
                from
                    #src r
			    where 
                    r.UserID = u.UserID
            )

		-- ReportToUserSK
		update [db-au-dtc].dbo.pnpUser
		set ReportToUserSK = rtu.ReportToUserSK
		from [db-au-dtc].dbo.pnpUser u
			outer apply (
				select top 1 UserSK as ReportToUserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = u.ReportToUserID
					and IsCurrent = 1
			) rtu


		-- SectionCode 
		if object_id('tempdb..#sc') is not null drop table #sc 
		--#mod20181019 - Commented out due to Server issues. Will need to be uncommented when resolved.
		select UserID, SectionCode 
		into #sc 
		from openquery([SAEAPSYD03VDB01], 
		'select convert(varchar, kuserid) UserId, section_code SectionCode, row_number() over(partition by kuserid order by Effective_Date desc) rn 
		from [Penelope_DataMart].[RCTI].[pnp_WorkerActiveDates]')
		where rn = 1 

		update u 
		set SectionCode = #sc.SectionCode
		from [db-au-dtc]..pnpUser u join #sc on #sc.UserID = u.UserID 

		--Clean the First and Last Names - remove anything after the semi-colon
		update u
			set FirstName	= [db-au-dtc].dbo.UF_CleanUserName(FirstName),
				LastName	= [db-au-dtc].dbo.UF_CleanUserName(LastName),
				UserFullName = [db-au-dtc].dbo.UF_CleanUserName(FirstName) + ' ' + [db-au-dtc].dbo.UF_CleanUserName(LastName)
		from [db-au-dtc].dbo.pnpUser U
		
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


        
    --20180122, LL, worker category
	if object_id('[db-au-dtc].dbo.pnpUserCategory') is null
	begin 

        create table [db-au-dtc].[dbo].[pnpUserCategory]
        (
	        [UserCategorySK] [int] identity(1,1) not null,
	        [UserSK] [int] not null,
	        [UserID] [varchar](50) null,
	        [WorkerCategoryID] [int] not null,
	        [WorkerCategory] [varchar](250) null,
	        [CreatedDatetime] [datetime] not null,
	        [UpdatedDatetime] [datetime] not null,
	        [isActive] bit not null,
	        [ExcludeFromMessageDistribution] bit not null,
            primary key clustered ([UserCategorySK])
        )

        create nonclustered index idx_pnpUserCategory_UserSK on [db-au-dtc].[dbo].[pnpUserCategory] (UserSK) include ([UserID],[WorkerCategory],[isActive],[ExcludeFromMessageDistribution])
        create nonclustered index idx_pnpUserCategory_UserID on [db-au-dtc].[dbo].[pnpUserCategory] ([UserID]) include (UserSK,[WorkerCategory],[isActive],[ExcludeFromMessageDistribution])

    end
    else 
        truncate table [db-au-dtc].[dbo].[pnpUserCategory]

    insert into [db-au-dtc].[dbo].[pnpUserCategory]
    (
	    [UserSK],
	    [UserID],
	    [WorkerCategoryID],
	    [WorkerCategory],
	    [CreatedDatetime],
	    [UpdatedDatetime],
	    [isActive],
	    [ExcludeFromMessageDistribution]
    )
    select 
        u.UserSK,
        convert(varchar(50), u.UserID) UserID,
        c.luworkercatid WorkerCategoryID,
        convert(varchar(250), c.workercat) WorkerCategory,
        c.slogin CreatedDatetime,
        c.slogmod UpdatedDatetime,
        c.valisactive isActive,
        c.excludefrommsgdist ExcludeFromMessageDistribution
    from
        [db-au-dtc]..pnpUser u
        inner join [db-au-stage].[dbo].[penelope_wtusercat_audtc] uc on
            uc.kuserid = try_convert(int, u.UserID)
        inner join [db-au-stage].[dbo].[penelope_luworkercat_audtc] c on
            c.luworkercatid = uc.luworkercatid


END


GO
