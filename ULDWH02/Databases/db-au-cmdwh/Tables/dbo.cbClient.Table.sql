USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbClient]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbClient](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](3) NOT NULL,
	[ClientCode] [nvarchar](2) NOT NULL,
	[ClientName] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[EvacDebtorCode] [nvarchar](50) NULL,
	[NonEvacDebtorCode] [nvarchar](50) NULL,
	[CurrencyCode] [nvarchar](3) NULL,
	[IsCovermoreClient] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbClient_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cbClient_BIRowID] ON [dbo].[cbClient]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbClient_ClientCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbClient_ClientCode] ON [dbo].[cbClient]
(
	[ClientCode] ASC,
	[CountryKey] ASC
)
INCLUDE([EvacDebtorCode],[NonEvacDebtorCode],[CurrencyCode],[IsCovermoreClient]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
