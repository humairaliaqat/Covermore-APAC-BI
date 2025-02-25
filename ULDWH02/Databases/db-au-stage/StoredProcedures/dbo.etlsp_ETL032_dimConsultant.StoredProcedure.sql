USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimConsultant]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL032_dimConsultant]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131114
Prerequisite:   Requires Penguin Data Model ETL successfully run.
                Requires [db-au-cmdwh].dbo.penUser table available
Description:    dimConsultant dimension table contains consultant attributes.
Parameters:     @LoadType: value is Migration or Incremental
Change History:
                20131114 - LT - Procedure created
                20140710 - PW - Null handling
                20140725 - LT - Amended merged statement
                20140905 - LS - refactoring
                                move aggresive load to fact tables
                                don't return result unless debuging (cut time on network transfer)
                20140908 - LS - upper consultant key there may be issue with mix collation
				20141118 - LT - Fixed the MERGE statement where it complained of multiple rows of same record in target.
								Uncommented SRC.UserName = DST.Username in the MERGE test conditions
                20150204 - LS - replace batch codes with standard batch logging
                20150313 - LT - Added ConsultantType column.

*************************************************************************************************************************************/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Policy Star',
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

    --create dimOutlet if table does not exist
    if object_id('[db-au-star].dbo.dimConsultant') is null
    begin
    
        create table [db-au-star].dbo.dimConsultant
        (
            ConsultantSK int identity(1,1) not null,
            Country nvarchar(10) not null,
            ConsultantKey nvarchar(50) not null,
            OutletAlphaKey nvarchar(50) not null,
            Firstname nvarchar(50) null,
            Lastname nvarchar(50) null,
            ConsultantName nvarchar(100) null,
            UserName nvarchar(100) null,
            ASICNumber int null,
            AgreementDate datetime null,
            [Status] nvarchar(20) null,
            InactiveDate datetime null,
            RefereeName nvarchar(255) null,
            AccreditationDate datetime null,
            DeclaredDate datetime null,
            PreviouslyKnownAs nvarchar(100) null,
            YearsOfExperience nvarchar(15) null,
            DateOfBirth datetime null,
            ASICCheck nvarchar(50) null,
            Email nvarchar(200) null,
            FirstSellDate datetime null,
            LastSellDate datetime null,
            ConsultantType nvarchar(50) null,
            LoadDate datetime not null,
            updateDate datetime null,
            LoadID int not null,
            updateID int null,
            HashKey varbinary(30) null
        )
        
        create clustered index idx_dimConsultant_ConsultantSK on [db-au-star].dbo.dimConsultant(ConsultantSK)
        create nonclustered index idx_dimConsultant_ConsultantKey on [db-au-star].dbo.dimConsultant(ConsultantKey)
        create nonclustered index idx_dimConsultant_Country on [db-au-star].dbo.dimConsultant(Country)
        create nonclustered index idx_dimConsultant_ConsultantName on [db-au-star].dbo.dimConsultant(ConsultantName)
        create nonclustered index idx_dimConsultant_Status on [db-au-star].dbo.dimConsultant([Status])
        create nonclustered index idx_dimConsultant_InactiveDate on [db-au-star].dbo.dimConsultant(InactiveDate)

        set identity_insert [db-au-star].dbo.dimConsultant on

        --populate dimension with default unknown values
        insert [db-au-star].dbo.dimConsultant
        (
            ConsultantSK,
            Country,
            ConsultantKey,
            OutletAlphaKey,
            Firstname,
            Lastname,
            ConsultantName,
            UserName,
            ASICNumber,
            AgreementDate,
            [Status],
            InactiveDate,
            RefereeName,
            AccreditationDate,
            DeclaredDate,
            PreviouslyKnownAs,
            YearsOfExperience,
            DateOfBirth,
            ASICCheck,
            Email,
            FirstSellDate,
            LastSellDate,
            ConsultantType,
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
            0,
            null,
            'UNKNOWN',
            null,
            'UNKNOWN',
            null,
            null,
            'UNKNOWN',
            'UNKNOWN',
            null,
            'UNKNOWN',
            'UNKNOWN',
            null,
            null,
            'UNKNOWN',
            getdate(),
            null,
            @batchid,
            null,
            binary_checksum('UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN',0,null,'',null,'',null,null,'','',null,'','',null,null)
        )
        
        set identity_insert [db-au-star].dbo.dimConsultant off
        
    end


    if object_id('[db-au-stage].dbo.etl_dimConsultant') is not null 
        drop table [db-au-stage].dbo.etl_dimConsultant
        
    select distinct
        isnull(SUBSTRING(o.OutletKey,1,2),'AU') as Country,
        upper(u.UserKey) as ConsultantKey,
        upper(isnull(o.OutletAlphaKey,'UNKNOWN')) as OutletAlphaKey,
        u.Firstname,
        u.Lastname,
        u.FirstName + ' ' + u.LastName as ConsultantName,
        u.[Login] as UserName,
        isnull(u.ASICNumber,0) ASICNumber,
        u.AgreementDate,
        isnull(u.[Status],'UNKNOWN') as [Status],
        u.InactiveDate,
        isnull(u.RefereeName,'') RefereeName,
        u.AccreditationDate,
        u.DeclaredDate,
        isnull(u.PreviouslyKnownAs,'') PreviouslyKnownAs,
        isnull(u.YearsOfExperience,'') YearsOfExperience,
        u.DateOfBirth,
        isnull(u.ASICCheck,'') ASICCheck,
        isnull(u.Email,'') Email,
        u.FirstSellDate,
        u.LastSellDate,
        isnull(u.ConsultantType,'') as ConsultantType,
        convert(datetime,null) as LoadDate,
        convert(datetime,null) as updateDate,
        convert(int,null) as LoadID,
        convert(int,null) as updateID,
        convert(varbinary,null) as HashKey
    into [db-au-stage].dbo.etl_dimConsultant
    from
        [db-au-cmdwh].dbo.penUser u
        left join [db-au-cmdwh].dbo.penOutlet o
            on u.OutletKey = o.OutletKey            
    where
        u.UserKey not in ('NZ-CM8-TFLZ1288AM','NZ-CM8-TFLZ1288JW','NZ-CM8-TFLZ1288LS') --this legacy TRIPS consultants contains duplicate consultants. it can be safely excluded as there are no sales since 2009
        and u.UserStatus = 'Current'
        and isnull(o.OutletStatus,'Current') = 'Current'
				

    --Update HashKey value
    update [db-au-stage].dbo.etl_dimConsultant
    set 
        HashKey = 
            binary_checksum(
                Country, 
                ConsultantKey, 
                OutletAlphaKey, 
                Firstname, 
                Lastname, 
                ConsultantName, 
                UserName,
                ASICNumber, 
                AgreementDate, 
                [Status], 
                InactiveDate, 
                RefereeName, 
                AccreditationDate, 
                DeclaredDate,
                PreviouslyKnownAs, 
                YearsOfExperience, 
                DateOfBirth, 
                ASICCheck, 
                Email, 
                FirstSellDate, 
                LastSellDate
            )
            
    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_dimConsultant

    begin transaction
    begin try

        -- Merge statement
        merge into [db-au-star].dbo.dimConsultant as DST
        using [db-au-stage].dbo.etl_dimConsultant as SRC
        on 
            (
                SRC.ConsultantKey = DST.ConsultantKey and
                SRC.OutletAlphaKey = DST.OutletAlphaKey and 
                SRC.UserName = DST.UserName
            )

        -- inserting new records
        when not matched by target then
        insert
        (
            Country,
            ConsultantKey,
            OutletAlphaKey,
            Firstname,
            Lastname,
            ConsultantName,
            UserName,
            ASICNumber,
            AgreementDate,
            [Status],
            InactiveDate,
            RefereeName,
            AccreditationDate,
            DeclaredDate,
            PreviouslyKnownAs,
            YearsOfExperience,
            DateOfBirth,
            ASICCheck,
            Email,
            FirstSellDate,
            LastSellDate,
            ConsultantType,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            SRC.Country,
            SRC.ConsultantKey,
            SRC.OutletAlphaKey,
            SRC.Firstname,
            SRC.Lastname,
            SRC.ConsultantName,
            SRC.UserName,
            SRC.ASICNumber,
            SRC.AgreementDate,
            SRC.[Status],
            SRC.InactiveDate,
            SRC.RefereeName,
            SRC.AccreditationDate,
            SRC.DeclaredDate,
            SRC.PreviouslyKnownAs,
            SRC.YearsOfExperience,
            SRC.DateOfBirth,
            SRC.ASICCheck,
            SRC.Email,
            SRC.FirstSellDate,
            SRC.LastSellDate,
            SRC.ConsultantType,
            getdate(),
            null,
            @batchid,
            null,
            SRC.HashKey
        )
        
        -- update existing records where data has changed via HashKey
        when matched and SRC.HashKey <> DST.HashKey then
        update
        set
            DST.Country = SRC.Country,
            DST.ConsultantKey = SRC.ConsultantKey,
            DST.OutletAlphaKey = SRC.OutletAlphaKey,
            DST.FirstName = SRC.Firstname,
            DST.LastName = SRC.Lastname,
            DST.ConsultantName = SRC.ConsultantName,
            DST.UserName = SRC.UserName,
            DST.ASICNumber = SRC.ASICNumber,
            DST.AgreementDate = SRC.AgreementDate,
            DST.[Status] = SRC.[Status],
            DST.InactiveDate = SRC.InactiveDate,
            DST.RefereeName = SRC.RefereeName,
            DST.AccreditationDate = SRC.AccreditationDate,
            DST.DeclaredDate = SRC.DeclaredDate,
            DST.PreviouslyKnownAs = SRC.PreviouslyKnownAs,
            DST.YearsOfExperience = SRC.YearsOfExperience,
            DST.DateOfBirth = SRC.DateOfBirth,
            DST.ASICCheck = SRC.ASICCheck,
            DST.Email = SRC.Email,
            DST.FirstSellDate = SRC.FirstSellDate,
            DST.LastSellDate = SRC.LastSellDate,
            DST.ConsultantType = SRC.ConsultantType,
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

end
GO
