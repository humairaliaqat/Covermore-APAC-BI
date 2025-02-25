USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmTargetTemp]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmTargetTemp](
	[Country] [nvarchar](10) NOT NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[Date] [datetime] NULL,
	[SalesTarget] [float] NULL,
	[PolicyCount] [float] NULL
) ON [PRIMARY]
GO
