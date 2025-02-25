USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penAUDIT_Policy]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penAUDIT_Policy](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[AuditPolicyKey] [varchar](71) NULL,
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_RECORDTYPE] [varchar](255) NULL,
	[Audit_DateTime] [datetime] NULL,
	[AUDIT_DATETIME_UTC] [datetime] NULL,
	[AUDIT_PolicyID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[PolicyNumber] [varchar](25) NULL,
	[QuotePlanID] [int] NOT NULL,
	[AlphaCode] [nvarchar](60) NULL,
	[IssueDate] [datetime] NOT NULL,
	[CancelledDate] [datetime] NULL,
	[PolicyStatus] [int] NULL,
	[Area] [nvarchar](100) NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[AffiliateReference] [nvarchar](200) NULL,
	[HowDidYouHear] [nvarchar](200) NULL,
	[AffiliateComments] [varchar](500) NULL,
	[GroupName] [nvarchar](100) NULL,
	[CompanyName] [nvarchar](100) NULL,
	[IsCancellation] [bit] NULL,
	[ExternalReference] [nvarchar](75) NULL,
	[DomainId] [int] NOT NULL,
	[CurrencyCode] [varchar](3) NOT NULL,
	[PreviousPolicyNumber] [varchar](25) NULL,
	[CultureCode] [nvarchar](20) NULL,
	[AreaCode] [nvarchar](3) NULL,
	[InitialDepositDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
