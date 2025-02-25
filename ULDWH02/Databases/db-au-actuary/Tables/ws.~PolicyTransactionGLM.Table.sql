USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~PolicyTransactionGLM]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~PolicyTransactionGLM](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[TransactionOrder] [int] NULL,
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[IssueTime] [datetime] NULL,
	[PostingTime] [datetime] NULL,
	[TransactionType] [varchar](50) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[AutoComments] [nvarchar](max) NULL,
	[DepartureDate] [date] NULL,
	[ReturnDate] [date] NULL,
	[MaxAMTDuration] [int] NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[PostCode] [nvarchar](50) NULL,
	[Previous_DepartureDate] [date] NULL,
	[Previous_ReturnDate] [date] NULL,
	[Previous_MaxAMTDuration] [int] NULL,
	[Previous_PrimaryCountry] [nvarchar](max) NULL,
	[Previous_PostCode] [nvarchar](50) NULL,
	[YoungestChargedDOB] [date] NULL,
	[OldestChargedDOB] [date] NULL,
	[HasLuggage] [smallint] NULL,
	[HasEMC] [smallint] NULL,
	[HasMotorcycle] [smallint] NULL,
	[HasWintersport] [smallint] NULL,
	[HasCruise] [smallint] NULL,
	[TripCostString] [varchar](50) NULL,
	[TripCostDelta] [int] NULL,
	[Running_HasLuggage] [smallint] NULL,
	[Running_HasEMC] [smallint] NULL,
	[Running_HasMotorcycle] [smallint] NULL,
	[Running_HasWintersport] [smallint] NULL,
	[Running_HasCruise] [smallint] NULL,
	[Running_TripCost] [int] NULL,
	[Bundled_Luggage] [bit] NULL,
	[Bundled_EMC] [bit] NULL,
	[Bundled_Motorcycle] [bit] NULL,
	[Bundled_Wintersport] [bit] NULL,
	[Bundled_Cruise] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx_penPolicyTransactionGLM]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_penPolicyTransactionGLM] ON [ws].[~PolicyTransactionGLM]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransactionGLM_PolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransactionGLM_PolicyKey] ON [ws].[~PolicyTransactionGLM]
(
	[PolicyKey] ASC,
	[TransactionOrder] ASC
)
INCLUDE([PolicyTransactionKey],[TransactionType],[TransactionStatus],[IssueTime],[PostingTime],[DepartureDate],[ReturnDate],[MaxAMTDuration],[PrimaryCountry],[YoungestChargedDOB],[OldestChargedDOB],[PostCode],[Previous_DepartureDate],[Previous_ReturnDate],[Previous_MaxAMTDuration],[Previous_PrimaryCountry],[Previous_PostCode],[HasLuggage],[HasEMC],[HasMotorcycle],[HasWintersport],[HasCruise],[TripCostDelta]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransactionGLM_PolicyTransactionKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransactionGLM_PolicyTransactionKey] ON [ws].[~PolicyTransactionGLM]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
