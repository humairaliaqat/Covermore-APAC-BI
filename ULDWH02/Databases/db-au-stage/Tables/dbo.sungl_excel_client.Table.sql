USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_client]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_client](
	[Parent Client Code] [nvarchar](255) NULL,
	[Parent Client Description] [nvarchar](255) NULL,
	[Client Code] [nvarchar](255) NULL,
	[Client Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
