USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimDomain]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_dimDomain]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131114
Prerequisite:   Requires Penguin Data Model ETL successfully run.
                Requires [db-au-cmdwh].dbo.penDomain table available
Description:    dimDomain dimension table contains domain attributes.
Parameters:     @LoadType: value is Migration or Incremental
Change History:
                20131114 - LT - Procedure created
                20170714 - PW - Removed type 2 references
                20140725 - LT - Amended merged statement
                20140905 - LS - refactoring
                20150204 - LS - unique domain id, CM takes precedence
                                replace batch codes with standard batch logging
                20180627 - LL - materialise FX

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


    --create dimDomain if table does not exist
    if object_id('[db-au-star].dbo.dimDomain') is null
    begin
    
        create table [db-au-star].dbo.dimDomain
        (
            DomainSK int identity(1,1) not null,
            DomainID int not null,
            CountryCode nvarchar(20) not null,
            CurrencySymbol nvarchar(50) not null,
            CurrencyCode nvarchar(50) not null,
            Underwriter nvarchar(50) not null,
            TimeZoneCode nvarchar(50) not null,
            LoadDate datetime not null,
            updateDate datetime null,
            LoadID int not null,
            updateID int null,
            HashKey varbinary(30) null
        )
        create clustered index idx_dimDomain_DomainSK on [db-au-star].dbo.dimDomain(DomainSK)
        create nonclustered index idx_dimDomain_DomainID on [db-au-star].dbo.dimDomain(DomainID)
        create nonclustered index idx_dimDomain_CountryCode on [db-au-star].dbo.dimDomain(CountryCode)
        create nonclustered index idx_dimDomain_HashKey on [db-au-star].dbo.dimDomain(HashKey)

        set identity_insert [db-au-star].dbo.dimDomain on

        insert [db-au-star].[dbo].[dimDomain]
        (
            DomainSK,
            DomainID,
            CountryCode,
            CurrencySymbol,
            CurrencyCode,
            Underwriter,
            TimeZoneCode,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            -1,
            0,
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            getdate(),
            null,
            @batchid,
            null,
            binary_checksum(0, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN')
        )

        set identity_insert [db-au-star].dbo.dimDomain off

    end


    if object_id('[db-au-stage].dbo.etl_dimDomain') is not null 
        drop table [db-au-stage].dbo.etl_dimDomain
        
    select 
        r.DomainID,
        CountryKey as CountryCode,
        CurrencySymbol,
        CurrencyCode,
        Underwriter,
        TimeZoneCode,
        convert(datetime,null) as LoadDate,
        convert(datetime,null) as updateDate,
        convert(int,null) as LoadID,
        convert(int,null) as updateID,
        convert(varbinary,null) as HashKey
    into [db-au-stage].dbo.etl_dimDomain
    from
        (
            select distinct 
                DomainID
            from
                [db-au-cmdwh].dbo.penDomain
        ) d
        cross apply
        (
            select top 1 
                r.*    
            from
                [db-au-cmdwh].dbo.penDomain r
            where
                r.DomainID = d.DomainID
            order by
                case
                    when CompanyKey = 'CM' then 1
                    when CompanyKey = 'TIP' then 2
                    else 3
                end
        ) r

    --Update HashKey value
    update etl_dimDomain
    set HashKey = binary_checksum(DomainID, CountryCode, CurrencySymbol, CurrencyCode, Underwriter, TimeZoneCode)


    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_dimDomain

    begin transaction
    begin try

        -- Merge statement
        merge into [db-au-star].dbo.dimDomain as DST
        using [db-au-stage].dbo.etl_dimDomain as SRC
        on (src.DomainID = DST.DomainID)

        -- inserting new records
        when not matched by target then
        insert
        (
            DomainID,
            CountryCode,
            CurrencySymbol,
            CurrencyCode,
            Underwriter,
            TimeZoneCode,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            SRC.DomainID,
            SRC.CountryCode,
            SRC.CurrencySymbol,
            SRC.CurrencyCode,
            SRC.Underwriter,
            SRC.TimeZoneCode,
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
            DST.DomainID = SRC.DomainID,
            DST.CountryCode = SRC.CountryCode,
            DST.CurrencySymbol = SRC.CurrencySymbol,
            DST.CurrencyCode = SRC.CurrencyCode,
            DST.Underwriter = SRC.Underwriter,
            DST.TimeZoneCode = SRC.TimeZoneCode,
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


    --domain fx
    if object_id('[db-au-star].dbo.dimDomainFX') is null
    begin
    
        create table [db-au-star].dbo.dimDomainFX
        (
            DomainFXSK bigint identity(1,1) not null,
            DomainSK int not null,
            DateSK bigint not null,
            FXCurrency varchar(50) not null,
            FXRate decimal(25,10)
        )

        create clustered index idx_dimDomainFX_DomainFXSK on [db-au-star].dbo.dimDomainFX(DomainFXSK)
        create nonclustered index idx_dimDomainFX_DateSK on [db-au-star].dbo.dimDomainFX(DateSK,DomainSK) include (FXCurrency,FXRate)

    end

    if object_id('tempdb..#fxrate') is not null
        drop table #fxrate

    select 
        DomainSK,
        Date_SK,
        'AUD' FXCurrency,
        case
            when isnull(fxr.FXRate, 0) = 0 then 0
            else 1 / fxr.FXRate
        end FXRate
    into #fxrate
    from
        [db-au-star]..dimDomain dm
        inner join [db-au-star]..dim_Date dd on
            dd.[Date] < getdate()
        cross apply [db-au-actuary].dbo.[fn_GetFXRate]
            (
                'AUD',
                dm.CurrencyCode,
                dd.Date,
                'Oanda'
            ) fxr

    union all

    select 
        DomainSK,
        Date_SK,
        'USD' FXCurrency,
        case
            when isnull(fxr.FXRate, 0) = 0 then 0
            else 1 / fxr.FXRate
        end FXRate
    from
        [db-au-star]..dimDomain dm
        inner join [db-au-star]..dim_Date dd on
            dd.[Date] < getdate()
        cross apply [db-au-actuary].dbo.[fn_GetFXRate]
            (
                'USD',
                dm.CurrencyCode,
                dd.Date,
                'Oanda'
            ) fxr

    merge into [db-au-star]..dimDomainFX as t
        using #fxrate as s on
            s.Date_SK = t.DateSK and
            s.DomainSK = t.DomainSK and
            s.FXCurrency = t.FXCurrency

        when not matched by target then
            insert
            (
                DomainSK,
                DateSK,
                FXCurrency,
                FXRate
            )
            values
            (
                s.DomainSK,
                s.Date_SK,
                s.FXCurrency,
                s.FXRate
            )

        when matched then
            update
            set
                t.FXRate = s.FXRate

        ;


end
GO
