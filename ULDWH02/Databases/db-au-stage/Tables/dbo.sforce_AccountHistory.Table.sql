USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sforce_AccountHistory]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sforce_AccountHistory](
	[AccountId] [nvarchar](18) NULL,
	[CreatedById] [nvarchar](18) NULL,
	[CreatedDate] [datetime] NULL,
	[Field] [nvarchar](255) NULL,
	[Id] [nvarchar](18) NULL,
	[IsDeleted] [bit] NULL,
	[NewValue] [nvarchar](255) NULL,
	[OldValue] [nvarchar](255) NULL
) ON [PRIMARY]
GO
