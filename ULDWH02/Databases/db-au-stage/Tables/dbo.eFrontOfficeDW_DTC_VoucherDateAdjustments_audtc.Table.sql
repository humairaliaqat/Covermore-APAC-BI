USE [db-au-stage]
GO
/****** Object:  Table [dbo].[eFrontOfficeDW_DTC_VoucherDateAdjustments_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eFrontOfficeDW_DTC_VoucherDateAdjustments_audtc](
	[VoucherNo] [varchar](20) NOT NULL,
	[AdjustedDate] [date] NOT NULL
) ON [PRIMARY]
GO
