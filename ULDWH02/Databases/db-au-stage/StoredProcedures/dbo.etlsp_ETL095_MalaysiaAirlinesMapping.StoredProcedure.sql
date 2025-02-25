USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL095_MalaysiaAirlinesMapping]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [dbo].[etlsp_ETL095_MalaysiaAirlinesMapping]
as
begin

    execute
    (
        'exec xp_cmdshell ''copy "\\aust.covermore.com.au\data\NorthSydney_data\Business Intelligence Share\EIPINTRANET files_ETL095\Malaysia\MA Products.xlsx" e:\etl\data\MAProducts.xlsx /Y''' -- CHG0036692
    )  at [BHDWH03]

    waitfor delay '00:00:05'

    if object_id('[db-au-cmdwh].[dbo].[usrMYMAProductMapping]') is null
    begin

        create table [db-au-cmdwh].[dbo].[usrMYMAProductMapping]
        (
            BIRowID bigint not null identity(1,1),
            Domain varchar(5),
            AreaType varchar(255),
            TripType varchar(255),
            PlanName varchar(255),
            ProductCode varchar(255)
        )

        create unique clustered index ucidx_usrMYMAProductMapping on [db-au-cmdwh].[dbo].[usrMYMAProductMapping](BIRowID)
        create index idx_usrMYMAProductMapping_Lookup on [db-au-cmdwh].[dbo].[usrMYMAProductMapping](Domain,AreaType,TripType,PlanName,ProductCode)

    end
    else
        truncate table [db-au-cmdwh].[dbo].usrMYMAProductMapping

    insert into [db-au-cmdwh].[dbo].usrMYMAProductMapping
    (
        Domain,
        AreaType,
        TripType,
        PlanName,
        ProductCode
    )
    select 
        Domain,
        AreaType,
        TripType,
        PlanName,
        ProductCode
    from
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;Database=\\bhdwh03\etl\data\MAProducts.xlsx',
            '
            select 
                *
            from 
                [Product$]
            '
        )
    where
        Domain is not null


end
GO
