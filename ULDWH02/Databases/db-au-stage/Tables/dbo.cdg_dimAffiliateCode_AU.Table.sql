USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimAffiliateCode_AU]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimAffiliateCode_AU](
	[DimAffiliateCodeID] [int] NOT NULL,
	[AffiliateCode] [varchar](100) NULL
) ON [PRIMARY]
GO
