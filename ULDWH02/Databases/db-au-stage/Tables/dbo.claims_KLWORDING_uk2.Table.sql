USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLWORDING_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLWORDING_uk2](
	[KW_ID] [int] NOT NULL,
	[KWCODE] [varchar](5) NULL,
	[KWORDING] [nvarchar](255) NULL,
	[KLDOMAINID] [int] NOT NULL
) ON [PRIMARY]
GO
