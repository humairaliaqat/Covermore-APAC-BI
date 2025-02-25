USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpSite]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpSite
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpSite] 
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

	declare @mergeoutput table (MergeAction varchar(20))

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

	if object_id('[db-au-dtc].dbo.pnpSite') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpSite](
			SiteSK int identity(1,1) primary key,
			SiteID varchar(50),
            SiteName nvarchar(100),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            AddressLine1 nvarchar(60),
            AddressLine2 nvarchar(60),
            City nvarchar(20),
            [State] nvarchar(20),
            StateShort nvarchar(10),
            Country nvarchar(30),
            CountryShort nvarchar(3),
            Postcode nvarchar(12),
            Phone nvarchar(13),
            Fax nvarchar(13),
            PlaceOfService nchar(4),
            SendClaimToAddress varchar(5),
            SendPaymentToAddress varchar(5),
            Active varchar(5),
            ParentSiteID varchar(50),
            sitefahcsiaoutlet nvarchar(4000),
            BankNumber nvarchar(4000),
            siteud1 nvarchar(100),
            siteud2 nvarchar(100),
            siteud3 nvarchar(4000),
            siteud4 nvarchar(4000),
            siteud5 nvarchar(100),
            siteud6 nvarchar(100),
            Region nvarchar(100),
            RegionCode nvarchar(15),
            County nvarchar(50),
            SiteGLCode nvarchar(50),
            LocSameAsAgency varchar(5),
            OwnedBy nvarchar(100),
			index idx_pnpSite_SiteID nonclustered (SiteID)
	)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			convert(varchar(50), s.ksiteid) as SiteID,
			s.sitename as SiteName,
			s.slogin as CreatedDatetime,
			s.slogmod as UpdatedDatetime,
			s.siteaddr1 as AddressLine1,
			s.siteaddr2 as AddressLine2,
			s.sitecity as City,
			ps.provstatename as [State],
			ps.provstateshort as StateShort,
			c.country as Country,
			c.countryshort as CountryShort,
			s.sitepczip as Postcode,
			s.sitephone as Phone,
			s.sitefax as Fax,
			s.siteplaceofservice as PlaceOfService,
			s.sitesendclaimtoaddr as SendClaimToAddress,
			s.sitesendpaymenttoaddr as SendPaymentToAddress,
			s.siteactive as Active,
			convert(varchar(50), s.kparentsiteid) as ParentSiteID,
			s.sitefahcsiaoutlet as sitefahcsiaoutlet,
			s.banknumber as BankNumber,
			sud1.siteud1 as siteud1,
			sud2.siteud2 as siteud2,
			s.siteud3 as siteud3,
			s.siteud4 as siteud4,
			s.siteud5 as siteud5,
			s.siteud6 as siteud6,
			sr.siteregion as Region,
			sr.siteregionglcode as RegionCode,
			s.sitecounty as County,
			s.siteglcode as SiteGLCode,
			s.sitelocsameasagency as LocSameAsAgency,
			sud7.siteud7 as OwnedBy
		into #src
		from 
			penelope_sasite_audtc s
			left join penelope_luprovstate_audtc ps on ps.luprovstateid = s.lusiteprovstateid
			left join penelope_lucountry_audtc c on c.lucountryid = s.lusitecountryid
			left join penelope_lusiteud1_audtc sud1 on sud1.lusiteud1id = s.lusiteud1id
			left join penelope_lusiteud2_audtc sud2 on sud2.lusiteud2id = s.lusiteud2id
			left join penelope_lusiteregion_audtc sr on sr.lusiteregionid = s.lusiteregionid
			left join penelope_lusiteud7_audtc sud7 on sud7.lusiteud7id = s.lusiteud7id
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpSite as tgt
		using #src
			on #src.SiteID = tgt.SiteID
		when matched then 
			update set 
				tgt.SiteName = #src.SiteName,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.AddressLine1 = #src.AddressLine1,
				tgt.AddressLine2 = #src.AddressLine2,
				tgt.City = #src.City,
				tgt.[State] = #src.[State],
				tgt.StateShort = #src.StateShort,
				tgt.Country = #src.Country,
				tgt.CountryShort = #src.CountryShort,
				tgt.Postcode = #src.Postcode,
				tgt.Phone = #src.Phone,
				tgt.Fax = #src.Fax,
				tgt.PlaceOfService = #src.PlaceOfService,
				tgt.SendClaimToAddress = #src.SendClaimToAddress,
				tgt.SendPaymentToAddress = #src.SendPaymentToAddress,
				tgt.Active = #src.Active,
				tgt.ParentSiteID = #src.ParentSiteID,
				tgt.sitefahcsiaoutlet = #src.sitefahcsiaoutlet,
				tgt.BankNumber = #src.BankNumber,
				tgt.siteud1 = #src.siteud1,
				tgt.siteud2 = #src.siteud2,
				tgt.siteud3 = #src.siteud3,
				tgt.siteud4 = #src.siteud4,
				tgt.siteud5 = #src.siteud5,
				tgt.siteud6 = #src.siteud6,
				tgt.Region = #src.Region,
				tgt.RegionCode = #src.RegionCode,
				tgt.County = #src.County,
				tgt.SiteGLCode = #src.SiteGLCode,
				tgt.LocSameAsAgency = #src.LocSameAsAgency,
				tgt.OwnedBy = #src.OwnedBy
		when not matched by target then 
			insert (
				SiteID,
				SiteName,
				CreatedDatetime,
				UpdatedDatetime,
				AddressLine1,
				AddressLine2,
				City,
				[State],
				StateShort,
				Country,
				CountryShort,
				Postcode,
				Phone,
				Fax,
				PlaceOfService,
				SendClaimToAddress,
				SendPaymentToAddress,
				Active,
				ParentSiteID,
				sitefahcsiaoutlet,
				BankNumber,
				siteud1,
				siteud2,
				siteud3,
				siteud4,
				siteud5,
				siteud6,
				Region,
				RegionCode,
				County,
				SiteGLCode,
				LocSameAsAgency,
				OwnedBy
			)
			values (
				#src.SiteID,
				#src.SiteName,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.AddressLine1,
				#src.AddressLine2,
				#src.City,
				#src.[State],
				#src.StateShort,
				#src.Country,
				#src.CountryShort,
				#src.Postcode,
				#src.Phone,
				#src.Fax,
				#src.PlaceOfService,
				#src.SendClaimToAddress,
				#src.SendPaymentToAddress,
				#src.Active,
				#src.ParentSiteID,
				#src.sitefahcsiaoutlet,
				#src.BankNumber,
				#src.siteud1,
				#src.siteud2,
				#src.siteud3,
				#src.siteud4,
				#src.siteud5,
				#src.siteud6,
				#src.Region,
				#src.RegionCode,
				#src.County,
				#src.SiteGLCode,
				#src.LocSameAsAgency,
				#src.OwnedBy
			)

		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
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
