USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLEVENT_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLEVENT_uk](
	[KE_ID] [int] NOT NULL,
	[KECLAIM] [int] NULL,
	[KEEMC_ID] [int] NULL,
	[KEPERIL] [varchar](3) NULL,
	[KECOUNTRY] [varchar](3) NULL,
	[KEDLOSS] [datetime] NULL,
	[KEDESC] [varchar](80) NULL,
	[KEDCREATED] [datetime] NULL,
	[KECREATEDBY_ID] [int] NULL,
	[KECASE_ID] [varchar](15) NULL,
	[KECATASTROPHE] [varchar](3) NULL
) ON [PRIMARY]
GO
