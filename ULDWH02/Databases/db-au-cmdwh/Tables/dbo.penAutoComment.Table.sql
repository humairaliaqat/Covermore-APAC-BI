USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penAutoComment]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penAutoComment](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[AutoCommentKey] [varchar](41) NULL,
	[OutletKey] [varchar](41) NULL,
	[CSRKey] [varchar](41) NULL,
	[AutoCommentID] [int] NULL,
	[OutletID] [int] NULL,
	[CSRID] [int] NULL,
	[AlphaCode] [nvarchar](50) NULL,
	[AutoComments] [nvarchar](max) NULL,
	[CommentDate] [datetime] NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[CommentDateUTC] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAutoComment_AutoCommentKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_penAutoComment_AutoCommentKey] ON [dbo].[penAutoComment]
(
	[AutoCommentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAutoComment_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penAutoComment_OutletKey] ON [dbo].[penAutoComment]
(
	[OutletKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
