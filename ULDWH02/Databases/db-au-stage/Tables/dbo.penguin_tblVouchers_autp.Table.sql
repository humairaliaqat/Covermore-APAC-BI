USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblVouchers_autp]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblVouchers_autp](
	[VoucherID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[DomainID] [int] NOT NULL,
	[VoucherType] [nvarchar](20) NOT NULL,
	[VoucherCode] [nvarchar](20) NOT NULL,
	[VoucherAmount] [money] NOT NULL,
	[IssueDate] [datetime] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[VoucherStatus] [nvarchar](20) NOT NULL
) ON [PRIMARY]
GO
