USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_UCT_CASETYPE_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_UCT_CASETYPE_aucm](
	[CT_ID] [int] NOT NULL,
	[CT_DESCRIPTION] [nvarchar](30) NULL,
	[CHARGEABLE] [bit] NULL,
	[FIXED_CHARGE] [bit] NULL
) ON [PRIMARY]
GO
