USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_Work_v4]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_Work_v4](
	[Id] [uniqueidentifier] NOT NULL,
	[WorkClass_Id] [int] NOT NULL,
	[Category1_Id] [int] NOT NULL,
	[Category2_Id] [int] NOT NULL,
	[Category3_Id] [int] NOT NULL,
	[Status_Id] [int] NOT NULL,
	[StatusEventDate] [datetime] NULL,
	[StatusDetail] [nvarchar](100) NULL,
	[AssignedDate] [datetime] NULL,
	[AssignedUser] [nvarchar](100) NULL,
	[CreationDate] [datetime] NOT NULL,
	[CreationUser] [nvarchar](100) NULL,
	[CompletionDate] [datetime] NULL,
	[CompletionUser] [nvarchar](100) NULL,
	[SLAExpiryDate] [datetime] NULL,
	[Priority] [int] NULL,
	[LockUser] [nvarchar](100) NULL,
	[LockDate] [datetime] NULL,
	[Allocation] [varchar](20) NULL,
	[Reference] [int] NULL,
	[Parent_Id] [uniqueidentifier] NULL,
	[WorkflowVersion_Id] [uniqueidentifier] NULL,
	[Origin_Id] [uniqueidentifier] NULL,
	[SiteGroup] [int] NULL,
	[_Id] [int] NOT NULL,
	[isMigrated] [tinyint] NULL,
	[LifecycleSLAExpiryDate] [datetime] NULL,
	[SubCategory3_Id] [int] NULL,
	[GetNextValue] [numeric](20, 6) NOT NULL,
	[WorkflowSchemaVersion] [nvarchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [e5_Work_v4]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [e5_Work_v4] ON [dbo].[e5_Work_v4]
(
	[Id] ASC
)
INCLUDE([Category1_Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
