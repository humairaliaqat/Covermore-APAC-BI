USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPaymentRegister]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPaymentRegister](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PaymentRegisterKey] [varchar](41) NULL,
	[OutletKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[BankAccountKey] [varchar](41) NULL,
	[PaymentRegisterID] [int] NOT NULL,
	[OutletID] [int] NULL,
	[CRMUserID] [int] NOT NULL,
	[BankAccountID] [tinyint] NOT NULL,
	[PaymentStatus] [varchar](15) NOT NULL,
	[PaymentTypeID] [int] NOT NULL,
	[PaymentType] [varchar](55) NULL,
	[PaymentCode] [varchar](3) NULL,
	[PaymentSource] [varchar](50) NOT NULL,
	[Comment] [varchar](500) NULL,
	[PaymentCreateDateTime] [datetime] NULL,
	[PaymentUpdateDateTime] [datetime] NULL,
	[PaymentCreateDateTimeUTC] [datetime] NOT NULL,
	[PaymentUpdateDateTimeUTC] [datetime] NOT NULL,
	[DomainID] [int] NOT NULL,
	[TripsAccount] [int] NULL
) ON [PRIMARY]
GO
