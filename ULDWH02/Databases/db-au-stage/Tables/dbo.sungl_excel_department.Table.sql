USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_department]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_department](
	[Parent Dept Code] [nvarchar](255) NULL,
	[Parent Dept Description] [nvarchar](255) NULL,
	[Child Dept Code] [nvarchar](255) NULL,
	[Child Dept Description] [nvarchar](255) NULL,
	[Department Type Code] [nvarchar](255) NULL,
	[Department Type Description] [nvarchar](255) NULL,
	[Department Entity Code] [nvarchar](255) NULL,
	[Department Entity Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
