USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[clmSecheque_ASP372]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmSecheque_ASP372](
	[CountryKey] [varchar](2) NOT NULL,
	[ClaimKey] [varchar](40) NULL,
	[ChequeKey] [varchar](40) NULL,
	[PayeeKey] [varchar](40) NULL,
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
	[BatchNo] [int] NULL,
	[PaymentMethodID] [int] NULL,
	[isBounced] [bit] NULL,
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[PaymentDateTimeUTC] [datetime] NULL
) ON [PRIMARY]
GO
