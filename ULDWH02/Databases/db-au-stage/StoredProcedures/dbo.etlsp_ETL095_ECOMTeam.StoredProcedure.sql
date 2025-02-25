USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL095_ECOMTeam]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [dbo].[etlsp_ETL095_ECOMTeam]
as
begin

    --execute
    --(
    --    'exec xp_cmdshell "del e:\etl\data\ecom_team.xlsx"'
    --)  at [BHDWH03]

    --waitfor delay '00:00:03'

    execute
    (
        'exec xp_cmdshell ''copy "\\aust.covermore.com.au\data\NorthSydney_data\Business Intelligence Share\EIPINTRANET files_ETL095\ECOM\DS Teams.xlsx" e:\etl\data\ecom_team.xlsx /Y''' -- CHG0036692
    )  at [BHDWH03]

    waitfor delay '00:00:07'

    if object_id('[db-au-cmdwh]..usrECOMTeam') is null
    begin
    
        create table [db-au-cmdwh]..usrECOMTeam
        (
            [BIRowID] bigint identity(1,1),
            [Strategist] varchar(250),
            [Country Code] varchar(250),
            [Super Group Name] varchar(250),
            [Group Name] varchar(250),
            [Sub Group Name] varchar(250)
        )

        create index idx on [db-au-cmdwh]..usrECOMTeam ([Country Code],[Super Group Name],[Group Name],[Sub Group Name]) include ([Strategist])

    end
    else
        truncate table [db-au-cmdwh]..usrECOMTeam

    insert into [db-au-cmdwh]..usrECOMTeam
    (
        [Strategist],
        [Country Code],
        [Super Group Name],
        [Group Name],
        [Sub Group Name]
    )
    select
        [Strategist],
        [Country Code],
        [Super Group Name],
        [Group Name],
        [Sub Group Name]
    from
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;Database=\\bhdwh03\etl\data\ecom_team.xlsx',
            '
            select 
                *
            from 
                [Team$]
            '
        )

end
GO
