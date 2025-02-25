USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_dimDate_AU]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_dimDate_AU](
	[DimDateID] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Day] [char](2) NOT NULL,
	[DaySuffix] [varchar](4) NOT NULL,
	[DayOfWeek] [varchar](9) NOT NULL,
	[DOWInMonth] [tinyint] NOT NULL,
	[DayOfYear] [int] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[WeekOfMonth] [tinyint] NOT NULL,
	[Month] [char](2) NOT NULL,
	[MonthName] [varchar](9) NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [varchar](6) NOT NULL,
	[Year] [char](4) NOT NULL,
	[StandardDate] [varchar](10) NULL,
	[HolidayTextUS] [varchar](50) NULL,
	[HolidayTextAU] [varchar](60) NULL
) ON [PRIMARY]
GO
