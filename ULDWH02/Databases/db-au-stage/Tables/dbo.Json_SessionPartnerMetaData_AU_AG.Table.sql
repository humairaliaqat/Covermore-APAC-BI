USE [db-au-stage]
GO
/****** Object:  Table [dbo].[Json_SessionPartnerMetaData_AU_AG]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Json_SessionPartnerMetaData_AU_AG](
	[Sessiontoken] [varchar](500) NULL,
	[LinkID] [varchar](500) NULL,
	[gclid] [varchar](500) NULL,
	[gaClientID] [varchar](500) NULL,
	[Age] [varchar](500) NULL,
	[PROMOCODE] [varchar](500) NULL,
	[PromoType] [varchar](500) NULL,
	[DiscountPercent] [varchar](500) NULL
) ON [PRIMARY]
GO
