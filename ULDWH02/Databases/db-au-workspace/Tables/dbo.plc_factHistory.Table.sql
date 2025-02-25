USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[plc_factHistory]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[plc_factHistory](
	[TransactionSK] [bigint] IDENTITY(1,1) NOT NULL,
	[TravellerSK] [bigint] NOT NULL,
	[PolicySK] [bigint] NOT NULL,
	[AddonSK] [bigint] NOT NULL,
	[PolicyTransactionKey] [varchar](50) NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
	[TransactionType] [nvarchar](100) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[Autocomments] [nvarchar](2000) NULL,
	[TransactionStart] [datetime] NULL,
	[TransactionEnd] [datetime] NULL,
	[ItemNumber] [int] NULL,
	[Item] [nvarchar](2000) NULL,
	[SellPrice] [money] NULL,
	[PolicyCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_plcfactHistory_TransactionSK]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [idx_plcfactHistory_TransactionSK] ON [dbo].[plc_factHistory]
(
	[TransactionSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_plcfactHistory_PolicyTransactionKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_plcfactHistory_PolicyTransactionKey] ON [dbo].[plc_factHistory]
(
	[PolicyTransactionKey] ASC
)
INCLUDE([TravellerSK],[PolicySK],[AddonSK],[TransactionDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
