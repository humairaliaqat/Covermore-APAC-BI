USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL095_CaseFeeMapping]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [dbo].[etlsp_ETL095_CaseFeeMapping]
as
begin

/************************************************************************************************************************************
Author:         Saurabh Date
Date:           20190327
Description:    This script reads the CaseFee.xlsx file from sharepoint path, and updates the CaseFee mapping data accordingly.
Change History:
                20190327 - SD - Procedure created
				30/11/2022 - CHG0036692
Change Description: Move all dependent resources out of the old EIP Intranet location to the new location \\aust.covermore.com.au\data\NorthSydney_data\Business Intelligence Share, 
due to the decommissioning of EIP Intranet.
*************************************************************************************************************************************/

    execute
    (
        'exec xp_cmdshell ''copy "\\aust.covermore.com.au\data\NorthSydney_data\Business Intelligence Share\Atlas\Finance\CaseFee.xlsx" e:\etl\data\CaseFee.xlsx /Y''' -- CHG0036692
    )  at [BHDWH03]

    waitfor delay '00:00:07'

    if object_id('[db-au-cmdwh].[dbo].[cbCaseTypeFee]') is null
    begin

        create table [db-au-cmdwh].[dbo].[cbCaseTypeFee]
        (
			BIRowID bigint not null identity(1,1),
			FeeID int NOT NULL,
			ClientCode nvarchar(2) NOT NULL,
			ProgramType nvarchar(2) NULL,
			ProgramDescription nvarchar(255) NULL,
			Channel nvarchar(250) NULL,
			CaseType nvarchar(255) NULL,
			Protocol nvarchar(250) NULL,
			Fee money NULL,
			Tax money NULL
        ) ON [PRIMARY]

        create unique clustered index ucidx_cbCaseTypeFee on [db-au-cmdwh].[dbo].[cbCaseTypeFee](BIRowID)
        

    end
    else
        truncate table [db-au-cmdwh].[dbo].cbCaseTypeFee

	insert into [db-au-cmdwh]..cbCaseTypeFee
	(
		FeeID,
		ClientCode,
		ProgramDescription,
		[Channel],
		CaseType,
		[Protocol],
		Fee,
		Tax
	)

	select 
		-1 FeeID,
		[Client Code] ClientCode,
		[Name] ProgramDescription,
		[Channel],
		[Case Type] CaseType,
		[Protocol],
		[Case Fee] Fee,
		[GST] Tax
	from
		openrowset
		(
			'Microsoft.ACE.OLEDB.12.0',
			'Excel 12.0 Xml;HDR=YES;Database=\\bhdwh03\etl\data\CaseFee.xlsx',
			'
			select 
				*
			from 
				[CaseFee list$]
			'
		)


	 if object_id('[db-au-cmdwh].[dbo].[usrCBCaseFee]') is null
    begin

        create table [db-au-cmdwh].[dbo].[usrCBCaseFee]
        (
			 BIRowID  bigint IDENTITY(1,1) NOT NULL,
			 CountryKey  varchar(2) NULL,
			 ClientCode  varchar(2) NULL,
			 ProgramCode  varchar(2) NULL,
			 FeeDescription  varchar(100) NULL,
			 BusinessUnit  varchar(50) NULL,
			 DebtorsCode  varchar(30) NULL,
			 Quotation  varchar(50) NULL,
			 SimpleMedicalCaseFee  money NOT NULL,
			 SimpleTechnicalCaseFee  money NOT NULL,
			 MediumMedicalCaseFee  money NOT NULL,
			 MediumTechnicalCaseFee  money NOT NULL,
			 ComplexMedicalCaseFee  money NOT NULL,
			 ComplexTechnicalCaseFee  money NOT NULL,
			 EvacuationCaseFee  money NOT NULL,
			 GST  numeric(5, 2) NOT NULL
        ) ON [PRIMARY]

        create unique clustered index ucidx_usrCBCaseFee on [db-au-cmdwh].[dbo].[usrCBCaseFee](BIRowID)
       
    end
    else
        truncate table [db-au-cmdwh].[dbo].usrCBCaseFee

	insert into [db-au-cmdwh]..usrCBCaseFee
		(
			ClientCode,
			ProgramCode,
			DebtorsCode
		)
		select distinct
			[Client Code] ClientCode,
			[Program Type] ProgramCode,
			[Debtor Code] DebtorsCode
		from
			openrowset
			(
				'Microsoft.ACE.OLEDB.12.0',
				'Excel 12.0 Xml;HDR=YES;Database=\\bhdwh03\etl\data\CaseFee.xlsx',
				'
				select 
					*
				from 
					[CaseFee DebtorCode$]
				'
			)



end
GO
