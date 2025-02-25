USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penVoucher_20250114]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penVoucher_20250114](
	[DomainId] [int] NULL,
	[Partner] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[PolicyNumber] [nvarchar](25) NULL,
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
