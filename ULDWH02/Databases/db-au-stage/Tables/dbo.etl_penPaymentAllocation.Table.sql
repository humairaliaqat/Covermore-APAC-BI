USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPaymentAllocation]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPaymentAllocation](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[OutletKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[PaymentAllocationID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[AlphaCode] [varchar](20) NOT NULL,
	[AccountingPeriod] [datetime] NULL,
	[AccountingPeriodUTC] [date] NOT NULL,
	[PaymentAmount] [money] NOT NULL,
	[AmountType] [varchar](15) NOT NULL,
	[Comments] [varchar](255) NULL,
	[Status] [varchar](15) NOT NULL,
	[Source] [varchar](50) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NOT NULL,
	[UpdateDateTimeUTC] [datetime] NOT NULL,
	[PolicyAmount] [money] NOT NULL
) ON [PRIMARY]
GO
