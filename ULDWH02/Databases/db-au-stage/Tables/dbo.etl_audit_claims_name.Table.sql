USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_audit_claims_name]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_audit_claims_name](
	[CountryKey] [varchar](2) NULL,
	[AuditKey] [varchar](8000) NULL,
	[NameKey] [varchar](64) NULL,
	[ClaimKey] [varchar](33) NULL,
	[AuditUserName] [varchar](255) NULL,
	[AuditDateTime] [datetime] NULL,
	[AuditDateTimeUTC] [datetime] NULL,
	[AuditAction] [varchar](10) NULL,
	[NameID] [int] NOT NULL,
	[ClaimNo] [int] NULL,
	[Num] [smallint] NULL,
	[Surname] [nvarchar](100) NULL,
	[Firstname] [nvarchar](100) NULL,
	[Title] [nvarchar](50) NULL,
	[DOB] [date] NULL,
	[AddressStreet] [nvarchar](100) NULL,
	[AddressSuburb] [nvarchar](50) NULL,
	[AddressState] [nvarchar](100) NULL,
	[AddressCountry] [nvarchar](100) NULL,
	[AddressPostCode] [nvarchar](50) NULL,
	[HomePhone] [nvarchar](50) NULL,
	[WorkPhone] [nvarchar](50) NULL,
	[Fax] [varchar](20) NULL,
	[Email] [nvarchar](255) NULL,
	[isDirectCredit] [bit] NOT NULL,
	[AccountNo] [varchar](20) NULL,
	[AccountName] [nvarchar](100) NULL,
	[BSB] [varchar](6) NULL,
	[isPrimary] [bit] NOT NULL,
	[isThirdParty] [bit] NOT NULL,
	[isForeign] [bit] NOT NULL,
	[ProviderID] [int] NULL,
	[BusinessName] [varchar](30) NULL,
	[isEmailOK] [bit] NULL,
	[PaymentMethodID] [int] NULL,
	[EMC] [nvarchar](100) NULL,
	[ITC] [bit] NULL,
	[ITCPCT] [float] NULL,
	[isGST] [bit] NULL,
	[GSTPercentage] [float] NULL,
	[GoodsSupplier] [bit] NULL,
	[ServiceProvider] [bit] NULL,
	[SupplyBy] [int] NULL,
	[EncryptAccount] [varbinary](256) NULL,
	[EncryptBSB] [varbinary](256) NULL,
	[isPayer] [bit] NULL,
	[BankName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
