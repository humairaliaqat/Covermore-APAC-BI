USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL095_CardVolume]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [dbo].[etlsp_ETL095_CardVolume]
as
begin

    --execute
    --(
    --    'exec xp_cmdshell "del e:\etl\data\card_volume.xlsx"'
    --)  at [BHDWH03]

    --waitfor delay '00:00:03'

    execute
    (
        'exec xp_cmdshell ''copy "\\aust.covermore.com.au\data\NorthSydney_data\Business Intelligence Share\Atlas\Finance\Card Volume.xlsx" e:\etl\data\card_volume.xlsx /Y''' -- CHG0036692
    )  at [BHDWH03]

    waitfor delay '00:00:07'

    if object_id('[db-au-cmdwh]..usrCardVolume') is null
    begin
    
        create table [db-au-cmdwh]..usrCardVolume
        (
            [BIRowID] bigint identity(1,1),
            [Bank] varchar(50),
            [CC Type] varchar(250),
            [CC Group] varchar(250),
            [Reference Date] date,
            [Card Volume] int,
            [ITI] decimal(10,2),
            [EW] decimal(10,2),
            [PS] decimal(10,2),
            [GP] decimal(10,2),
            [TA] decimal(10,2),
            [STA] decimal(10,2),
            [IFI] decimal(10,2),
            [UT] decimal(10,2),
            [NAC Other] decimal(10,2)
        )

        create unique clustered index cidx on [db-au-cmdwh]..usrCardVolume (BIrowID)

    end
    else
        truncate table [db-au-cmdwh]..usrCardVolume

    insert into [db-au-cmdwh]..usrCardVolume
    (
        [Bank],
        [CC Type],
        [CC Group],
        [Reference Date],
        [Card Volume],
        [ITI],
        [EW],
        [PS],
        [GP],
        [TA],
        [STA],
        [IFI],
        [UT],
        [NAC Other]
    )
    select
        [Bank],
        [CC Type],
        [Retail/Business],
        [As at Date],
        [Card Volume],
        [ITI],
        [EW],
        [PS],
        [GP],
        [TA],
        [STA],
        [IFI],
        [UT],
        [NAC-Other]
    from
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;Database=\\bhdwh03\etl\data\card_volume.xlsx',
            '
            select 
                *
            from 
                [Card Volume & Rate$]
            '
        )

end
GO
