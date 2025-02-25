USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[bobjReport]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bobjReport](
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
