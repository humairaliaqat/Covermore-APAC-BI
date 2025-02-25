USE [db-au-actuary]
GO
/****** Object:  Table [ws].[CustomerOnBasePolicy]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[CustomerOnBasePolicy](
	[BIRowID] [bigint] NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[CustomerKey] [varchar](41) NULL,
	[CustomerID] [int] NULL,
	[Title] [varchar](6) NULL,
	[FirstName] [varchar](25) NULL,
	[LastName] [varchar](25) NULL,
	[DateOfBirth] [datetime] NULL,
	[AgeAtDateOfIssue] [int] NULL,
	[PersonIsAdult] [bit] NULL,
	[isPrimary] [bit] NULL,
	[ClientID] [varchar](35) NULL,
	[EMCPremiumAmount] [money] NULL,
 CONSTRAINT [PK_CustomerOnBasePolicy] PRIMARY KEY NONCLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx] ON [ws].[CustomerOnBasePolicy]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ClientID]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_ClientID] ON [ws].[CustomerOnBasePolicy]
(
	[ClientID] ASC
)
INCLUDE([PolicyKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxCustomerKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idxCustomerKey] ON [ws].[CustomerOnBasePolicy]
(
	[CustomerKey] ASC
)
INCLUDE([PolicyKey],[Title],[FirstName],[LastName],[DateOfBirth],[PersonIsAdult],[ClientID],[EMCPremiumAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxPolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idxPolicyKey] ON [ws].[CustomerOnBasePolicy]
(
	[PolicyKey] ASC
)
INCLUDE([CustomerKey],[Title],[FirstName],[LastName],[DateOfBirth],[PersonIsAdult],[ClientID],[EMCPremiumAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
