USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_CCATeams]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_CCATeams](
	[Parent CCA Teams Code] [nvarchar](255) NULL,
	[Parent CCA Teams Code Description] [nvarchar](255) NULL,
	[CCA Teams Owner Code] [nvarchar](255) NULL,
	[CCA Teams Owner Description] [nvarchar](255) NULL,
	[CCA Teams Code] [nvarchar](255) NULL,
	[CCA Teams Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
