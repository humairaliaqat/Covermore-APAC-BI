USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_NAR_Target]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_NAR_Target](
	[Month] [datetime] NULL,
	[Group] [nvarchar](255) NULL,
	[TargetDuration] [float] NULL,
	[TargetAppointments] [float] NULL
) ON [PRIMARY]
GO
