USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[orbit_policies]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[orbit_policies](
	[Policy_Number] [varchar](20) NULL,
	[Policy_Start_Date] [date] NULL,
	[Customer_Name] [varchar](100) NULL,
	[DOB] [date] NULL,
	[Country] [varchar](50) NULL,
	[Transaction_Type] [varchar](10) NULL,
	[Insertion_date] [datetime] NULL
) ON [PRIMARY]
GO
