USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penCreditCardReconcile]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penCreditCardReconcile](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[CreditCardReconcileKey] [varchar](71) NULL,
	[CRMUserKey] [varchar](71) NULL,
	[CreditCardReconcileID] [int] NOT NULL,
	[CRMUserID] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[AccountingPeriod] [datetime] NULL,
	[AccountingPeriodUTC] [date] NOT NULL,
	[Groups] [varchar](255) NULL,
	[DomainID] [int] NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NULL,
	[UpdateDateTimeUTC] [datetime] NOT NULL,
	[DirectsCheque] [varchar](30) NULL,
	[NetCheque] [varchar](30) NULL,
	[CommissionCheque] [varchar](30) NULL
) ON [PRIMARY]
GO
