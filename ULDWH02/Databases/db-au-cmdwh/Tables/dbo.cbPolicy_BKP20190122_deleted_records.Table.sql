USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbPolicy_BKP20190122_deleted_records]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbPolicy_BKP20190122_deleted_records](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[TRIPSPolicyKey] [nvarchar](41) NULL,
	[PolicyTransactionKey] [nvarchar](41) NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[IsMainPolicy] [bit] NOT NULL,
	[PolicyNo] [nvarchar](25) NULL,
	[IssueDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[VerifyDate] [datetime] NULL,
	[VerifiedBy] [nvarchar](10) NULL,
	[ConsultantInitial] [nvarchar](30) NULL,
	[PolicyType] [nvarchar](25) NULL,
	[SingleFamily] [nvarchar](15) NULL,
	[PlanCode] [nvarchar](15) NULL,
	[DepartureDate] [datetime] NULL,
	[InsurerName] [nvarchar](20) NULL,
	[Excess] [int] NULL,
	[ProductCode] [nvarchar](3) NULL
) ON [PRIMARY]
GO
