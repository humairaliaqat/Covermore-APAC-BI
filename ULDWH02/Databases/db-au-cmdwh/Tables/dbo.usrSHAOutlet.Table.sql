USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrSHAOutlet]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrSHAOutlet](
	[AlphaCode] [varchar](20) NOT NULL,
	[HashedAlphaCode] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_HashedAlphaCode_usrSHAOutlet]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_HashedAlphaCode_usrSHAOutlet] ON [dbo].[usrSHAOutlet]
(
	[HashedAlphaCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
