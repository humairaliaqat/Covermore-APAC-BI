USE [db-au-star]
GO
/****** Object:  Table [dbo].[AlphaMappingJV]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlphaMappingJV](
	[AlphaCode] [nvarchar](255) NULL,
	[SuperGroupName] [nvarchar](255) NULL,
	[GroupName] [nvarchar](255) NULL,
	[SubGroupName] [nvarchar](255) NULL,
	[TradingStatus] [nvarchar](255) NULL,
	[JV] [float] NULL
) ON [PRIMARY]
GO
