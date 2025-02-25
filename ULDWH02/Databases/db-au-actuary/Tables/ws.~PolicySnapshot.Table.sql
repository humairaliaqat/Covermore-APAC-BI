USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~PolicySnapshot]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~PolicySnapshot](
	[PolicySK] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[PolicyNumber] [varchar](50) NOT NULL,
	[IssueDate] [datetime] NOT NULL,
	[PolicyStatus] [nvarchar](50) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[TripType] [nvarchar](50) NULL,
	[TripCost] [nvarchar](50) NULL,
	[TripDuration] [int] NULL,
	[Excess] [money] NOT NULL,
	[DaysCovered] [int] NULL,
	[MaxDuration] [int] NULL,
	[CancellationCover] [nvarchar](50) NULL,
	[Area] [nvarchar](100) NULL,
	[AreaType] [varchar](25) NULL,
	[PrimaryCountry] [nvarchar](200) NULL,
	[MultiDestination] [nvarchar](max) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[ProductName] [nvarchar](50) NULL,
	[PlanCode] [nvarchar](50) NULL,
	[PlanName] [nvarchar](50) NULL,
	[HashKey] [binary](30) NULL,
	[isLatest] [char](1) NOT NULL,
	[ValidStartDate] [datetime] NOT NULL,
	[ValidEndDate] [datetime] NULL,
	[LoadDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_PolicySnapshot_PolicySK]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_PolicySnapshot_PolicySK] ON [ws].[~PolicySnapshot]
(
	[PolicySK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_PolicySnapshot_HashKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_PolicySnapshot_HashKey] ON [ws].[~PolicySnapshot]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_PolicySnapshot_PolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_PolicySnapshot_PolicyKey] ON [ws].[~PolicySnapshot]
(
	[PolicyKey] ASC
)
INCLUDE([PolicyNumber],[IssueDate],[PolicyTransactionKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
