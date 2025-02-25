USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penCreditCardReconcile]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penCreditCardReconcile](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[CreditCardReconcileKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[CreditCardReconcileID] [int] NULL,
	[CRMUserID] [int] NULL,
	[Status] [varchar](15) NULL,
	[AccountingPeriod] [datetime] NULL,
	[AccountingPeriodUTC] [datetime] NULL,
	[Groups] [varchar](255) NULL,
	[DomainID] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[UpdateDateTimeUTC] [datetime] NULL,
	[DirectsCheque] [varchar](30) NULL,
	[NetCheque] [varchar](30) NULL,
	[CommissionCheque] [varchar](30) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penCreditCardReconcile_CreditCardReconcileKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_penCreditCardReconcile_CreditCardReconcileKey] ON [dbo].[penCreditCardReconcile]
(
	[CreditCardReconcileKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penCreditCardReconcile_AccountingPeriod]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penCreditCardReconcile_AccountingPeriod] ON [dbo].[penCreditCardReconcile]
(
	[AccountingPeriod] ASC,
	[CountryKey] ASC,
	[CompanyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
