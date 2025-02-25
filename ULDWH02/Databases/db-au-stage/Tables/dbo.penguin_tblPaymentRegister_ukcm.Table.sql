USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPaymentRegister_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPaymentRegister_ukcm](
	[PaymentRegisterId] [int] NOT NULL,
	[OutletId] [int] NULL,
	[CRMUserId] [int] NOT NULL,
	[DomainId] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[PaymentTypeId] [int] NOT NULL,
	[BankAccountId] [tinyint] NOT NULL,
	[Source] [varchar](50) NOT NULL,
	[Comment] [varchar](500) NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
