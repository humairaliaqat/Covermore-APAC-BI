USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPaymentAllocationAdjustment]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPaymentAllocationAdjustment](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PaymentAllocationAdjustmentKey] [varchar](41) NULL,
	[PaymentAllocationKey] [varchar](41) NULL,
	[PaymentAllocationAdjustmentID] [int] NOT NULL,
	[PaymentAllocationID] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[AdjustmentType] [varchar](30) NOT NULL,
	[Comments] [varchar](255) NULL
) ON [PRIMARY]
GO
