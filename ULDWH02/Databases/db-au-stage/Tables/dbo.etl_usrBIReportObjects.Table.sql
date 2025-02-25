USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_usrBIReportObjects]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_usrBIReportObjects](
	[ReportID] [float] NULL,
	[No] [float] NULL,
	[ReportNo] [nvarchar](255) NULL,
	[ReportTitle] [nvarchar](255) NULL,
	[ReportType] [nvarchar](255) NULL,
	[Path] [nvarchar](255) NULL,
	[Author] [nvarchar](255) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[Universe] [nvarchar](255) NULL
) ON [PRIMARY]
GO
