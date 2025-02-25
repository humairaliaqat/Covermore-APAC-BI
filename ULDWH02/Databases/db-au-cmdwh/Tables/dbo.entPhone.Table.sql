USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entPhone]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entPhone](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[PhoneID] [bigint] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[STATUS] [nvarchar](10) NULL,
	[SourceSystem] [nchar](14) NULL,
	[CountryCode] [nvarchar](5) NULL,
	[PhoneNumber] [nvarchar](25) NULL,
	[ContactType] [nvarchar](20) NULL,
	[UpdateBatchID] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_entPhone_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_entPhone_BIRowID] ON [dbo].[entPhone]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_entPhone_CustomerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entPhone_CustomerID] ON [dbo].[entPhone]
(
	[CustomerID] ASC
)
INCLUDE([BIRowID],[PhoneID],[PhoneNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_entPhone_PhoneNumber]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entPhone_PhoneNumber] ON [dbo].[entPhone]
(
	[PhoneNumber] ASC
)
INCLUDE([BIRowID],[CustomerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
