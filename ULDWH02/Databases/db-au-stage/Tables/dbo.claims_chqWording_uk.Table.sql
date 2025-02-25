USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_chqWording_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_chqWording_uk](
	[wID] [int] NOT NULL,
	[chqPAYID] [int] NULL,
	[chqBATCH] [int] NULL,
	[chqWORDINGS] [varchar](255) NULL,
	[chqWORD1] [varchar](25) NULL,
	[chqWORD2] [varchar](15) NULL,
	[chqWORD3] [varchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_chqWording_uk_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_chqWording_uk_id] ON [dbo].[claims_chqWording_uk]
(
	[chqBATCH] ASC,
	[chqPAYID] ASC
)
INCLUDE([chqWORDINGS]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
