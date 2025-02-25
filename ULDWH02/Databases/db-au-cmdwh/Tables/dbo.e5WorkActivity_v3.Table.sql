USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5WorkActivity_v3]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5WorkActivity_v3](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](5) NULL,
	[Country] [varchar](5) NULL,
	[Work_ID] [varchar](50) NULL,
	[ID] [varchar](50) NULL,
	[Original_ID] [uniqueidentifier] NOT NULL,
	[Original_Work_ID] [uniqueidentifier] NOT NULL,
	[WorkActivity_ID] [bigint] NULL,
	[CategoryActivityName] [nvarchar](100) NULL,
	[StatusName] [nvarchar](100) NULL,
	[SortOrder] [int] NULL,
	[CreationDate] [datetime] NULL,
	[CreationUserID] [nvarchar](100) NULL,
	[CreationUser] [nvarchar](455) NULL,
	[CompletionDate] [datetime] NULL,
	[CompletionUserID] [nvarchar](100) NULL,
	[CompletionUser] [nvarchar](455) NULL,
	[AssignedDate] [datetime] NULL,
	[AssignedUserID] [nvarchar](100) NULL,
	[AssignedUser] [nvarchar](455) NULL,
	[DueDate] [datetime] NULL,
	[AssessmentOutcome] [int] NULL,
	[AssessmentOutcomeDescription] [nvarchar](400) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[DeleteBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_e5WorkActivity_v3_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_e5WorkActivity_v3_BIRowID] ON [dbo].[e5WorkActivity_v3]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_e5Work_v3Act_CompletionDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_e5Work_v3Act_CompletionDate] ON [dbo].[e5WorkActivity_v3]
(
	[CompletionDate] ASC
)
INCLUDE([Work_ID],[ID],[AssessmentOutcome],[AssessmentOutcomeDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_e5WorkActivity_v3_ID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_e5WorkActivity_v3_ID] ON [dbo].[e5WorkActivity_v3]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_e5WorkActivity_v3_Work_ID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_e5WorkActivity_v3_Work_ID] ON [dbo].[e5WorkActivity_v3]
(
	[Work_ID] ASC,
	[CompletionDate] DESC,
	[CategoryActivityName] ASC
)
INCLUDE([ID],[Country],[StatusName],[CompletionUser],[AssessmentOutcome],[AssessmentOutcomeDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
