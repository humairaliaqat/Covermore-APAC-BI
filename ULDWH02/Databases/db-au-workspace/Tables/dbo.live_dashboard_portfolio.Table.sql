USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_portfolio]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_portfolio](
	[Country] [varchar](max) NULL,
	[Claim Number] [int] NULL,
	[Work Type] [varchar](max) NULL,
	[Date Received] [date] NULL,
	[Absolute Age] [int] NULL,
	[Time in current status] [int] NULL,
	[Team Leader] [varchar](max) NULL,
	[Assigned User] [varchar](max) NULL,
	[AssociatedCustomerID] [bigint] NULL,
	[Customer Name] [nvarchar](255) NULL,
	[MDM SortID] [int] NULL,
	[RiskCategory] [varchar](29) NULL,
	[e5URL] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
