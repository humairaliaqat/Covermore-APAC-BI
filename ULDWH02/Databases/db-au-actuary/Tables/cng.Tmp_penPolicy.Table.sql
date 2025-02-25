USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_penPolicy]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_penPolicy](
	[PolicyKey] [varchar](41) NULL,
	[PolicyID] [int] NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[Area] [nvarchar](100) NULL,
	[AreaCode] [nvarchar](3) NULL,
	[MultiDestination] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicy_PolicyKeyProductCode]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_penPolicy_PolicyKeyProductCode] ON [cng].[Tmp_penPolicy]
(
	[PolicyKey] ASC,
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicy_PolicyID]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicy_PolicyID] ON [cng].[Tmp_penPolicy]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
