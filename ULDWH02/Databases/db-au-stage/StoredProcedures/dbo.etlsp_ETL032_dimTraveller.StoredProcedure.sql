USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimTraveller]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_dimTraveller]    
    @DateRange nvarchar(30),
    @StartDate nvarchar(10),
    @EndDate nvarchar(10)
    
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131114
Prerequisite:   Requires Penguin Data Model ETL successfully run.
                Requires [db-au-cmdwh].dbo.penPolicyTraveller table available
Description:    dimTraveller dimension table contains destination attributes.
Parameters:        @LoadType: Required. value is Migration or Incremental
                @DateRange: Required. Value is standard date range or _User Defined
                @StartDate: Optional. if _User Defined enter start date. Format: YYYY-MM-DD
                @StartDate: Optional. if _User Defined enter end date. Format: YYYY-MM-DD
Change History:
                20131114 - LT - Procedure created
                20140710 - PW - Null handling and removed Domain references
                20140714 - PW - Removed type 2 references
                20140725 - LT - Removed penPolicy from theAmended merged statement
                20140905 - LS - refactoring
                20150204 - LS - replace batch codes with standard batch logging

*************************************************************************************************************************************/

--uncomment to debug
/*
declare @DateRange nvarchar(30)
declare @StartDate nvarchar(10)
declare @EndDate nvarchar(10)
select @DateRange = '_User Defined', @StartDate = '2011-07-01', @EndDate = '2014-06-30'
*/

    set nocount on

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @rptStartDate date,
        @rptEndDate date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    select
        @name = object_name(@@procid)

    begin try
    
        --check if this is running on batch

        exec syssp_getrunningbatch
            @SubjectArea = 'Policy Star',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Running'

        select 
            @rptStartDate = @start, 
            @rptEndDate = @end

    end try
    
    begin catch
    
        --or manually
    
        set @batchid = -1

        --get date range
        if @DateRange = '_User Defined'
            select 
                @rptStartDate = @StartDate, 
                @rptEndDate = @EndDate
        else
            select 
                @rptStartDate = StartDate,
                @rptEndDate = EndDate
            from 
                [db-au-cmdwh].dbo.vDateRange
            where 
                DateRange = @DateRange

    end catch


    --create dimTraveller if table does not exist
    if object_id('[db-au-star].dbo.dimTraveller') is null
    begin
    
        create table [db-au-star].dbo.dimTraveller
        (
            TravellerSK int identity(1,1) not null,
            Country nvarchar(10) not null,
            TravellerKey nvarchar(50) not null,
            PolicyKey nvarchar(50) null,
            Title nvarchar(50) null,
            FirstName nvarchar(100) null,
            LastName nvarchar(100) null,
            FullName nvarchar(200) null,
            DOB datetime null,
            Age int null,
            isAdult bit null,
            AdultCharge numeric(18,5) null,
            isPrimary bit null,
            [StreetAddress] nvarchar(200) null,
            PostCode nvarchar(50) null,
            Suburb nvarchar(50) null,
            [State] nvarchar(50) null,
            AddressCountry nvarchar(100) null,
            HomePhone nvarchar(50) null,
            WorkPhone nvarchar(50) null,
            MobilePhone nvarchar(50) null,
            EmailAddress nvarchar(255) null,
            OptFurtherContact bit null,
            MemberNumber nvarchar(25) null,
            EMCRef nvarchar(100) null,
            EMCScore numeric(10,4) null,
            DisplayName nvarchar(100) null,
            AssessmentType nvarchar(20) null,
            LoadDate datetime not null,
            updateDate datetime null,
            LoadID int not null,
            updateID int null,
            HashKey varbinary(30) null
        )
        
        create clustered index idx_dimTraveller_TravellerSK on [db-au-star].dbo.dimTraveller(TravellerSK)
        create nonclustered index idx_dimTraveller_TravellerKey on [db-au-star].dbo.dimTraveller(TravellerKey)
        create nonclustered index idx_dimTraveller_Country on [db-au-star].dbo.dimTraveller(Country)
        create nonclustered index idx_dimTraveller_PolicyKey on [db-au-star].dbo.dimTraveller(PolicyKey)
        create nonclustered index idx_dimTraveller_isPrimary on [db-au-star].dbo.dimTraveller(isPrimary)
        create nonclustered index idx_dimTraveller_State on [db-au-star].dbo.dimTraveller([State])
        create nonclustered index idx_dimTraveller_HashKey on [db-au-star].dbo.dimTraveller(HashKey)

        set identity_insert [db-au-star].dbo.dimTraveller on

        --populate dimension with default unknown values
        insert [db-au-star].dbo.dimTraveller
        (
            TravellerSK,
            Country,
            TravellerKey,
            PolicyKey,
            Title,
            FirstName,
            LastName,
            FullName,
            DOB,
            Age,
            isAdult,
            AdultCharge,
            isPrimary,
            [StreetAddress],
            PostCode,
            Suburb,
            [State],
            AddressCountry,
            HomePhone,
            WorkPhone,
            MobilePhone,
            EmailAddress,
            OptFurtherContact,
            MemberNumber,
            EMCRef,
            EMCScore,
            DisplayName,
            AssessmentType,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            -1,
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            null,
            0,
            -1,
            0,
            -1,
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            0,
            'UNKNOWN',
            'UNKNOWN',
            0,
            'UNKNOWN',
            'UNKNOWN',
            getdate(),
            null,
            @batchid,
            null,
            binary_checksum(-1, -1, 'UNKNOWN','UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', null, 0, null, 0, null, 'UNKNOWN',
                            'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', null, 'UNKNOWN',
                            'UNKNOWN', 0, 'UNKNOWN', 'UNKNOWN')
        )

        set identity_insert [db-au-star].dbo.dimTraveller off
        
    end


    if object_id('[db-au-stage].dbo.etl_dimTraveller') is not null 
        drop table [db-au-stage].dbo.etl_dimTraveller
        
    select
        isnull(d.CountryCode,'UNKNOWN') as Country,
        pt.PolicyTravellerKey as TravellerKey,
        pt.PolicyKey,
        pt.Title,
        pt.FirstName,
        pt.LastName,
        ltrim(rtrim(pt.FirstName)) + ' ' + ltrim(rtrim(pt.LastName)) as FullName,
        pt.DOB,
        pt.Age,
        pt.isAdult,
        pt.AdultCharge,
        pt.isPrimary,
        isnull(ltrim(rtrim(pt.AddressLine1)) + ' ' + ltrim(rtrim(pt.AddressLine2)),'') as [StreetAddress],
        isnull(pt.PostCode,'') PostCode,
        isnull(pt.Suburb,'') Suburb,
        isnull(pt.[State],'') [State],
        isnull(pt.Country,'')  as AddressCountry,
        isnull(pt.HomePhone,'') HomePhone,
        isnull(pt.WorkPhone,'') WorkPhone,
        isnull(pt.MobilePhone,'') MobilePhone,
        isnull(pt.EmailAddress,'') EmailAddress,
        isnull(pt.OptFurtherContact,0) OptFurtherContact,
        isnull(pt.MemberNumber,'') MemberNumber,
        isnull(pt.EMCRef,'') EMCRef,
        isnull(pt.EMCScore,0) EMCScore,
        isnull(pt.DisplayName,'') DisplayName,
        isnull(pt.AssessmentType,'') AssessmentType,
        convert(datetime,null) as LoadDate,
        convert(datetime,null) as updateDate,
        convert(int,null) as LoadID,
        convert(int,null) as updateID,
        convert(varbinary,null) as HashKey
    into [db-au-stage].dbo.etl_dimTraveller
    from
        [db-au-cmdwh].dbo.penPolicyTraveller pt
        left join [db-au-star].dbo.dimDomain d on 
            pt.DomainID = d.DomainID
    where
        pt.PolicyKey in 
        (
            select distinct 
                PolicyKey
            from 
                [db-au-cmdwh].dbo.penPolicyTransSummary
            where 
                PostingDate >= @rptStartDate and 
                PostingDate <  dateadd(day, 1, @rptEndDate)
        )

    --Update HashKey value
    update [db-au-stage].dbo.etl_dimTraveller
    set 
        HashKey = 
            binary_checksum(
                Country, 
                TravellerKey, 
                PolicyKey, 
                Title, 
                FirstName, 
                LastName, 
                FullName, 
                DOB, 
                Age, 
                isAdult, 
                AdultCharge, 
                isPrimary,
                StreetAddress, 
                PostCode, 
                Suburb, 
                [State], 
                AddressCountry, 
                HomePhone, 
                WorkPhone, 
                MobilePhone, 
                EmailAddress, 
                OptFurtherContact,
                MemberNumber, 
                EMCRef, 
                EMCScore, 
                DisplayName, 
                AssessmentType
            )
            

    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_dimTraveller

    begin transaction
    begin try

        -- Merge statement
        merge into [db-au-star].dbo.dimTraveller as DST
        using [db-au-stage].dbo.etl_dimTraveller as SRC
        on (SRC.TravellerKey = DST.TravellerKey)

        -- inserting new records
        when not matched by target then
        insert
        (
            Country,
            TravellerKey,
            PolicyKey,
            Title,
            FirstName,
            LastName,
            FullName,
            DOB,
            Age,
            isAdult,
            AdultCharge,
            isPrimary,
            [StreetAddress],
            PostCode,
            Suburb,
            [State],
            AddressCountry,
            HomePhone,
            WorkPhone,
            MobilePhone,
            EmailAddress,
            OptFurtherContact,
            MemberNumber,
            EMCRef,
            EMCScore,
            DisplayName,
            AssessmentType,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            SRC.Country,
            SRC.TravellerKey,
            SRC.PolicyKey,
            SRC.Title,
            SRC.FirstName,
            SRC.LastName,
            SRC.FullName,
            SRC.DOB,
            SRC.Age,
            SRC.isAdult,
            SRC.AdultCharge,
            SRC.isPrimary,
            SRC.[StreetAddress],
            SRC.PostCode,
            SRC.Suburb,
            SRC.[State],
            SRC.AddressCountry,
            SRC.HomePhone,
            SRC.WorkPhone,
            SRC.MobilePhone,
            SRC.EmailAddress,
            SRC.OptFurtherContact,
            SRC.MemberNumber,
            SRC.EMCRef,
            SRC.EMCScore,
            SRC.DisplayName,
            SRC.AssessmentType,
            getdate(),
            null,
            @batchid,
            null,
            SRC.HashKey
        )
        
        -- update existing records where data has changed via HashKey
        when matched and DST.HashKey <> SRC.HashKey then
        update
        SET
            DST.Country = SRC.Country,
            DST.TravellerKey = SRC.TravellerKey,
            DST.PolicyKey = SRC.PolicyKey,
            DST.Title = SRC.Title,
            DST.FirstName = SRC.FirstName,
            DST.LastName = SRC.LastName,
            DST.FullName = SRC.FullName,
            DST.DOB = SRC.DOB,
            DST.Age = SRC.Age,
            DST.isAdult = SRC.isAdult,
            DST.AdultCharge = SRC.AdultCharge,
            DST.isPrimary = SRC.isPrimary,
            DST.[StreetAddress] = SRC.[StreetAddress],
            DST.PostCode = SRC.PostCode,
            DST.Suburb = SRC.Suburb,
            DST.[State] = SRC.[State],
            DST.AddressCountry = SRC.AddressCountry,
            DST.HomePhone = SRC.HomePhone,
            DST.WorkPhone = SRC.WorkPhone,
            DST.MobilePhone = SRC.MobilePhone,
            DST.EmailAddress = SRC.EmailAddress,
            DST.OptFurtherContact = SRC.OptFurtherContact,
            DST.MemberNumber = SRC.MemberNumber,
            DST.EMCRef = SRC.EMCRef,
            DST.EMCScore = SRC.EMCScore,
            DST.DisplayName = SRC.DisplayName,
            DST.AssessmentType = SRC.AssessmentType,
            DST.UpdateDate = getdate(),
            DST.UpdateID = @batchid,
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

        if @batchid <> -1
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

        if @batchid <> -1
            exec syssp_genericerrorhandler
                @SourceInfo = 'data refresh failed',
                @LogToTable = 1,
                @ErrorCode = '-100',
                @BatchID = @batchid,
                @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
