USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL095_FCUSMapping]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [dbo].[etlsp_ETL095_FCUSMapping]
as
begin

    execute
    (
        'exec xp_cmdshell ''copy "\\aust.covermore.com.au\data\NorthSydney_data\Business Intelligence Share\EIPINTRANET files_ETL095\FC US\Master CM FC US Mapping.xlsx" e:\etl\data\MasterCMFCUSMapping.xlsx /Y''' -- CHG0036692
    )  at [BHDWH03]

    waitfor delay '00:00:07'

    if object_id('[db-au-cmdwh].[dbo].[usrFCUSMapping]') is null
    begin

        create table [db-au-cmdwh].[dbo].[usrFCUSMapping]
        (
			BIRowID bigint not null identity(1,1),
			AlphaCode varchar(50),
			BDMName varchar(100),
			Region varchar(100),
			Brand varchar(100),
			TeamName varchar(100)
        ) ON [PRIMARY]

        create unique clustered index ucidx_usrFCUSMapping on [db-au-cmdwh].[dbo].[usrFCUSMapping](BIRowID)
        

    end
    else
        truncate table [db-au-cmdwh].[dbo].usrFCUSMapping

    insert into [db-au-cmdwh].[dbo].usrFCUSMapping
	(
		AlphaCode,
		BDMName,
		Region,
		Brand,
		TeamName
	)
	select 
		AlphaCode,
		BDMName,
		Region,
		Brand,
		TeamName
	from
		openrowset
		(
			'Microsoft.ACE.OLEDB.12.0',
			'Excel 12.0 Xml;HDR=YES;Database=\\bhdwh03\etl\data\MasterCMFCUSMapping.xlsx',
			'
			select 
				*
			from 
				[FCUS$]
			'
		)

end
GO
