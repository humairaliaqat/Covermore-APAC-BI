USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_corpBank_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_corpBank_nz](
	[RecordNo] [int] NOT NULL,
	[BankDate] [datetime] NULL,
	[ACT] [datetime] NULL,
	[Account] [varchar](6) NULL,
	[Product] [varchar](3) NULL,
	[Alpha] [varchar](7) NULL,
	[CompID] [int] NULL,
	[Gross] [money] NULL,
	[Commission] [money] NULL,
	[Adjustment] [money] NULL,
	[Refund] [money] NULL,
	[RefundChq] [int] NULL,
	[Op] [varchar](10) NULL,
	[Comments] [varchar](100) NULL,
	[MMBonus] [money] NULL
) ON [PRIMARY]
GO
