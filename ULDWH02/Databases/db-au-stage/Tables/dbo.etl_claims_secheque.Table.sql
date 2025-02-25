USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_claims_secheque]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_claims_secheque](
	[CountryKey] [varchar](2) NULL,
	[ClaimKey] [varchar](33) NULL,
	[ChequeKey] [varchar](64) NULL,
	[PayeeKey] [varchar](64) NULL,
	[ChequeID] [int] NOT NULL,
	[ChequeNo] [bigint] NULL,
	[ClaimNo] [int] NULL,
	[Status] [varchar](10) NULL,
	[TransactionType] [varchar](4) NULL,
	[Currency] [varchar](4) NULL,
	[Amount] [money] NULL,
	[isManual] [bit] NOT NULL,
	[PayeeID] [int] NULL,
	[AddresseeID] [int] NULL,
	[AccountID] [int] NULL,
	[ReasonCategoryID] [int] NULL,
	[PaymentDate] [datetime] NULL,
	[PaymentDateTimeUTC] [datetime] NULL,
	[BatchNo] [int] NULL,
	[PaymentMethodID] [int] NULL,
	[isBounced] [bit] NULL
) ON [PRIMARY]
GO
