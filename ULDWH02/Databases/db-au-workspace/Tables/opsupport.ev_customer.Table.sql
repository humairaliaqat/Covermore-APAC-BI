USE [db-au-workspace]
GO
/****** Object:  Table [opsupport].[ev_customer]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [opsupport].[ev_customer](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[MergedTo] [bigint] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[Status] [nvarchar](10) NULL,
	[CustomerName] [nvarchar](255) NULL,
	[CustomerRole] [nvarchar](50) NULL,
	[Title] [nvarchar](20) NULL,
	[FirstName] [nvarchar](100) NULL,
	[MidName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[Gender] [nvarchar](7) NULL,
	[MaritalStatus] [nvarchar](15) NULL,
	[DOB] [date] NOT NULL,
	[isDeceased] [bit] NULL,
	[CurrentAddress] [nvarchar](614) NULL,
	[CurrentEmail] [nvarchar](255) NULL,
	[CurrentContact] [nvarchar](25) NULL,
	[SortID] [int] NULL,
	[PrimaryScore] [int] NULL,
	[SecondaryScore] [int] NULL,
	[RiskCategory] [varchar](29) NOT NULL,
	[ForceFlag] [int] NOT NULL,
	[BlockFlag] [int] NOT NULL,
	[Alias] [nvarchar](4000) NULL,
	[Comment] [varchar](max) NULL,
	[isEmployee] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [opsupport].[ev_customer]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [opsupport].[ev_customer]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [opsupport].[ev_customer] ADD  DEFAULT ((0)) FOR [isEmployee]
GO
