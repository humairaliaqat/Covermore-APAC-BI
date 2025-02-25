USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrPublicHoliday_Claims]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrPublicHoliday_Claims](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Date] [date] NULL,
	[Description] [varchar](100) NULL,
	[StateLocation] [varchar](100) NULL,
	[DomainCountry] [varchar](5) NULL,
	[isHoliday] [int] NULL
) ON [PRIMARY]
GO
