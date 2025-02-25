USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[verEmployee]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[verEmployee](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[EmployeeName] [nvarchar](100) NOT NULL,
	[EmployeeFirstName] [nvarchar](50) NOT NULL,
	[EmployeeLastName] [nvarchar](50) NOT NULL,
	[EmployeeStartTime] [datetime] NULL,
	[EmployeeEndTime] [datetime] NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[UserName] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_verEmployee_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_verEmployee_BIRowID] ON [dbo].[verEmployee]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_verEmployee_EmployeeKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verEmployee_EmployeeKey] ON [dbo].[verEmployee]
(
	[EmployeeKey] ASC
)
INCLUDE([UserName],[EmployeeName],[EmployeeFirstName],[EmployeeLastName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_verEmployee_EmployeeName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verEmployee_EmployeeName] ON [dbo].[verEmployee]
(
	[EmployeeName] ASC
)
INCLUDE([EmployeeKey],[UserName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_verEmployee_UserName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verEmployee_UserName] ON [dbo].[verEmployee]
(
	[UserName] ASC
)
INCLUDE([EmployeeKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
