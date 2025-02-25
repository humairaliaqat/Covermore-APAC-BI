USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_PaymentRegisterAllocation]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_PaymentRegisterAllocation](
	[SuperGroupName] [nvarchar](255) NULL,
	[GroupName] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[AccountName] [nvarchar](255) NULL,
	[Underwriter] [nvarchar](255) NULL,
	[PaymentRegisterID] [int] NULL,
	[PaymentStatus] [varchar](15) NULL,
	[PaymentType] [varchar](55) NULL,
	[PaymentCode] [varchar](3) NULL,
	[PaymentSource] [varchar](50) NULL,
	[PaymentCreateDateTime] [datetime] NULL,
	[PaymentUpdateDateTime] [datetime] NULL,
	[Comment] [varchar](500) NULL,
	[PaymentRegisterTransactionID] [int] NULL,
	[PaymentAllocationID] [int] NULL,
	[Payer] [varchar](50) NULL,
	[BankDate] [datetime] NULL,
	[ChequeNumber] [varchar](30) NULL,
	[Amount] [money] NULL,
	[AmountType] [varchar](15) NULL,
	[PRTStatus] [varchar](15) NULL,
	[PRTComment] [varchar](500) NULL,
	[PRTCreateDateTime] [datetime] NULL,
	[PRTUpdateDateTime] [datetime] NULL,
	[CreditNoteDepartmentID] [int] NULL,
	[CreditNoteDepartmentName] [varchar](55) NULL,
	[CreditNoteDepartmentCode] [varchar](3) NULL,
	[JVCode] [varchar](3) NULL,
	[JVDescription] [varchar](55) NULL,
	[PA_AlphaCode] [varchar](20) NULL,
	[PA_AccountingPeriod] [datetime] NULL,
	[PA_PaymentAmount] [money] NULL,
	[PA_AmountType] [varchar](30) NULL,
	[PA_Comments] [varchar](255) NULL,
	[PA_Status] [varchar](15) NULL,
	[PA_Source] [varchar](50) NULL,
	[PA_CreateDateTime] [datetime] NULL,
	[PA_UpdateDateTime] [datetime] NULL,
	[PTA_AlphaCode] [varchar](20) NULL,
	[PTA_AccountingPeriod] [datetime] NULL,
	[PTA_PaymentAmount] [money] NULL,
	[PTA_AmountType] [varchar](30) NULL,
	[PTA_Comments] [varchar](255) NULL,
	[PTA_Status] [varchar](15) NULL,
	[PTA_Source] [varchar](50) NULL,
	[PTA_CreateDateTime] [datetime] NULL,
	[PTA_UpdateDateTime] [datetime] NULL
) ON [PRIMARY]
GO
