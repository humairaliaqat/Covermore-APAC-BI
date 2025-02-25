USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [ws].[spReloadGLMFactors]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ws].[spReloadGLMFactors]
as
begin

    if object_id('[db-au-actuary].ws.GLMFactors') is null
    begin
        
        create table [db-au-actuary].ws.GLMFactors
        (
            BIRowID bigint not null identity(1,1),
            [Factor Name] varchar(255),
            [Factor Level] varchar(500),
            [Estimate Value] decimal(30,10),
            constraint [PK_GLMFactors] primary key clustered (BIRowID)
        )
    
        create nonclustered index idx_factor on [db-au-actuary].ws.GLMFactors ([Factor Name],[Factor Level]) include ([Estimate Value])

    end
    else
        truncate table [db-au-actuary].ws.GLMFactors

    insert into [db-au-actuary].ws.GLMFactors
    (
        [Factor Name],
        [Factor Level],
        [Estimate Value]
    )
    select 
        [Factor Name],
        [Factor Level],
        [Estimate Value]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Factor$]
            '
        )


    if object_id('[db-au-actuary].ws.GLMMapping') is null
    begin
        
        create table [db-au-actuary].ws.GLMMapping
        (
            BIRowID bigint not null identity(1,1),
            [Factor Name] varchar(255),
            [Original Value] varchar(500),
            [Mapped Value] varchar(500),
            constraint [PK_GLMMapping] primary key clustered (BIRowID)
        )
    
        create nonclustered index idx_factor on [db-au-actuary].ws.GLMMapping ([Factor Name],[Original Value]) include ([Mapped Value])

    end
    else
        truncate table [db-au-actuary].ws.GLMMapping

    insert into [db-au-actuary].ws.GLMMapping
    (
        [Factor Name],
        [Original Value],
        [Mapped Value]
    )
    select 
        'Country Group' [Factor Name],
        [Country],
        [Label]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Country Group$]
            '
        )

    insert into [db-au-actuary].ws.GLMMapping
    (
        [Factor Name],
        [Original Value],
        [Mapped Value]
    )
    select 
        'Product Group' [Factor Name],
        [Product Code],
        [Product Group]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Product Group$]
            '
        )

    insert into [db-au-actuary].ws.GLMMapping
    (
        [Factor Name],
        [Original Value],
        [Mapped Value]
    )
    select 
        'JV Group' [Factor Name],
        [JV],
        [JV Group] 
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [JV Group$]
            '
        )
        
    insert into [db-au-actuary].ws.GLMMapping
    (
        [Factor Name],
        [Original Value],
        [Mapped Value]
    )
    select 
        'Plan Type' [Factor Name],
        [Plan Type],
        [Plan Type Label]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Plan Type$]
            '
        )

    if object_id('[db-au-actuary].ws.GLMBanding') is null
    begin
        
        create table [db-au-actuary].ws.GLMBanding
        (
            BIRowID bigint not null identity(1,1),
            [Factor Name] varchar(255),
            [Minimum Value] decimal(16,6),
            [Maximum Value] decimal(16,6),
            [Band] varchar(500),
            constraint [PK_GLMBanding] primary key clustered (BIRowID)
        )
    
        create nonclustered index idx_factor on [db-au-actuary].ws.GLMBanding ([Factor Name],[Minimum Value],[Maximum Value]) include ([Band])

    end
    else
        truncate table [db-au-actuary].ws.GLMBanding

    insert into [db-au-actuary].ws.GLMBanding
    (
        [Factor Name],
        [Minimum Value],
        [Maximum Value],
        [Band]
    )
    select 
        'Age Band' [Factor Name],
        [Min Age],
        [Max Age],
        [Age Band]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Age Band$]
            '
        )

    insert into [db-au-actuary].ws.GLMBanding
    (
        [Factor Name],
        [Minimum Value],
        [Maximum Value],
        [Band]
    )
    select 
        'Lead Time Band' [Factor Name],
        [Min Lead Time],
        [Max Lead Time],
        [Lead Time Band]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Lead Time Band$]
            '
        )

    insert into [db-au-actuary].ws.GLMBanding
    (
        [Factor Name],
        [Minimum Value],
        [Maximum Value],
        [Band]
    )
    select 
        'Trip Length Band' [Factor Name],
        [Min Trip Length],
        [Max Trip Length],
        [Trip Length Band]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Trip Length Band$]
            '
        )

    insert into [db-au-actuary].ws.GLMBanding
    (
        [Factor Name],
        [Minimum Value],
        [Maximum Value],
        [Band]
    )
    select 
        'Traveller Count Band' [Factor Name],
        [Min],
        [Max],
        [Band]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Traveller Count Band$]
            '
        )

    insert into [db-au-actuary].ws.GLMBanding
    (
        [Factor Name],
        [Minimum Value],
        [Maximum Value],
        [Band]
    )
    select 
        'AMT Trip Length Band' [Factor Name],
        [Min AMT Trip Length],
        [Max AMT Trip Length],
        [AMT Trip Length Band]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [AMT Trip Length Band$]
            '
        )

    insert into [db-au-actuary].ws.GLMBanding
    (
        [Factor Name],
        [Minimum Value],
        [Maximum Value],
        [Band]
    )
    select 
        'Excess Band' [Factor Name],
        [Min Excess],
        [Max Excess],
        [Excess Band]
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GLM Master Data.xlsx',
            '
            select 
                *
            from 
                [Excess Band$]
            '
        )


end
GO
