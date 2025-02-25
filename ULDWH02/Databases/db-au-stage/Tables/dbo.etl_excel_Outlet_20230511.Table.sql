USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_Outlet_20230511]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_Outlet_20230511](
	[Country] [nvarchar](255) NULL,
	[DomainID] [int] NULL,
	[Distributor] [nvarchar](255) NULL,
	[SuperGroupName] [nvarchar](255) NULL,
	[GroupCode] [nvarchar](255) NULL,
	[GroupName] [nvarchar](255) NULL,
	[SubGroupCode] [nvarchar](255) NULL,
	[SubGroupName] [nvarchar](255) NULL,
	[AlphaCode] [nvarchar](255) NULL,
	[OutletName] [nvarchar](255) NULL,
	[JV] [nvarchar](255) NULL,
	[ChannelID] [float] NULL,
	[JV Desc] [nvarchar](255) NULL
) ON [PRIMARY]
GO
