USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[glBusinessUnits_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glBusinessUnits_ind](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentBusinessUnitCode] [varchar](50) NULL,
	[BusinessUnitCode] [varchar](50) NOT NULL,
	[BusinessUnitDescription] [nvarchar](255) NULL,
	[CurrencyCode] [varchar](50) NULL,
	[SourceSystemCode] [varchar](50) NULL,
	[DomainID] [varchar](50) NULL,
	[CountryCode] [varchar](50) NULL,
	[CountryDescription] [varchar](200) NULL,
	[RegionCode] [varchar](50) NULL,
	[RegionDescription] [varchar](200) NULL,
	[TypeOfEntityCode] [varchar](50) NULL,
	[TypeOfEntityDescription] [varchar](50) NULL,
	[TypeOfBusinessCode] [varchar](50) NULL,
	[TypeOfBusinessDescription] [varchar](200) NULL,
	[CreateBatchID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateBatchID] [int] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_ind]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [cidx_ind] ON [dbo].[glBusinessUnits_ind]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ind] ON [dbo].[glBusinessUnits_ind]
(
	[BusinessUnitCode] ASC
)
INCLUDE([ParentBusinessUnitCode],[BusinessUnitDescription],[CurrencyCode],[SourceSystemCode],[DomainID],[CountryCode],[CountryDescription],[RegionCode],[RegionDescription],[TypeOfEntityCode],[TypeOfEntityDescription],[TypeOfBusinessCode],[TypeOfBusinessDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_parent_ind]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_parent_ind] ON [dbo].[glBusinessUnits_ind]
(
	[ParentBusinessUnitCode] ASC
)
INCLUDE([BusinessUnitCode],[BusinessUnitDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
