USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCPayrollLeave]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCPayrollLeave](
	[ID Number] [float] NULL,
	[Full Name] [nvarchar](255) NULL,
	[Leave Type] [nvarchar](255) NULL,
	[Period Ending Date] [datetime] NULL,
	[Pay Date] [datetime] NULL,
	[Total Hours] [float] NULL
) ON [PRIMARY]
GO
