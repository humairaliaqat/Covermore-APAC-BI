USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_QualtricsFeedNZ]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_QualtricsFeedNZ](
	[Selection Date] [varchar](50) NULL,
	[First Name] [varchar](100) NULL,
	[Last Name] [varchar](100) NULL,
	[Email] [varchar](255) NULL,
	[ID Number] [varchar](50) NULL,
	[Company] [varchar](100) NULL,
	[Division] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[Reports To Position Title] [varchar](100) NULL,
	[Gender] [varchar](50) NULL,
	[Personnel Type Desc] [varchar](100) NULL,
	[Employment Type Desc] [varchar](100) NULL,
	[Location] [varchar](100) NULL,
	[Country] [varchar](100) NULL,
	[Hire Date] [varchar](50) NULL
) ON [PRIMARY]
GO
