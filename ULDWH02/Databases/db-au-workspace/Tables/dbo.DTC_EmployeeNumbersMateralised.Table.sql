USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTC_EmployeeNumbersMateralised]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_EmployeeNumbersMateralised](
	[Org_id] [varchar](32) NULL,
	[Group_id] [varchar](32) NULL,
	[SubLevel_id] [varchar](32) NULL,
	[helper] [int] NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[EmployeeCount] [int] NULL
) ON [PRIMARY]
GO
