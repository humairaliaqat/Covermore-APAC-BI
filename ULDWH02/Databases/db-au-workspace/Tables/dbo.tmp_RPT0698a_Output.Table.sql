USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_RPT0698a_Output]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_RPT0698a_Output](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[data] [varchar](max) NULL,
	[xDataIDx] [varchar](41) NULL,
	[xDataValuex] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
