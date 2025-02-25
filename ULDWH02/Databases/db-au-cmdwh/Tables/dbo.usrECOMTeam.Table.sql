USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrECOMTeam]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrECOMTeam](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Strategist] [varchar](250) NULL,
	[Country Code] [varchar](250) NULL,
	[Super Group Name] [varchar](250) NULL,
	[Group Name] [varchar](250) NULL,
	[Sub Group Name] [varchar](250) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[usrECOMTeam]
(
	[Country Code] ASC,
	[Super Group Name] ASC,
	[Group Name] ASC,
	[Sub Group Name] ASC
)
INCLUDE([Strategist]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
