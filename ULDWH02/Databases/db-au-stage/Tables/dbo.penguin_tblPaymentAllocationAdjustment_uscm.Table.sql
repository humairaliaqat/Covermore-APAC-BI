USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPaymentAllocationAdjustment_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPaymentAllocationAdjustment_uscm](
	[PaymentAllocationAdjustmentId] [int] NOT NULL,
	[PaymentAllocationId] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[AdjustmentType] [varchar](30) NOT NULL,
	[Comments] [varchar](255) NULL
) ON [PRIMARY]
GO
