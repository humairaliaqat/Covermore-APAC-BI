USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DM_PrecedaLeave]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_PrecedaLeave](
	[Level 1] [float] NULL,
	[Status] [nvarchar](255) NULL,
	[ID Number] [float] NULL,
	[Full Name] [nvarchar](255) NULL,
	[Leave Type] [nvarchar](255) NULL,
	[Leave Type Descripion] [nvarchar](255) NULL,
	[Leave Start Date] [datetime] NULL,
	[Leave End Date] [datetime] NULL,
	[Hours Taken] [float] NULL,
	[Leave Reason Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
