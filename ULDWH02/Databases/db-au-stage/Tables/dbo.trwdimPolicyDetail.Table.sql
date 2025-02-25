USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimPolicyDetail]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimPolicyDetail](
	[PolicyDetailSK] [int] IDENTITY(1,1) NOT NULL,
	[PolicyDetailID] [int] NOT NULL,
	[PolicyID] [numeric](18, 0) NULL,
	[Endorsement] [numeric](18, 0) NULL,
	[EndorsementDate] [datetime] NULL,
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
	[BasePremium] [numeric](18, 2) NULL,
	[Premium] [numeric](18, 2) NULL,
	[RiderPercent] [numeric](18, 2) NULL,
	[RiderPremium] [numeric](18, 2) NULL,
	[NewPremium] [numeric](18, 2) NULL,
	[OldPremium] [numeric](18, 2) NULL,
	[TotalAmount] [numeric](18, 2) NULL,
	[ServiceTaxRate] [numeric](18, 2) NULL,
	[CESS1Rate] [numeric](18, 2) NULL,
	[CESS2Rate] [numeric](18, 2) NULL,
	[ServiceTax] [numeric](18, 2) NULL,
	[CESS1] [numeric](18, 2) NULL,
	[CESS2] [numeric](18, 2) NULL,
	[GrossAmount] [numeric](18, 2) NULL,
	[DiscountPercent] [numeric](18, 2) NULL,
	[DiscountAmount] [numeric](18, 2) NULL,
	[DiscountServiceTax] [numeric](18, 2) NULL,
	[DiscountCESS1] [numeric](18, 2) NULL,
	[DiscountCESS2] [numeric](18, 2) NULL,
	[NetServiceTax] [numeric](18, 2) NULL,
	[NetCESS1] [numeric](18, 2) NULL,
	[NetCESS2] [numeric](18, 2) NULL,
	[NetAmount] [numeric](18, 2) NULL,
	[InvoiceID] [int] NULL,
	[AgentCommissionDocumentID] [int] NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [nvarchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[OldRiderPremium] [numeric](18, 2) NULL,
	[OldTotalAmount] [numeric](18, 2) NULL,
	[ActualNewPremium] [numeric](18, 2) NULL,
	[ActualOldPremium] [numeric](18, 2) NULL,
	[ActualTotalAmount] [numeric](18, 2) NULL,
	[ActualServiceTax] [numeric](18, 2) NULL,
	[ActualCESS1] [numeric](18, 2) NULL,
	[ActualCESS2] [numeric](18, 2) NULL,
	[ActualGrossAmount] [numeric](18, 2) NULL,
	[ActualDiscountPercent] [numeric](18, 2) NULL,
	[ActualDiscountAmount] [numeric](18, 2) NULL,
	[ActualDiscountServiceTax] [numeric](18, 2) NULL,
	[ActualDiscountCESS1] [numeric](18, 2) NULL,
	[ActualDiscountCESS2] [numeric](18, 2) NULL,
	[ActualNetServiceTax] [numeric](18, 2) NULL,
	[ActualNetCESS1] [numeric](18, 2) NULL,
	[ActualNetCESS2] [numeric](18, 2) NULL,
	[ActualNetAmount] [numeric](18, 2) NULL,
	[Actualoldinsurancecost] [numeric](18, 2) NULL,
	[ActualNewinsurancecost] [numeric](18, 2) NULL,
	[Actualinsurancecost] [numeric](18, 2) NULL,
	[CreditNoteId] [numeric](18, 0) NULL,
	[ActualTdsAmount] [numeric](18, 2) NULL,
	[ActualComissionAmount] [numeric](18, 2) NULL,
	[ActualoldTApremium] [numeric](18, 2) NULL,
	[ActualNewTApremium] [numeric](18, 2) NULL,
	[ActualTApremim] [numeric](18, 2) NULL,
	[Remarks] [ntext] NULL,
	[pdfreference] [nvarchar](max) NULL,
	[DebitNoteId] [numeric](18, 0) NULL,
	[ManualPremiumTotal] [numeric](18, 2) NULL,
	[ManualPremiumBasic] [numeric](18, 2) NULL,
	[ManualPremiumServiceTax] [numeric](18, 2) NULL,
	[sponsorname] [nvarchar](max) NULL,
	[sponsorrelation] [nvarchar](max) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyDetail_PolicyDetailSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimPolicyDetail_PolicyDetailSK] ON [dbo].[trwdimPolicyDetail]
(
	[PolicyDetailSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyDetail_AgentEmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyDetail_AgentEmployeeID] ON [dbo].[trwdimPolicyDetail]
(
	[InsuranceCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyDetail_CreditNoteId]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyDetail_CreditNoteId] ON [dbo].[trwdimPolicyDetail]
(
	[CreditNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyDetail_EmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyDetail_EmployeeID] ON [dbo].[trwdimPolicyDetail]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimPolicyDetail_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyDetail_HashKey] ON [dbo].[trwdimPolicyDetail]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyDetail_PolicyID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyDetail_PolicyID] ON [dbo].[trwdimPolicyDetail]
(
	[PolicyDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyDetail_ReferralAgentID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyDetail_ReferralAgentID] ON [dbo].[trwdimPolicyDetail]
(
	[SellingPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
