USE [db-au-log]
GO
/****** Object:  Table [dbo].[Data_Reconciliation_Invalid]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Data_Reconciliation_Invalid](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SummaryID] [int] NULL,
	[MetadataID] [int] NULL,
	[CountryCode] [varchar](10) NULL,
	[Identifier] [varchar](100) NULL,
	[Source1Value] [numeric](16, 2) NULL,
	[Source2Value] [numeric](16, 2) NULL,
	[Source3Value] [numeric](16, 2) NULL,
	[Date] [date] NULL,
	[InsertDatetime] [datetime2](7) NULL,
	[UpdateDatetime] [datetime2](7) NULL,
	[Comment] [varchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_Data_Reconciliation_Invalid_Summary_ID]    Script Date: 24/02/2025 2:34:44 PM ******/
CREATE NONCLUSTERED INDEX [idx_Data_Reconciliation_Invalid_Summary_ID] ON [dbo].[Data_Reconciliation_Invalid]
(
	[SummaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
