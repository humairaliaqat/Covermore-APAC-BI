USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblBankAccount_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblBankAccount_uscm](
	[BankAccountId] [tinyint] NOT NULL,
	[AccountName] [varchar](255) NOT NULL,
	[Code] [varchar](6) NOT NULL,
	[BSB] [varchar](10) NULL,
	[AccountNumber] [varchar](30) NOT NULL,
	[CompanyId] [tinyint] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
