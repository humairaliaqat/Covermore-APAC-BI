USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTNSWDW_DTC_VoucherLineTimesheetDetails_audtc]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSWDW_DTC_VoucherLineTimesheetDetails_audtc](
	[TimesheetControlID] [varchar](50) NOT NULL,
	[VoucherNo] [varchar](16) NULL,
	[LineNum] [int] NULL,
	[ImportDate] [datetime] NULL,
	[ImportUser] [varchar](50) NULL,
	[PostDate] [datetime] NULL,
	[PostUser] [varchar](50) NULL
) ON [PRIMARY]
GO
