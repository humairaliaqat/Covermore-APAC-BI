USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_usrNARTarget]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_usrNARTarget](
	[Month] [datetime] NULL,
	[Group] [nvarchar](100) NULL,
	[TargetDuration] [int] NULL,
	[TargetAppointment] [int] NULL
) ON [PRIMARY]
GO
