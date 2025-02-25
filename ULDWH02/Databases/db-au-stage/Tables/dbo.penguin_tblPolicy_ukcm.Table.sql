USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicy_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicy_ukcm](
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
	[IsCancellation] [bit] NOT NULL,
	[ExternalReference] [nvarchar](75) NULL,
	[DomainId] [int] NOT NULL,
	[CurrencyCode] [varchar](3) NOT NULL,
	[PreviousPolicyNumber] [varchar](25) NULL,
	[CultureCode] [nvarchar](20) NULL,
	[AreaCode] [nvarchar](3) NULL,
	[ReferredBy] [nvarchar](50) NULL,
	[InitialDepositDate] [datetime] NULL,
	[IsResident] [bit] NULL,
	[ExternalReference1] [nvarchar](75) NULL,
	[ExternalReference2] [nvarchar](75) NULL,
	[ExternalReference3] [nvarchar](75) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicy_ukcm_PolicyID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPolicy_ukcm_PolicyID] ON [dbo].[penguin_tblPolicy_ukcm]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicy_ukcm_DomainID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblPolicy_ukcm_DomainID] ON [dbo].[penguin_tblPolicy_ukcm]
(
	[PolicyID] ASC
)
INCLUDE([DomainId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicy_ukcm_QuotePlanID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblPolicy_ukcm_QuotePlanID] ON [dbo].[penguin_tblPolicy_ukcm]
(
	[QuotePlanID] ASC
)
INCLUDE([PolicyNumber],[PolicyID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
