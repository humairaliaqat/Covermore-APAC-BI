USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_PrecedaLeaveData]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_PrecedaLeaveData](
	[Status] [nvarchar](255) NULL,
	[ID Number] [float] NULL,
	[Full Name] [nvarchar](255) NULL,
	[Hours Description] [nvarchar](255) NULL,
	[Date From] [datetime] NULL,
	[Date To] [datetime] NULL,
	[Return To Work] [datetime] NULL,
	[Hours] [float] NULL
) ON [PRIMARY]
GO
