USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rpt0491a_travellers]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rpt0491a_travellers](
	[PolicyKey] [varchar](41) NULL,
	[CustomerGivenName1] [varchar](100) NULL,
	[CustomerSurname1] [varchar](100) NULL,
	[CustomerDOB1] [varchar](10) NULL,
	[CustomerMemberNumber1] [varchar](25) NULL,
	[CustomerAge1] [varchar](5) NULL,
	[CustomerState1] [varchar](25) NULL,
	[CustomerPostcode1] [varchar](50) NULL,
	[CustomerHomePhone1] [varchar](50) NULL,
	[CustomerMobilePhone1] [varchar](50) NULL,
	[CustomerEmailAddress1] [varchar](255) NULL,
	[CustomerOptFurtherContact1] [varchar](1) NULL,
	[CustomerTitle1] [varchar](50) NULL
) ON [PRIMARY]
GO
