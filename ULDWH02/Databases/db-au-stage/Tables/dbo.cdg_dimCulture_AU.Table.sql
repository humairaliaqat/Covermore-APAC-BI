USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimCulture_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimCulture_AU](
	[DimCultureID] [int] NOT NULL,
	[CultureCode] [nvarchar](20) NULL,
	[CultureName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
