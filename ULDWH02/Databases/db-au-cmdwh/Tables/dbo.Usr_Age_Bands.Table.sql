USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Usr_Age_Bands]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usr_Age_Bands](
	[Age] [int] NOT NULL,
	[Age_Band_Code] [varchar](50) NOT NULL,
	[Age_Band_Desc] [varchar](200) NULL
) ON [PRIMARY]
GO
