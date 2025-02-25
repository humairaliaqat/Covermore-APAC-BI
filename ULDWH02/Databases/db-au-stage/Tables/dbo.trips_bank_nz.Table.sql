USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_bank_nz]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_bank_nz](
	[RecordNo] [int] NOT NULL,
	[BankDate] [datetime] NULL,
	[ACT] [datetime] NULL,
	[Account] [varchar](4) NULL,
	[Product] [varchar](3) NULL,
	[Alpha] [varchar](7) NULL,
	[Gross] [money] NULL,
	[Commission] [money] NULL,
	[Adjustment] [money] NULL,
	[Refund] [money] NULL,
	[RefundChq] [int] NULL,
	[Op] [varchar](2) NULL,
	[Comments] [varchar](100) NULL,
	[MMBonus] [money] NULL,
	[AdjTypeID] [smallint] NULL
) ON [PRIMARY]
GO
