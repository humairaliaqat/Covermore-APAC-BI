USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penArea]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penArea](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[AreaKey] [varchar](41) NULL,
	[AreaID] [int] NULL,
	[DomainID] [int] NULL,
	[AreaName] [nvarchar](100) NULL,
	[Domestic] [bit] NULL,
	[MinimumDuration] [numeric](5, 4) NULL,
	[ChildAreaID] [int] NULL,
	[AreaGroup] [int] NULL,
	[NonResident] [bit] NULL,
	[Weighting] [int] NULL,
	[DomainKey] [varchar](41) NULL,
	[AreaType] [varchar](50) NULL,
	[AreaNumber] [varchar](20) NULL,
	[AreaSetID] [int] NULL,
	[AreaCode] [nvarchar](3) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penArea_AreaKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_penArea_AreaKey] ON [dbo].[penArea]
(
	[AreaKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penArea_AreaID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penArea_AreaID] ON [dbo].[penArea]
(
	[AreaID] ASC,
	[CountryKey] ASC
)
INCLUDE([AreaKey],[AreaName],[AreaNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penArea_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penArea_CountryKey] ON [dbo].[penArea]
(
	[CountryKey] ASC,
	[CompanyKey] ASC,
	[AreaName] ASC
)
INCLUDE([AreaID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
