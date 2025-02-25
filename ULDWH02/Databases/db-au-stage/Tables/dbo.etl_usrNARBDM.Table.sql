USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_usrNARBDM]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_usrNARBDM](
	[Month] [datetime] NULL,
	[BDM] [nvarchar](100) NULL,
	[SalesRegion] [nvarchar](100) NULL,
	[Status] [nvarchar](50) NULL,
	[LeavePublicHoliday] [float] NULL,
	[OfficeTravelOther] [float] NULL
) ON [PRIMARY]
GO
