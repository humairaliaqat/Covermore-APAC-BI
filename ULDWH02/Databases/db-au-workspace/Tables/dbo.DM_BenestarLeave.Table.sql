USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DM_BenestarLeave]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_BenestarLeave](
	[Level 1] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[ID Number] [varchar](50) NULL,
	[Full Name] [varchar](50) NULL,
	[Leave Type] [varchar](50) NULL,
	[Date Paid] [varchar](50) NULL,
	[Leave Type Descripion] [varchar](50) NULL,
	[Leave Start Date] [datetime] NULL,
	[Leave End Date] [datetime] NULL,
	[Hours Taken] [varchar](50) NULL,
	[Leave Reason Description] [varchar](50) NULL
) ON [PRIMARY]
GO
