USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLWORDING_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLWORDING_nz](
	[KW_ID] [int] NOT NULL,
	[KWCODE] [varchar](5) NULL,
	[KWORDING] [varchar](255) NULL
) ON [PRIMARY]
GO
