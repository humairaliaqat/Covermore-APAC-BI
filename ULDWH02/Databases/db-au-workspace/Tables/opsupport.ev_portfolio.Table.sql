USE [db-au-workspace]
GO
/****** Object:  Table [opsupport].[ev_portfolio]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [opsupport].[ev_portfolio](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Country] [varchar](max) NULL,
	[Claim Number] [int] NULL,
	[Work Type] [varchar](max) NULL,
	[Date Received] [date] NULL,
	[Absolute Age] [int] NULL,
	[Time in current status] [int] NULL,
	[Team Leader] [varchar](max) NULL,
	[Team Leader Email] [varchar](512) NULL,
	[Assigned User] [varchar](max) NULL,
	[Assigned User Email] [varchar](512) NULL,
	[AssociatedCustomerID] [bigint] NULL,
	[Customer Name] [nvarchar](255) NULL,
	[MDM SortID] [int] NULL,
	[RiskCategory] [varchar](29) NULL,
	[e5URL] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_ev_portfolio_BIRowID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_ev_portfolio_BIRowID] ON [opsupport].[ev_portfolio]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ncidx_assignee]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [ncidx_assignee] ON [opsupport].[ev_portfolio]
(
	[Assigned User Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ncidx_teamleader]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [ncidx_teamleader] ON [opsupport].[ev_portfolio]
(
	[Team Leader Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
