USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFLCalendar]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFLCalendar](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[MonthName] [varchar](50) NULL,
	[FiscalYear] [int] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[DayCount] [int] NULL
) ON [PRIMARY]
GO
