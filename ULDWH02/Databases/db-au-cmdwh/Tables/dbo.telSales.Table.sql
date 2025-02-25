USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[telSales]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[telSales](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AgentName] [nvarchar](100) NULL,
	[TeamName] [nvarchar](255) NULL,
	[Company] [varchar](50) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PostingDate] [datetime] NULL,
	[Premium] [money] NULL,
	[SellPrice] [money] NULL,
	[PolicyCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_telSales_BIRowID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_telSales_BIRowID] ON [dbo].[telSales]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_telSales_Activity]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_telSales_Activity] ON [dbo].[telSales]
(
	[PostingDate] ASC,
	[AgentName] ASC
)
INCLUDE([TeamName],[Premium],[SellPrice],[PolicyCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_telSales_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_telSales_PolicyTransactionKey] ON [dbo].[telSales]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
