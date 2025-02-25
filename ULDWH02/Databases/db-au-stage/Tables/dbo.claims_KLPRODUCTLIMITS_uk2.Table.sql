USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLPRODUCTLIMITS_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLPRODUCTLIMITS_uk2](
	[KI_ID] [int] NOT NULL,
	[KIPlan_ID] [int] NULL,
	[KIPerson_ID] [int] NULL,
	[KILimitAmt] [money] NULL,
	[KIProduct_ID] [int] NULL
) ON [PRIMARY]
GO
