USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_Codes_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_Codes_AU](
	[Code] [varchar](10) NOT NULL,
	[Description] [varchar](50) NULL,
	[Other] [varchar](50) NULL,
	[email] [varchar](50) NULL
) ON [PRIMARY]
GO
