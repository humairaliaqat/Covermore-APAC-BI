USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_dtcWorkerCH_Jan]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_dtcWorkerCH_Jan](
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
	[Employment Type Desc] [nvarchar](255) NULL,
	[Personnel Type Desc] [nvarchar](255) NULL,
	[Work Pattern Description] [nvarchar](255) NULL,
	[Base Hours Amount] [float] NULL,
	[Monday] [money] NULL,
	[Tuesday] [money] NULL,
	[Wednesday] [money] NULL,
	[Thursday] [money] NULL,
	[Friday] [money] NULL,
	[Saturday] [money] NULL,
	[Sunday] [money] NULL
) ON [PRIMARY]
GO
