USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLLOCATION_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLLOCATION_nz](
	[LO_ID] [int] NOT NULL,
	[LOCAT] [varchar](15) NULL,
	[LODESC] [varchar](50) NULL,
	[Display] [bit] NULL
) ON [PRIMARY]
GO
