USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLPRODUCTS_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLPRODUCTS_uk](
	[KPProd_ID] [int] NOT NULL,
	[KPProduct] [varchar](5) NOT NULL,
	[KPDescription] [varchar](30) NULL,
	[KPStartDate] [datetime] NULL,
	[KPSuperceed_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_klproducts_uk_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klproducts_uk_id] ON [dbo].[claims_KLPRODUCTS_uk]
(
	[KPProd_ID] ASC
)
INCLUDE([KPProduct]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
