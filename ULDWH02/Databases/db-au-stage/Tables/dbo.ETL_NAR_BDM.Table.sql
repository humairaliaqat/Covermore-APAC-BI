USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_NAR_BDM]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_NAR_BDM](
	[Month] [datetime] NULL,
	[BDM] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[LeavePublicHoliday] [float] NULL,
	[OfficeTravelOther] [float] NULL
) ON [PRIMARY]
GO
