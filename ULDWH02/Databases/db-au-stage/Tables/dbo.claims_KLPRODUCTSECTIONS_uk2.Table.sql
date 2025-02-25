USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLPRODUCTSECTIONS_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLPRODUCTSECTIONS_uk2](
	[KS_ID] [int] NOT NULL,
	[KSProduct_ID] [int] NULL,
	[KSSectCode] [varchar](5) NULL,
	[KSDescription] [varchar](200) NULL,
	[KSDisplayOrder] [int] NULL
) ON [PRIMARY]
GO
