USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimGroupType_AU_AG]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimGroupType_AU_AG](
	[DimGroupTypeID] [int] NOT NULL,
	[GroupTypeName] [nvarchar](7) NULL,
	[GroupTypeNameShort] [nvarchar](1) NULL
) ON [PRIMARY]
GO
