USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_AgeBands]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_AgeBands](
	[Age] [float] NULL,
	[Code] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
