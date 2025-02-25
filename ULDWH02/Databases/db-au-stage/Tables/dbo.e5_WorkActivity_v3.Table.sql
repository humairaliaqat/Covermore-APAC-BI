USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_WorkActivity_v3]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkActivity_v3](
	[Work_Id] [uniqueidentifier] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[CategoryActivity_Id] [int] NOT NULL,
	[Status_Id] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[CreationDate] [datetime] NULL,
	[CreationUser] [uniqueidentifier] NULL,
	[CompletionDate] [datetime] NULL,
	[CompletionUser] [uniqueidentifier] NULL,
	[AssignedDate] [datetime] NULL,
	[AssignedUser] [uniqueidentifier] NULL,
	[SLAExpiryDate] [datetime] NULL,
	[EnableActivityPostProcessor] [bit] NOT NULL,
	[_Id] [bigint] NOT NULL,
	[ProcessDriven] [bit] NOT NULL
) ON [PRIMARY]
GO
