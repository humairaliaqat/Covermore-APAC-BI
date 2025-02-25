USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL095_CallMapping]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [dbo].[etlsp_ETL095_CallMapping]
as
begin

    execute
    (
        'exec xp_cmdshell ''copy "\\aust.covermore.com.au\data\NorthSydney_data\Business Intelligence Share\EIPINTRANET files_ETL095\Telephony\Call Mapping.xlsx" e:\etl\data\callmapping.xlsx /Y''' -- CHG0036692
    )  at [BHDWH03]

    waitfor delay '00:00:07'

    if object_id('[db-au-cmdwh]..usrCallMapping') is null
    begin
    
        create table [db-au-cmdwh]..usrCallMapping
        (
            [BIRowID] bigint identity(1,1),
            [Answer Point] nvarchar(30),
            [Call Classification] varchar(250),
            [Call Type] varchar(50),
            [Agent Group] varchar(50),
            [Caller] varchar(50),
            [Team Type] varchar(50),
            [Start Date] date,
            [End Date] date
        )

        create unique clustered index cidx on [db-au-cmdwh]..usrCallMapping ([BIRowID])
        create index idx on [db-au-cmdwh]..usrCallMapping ([Answer Point],[Start Date],[End Date]) include ([Call Classification],[Call Type],[Agent Group],[Caller],[Team Type])

    end
    else
        truncate table [db-au-cmdwh]..usrCallMapping

    insert into [db-au-cmdwh]..usrCallMapping
    (
        [Answer Point],
        [Call Classification],
        [Call Type],
        [Agent Group],
        [Caller],
        [Team Type],
        [Start Date],
        [End Date]
    )
    select
        [Answer Point],
        [Call Classification],
        [Call Type],
        [Agent Group],
        [Caller],
        [Team Type],
        [Start Date],
        [End Date]
    from
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;Database=\\bhdwh03\etl\data\callmapping.xlsx',
            '
            select 
                *
            from 
                [Call Mapping$]
            '
        )
    where
        isnull(ltrim(rtrim([Answer Point])), '') not in ('', 'do not remove this line')

end
GO
