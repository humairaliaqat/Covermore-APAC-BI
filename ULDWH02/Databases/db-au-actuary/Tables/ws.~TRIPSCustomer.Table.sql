USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~TRIPSCustomer]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~TRIPSCustomer](
	[BIRowID] [bigint] NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[CustomerKey] [varchar](41) NULL,
	[PolicyNo] [int] NULL,
	[CustomerID] [int] NULL,
	[Title] [varchar](6) NULL,
	[FirstName] [varchar](25) NULL,
	[LastName] [varchar](25) NULL,
	[DateOfBirth] [datetime] NULL,
	[AgeAtDateOfIssue] [int] NULL,
	[PersonIsAdult] [bit] NULL,
 CONSTRAINT [PK_TRIPSCustomer] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idxCustomernames]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idxCustomernames] ON [ws].[~TRIPSCustomer]
(
	[CustomerKey] ASC,
	[FirstName] ASC,
	[LastName] ASC,
	[DateOfBirth] ASC
)
INCLUDE([CountryKey],[CustomerID],[PolicyNo]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
