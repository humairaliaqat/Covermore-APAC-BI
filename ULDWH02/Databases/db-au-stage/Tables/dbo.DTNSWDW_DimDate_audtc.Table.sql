USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTNSWDW_DimDate_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSWDW_DimDate_audtc](
	[DateID] [int] NOT NULL,
	[DateText] [nvarchar](50) NOT NULL,
	[HYear] [nvarchar](50) NOT NULL,
	[HMonthID] [int] NOT NULL,
	[CYear] [nvarchar](50) NOT NULL,
	[CMonthID] [int] NOT NULL,
	[CMonth] [nvarchar](50) NOT NULL,
	[CQtr] [nvarchar](50) NOT NULL,
	[Closed] [int] NOT NULL,
	[EPICORdate] [int] NULL,
	[date] [date] NULL,
	[fiscalYear] [varchar](50) NULL,
	[fiscalHalf] [varchar](50) NULL,
	[epicorStartDate] [int] NULL,
	[epicorEndDate] [int] NULL
) ON [PRIMARY]
GO
