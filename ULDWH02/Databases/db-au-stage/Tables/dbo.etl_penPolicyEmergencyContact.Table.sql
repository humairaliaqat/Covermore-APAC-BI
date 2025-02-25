USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyEmergencyContact]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyEmergencyContact](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PolicyKey] [varchar](71) NULL,
	[PolicyTransactionKey] [varchar](71) NULL,
	[DomainID] [int] NOT NULL,
	[PolicyNumber] [varchar](25) NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[SurName] [nvarchar](100) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[MobilePhone] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedDateUTC] [datetime] NULL
) ON [PRIMARY]
GO
