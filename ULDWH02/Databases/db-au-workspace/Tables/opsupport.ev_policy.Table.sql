USE [db-au-workspace]
GO
/****** Object:  Table [opsupport].[ev_policy]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [opsupport].[ev_policy](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NULL,
	[Domain] [varchar](5) NULL,
	[Business] [varchar](5) NULL,
	[GroupName] [nvarchar](50) NULL,
	[PolicyKey] [varchar](50) NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[IssueDate] [date] NULL,
	[TripStart] [date] NULL,
	[TripEnd] [date] NULL,
	[TripType] [nvarchar](50) NULL,
	[PrimaryCountry] [nvarchar](50) NULL,
	[TravellerCount] [int] NULL,
	[ClaimCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [opsupport].[ev_policy]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [opsupport].[ev_policy]
(
	[CustomerID] ASC,
	[PolicyKey] ASC
)
INCLUDE([PolicyNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
