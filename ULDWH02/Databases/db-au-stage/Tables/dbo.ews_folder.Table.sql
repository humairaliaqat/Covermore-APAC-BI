USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ews_folder]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ews_folder](
	[mailbox] [nvarchar](450) NULL,
	[id] [nvarchar](450) NULL,
	[name] [nvarchar](max) NULL,
	[parentid] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ews_folder_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_ews_folder_id] ON [dbo].[ews_folder]
(
	[id] ASC
)
INCLUDE([mailbox],[name],[parentid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
