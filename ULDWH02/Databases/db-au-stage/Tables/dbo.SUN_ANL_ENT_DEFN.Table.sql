USE [db-au-stage]
GO
/****** Object:  Table [dbo].[SUN_ANL_ENT_DEFN]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SUN_ANL_ENT_DEFN](
	[Analysis_Business_Unit_Code] [varchar](50) NOT NULL,
	[Analysis_Category_ID] [varchar](50) NOT NULL,
	[Entry_Number] [smallint] NOT NULL,
	[Subject_Header] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
