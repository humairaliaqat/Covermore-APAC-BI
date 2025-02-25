USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\chris.herron].[overwrite_target2020]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\chris.herron].[overwrite_target2020](
	[country] [nvarchar](10) NOT NULL,
	[date] [smalldatetime] NULL,
	[jv] [nvarchar](20) NULL,
	[channel] [nvarchar](100) NULL,
	[outletalphakey] [nvarchar](50) NOT NULL,
	[newvalue] [float] NULL,
	[newsellprice] [float] NULL
) ON [PRIMARY]
GO
