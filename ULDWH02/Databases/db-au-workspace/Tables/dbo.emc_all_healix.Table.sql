USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[emc_all_healix]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_all_healix](
	[Month] [date] NULL,
	[Mapping - Product] [nvarchar](50) NOT NULL,
	[Mapping - Platform] [nvarchar](50) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[CountryKey] [varchar](2) NULL,
	[GroupName] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[OutletType] [nvarchar](50) NULL,
	[Channel] [nvarchar](100) NULL,
	[AssessmentCount] [int] NULL,
	[NonTestCount] [int] NULL
) ON [PRIMARY]
GO
