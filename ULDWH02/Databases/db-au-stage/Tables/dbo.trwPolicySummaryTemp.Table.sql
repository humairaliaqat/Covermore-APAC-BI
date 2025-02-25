USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwPolicySummaryTemp]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwPolicySummaryTemp](
	[PolicyDetailID] [int] NULL,
	[PolicySK] [int] NULL,
	[EmployeeSK] [int] NULL,
	[AgentEmployeeSK] [int] NULL,
	[SellingPlanSK] [int] NULL,
	[InvoiceSK] [int] NULL,
	[PolicyNumber] [numeric](22, 0) NULL,
	[OrgStatus] [nvarchar](50) NULL,
	[CurStatus] [nvarchar](50) NULL,
	[Endorsement] [numeric](18, 0) NULL,
	[ActualPolicyCount] [int] NULL,
	[EndorsementDate] [date] NULL,
	[EndorsementDateTime] [datetime] NULL,
	[YAGOEndorsementDate] [date] NULL,
	[DateOfPolicyCancelled] [date] NULL,
	[DateTimeOfPolicyCancelled] [datetime] NULL,
	[YAGODateOfPolicyCancelled] [date] NULL,
	[DateOfPolicy] [date] NULL,
	[DateTimeOfPolicy] [datetime] NULL,
	[YAGODateOfPolicy] [date] NULL,
	[PassportNumber] [nvarchar](50) NULL,
	[DepartureDate] [datetime] NULL,
	[Days] [numeric](18, 0) NULL,
	[DaySlab] [nvarchar](50) NULL,
	[ArrivalDate] [datetime] NULL,
	[Name] [nvarchar](50) NULL,
	[DOB] [datetime] NULL,
	[Age] [numeric](18, 0) NULL,
	[AgeSlab] [nvarchar](50) NULL,
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
	[ActualTdsAmount] [numeric](18, 2) NULL,
	[ActualComissionAmount] [numeric](18, 2) NULL,
	[ActualoldTApremium] [numeric](18, 2) NULL,
	[ActualNewTApremium] [numeric](18, 2) NULL,
	[ActualTApremim] [numeric](18, 2) NULL,
	[Remarks] [ntext] NULL,
	[CreatedDate] [date] NULL,
	[CreatedDateTime] [datetime] NULL,
	[YAGOCreatedDate] [date] NULL,
	[pdfreference] [nvarchar](max) NULL,
	[ManualPremiumTotal] [numeric](18, 2) NULL,
	[ManualPremiumBasic] [numeric](18, 2) NULL,
	[ManualPremiumServiceTax] [numeric](18, 2) NULL,
	[sponsorname] [nvarchar](max) NULL,
	[sponsorrelation] [nvarchar](max) NULL,
	[Rider] [nvarchar](max) NULL,
	[hashkey] [varbinary](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_trwPolicyTemp_PolicyDetailID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_trwPolicyTemp_PolicyDetailID] ON [dbo].[trwPolicySummaryTemp]
(
	[PolicyDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwPolicyTemp_AgentEmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwPolicyTemp_AgentEmployeeID] ON [dbo].[trwPolicySummaryTemp]
(
	[AgentEmployeeSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwPolicyTemp_EmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwPolicyTemp_EmployeeID] ON [dbo].[trwPolicySummaryTemp]
(
	[EmployeeSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_trwPolicyTemp_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwPolicyTemp_HashKey] ON [dbo].[trwPolicySummaryTemp]
(
	[hashkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwPolicyTemp_InvoiceID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwPolicyTemp_InvoiceID] ON [dbo].[trwPolicySummaryTemp]
(
	[InvoiceSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwPolicyTemp_PolicyID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwPolicyTemp_PolicyID] ON [dbo].[trwPolicySummaryTemp]
(
	[PolicySK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwPolicyTemp_SellingPlanID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwPolicyTemp_SellingPlanID] ON [dbo].[trwPolicySummaryTemp]
(
	[SellingPlanSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
