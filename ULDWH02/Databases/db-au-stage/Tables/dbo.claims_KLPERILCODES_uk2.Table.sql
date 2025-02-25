USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLPERILCODES_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLPERILCODES_uk2](
	[KLPER_ID] [int] NOT NULL,
	[KLPERCODE] [varchar](3) NULL,
	[KLPERDESC] [varchar](65) NULL,
	[OnlineClaimDisplayOrder] [int] NULL,
	[UserDescription] [varchar](100) NULL,
	[MappedPerilCode] [varchar](3) NULL,
	[IsClaimPeril] [bit] NOT NULL,
	[IsOnlineClaimPeril] [bit] NOT NULL,
	[KLDOMAINID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_klperilcodes_uk2_cid]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klperilcodes_uk2_cid] ON [dbo].[claims_KLPERILCODES_uk2]
(
	[KLPER_ID] ASC
)
INCLUDE([KLPERCODE],[KLPERDESC]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_claims_klperilcodes_uk2_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klperilcodes_uk2_id] ON [dbo].[claims_KLPERILCODES_uk2]
(
	[KLPERCODE] ASC
)
INCLUDE([KLPERDESC]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
