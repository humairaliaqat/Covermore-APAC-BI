USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_penPolicyAdminCallComment]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_penPolicyAdminCallComment](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](3) NOT NULL,
	[CallCommentKey] [varchar](41) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[CallCommentID] [int] NOT NULL,
	[PolicyID] [int] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[CRMUserID] [int] NULL,
	[CallDate] [datetime] NULL,
	[CallReason] [nvarchar](50) NULL,
	[CallComment] [nvarchar](max) NULL,
	[DomainID] [int] NULL,
	[CallDateUTC] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
