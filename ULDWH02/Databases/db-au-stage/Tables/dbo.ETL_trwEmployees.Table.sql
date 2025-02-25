USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwEmployees]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwEmployees](
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[DepartmentID] [numeric](18, 0) NULL,
	[EmployeeID] [numeric](18, 0) NULL,
	[EmployeeCode] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[MiddleName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[DesignationID] [numeric](18, 0) NULL,
	[BranchID] [numeric](18, 0) NULL,
	[AreaID] [numeric](18, 0) NULL,
	[RegionID] [numeric](18, 0) NULL,
	[ReportingEmployeeID] [numeric](18, 0) NULL,
	[UserName] [varchar](256) NULL,
	[SecurityAnswer] [varchar](50) NULL,
	[DateofJoining] [datetime] NULL,
	[DateofBirth] [datetime] NULL,
	[AnniversaryDate] [datetime] NULL,
	[SalaryGrossSalary] [numeric](18, 0) NULL,
	[SalaryConveyance] [numeric](18, 0) NULL,
	[SalaryMobileExpenses] [numeric](18, 0) NULL,
	[SalaryPFContribution] [numeric](18, 0) NULL,
	[SalaryBonus] [numeric](18, 0) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[EntityID] [numeric](18, 0) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
