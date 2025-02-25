USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_businessunit]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_businessunit](
	[Business Unit Code] [nvarchar](255) NULL,
	[Business Unit Description] [nvarchar](255) NULL,
	[Currency Code] [nvarchar](255) NULL,
	[Source System Code] [nvarchar](255) NULL,
	[Domain ID] [nvarchar](255) NULL,
	[Parent Business Unit Code] [nvarchar](255) NULL,
	[Country Code] [nvarchar](255) NULL,
	[Country Description] [nvarchar](255) NULL,
	[Region Code] [nvarchar](255) NULL,
	[Region Description] [nvarchar](255) NULL,
	[Type of Entity Code] [nvarchar](255) NULL,
	[Type of Entity Description] [nvarchar](255) NULL,
	[Type of Business Code] [nvarchar](255) NULL,
	[Type of Business Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
