USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrASICBlacklist]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrASICBlacklist](
	[BanRegisterName] [varchar](255) NULL,
	[FullNameASIC] [varchar](255) NULL,
	[FirstName] [varchar](255) NULL,
	[MiddleName] [varchar](255) NULL,
	[LastName] [varchar](255) NULL,
	[FullNamePenguin] [varchar](255) NULL,
	[BanType] [varchar](255) NULL,
	[BanDocumentNumber] [varchar](255) NULL,
	[BanStartDate] [datetime] NULL,
	[BanEndDate] [datetime] NULL,
	[LocalAddress] [varchar](255) NULL,
	[State] [varchar](255) NULL,
	[PostCode] [varchar](255) NULL,
	[Country] [varchar](255) NULL,
	[Comments] [varchar](1000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [usrASICBlacklist_idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [usrASICBlacklist_idx] ON [dbo].[usrASICBlacklist]
(
	[FullNamePenguin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
