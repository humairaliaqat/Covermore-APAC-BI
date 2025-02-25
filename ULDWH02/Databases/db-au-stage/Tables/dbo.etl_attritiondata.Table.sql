USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_attritiondata]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_attritiondata](
	[Status] [nvarchar](255) NULL,
	[ID Number] [bigint] NULL,
	[Level 1] [nvarchar](255) NULL,
	[Full Name] [nvarchar](255) NULL,
	[Gender] [nvarchar](255) NULL,
	[Date of Birth] [datetime] NULL,
	[Full Title] [nvarchar](255) NULL,
	[Seniority Level] [nvarchar](255) NULL,
	[Employment Type] [nvarchar](255) NULL,
	[Personnel Type] [nvarchar](255) NULL,
	[Weekly Hours] [nvarchar](255) NULL,
	[FTE] [nvarchar](255) NULL,
	[Hire Date] [datetime] NULL,
	[Term Date] [datetime] NULL,
	[Country] [nvarchar](255) NULL,
	[Division] [nvarchar](255) NULL,
	[Dept Description] [nvarchar](255) NULL,
	[Term Reason] [nvarchar](255) NULL,
	[State] [nvarchar](200) NULL,
	[HashKey] [binary](30) NULL
) ON [PRIMARY]
GO
