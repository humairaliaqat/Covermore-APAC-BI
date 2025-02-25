USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbDateSummary]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbDateSummary](
	[Date] [datetime] NOT NULL,
	[ClientName] [varchar](25) NULL,
	[Protocol] [varchar](10) NULL,
	[Country] [varchar](25) NULL,
	[DeletedCount] [int] NULL,
	[AllCount] [int] NULL,
	[AllAge] [int] NULL,
	[OpenCount] [int] NULL,
	[OpenAge] [int] NULL,
	[OpenedCount] [int] NULL,
	[ClosedCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbDateSummary_Date]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cbDateSummary_Date] ON [dbo].[cbDateSummary]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
