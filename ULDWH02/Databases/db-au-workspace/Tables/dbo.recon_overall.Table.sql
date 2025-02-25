USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[recon_overall]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[recon_overall](
	[SUNPeriod] [int] NULL,
	[CountryKey] [varchar](2) NULL,
	[JVDescription] [nvarchar](255) NULL,
	[JVCode] [nvarchar](50) NULL,
	[FinanceProductCode] [nvarchar](4000) NULL,
	[ODS_PolicyCount] [int] NULL,
	[ODS_Premium] [money] NULL,
	[ODS_Commission] [money] NULL,
	[GL_PolicyCount] [numeric](38, 3) NULL,
	[GL_Premium] [numeric](38, 3) NULL,
	[GL_Commission] [numeric](38, 3) NULL,
	[Act_PolicyCount] [int] NULL,
	[Act_Premium] [float] NULL,
	[Act_Commission] [money] NULL,
	[ActS_PolicyCount] [int] NULL,
	[ActS_Premium] [float] NULL,
	[ActS_Commission] [money] NULL,
	[PC_PolicyCount] [int] NULL,
	[PC_Premium] [money] NULL,
	[PC_Commission] [money] NULL
) ON [PRIMARY]
GO
