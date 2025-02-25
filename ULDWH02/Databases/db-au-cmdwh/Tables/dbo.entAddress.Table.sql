USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entAddress]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entAddress](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[AddressID] [bigint] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[STATUS] [nvarchar](10) NULL,
	[SourceSystem] [nchar](14) NULL,
	[AddressType] [nvarchar](20) NULL,
	[Address] [nvarchar](511) NULL,
	[Suburb] [nvarchar](50) NULL,
	[State] [nvarchar](40) NULL,
	[Country] [nvarchar](40) NULL,
	[CountryCode] [nvarchar](3) NULL,
	[PostCode] [nvarchar](10) NULL,
	[DPID] [nvarchar](20) NULL,
	[UpdateBatchID] [bigint] NULL,
	[MinDate] [date] NULL,
	[MaxDate] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_entAddress_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_entAddress_BIRowID] ON [dbo].[entAddress]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_entAddress_CustomerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entAddress_CustomerID] ON [dbo].[entAddress]
(
	[CustomerID] ASC
)
INCLUDE([BIRowID],[AddressID],[DPID],[Address],[Suburb],[State],[Country],[PostCode],[MinDate],[MaxDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_entAddress_DPID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_entAddress_DPID] ON [dbo].[entAddress]
(
	[DPID] ASC,
	[SourceSystem] ASC
)
INCLUDE([BIRowID],[CustomerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
