USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_state]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_state](
	[Parent State Code] [nvarchar](255) NULL,
	[Parent State Description] [nvarchar](255) NULL,
	[State Code] [nvarchar](255) NULL,
	[State Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
