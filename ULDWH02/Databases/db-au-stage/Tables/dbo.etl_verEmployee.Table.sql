USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_verEmployee]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_verEmployee](
	[EmployeeKey] [int] NOT NULL,
	[EmployeeName] [varchar](101) NULL,
	[EmployeeFirstName] [varchar](50) NOT NULL,
	[EmployeeLastName] [varchar](50) NOT NULL,
	[EmployeeStartTime] [datetime] NOT NULL,
	[EmployeeEndTime] [datetime] NULL,
	[EmployeeDOB] [datetime] NULL,
	[USERNAME] [varchar](50) NULL
) ON [PRIMARY]
GO
