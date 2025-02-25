USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_emcAuditPayment]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_emcAuditPayment](
	[CountryKey] [varchar](2) NULL,
	[ApplicationKey] [varchar](15) NULL,
	[AuditPaymentKey] [varchar](15) NULL,
	[ApplicationID] [int] NULL,
	[AuditPaymentID] [int] NOT NULL,
	[OrderID] [varchar](50) NULL,
	[AuditDate] [datetime] NULL,
	[AuditUserLogin] [varchar](255) NULL,
	[AuditUser] [varchar](50) NULL,
	[AuditAction] [varchar](10) NULL,
	[PaymentDate] [datetime] NULL,
	[EMCPremium] [float] NOT NULL,
	[AgePremium] [float] NOT NULL,
	[Excess] [float] NOT NULL,
	[GeneralLimit] [float] NOT NULL,
	[PaymentDuration] [varchar](10) NULL,
	[RestrictedConditions] [varchar](255) NULL,
	[OtherRestrictions] [varchar](255) NULL,
	[PaymentComments] [varchar](1000) NULL,
	[Surname] [varchar](22) NULL,
	[CardType] [varchar](6) NULL,
	[GST] [money] NOT NULL,
	[MerchantID] [varchar](16) NULL,
	[ReceiptNo] [varchar](50) NULL,
	[TransactionResponseCode] [varchar](5) NULL,
	[ACQResponseCode] [varchar](50) NULL,
	[TransactionStatus] [varchar](100) NULL
) ON [PRIMARY]
GO
