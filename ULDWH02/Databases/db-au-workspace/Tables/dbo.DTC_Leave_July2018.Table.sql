USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTC_Leave_July2018]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_Leave_July2018](
	[Status] [nvarchar](255) NULL,
	[ID Number] [float] NULL,
	[Full Name] [nvarchar](255) NULL,
	[Full Title] [nvarchar](255) NULL,
	[Level 1] [float] NULL,
	[Organisation Unit Id] [float] NULL,
	[Leave Type] [nvarchar](255) NULL,
	[Leave Type Descripion] [nvarchar](255) NULL,
	[Leave Start Date] [datetime] NULL,
	[Leave End Date] [datetime] NULL,
	[Hours Taken] [float] NULL,
	[Leave Reason] [nvarchar](255) NULL,
	[Leave Reason Description] [nvarchar](255) NULL,
	[Base Hours Amount] [float] NULL,
	[Department] [float] NULL,
	[Department Description] [nvarchar](255) NULL,
	[F17] [nvarchar](255) NULL
) ON [PRIMARY]
GO
