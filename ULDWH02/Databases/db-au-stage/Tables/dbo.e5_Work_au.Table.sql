USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_Work_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_Work_au](
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
	[WFInstance] [varchar](200) NULL,
	[Origin_Id] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
