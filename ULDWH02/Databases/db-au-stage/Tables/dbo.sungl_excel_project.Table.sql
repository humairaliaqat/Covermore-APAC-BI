USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_project]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_project](
	[Parent Project Code] [nvarchar](255) NULL,
	[Parent Project Code Description] [nvarchar](255) NULL,
	[Project Owner Code] [nvarchar](255) NULL,
	[Project Owner Description] [nvarchar](255) NULL,
	[Project Code] [nvarchar](255) NULL,
	[Project Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
