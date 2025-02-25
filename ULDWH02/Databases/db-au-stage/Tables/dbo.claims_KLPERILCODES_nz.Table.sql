USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLPERILCODES_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLPERILCODES_nz](
	[KLPER_ID] [int] NOT NULL,
	[KLPERCODE] [varchar](3) NULL,
	[KLPERDESC] [varchar](65) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_claims_klperilcodes_nz_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klperilcodes_nz_id] ON [dbo].[claims_KLPERILCODES_nz]
(
	[KLPERCODE] ASC
)
INCLUDE([KLPERDESC]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
