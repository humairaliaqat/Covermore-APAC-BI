USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_POL_POLICY_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_POL_POLICY_aucm](
	[CLI_CODE] [varchar](2) NOT NULL,
	[POL_CODE] [varchar](2) NOT NULL,
	[POL_DESC] [nvarchar](25) NULL,
	[AUTOID] [int] NOT NULL
) ON [PRIMARY]
GO
