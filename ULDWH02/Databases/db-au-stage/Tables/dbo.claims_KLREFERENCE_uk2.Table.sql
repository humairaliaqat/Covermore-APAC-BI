USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLREFERENCE_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLREFERENCE_uk2](
	[ID] [int] NOT NULL,
	[ENTITY] [nvarchar](100) NOT NULL,
	[CODE] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[ISACTIVE] [bit] NOT NULL,
	[SORTORDER] [int] NULL
) ON [PRIMARY]
GO
