USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[dqaStandards]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dqaStandards](
	[dqaStandardID] [int] NOT NULL,
	[CountryKey] [char](2) NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Section] [varchar](50) NOT NULL,
	[dqaTest] [varchar](255) NOT NULL,
	[dqaWeight] [decimal](5, 2) NOT NULL,
	[dqaAdjust] [decimal](5, 2) NOT NULL,
	[isEnabled] [bit] NOT NULL,
	[dqaDimension] [varchar](50) NULL,
	[dqaCheckingType] [varchar](50) NULL,
	[Comments] [varchar](255) NULL
) ON [PRIMARY]
GO
