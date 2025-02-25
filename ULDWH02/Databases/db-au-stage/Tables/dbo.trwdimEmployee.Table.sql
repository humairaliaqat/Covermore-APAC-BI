USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimEmployee]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimEmployee](
	[EmployeeSK] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[EmployeeCode] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[DesignationID] [int] NULL,
	[DepartmentID] [int] NULL,
	[BranchID] [int] NULL,
	[AreaID] [int] NULL,
	[RegionID] [int] NULL,
	[ReportingEmployeeID] [int] NULL,
	[UserName] [nvarchar](256) NULL,
	[SecurityAnswer] [nvarchar](50) NULL,
	[DateofJoining] [datetime] NULL,
	[DateofBirth] [datetime] NULL,
	[AnniversaryDate] [datetime] NULL,
	[SalaryGrossSalary] [numeric](18, 0) NULL,
	[SalaryConveyance] [numeric](18, 0) NULL,
	[SalaryMobileExpenses] [numeric](18, 0) NULL,
	[SalaryPFContribution] [numeric](18, 0) NULL,
	[SalaryBonus] [numeric](18, 0) NULL,
	[EmailAddress] [nvarchar](100) NULL,
	[EntityID] [int] NULL,
	[Status] [nvarchar](50) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimEmployee_EmployeeSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimEmployee_EmployeeSK] ON [dbo].[trwdimEmployee]
(
	[EmployeeSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimEmployee_EmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimEmployee_EmployeeID] ON [dbo].[trwdimEmployee]
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimEmployee_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimEmployee_HashKey] ON [dbo].[trwdimEmployee]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
