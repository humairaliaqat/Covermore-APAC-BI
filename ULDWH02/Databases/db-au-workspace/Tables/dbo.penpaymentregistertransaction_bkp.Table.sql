USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[penpaymentregistertransaction_bkp]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penpaymentregistertransaction_bkp](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PaymentRegisterTransactionKey] [varchar](41) NULL,
	[PaymentRegisterKey] [varchar](41) NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[PaymentRegisterTransactionID] [int] NULL,
	[PaymentRegisterID] [int] NULL,
	[PaymentAllocationID] [int] NULL,
	[Payer] [varchar](50) NULL,
	[BankDate] [datetime] NULL,
	[BankDateUTC] [datetime] NULL,
	[BSB] [varchar](10) NULL,
	[ChequeNumber] [varchar](30) NULL,
	[Amount] [money] NULL,
	[AmountType] [varchar](15) NULL,
	[Status] [varchar](15) NULL,
	[Comment] [varchar](500) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NULL,
	[UpdateDateTimeUTC] [datetime] NULL,
	[CreditNoteDepartmentID] [int] NULL,
	[CreditNoteDepartmentName] [varchar](55) NULL,
	[CreditNoteDepartmentCode] [varchar](3) NULL,
	[JointVentureID] [int] NULL,
	[JVCode] [varchar](3) NULL,
	[JVDescription] [varchar](55) NULL
) ON [PRIMARY]
GO
