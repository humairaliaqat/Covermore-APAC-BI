USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\gitesh.shiraskar].[HR_EventReport_bkp1003]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\gitesh.shiraskar].[HR_EventReport_bkp1003](
	[Date] [datetime] NULL,
	[Time] [datetime] NULL,
	[Description] [nvarchar](255) NULL,
	[UserDesc] [nvarchar](255) NULL,
	[Door] [nvarchar](255) NULL
) ON [PRIMARY]
GO
