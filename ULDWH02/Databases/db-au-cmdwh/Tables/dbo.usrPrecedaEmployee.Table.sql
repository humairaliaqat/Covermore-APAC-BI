USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrPrecedaEmployee]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrPrecedaEmployee](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](2) NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[Email] [varchar](255) NULL,
	[EmployeeID] [int] NULL,
	[Company] [varchar](100) NULL,
	[Division] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[ReportsToPositionTitle] [varchar](100) NULL,
	[Gender] [varchar](50) NULL,
	[PersonnelType] [varchar](100) NULL,
	[EmploymentType] [varchar](50) NULL,
	[Location] [varchar](100) NULL,
	[Country] [varchar](100) NULL,
	[HireDate] [datetime] NULL,
	[SelectionDate] [datetime] NULL,
	[HashKey] [binary](30) NULL,
	[LoadDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[isSynced] [nvarchar](1) NULL,
	[SyncedDateTime] [datetime] NULL,
	[QualtricsContactID] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrPrecedaEmployee_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrPrecedaEmployee_BIRowID] ON [dbo].[usrPrecedaEmployee]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrPrecedaEmployee_HireDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrPrecedaEmployee_HireDate] ON [dbo].[usrPrecedaEmployee]
(
	[HireDate] ASC
)
INCLUDE([Domain],[SelectionDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
