USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[HR_LeaveEntReport]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HR_LeaveEntReport](
	[Co#] [float] NULL,
	[Level 1 Description] [nvarchar](255) NULL,
	[ID] [float] NULL,
	[Position Title] [nvarchar](255) NULL,
	[Department Description] [nvarchar](255) NULL,
	[Payroll Approver] [nvarchar](255) NULL,
	[Hours] [float] NULL,
	[Accrual Method] [float] NULL,
	[Accrual Method Description] [nvarchar](255) NULL,
	[Leave Type] [nvarchar](255) NULL,
	[Ent Hours] [float] NULL
) ON [PRIMARY]
GO
