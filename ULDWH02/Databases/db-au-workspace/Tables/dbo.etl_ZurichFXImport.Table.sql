USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[etl_ZurichFXImport]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_ZurichFXImport](
	[LocalCode] [varchar](5) NULL,
	[ForeignCode] [varchar](5) NULL,
	[FXDate] [varchar](10) NULL,
	[FXRate] [decimal](25, 10) NULL,
	[FXSource] [varchar](50) NULL,
	[FXDatedate] [date] NULL
) ON [PRIMARY]
GO
