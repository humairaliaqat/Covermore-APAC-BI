USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Group_Incident]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Group_Incident](
	[Business Unit Where Incident Occurred (Incident)] [nvarchar](255) NULL,
	[Reference Name] [nvarchar](255) NULL,
	[Incident Name] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL,
	[Incident Impact Assessment] [nvarchar](255) NULL,
	[Incident Status] [nvarchar](255) NULL,
	[Date Reported] [nvarchar](255) NULL,
	[Target Close Date] [nvarchar](255) NULL,
	[Root cause determination - Root cause] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
