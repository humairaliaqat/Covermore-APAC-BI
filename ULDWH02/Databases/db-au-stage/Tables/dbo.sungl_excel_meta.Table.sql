USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_meta]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_meta](
	[BusinessUnit] [nvarchar](255) NULL,
	[ServerName] [nvarchar](255) NULL,
	[DatabaseName] [nvarchar](255) NULL,
	[TableName] [nvarchar](511) NULL,
	[TableType] [nvarchar](255) NULL
) ON [PRIMARY]
GO
