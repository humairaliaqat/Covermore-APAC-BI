USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[ewsMalaysiaEmailHistory]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ewsMalaysiaEmailHistory](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmailID] [nvarchar](450) NULL,
	[FullPath] [nvarchar](max) NULL,
	[Category] [nvarchar](1024) NULL,
	[ModifyDateTime] [datetime] NULL,
	[ModifyBy] [nvarchar](320) NULL,
	[Importance] [nvarchar](255) NULL,
	[EmailSize] [bigint] NULL,
	[HasAttachment] [bit] NULL,
	[IsResend] [bit] NULL,
	[IsNew] [bit] NULL,
	[IsRead] [bit] NULL,
	[CreateDateTime] [datetime] NULL,
	[CreateBatchID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_ewsMalaysiaEmailHistory_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_ewsMalaysiaEmailHistory_BIRowID] ON [dbo].[ewsMalaysiaEmailHistory]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ewsMalaysiaEmailHistory_EmailID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ewsMalaysiaEmailHistory_EmailID] ON [dbo].[ewsMalaysiaEmailHistory]
(
	[EmailID] ASC
)
INCLUDE([FullPath],[Category],[ModifyDateTime],[ModifyBy],[Importance],[EmailSize],[HasAttachment],[IsResend],[IsNew],[IsRead],[CreateDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
