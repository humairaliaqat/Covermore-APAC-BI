USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5WorkActivity_v3_20240623_bkp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5WorkActivity_v3_20240623_bkp](
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
