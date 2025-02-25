USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[KLEVENT]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KLEVENT](
	[KE_ID] [int] NOT NULL,
	[KECLAIM] [int] NULL,
	[KEEMC_ID] [int] NULL,
	[KEPERIL] [varchar](3) NULL,
	[KECOUNTRY] [varchar](3) NULL,
	[KEDLOSS] [datetime] NULL,
	[KEDESC] [nvarchar](100) NULL,
	[KEDCREATED] [datetime] NULL,
	[KECREATEDBY_ID] [int] NULL,
	[KECASE_ID] [varchar](15) NULL,
	[KECATASTROPHE] [varchar](3) NULL,
	[KMOTORCYCLING] [bit] NULL,
	[KSKIINGSNOWBOARDING] [bit] NULL
) ON [PRIMARY]
GO
