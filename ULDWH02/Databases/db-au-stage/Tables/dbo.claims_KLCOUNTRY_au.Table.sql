USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLCOUNTRY_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLCOUNTRY_au](
	[KLCO_ID] [int] NOT NULL,
	[KLCNTRYCODE] [varchar](3) NULL,
	[KLCNTRYDESC] [varchar](200) NULL,
	[Active] [bit] NULL,
	[ISO2CODE] [varchar](2) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_claims_klcountry_au_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klcountry_au_id] ON [dbo].[claims_KLCOUNTRY_au]
(
	[KLCNTRYCODE] ASC
)
INCLUDE([KLCNTRYDESC]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
