USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrPartnerWorkDays]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrPartnerWorkDays](
	[CountryKey] [varchar](2) NULL,
	[PartnerGroup] [varchar](30) NULL,
	[WeekDayWeight] [decimal](5, 2) NULL,
	[SaturdayWeight] [decimal](5, 2) NULL,
	[SundayWeight] [decimal](5, 2) NULL,
	[HolidayWeight] [decimal](5, 2) NULL
) ON [PRIMARY]
GO
