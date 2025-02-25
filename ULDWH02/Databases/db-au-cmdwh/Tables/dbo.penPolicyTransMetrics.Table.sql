USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransMetrics]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransMetrics](
	[PolicyTransactionKey] [varchar](41) NOT NULL,
	[NewPolicyCount] [int] NOT NULL,
	[BasePolicyCount] [int] NOT NULL,
	[AddonPolicyCount] [int] NOT NULL,
	[ExtensionPolicyCount] [int] NOT NULL,
	[CancelledPolicyCount] [int] NOT NULL,
	[CancelledAddonPolicyCount] [int] NOT NULL,
	[CANXPolicyCount] [int] NOT NULL,
	[DomesticPolicyCount] [int] NOT NULL,
	[InternationalPolicyCount] [int] NOT NULL,
	[TravellersCount] [int] NOT NULL,
	[AdultsCount] [int] NOT NULL,
	[ChildrenCount] [int] NOT NULL,
	[ChargedAdultsCount] [int] NOT NULL,
	[DomesticTravellersCount] [int] NOT NULL,
	[DomesticAdultsCount] [int] NOT NULL,
	[DomesticChildrenCount] [int] NOT NULL,
	[DomesticChargedAdultsCount] [int] NOT NULL,
	[InternationalTravellersCount] [int] NOT NULL,
	[InternationalAdultsCount] [int] NOT NULL,
	[InternationalChildrenCount] [int] NOT NULL,
	[InternationalChargedAdultsCount] [int] NOT NULL,
	[NumberofDays] [int] NOT NULL,
	[LuggageCount] [int] NOT NULL,
	[MedicalCount] [int] NOT NULL,
	[MotorcycleCount] [int] NOT NULL,
	[RentalCarCount] [int] NOT NULL,
	[WintersportCount] [int] NOT NULL,
	[AttachmentCount] [int] NOT NULL,
	[EMCCount] [int] NOT NULL,
	[InternationalNewPolicyCount] [int] NOT NULL,
	[InternationalCANXPolicyCount] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransMetrics_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTransMetrics_PolicyTransactionKey] ON [dbo].[penPolicyTransMetrics]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [NewPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [BasePolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [AddonPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [ExtensionPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [CancelledPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [CancelledAddonPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [CANXPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [DomesticPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [InternationalPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [TravellersCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [AdultsCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [ChildrenCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [ChargedAdultsCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [DomesticTravellersCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [DomesticAdultsCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [DomesticChildrenCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [DomesticChargedAdultsCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [InternationalTravellersCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [InternationalAdultsCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [InternationalChildrenCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [InternationalChargedAdultsCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [NumberofDays]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [LuggageCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [MedicalCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [MotorcycleCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [RentalCarCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [WintersportCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [AttachmentCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [EMCCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [InternationalNewPolicyCount]
GO
ALTER TABLE [dbo].[penPolicyTransMetrics] ADD  DEFAULT ((0)) FOR [InternationalCANXPolicyCount]
GO
