USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLCATAS_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLCATAS_nz](
	[KC_CODE] [varchar](3) NOT NULL,
	[KCSHORT] [varchar](20) NULL,
	[KCLONG] [varchar](60) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_claims_klcatas_nz_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klcatas_nz_id] ON [dbo].[claims_KLCATAS_nz]
(
	[KC_CODE] ASC
)
INCLUDE([KCSHORT],[KCLONG]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
