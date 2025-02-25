USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[ews_folder_Malaysia]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ews_folder_Malaysia](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[MailBox] [nvarchar](320) NULL,
	[FolderID] [nvarchar](255) NULL,
	[FolderName] [nvarchar](255) NULL,
	[FullPath] [nvarchar](max) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_ews_folder_Malaysia_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_ews_folder_Malaysia_BIRowID] ON [dbo].[ews_folder_Malaysia]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
