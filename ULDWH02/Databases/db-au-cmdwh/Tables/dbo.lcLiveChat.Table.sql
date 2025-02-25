USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[lcLiveChat]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lcLiveChat](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ChatID] [nvarchar](50) NULL,
	[ChatType] [nvarchar](30) NULL,
	[Rate] [nvarchar](50) NULL,
	[Duration] [int] NULL,
	[StartURL] [varchar](max) NULL,
	[Referrer] [varchar](max) NULL,
	[IsPending] [bit] NULL,
	[Engagement] [nvarchar](50) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[CustomerName] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[IP] [varchar](100) NULL,
	[City] [nvarchar](max) NULL,
	[Region] [nvarchar](max) NULL,
	[Country] [nvarchar](max) NULL,
	[TimeZone] [nvarchar](100) NULL,
	[CustomerID] [bigint] NULL,
	[BatchID] [int] NULL,
	[Mobile] [varchar](20) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[ClaimNumber] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cid]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cid] ON [dbo].[lcLiveChat]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_chatid]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_chatid] ON [dbo].[lcLiveChat]
(
	[ChatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_customer]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_customer] ON [dbo].[lcLiveChat]
(
	[CustomerID] ASC
)
INCLUDE([ChatID],[ChatType],[StartTime],[Duration],[Rate],[IP],[Country]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_date]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_date] ON [dbo].[lcLiveChat]
(
	[StartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
