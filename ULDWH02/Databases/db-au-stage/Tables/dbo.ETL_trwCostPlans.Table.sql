USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwCostPlans]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwCostPlans](
	[CostPlanID] [numeric](18, 0) NULL,
	[Name] [varchar](100) NULL,
	[ShortName] [varchar](50) NULL,
	[InsuranceProviderID] [numeric](18, 0) NULL,
	[InsuranceCategoryID] [numeric](18, 0) NULL,
	[MasterPolicyNumber] [varchar](50) NULL,
	[DayPlan] [bit] NULL,
	[TAProviderID] [numeric](18, 0) NULL,
	[TAPlanID] [numeric](18, 0) NULL,
	[TANumber] [varchar](50) NULL,
	[VisitingCountryID] [numeric](18, 0) NULL,
	[Annualplan] [bit] NULL,
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[MaximumStayDays] [numeric](18, 0) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
