USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimPolicyEndorsementRequest]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimPolicyEndorsementRequest](
	[PolicyEndorsementRequestSK] [int] IDENTITY(1,1) NOT NULL,
	[PolicyEndorsementRequestID] [int] NOT NULL,
	[PolicyID] [int] NULL,
	[RequesterEntityID] [int] NULL,
	[PassportNumber] [nvarchar](50) NULL,
	[InsuranceCategoryID] [int] NULL,
	[SellingPlanID] [int] NULL,
	[DepartureDate] [datetime] NULL,
	[Days] [numeric](18, 0) NULL,
	[ArrivalDate] [datetime] NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[City] [nvarchar](50) NULL,
	[District] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[PinCode] [nvarchar](10) NULL,
	[Country] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](50) NULL,
	[MobileNo] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[UniversityName] [nvarchar](100) NULL,
	[UniversityAddress] [nvarchar](1000) NULL,
	[Name] [nvarchar](50) NULL,
	[DOB] [datetime] NULL,
	[Age] [numeric](18, 0) NULL,
	[TrawellTagNumber] [numeric](18, 0) NULL,
	[Nominee] [nvarchar](50) NULL,
	[Relation] [nvarchar](50) NULL,
	[PastIllness] [nvarchar](1000) NULL,
	[RestrictedCoverage] [bit] NULL,
	[NewPassportNumber] [nvarchar](50) NULL,
	[NewInsuranceCategoryID] [int] NULL,
	[NewSellingPlanID] [int] NULL,
	[NewDepartureDate] [datetime] NULL,
	[NewDays] [numeric](18, 0) NULL,
	[NewArrivalDate] [datetime] NULL,
	[NewAddress1] [nvarchar](500) NULL,
	[NewAddress2] [nvarchar](500) NULL,
	[NewCity] [nvarchar](50) NULL,
	[NewDistrict] [nvarchar](50) NULL,
	[NewState] [nvarchar](50) NULL,
	[NewPinCode] [nvarchar](10) NULL,
	[NewCountry] [nvarchar](100) NULL,
	[NewPhoneNo] [nvarchar](50) NULL,
	[NewMobileNo] [nvarchar](50) NULL,
	[NewEmailAddress] [nvarchar](50) NULL,
	[NewUniversityName] [nvarchar](100) NULL,
	[NewUniversityAddress] [nvarchar](1000) NULL,
	[NewName] [nvarchar](50) NULL,
	[NewDOB] [datetime] NULL,
	[NewAge] [numeric](18, 0) NULL,
	[NewTrawellTagNumber] [numeric](18, 0) NULL,
	[NewNominee] [nvarchar](50) NULL,
	[NewRelation] [nvarchar](50) NULL,
	[NewPastIllness] [nvarchar](1000) NULL,
	[NewRestrictedCoverage] [bit] NULL,
	[OldPremium] [numeric](18, 2) NULL,
	[NewPremium] [numeric](18, 2) NULL,
	[Reason] [nvarchar](1000) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[ProcessedByEntityID] [int] NULL,
	[Status] [nvarchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [nvarchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[Documentfile] [nvarchar](400) NULL,
	[pdfreference] [nvarchar](300) NULL,
	[Newpdfreference] [nvarchar](300) NULL,
	[OldDiscountPercent] [numeric](18, 2) NULL,
	[NewDiscountPercent] [numeric](18, 2) NULL,
	[AmountDifference] [numeric](18, 2) NULL,
	[sponsorname] [nvarchar](max) NULL,
	[sponsorrelation] [nvarchar](max) NULL,
	[newsponsorname] [nvarchar](max) NULL,
	[newsponsorrelation] [nvarchar](max) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyEndorsementRequest_PolicyEndorsementRequestSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimPolicyEndorsementRequest_PolicyEndorsementRequestSK] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[PolicyEndorsementRequestSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_NewInsuranceCategoryID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_NewInsuranceCategoryID] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[NewInsuranceCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimPolicyEndorsementRequest_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyEndorsementRequest_HashKey] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyEndorsementRequest_InsuranceCategoryID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyEndorsementRequest_InsuranceCategoryID] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[InsuranceCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyEndorsementRequest_NewSellingPlanID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyEndorsementRequest_NewSellingPlanID] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[NewSellingPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyEndorsementRequest_PolicyEndorsementRequestID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyEndorsementRequest_PolicyEndorsementRequestID] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[PolicyEndorsementRequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyEndorsementRequest_PolicyID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyEndorsementRequest_PolicyID] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyEndorsementRequest_RequesterEntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyEndorsementRequest_RequesterEntityID] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[RequesterEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyEndorsementRequest_SellingPlanID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyEndorsementRequest_SellingPlanID] ON [dbo].[trwdimPolicyEndorsementRequest]
(
	[SellingPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
