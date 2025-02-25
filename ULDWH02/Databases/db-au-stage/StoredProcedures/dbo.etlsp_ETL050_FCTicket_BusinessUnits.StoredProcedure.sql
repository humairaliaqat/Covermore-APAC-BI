USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL050_FCTicket_BusinessUnits]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL050_FCTicket_BusinessUnits]
as
begin

    set nocount on

    declare 
        @sql varchar(max),
        @filename varchar(max),
        @filedate date


    if object_id('[db-au-cmdwh].dbo.fltBusinessUnits') is null
    begin

        create table [db-au-cmdwh].dbo.fltBusinessUnits
        (
            BIRowID bigint not null identity(1,1),
            BusinessUnitID bigint,
            BusinessName varchar(255),
            Company varchar(50),
            OpenDate date,
            CloseDate date,
            BusinessType varchar(50),
            T3Code varchar(15),
            AlphaCode nvarchar(20),
            OutletKey varchar(33),
            PseudoCode varchar(15),
            Suburb varchar(100),
            State varchar(100),
            Country varchar(100),
            PostCode varchar(10),
            FCBrand varchar(100),
            FCDisipline varchar(100),
            FCVillage varchar(100),
            FCDivision varchar(100),
            FCRegion varchar(100),
            FCCountry varchar(100),
            DataDate date,
            FileDate date
        )

        create unique clustered index idx_fltBusinessUnits_BIRowID on [db-au-cmdwh].dbo.fltBusinessUnits (BIRowID)
        create nonclustered index idx_fltBusinessUnits_BusinessUnitID on [db-au-cmdwh].dbo.fltBusinessUnits (BusinessUnitID) include (AlphaCode,OutletKey,DataDate)

    end


    if object_id('tempdb..#filelist') is not null
        drop table #filelist

    create table #filelist
    (
        filenames varchar(max)
    )

    declare
        c_files cursor local for
            select 
                FileNames,
                try_convert(date, right(left(filenames, charindex('.', filenames) - 1), 8)) FileDate
            from
                #filelist
            where
                filenames is not null and
                filenames <> 'File Not Found'
            order by
                convert(date, right(left(filenames, charindex('.', filenames) - 1), 8)) desc

    truncate table #filelist

    insert into #filelist (filenames)
    exec xp_cmdshell 'dir "E:\ETL\Data\Flight Centre\Process\FLT_*BUSINESS_UNIT*.csv" /b'


    --iterate csv files

    open c_files

    fetch next from c_files into @filename, @filedate

    while @@fetch_status = 0
    begin

        print @filename
        print @filedate

        if object_id('[db-au-stage].[dbo].[etl_fltBusinessUnit]') is not null
            drop table [db-au-stage].[dbo].[etl_fltBusinessUnit]

        create table [db-au-stage].[dbo].[etl_fltBusinessUnit]
        (
            DimBusinessUnitId varchar(255),
            BusinessUnitId varchar(255),
            Business_Name varchar(255),
            Legal_Entity_Name varchar(255),
            Business_Open_Date varchar(255),
            Business_Close_Date varchar(255),
            BusinessType varchar(255),
            T3_Code varchar(255),
            Board_Report_Name varchar(255),
            Pseudo_Code varchar(255),
            Locality_Suburb varchar(255),
            State_Province varchar(255),
            Post_Code varchar(255),
            Brand_Name varchar(255),
            Discipline_Name varchar(255),
            Village_Name varchar(255),
            Division_Name varchar(255),
            Region_Name varchar(255),
            CountryNm varchar(255),
            Company_Name varchar(255),
            Nation_Name varchar(255),
            Group_Name varchar(255),
            Effective_From_Date varchar(255),
            Effective_To_Date varchar(255),
            Is_Current varchar(255)
			--,
            --ETLAuditId varchar(255),
            --HashId varchar(255)
        )

        exec xp_cmdshell 'del "E:\ETL\Data\Flight Centre\Process\LOAD_BU.csv"'

        set @sql = 'exec xp_cmdshell ''copy "E:\ETL\Data\Flight Centre\Process\' + @filename + '" "E:\ETL\Data\Flight Centre\Process\LOAD_BU.csv"'''
        print @sql
        exec (@sql)

        bulk insert [db-au-stage].[dbo].[etl_fltBusinessUnit]
        from 'E:\ETL\Data\Flight Centre\Process\LOAD_BU.csv'
        with
        (
            codepage = '1252',
            fieldterminator = ',',
            rowterminator = '\n',
            firstrow = 2,
            check_constraints
        ) 

        if object_id('tempdb..#fltBusinessUnits') is not null
            drop table #fltBusinessUnits

        ;with 
        cte_unquoted as
        (
            select 
                replace(BusinessUnitID, '"', '') BusinessUnitID,
                replace(Business_Name, '"', '') BusinessName,
                replace(Company_Name, '"', '') Company,
                replace(Business_Open_Date, '"', '') OpenDate,
                replace(Business_Close_Date, '"', '') CloseDate,
                replace(BusinessType, '"', '') BusinessType,
                replace(T3_Code, '"', '') T3Code,
                replace(Pseudo_Code, '"', '') PseudoCode,
                replace(Locality_Suburb, '"', '') Suburb,
                replace(State_Province, '"', '') State,
                replace(Nation_Name, '"', '') Country,
                replace(Post_Code, '"', '') PostCode,
                replace(Brand_Name, '"', '') FCBrand,
                replace(Discipline_Name, '"', '') FCDisipline,
                replace(Village_Name, '"', '') FCVillage,
                replace(Division_Name, '"', '') FCDivision,
                replace(Region_Name, '"', '') FCRegion,
                replace(CountryNm, '"', '') FCCountry,
                replace(Effective_From_Date, '"', '') DataDate
            from
                [etl_fltBusinessUnit]
            where
                Is_Current = '"True"'
        ),
        cte_formatted as
        (
            select 
                case
                    when Country = 'NEW ZEALAND' then 'NZ'
                    when Country = 'AUSTRALIA' then 'AU'
                    else null
                end Domain,
                try_convert(bigint, BusinessUnitID) BusinessUnitID,
                BusinessName,
                Company,
                try_convert(date, OpenDate) OpenDate,
                case
                    when CloseDate = '' then null
                    else try_convert(date, CloseDate) 
                end CloseDate,
                BusinessType,
                T3Code,
                PseudoCode,
                Suburb,
                State,
                Country,
                PostCode,
                FCBrand,
                FCDisipline,
                FCVillage,
                FCDivision,
                FCRegion,
                FCCountry,
                try_convert(date, DataDate) DataDate
            from
                cte_unquoted
        )
        select 
            t.*
        into #fltBusinessUnits
        from
            cte_formatted t


        merge into [db-au-cmdwh].dbo.fltBusinessUnits t
        using #fltBusinessUnits s on
            s.BusinessUnitID = t.BusinessUnitID

        when matched and s.DataDate > t.DataDate then
            update
            set
                BusinessName = s.BusinessName,
                Company = s.Company,
                OpenDate = s.OpenDate,
                CloseDate = s.CloseDate,
                BusinessType = s.BusinessType,
                T3Code = s.T3Code,
                PseudoCode = s.PseudoCode,
                Suburb = s.Suburb,
                State = s.State,
                Country = s.Country,
                PostCode = s.PostCode,
                FCBrand = s.FCBrand,
                FCDisipline = s.FCDisipline,
                FCVillage = s.FCVillage,
                FCDivision = s.FCDivision,
                FCRegion = s.FCRegion,
                FCCountry = s.FCCountry,
                DataDate = s.DataDate,
                FileDate = @filedate

        when not matched by target then
            insert
            (
                BusinessUnitID,
                BusinessName,
                Company,
                OpenDate,
                CloseDate,
                BusinessType,
                T3Code,
                PseudoCode,
                Suburb,
                State,
                Country,
                PostCode,
                FCBrand,
                FCDisipline,
                FCVillage,
                FCDivision,
                FCRegion,
                FCCountry,
                DataDate,
                FileDate
            )
            values
            (
                s.BusinessUnitID,
                s.BusinessName,
                s.Company,
                s.OpenDate,
                s.CloseDate,
                s.BusinessType,
                s.T3Code,
                s.PseudoCode,
                s.Suburb,
                s.State,
                s.Country,
                s.PostCode,
                s.FCBrand,
                s.FCDisipline,
                s.FCVillage,
                s.FCDivision,
                s.FCRegion,
                s.FCCountry,
                s.DataDate,
                @filedate
            )
        ;

        update t
        set
            AlphaCode = isnull(o.AlphaCode, map.AlphaCode),
            OutletKey = isnull(o.OutletKey, map.OutletKey)
        from
            [db-au-cmdwh].dbo.fltBusinessUnits t
            cross apply
            (
                select
                    case
                        when Country = 'NEW ZEALAND' then 'NZ'
                        when Country = 'AUSTRALIA' then 'AU'
                        else null
                    end Domain
            ) dm
            outer apply
            (
                select top 1 
                    o.AlphaCode,
                    o.OutletKey
                from
                    [db-au-cmdwh]..penOutlet o with(nolock)
                where
                    o.CountryKey = dm.Domain and
                    o.OutletStatus = 'Current' and
                    o.GroupCode = 'FL' and
                    (
                        o.ExtID = t.T3Code or
                        (
                            t.PseudoCode <> '' and
                            o.ExtID = t.PseudoCode
                        ) or
                        (
                            o.ContactPostCode = t.PostCode and
                            o.ContactMailSuburb = t.Suburb and
                            o.OutletName like '%' + rtrim(ltrim(replace(replace(t.BusinessName, t.FCBrand, ''), t.State, ''))) + '%'
                        ) 
                    )
            ) o
            outer apply
            (
                select top 1 
                    m.AlphaCode,
                    mo.OutletKey
                from
                    [db-au-cmdwh]..usrFCT3Mapping m with(nolock)
                    inner join [db-au-cmdwh]..penOutlet mo with(nolock) on
                        mo.CountryKey = m.Country and
                        mo.AlphaCode = m.AlphaCode and
                        mo.OutletStatus = 'Current' and
                        mo.GroupCode = 'FL'
                where
                    m.Country = dm.Domain and
                    m.T3Code = t.T3Code
            ) map
        where
            t.AlphaCode is null and
            isnull(o.AlphaCode, map.AlphaCode) is not null


        set @sql = 'exec xp_cmdshell ''move /Y "E:\ETL\Data\Flight Centre\Process\' + @filename + '" "E:\ETL\Data\Flight Centre\Archive"'''
        print @sql
        exec (@sql)

        fetch next from c_files into @filename, @filedate

    end

    close c_files
    deallocate c_files

end
GO
