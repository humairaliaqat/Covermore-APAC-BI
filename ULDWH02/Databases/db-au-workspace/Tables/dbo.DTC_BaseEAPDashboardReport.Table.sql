USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTC_BaseEAPDashboardReport]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_BaseEAPDashboardReport](
	[Job_Num] [varchar](20) NOT NULL,
	[Job_id] [varchar](32) NOT NULL,
	[BusinessUnit] [varchar](32) NULL,
	[SubLevel] [varchar](32) NULL,
	[trx_ctrl_num] [varchar](16) NOT NULL,
	[tran_date] [datetime] NOT NULL,
	[qty] [numeric](18, 2) NOT NULL,
	[ranked] [int] NOT NULL,
	[activity_code] [varchar](10) NOT NULL,
	[activity_desc] [varchar](40) NOT NULL,
	[modality] [varchar](20) NULL,
	[ServiceType] [varchar](30) NOT NULL,
	[NativeServiceType] [varchar](30) NOT NULL,
	[Org_ID] [varchar](32) NOT NULL,
	[EmployeeFamilyMember] [varchar](8) NOT NULL,
	[EmployeeCount] [int] NULL,
	[BUEmployeeCount] [int] NULL,
	[SLEmployeeCount] [int] NULL,
	[Primary Presenting Issue Sub-Category] [varchar](100) NULL,
	[Nature of Work Impact] [varchar](50) NULL,
	[Counselling Type] [varchar](50) NULL,
	[TopCat] [varchar](20) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_1]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_1] ON [dbo].[DTC_BaseEAPDashboardReport]
(
	[Org_ID] ASC,
	[tran_date] ASC,
	[qty] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
