USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emcPayment]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcPayment](
	[CountryKey] [varchar](2) NOT NULL,
	[ApplicationKey] [varchar](15) NOT NULL,
	[PaymentKey] [varchar](15) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[PaymentID] [int] NOT NULL,
	[OrderID] [varchar](50) NULL,
	[PaymentDate] [datetime] NULL,
	[EMCPremium] [decimal](18, 2) NOT NULL,
	[AgePremium] [decimal](18, 2) NOT NULL,
	[Excess] [decimal](18, 2) NOT NULL,
	[GeneralLimit] [decimal](18, 2) NOT NULL,
	[PaymentDuration] [varchar](15) NULL,
	[RestrictedConditions] [varchar](255) NULL,
	[OtherRestrictions] [varchar](255) NULL,
	[PaymentComments] [varchar](1000) NULL,
	[Surname] [varchar](22) NULL,
	[CardType] [varchar](6) NULL,
	[GST] [decimal](18, 2) NOT NULL,
	[MerchantID] [varchar](16) NULL,
	[ReceiptNo] [varchar](50) NULL,
	[TransactionResponseCode] [varchar](5) NULL,
	[ACQResponseCode] [varchar](50) NULL,
	[TransactionStatus] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcPayment_ApplicationKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcPayment_ApplicationKey] ON [dbo].[emcPayment]
(
	[ApplicationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcPayment_PaymentDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcPayment_PaymentDate] ON [dbo].[emcPayment]
(
	[PaymentDate] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
