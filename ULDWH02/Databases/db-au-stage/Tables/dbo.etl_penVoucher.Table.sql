USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penVoucher]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penVoucher](
	[DomainId] [int] NULL,
	[Partner] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[PolicyNumber] [varchar](25) NULL,
	[VoucherNumber] [nvarchar](20) NOT NULL,
	[Amount] [money] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[ExpiryDate] [datetime] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[RedemptionValue] [money] NULL,
	[RedemptionDate] [datetime] NULL,
	[VoucherType] [nvarchar](20) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_etl_penVoucher_VoucherNumber]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_etl_penVoucher_VoucherNumber] ON [dbo].[etl_penVoucher]
(
	[VoucherNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
