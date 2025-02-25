USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmSecheque]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmSecheque](
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
/****** Object:  Index [idx_clmSecheque_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_clmSecheque_BIRowID] ON [dbo].[clmSecheque]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmSecheque_ChequeKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmSecheque_ChequeKey] ON [dbo].[clmSecheque]
(
	[ChequeKey] ASC
)
INCLUDE([TransactionType],[Status],[PaymentDate],[Amount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmSecheque_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmSecheque_ClaimKey] ON [dbo].[clmSecheque]
(
	[ClaimKey] ASC
)
INCLUDE([PayeeKey],[ClaimNo],[PayeeID],[TransactionType],[Status],[PaymentDate],[Amount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmSecheque_PaymentDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmSecheque_PaymentDate] ON [dbo].[clmSecheque]
(
	[PaymentDate] ASC
)
INCLUDE([PayeeKey],[ClaimKey],[ClaimNo],[PayeeID],[TransactionType],[Status],[Amount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
