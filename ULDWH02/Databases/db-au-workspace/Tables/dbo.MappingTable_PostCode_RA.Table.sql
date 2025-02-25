USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MappingTable_PostCode_RA]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MappingTable_PostCode_RA](
	[POSTCODE_2017] [nvarchar](255) NULL,
	[POSTCODE_20171] [nvarchar](255) NULL,
	[RA_CODE_2016] [float] NULL,
	[RA_NAME_2016] [nvarchar](255) NULL,
	[RATIO] [float] NULL,
	[PERCENTAGE] [float] NULL
) ON [PRIMARY]
GO
