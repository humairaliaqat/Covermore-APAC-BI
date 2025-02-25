USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Policy_Budget]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Policy_Budget](
	[Year] [int] NULL,
	[Day] [varchar](20) NULL,
	[Date] [date] NULL,
	[Outlet_Code] [varchar](100) NULL,
	[Business_Unit] [varchar](50) NULL,
	[Currency_Code] [varchar](10) NULL,
	[Budget_Amount] [money] NULL,
	[Domain_Id] [int] NULL,
	[Source_System_Code] [varchar](50) NULL
) ON [PRIMARY]
GO
