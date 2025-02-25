USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_jv_ind]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_jv_ind](
	[Type of JV Code] [nvarchar](255) NULL,
	[Type of JV Description] [nvarchar](255) NULL,
	[Distribution Type Code] [nvarchar](255) NULL,
	[Distribution Type Description] [nvarchar](255) NULL,
	[Super Group Code] [nvarchar](255) NULL,
	[Super Group Description] [nvarchar](255) NULL,
	[JV Code] [nvarchar](255) NULL,
	[JV Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
