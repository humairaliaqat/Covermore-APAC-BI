USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DM_DTC_EmployeeDetails]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_DTC_EmployeeDetails](
	[Level 1] [float] NULL,
	[Status] [nvarchar](255) NULL,
	[Org Unit Description] [nvarchar](255) NULL,
	[Position ID] [nvarchar](255) NULL,
	[Position Title] [nvarchar](255) NULL,
	[Reports To Position Title] [nvarchar](255) NULL,
	[ID Number] [float] NULL,
	[First Name] [nvarchar](255) NULL,
	[Surname] [nvarchar](255) NULL,
	[Level 2 Description] [nvarchar](255) NULL,
	[Hire Date] [datetime] NULL,
	[Term Date] [nvarchar](255) NULL,
	[Employment Type Desc] [nvarchar](255) NULL,
	[Personnel Type Desc] [nvarchar](255) NULL,
	[Work Pattern Description] [nvarchar](255) NULL,
	[Base Hours Amount] [float] NULL,
	[State] [nvarchar](255) NULL
) ON [PRIMARY]
GO
