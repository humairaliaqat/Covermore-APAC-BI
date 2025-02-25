USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLLOCATION_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLLOCATION_au](
	[LO_ID] [int] NOT NULL,
	[LOCAT] [varchar](50) NULL,
	[LODESC] [nvarchar](50) NULL,
	[Display] [bit] NULL,
	[KLDOMAINID] [int] NOT NULL
) ON [PRIMARY]
GO
