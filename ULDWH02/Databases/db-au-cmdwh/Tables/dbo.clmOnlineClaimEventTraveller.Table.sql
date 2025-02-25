USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmOnlineClaimEventTraveller]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmOnlineClaimEventTraveller](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[ClaimKey] [varchar](40) NULL,
	[OnlineClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NULL,
	[OnlineClaimID] [int] NOT NULL,
	[FirstName] [varchar](255) NULL,
	[Lastname] [varchar](255) NULL,
	[DOB] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmOnlineClaimEventTraveller_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_clmOnlineClaimEventTraveller_BIRowID] ON [dbo].[clmOnlineClaimEventTraveller]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmOnlineClaimEventTraveller_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmOnlineClaimEventTraveller_ClaimKey] ON [dbo].[clmOnlineClaimEventTraveller]
(
	[ClaimKey] ASC
)
INCLUDE([BIRowID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmOnlineClaimEventTraveller_OnlineClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmOnlineClaimEventTraveller_OnlineClaimKey] ON [dbo].[clmOnlineClaimEventTraveller]
(
	[OnlineClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
