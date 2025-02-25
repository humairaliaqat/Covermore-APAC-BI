USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~PolicyTransactionGLMEstimate]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~PolicyTransactionGLMEstimate](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[TransactionOrder] [int] NULL,
	[Base Policy No] [varchar](50) NULL,
	[IssueMonth] [varchar](2) NULL,
	[IssueYear] [int] NULL,
	[DepartureMonth] [varchar](2) NULL,
	[JVGroup] [varchar](500) NOT NULL,
	[ProductGroup] [varchar](500) NOT NULL,
	[CountryGroup] [varchar](500) NOT NULL,
	[AgeOldestBand] [varchar](500) NULL,
	[LeadTimeBand] [varchar](500) NULL,
	[TripLengthBand] [varchar](500) NULL,
	[MaxTripLengthBand] [varchar](500) NULL,
	[ExcessBand] [varchar](500) NULL,
	[PlanType] [varchar](5) NOT NULL,
	[NoOfChildrenBand] [varchar](500) NULL,
	[NoOfChargedTravellerBand] [varchar](500) NULL,
	[HasEMC] [varchar](1) NOT NULL,
	[HasMotorcycle] [varchar](7) NOT NULL,
	[HasWintersport] [int] NOT NULL,
	[EstimateFactor] [decimal](30, 20) NULL,
	[Estimate] [decimal](30, 20) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_PolicyTransactionGLMEstimate]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_PolicyTransactionGLMEstimate] ON [ws].[~PolicyTransactionGLMEstimate]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_PolicyTransactionGLMEstimate_PolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_PolicyTransactionGLMEstimate_PolicyKey] ON [ws].[~PolicyTransactionGLMEstimate]
(
	[PolicyKey] ASC,
	[TransactionOrder] ASC
)
INCLUDE([Estimate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_PolicyTransactionGLMEstimate_PolicyTransactionKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_PolicyTransactionGLMEstimate_PolicyTransactionKey] ON [ws].[~PolicyTransactionGLMEstimate]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
