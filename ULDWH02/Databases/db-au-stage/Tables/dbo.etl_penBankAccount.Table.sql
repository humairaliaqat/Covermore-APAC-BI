USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penBankAccount]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penBankAccount](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[BankAccountKey] [varchar](71) NULL,
	[BankAccountID] [tinyint] NOT NULL,
	[CompanyID] [tinyint] NOT NULL,
	[DomainID] [int] NOT NULL,
	[AccountName] [varchar](255) NOT NULL,
	[AccountCode] [varchar](6) NOT NULL,
	[AccountBSB] [varchar](10) NULL,
	[AccountNumber] [varchar](30) NOT NULL,
	[AccountStatus] [varchar](15) NOT NULL,
	[AccountStartDate] [datetime] NOT NULL,
	[AccountEndDate] [datetime] NULL,
	[AccountCreateDateTime] [datetime] NULL,
	[AccountUpdateDateTime] [datetime] NULL,
	[AccountCreateDateTimeUTC] [datetime] NOT NULL,
	[AccountUpdateDateTimeUTC] [datetime] NOT NULL,
	[CompanyName] [varchar](255) NOT NULL,
	[CompanyFullName] [varchar](255) NULL,
	[CompanyCode] [varchar](3) NOT NULL,
	[Underwriter] [varchar](255) NULL,
	[CompanyABN] [varchar](50) NULL,
	[CompanyStatus] [varchar](15) NOT NULL,
	[CompanyCreateDateTime] [datetime] NULL,
	[CompanyUpdateDateTime] [datetime] NULL,
	[CompanyCreateDateTimeUTC] [datetime] NOT NULL,
	[CompanyUpdateDateTimeUTC] [datetime] NOT NULL,
	[PaymentProcessAgentID] [tinyint] NOT NULL,
	[PaymentProcessAgentName] [varchar](55) NOT NULL,
	[PaymentProcessAgentCode] [varchar](3) NOT NULL,
	[PaymentProcessAgentStatus] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
