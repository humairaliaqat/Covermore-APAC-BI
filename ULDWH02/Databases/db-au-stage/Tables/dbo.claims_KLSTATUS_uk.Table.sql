USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLSTATUS_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLSTATUS_uk](
	[KT_ID] [int] NOT NULL,
	[KTTABLE] [varchar](20) NULL,
	[KTFIELD] [varchar](20) NULL,
	[KTSTATUS] [varchar](4) NULL,
	[KTDESC] [varchar](30) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_claims_klstatus_uk_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klstatus_uk_id] ON [dbo].[claims_KLSTATUS_uk]
(
	[KT_ID] ASC,
	[KTTABLE] ASC
)
INCLUDE([KTSTATUS],[KTDESC]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
