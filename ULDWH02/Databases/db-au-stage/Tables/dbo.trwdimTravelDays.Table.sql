USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimTravelDays]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimTravelDays](
	[Day] [float] NULL,
	[Code] [nvarchar](50) NULL,
	[DayBand] [nvarchar](50) NULL,
	[DayBandDisplay] [nvarchar](150) NULL
) ON [PRIMARY]
GO
