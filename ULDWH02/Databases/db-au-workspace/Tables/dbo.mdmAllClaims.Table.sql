USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[mdmAllClaims]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mdmAllClaims](
	[ClaimKey] [varchar](40) NOT NULL,
	[PartyID] [nchar](14) NULL,
	[EventDescription] [varchar](max) NULL,
	[LocationFlag] [int] NOT NULL,
	[LuggageFlag] [int] NOT NULL,
	[SectionFlag] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[mdmAllClaims]
(
	[ClaimKey] ASC
)
INCLUDE([PartyID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
