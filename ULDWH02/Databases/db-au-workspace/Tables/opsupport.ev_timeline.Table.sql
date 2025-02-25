USE [db-au-workspace]
GO
/****** Object:  Table [opsupport].[ev_timeline]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [opsupport].[ev_timeline](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Who] [bigint] NULL,
	[When] [date] NULL,
	[What] [varchar](14) NULL,
	[Caption] [nvarchar](4000) NULL,
	[Where] [nvarchar](max) NULL,
	[Detail] [nvarchar](70) NULL,
	[Axis] [numeric](3, 2) NULL,
	[URL] [nvarchar](max) NULL,
	[Tooltip] [nvarchar](max) NOT NULL,
	[Value] [numeric](20, 2) NULL,
	[ReferenceID] [varchar](100) NULL,
	[Transcript] [nvarchar](4000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [opsupport].[ev_timeline]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [opsupport].[ev_timeline]
(
	[Who] ASC,
	[What] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
