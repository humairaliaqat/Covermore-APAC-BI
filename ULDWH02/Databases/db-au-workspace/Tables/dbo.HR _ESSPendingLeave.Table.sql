USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[HR _ESSPendingLeave]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HR _ESSPendingLeave](
	[Level 1] [float] NULL,
	[Company] [nvarchar](255) NULL,
	[ID] [float] NULL,
	[Full Name] [nvarchar](255) NULL,
	[Position Title] [nvarchar](255) NULL,
	[Dept] [float] NULL,
	[Department Description] [nvarchar](255) NULL,
	[Payroll Approver] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Code] [float] NULL,
	[Type] [nvarchar](255) NULL,
	[Date From] [datetime] NULL,
	[Date To] [datetime] NULL,
	[[ReturnDate]]] [datetime] NULL,
	[Hours] [float] NULL,
	[Applied] [datetime] NULL,
	[Approved By] [nvarchar](255) NULL,
	[Approved] [datetime] NULL,
	[Comment] [nvarchar](255) NULL,
	[Mgr Comment] [nvarchar](255) NULL
) ON [PRIMARY]
GO
