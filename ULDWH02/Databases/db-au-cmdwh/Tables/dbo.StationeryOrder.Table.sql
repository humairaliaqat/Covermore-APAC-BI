USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[StationeryOrder]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StationeryOrder](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NULL,
	[StationeryID] [int] NOT NULL,
	[DateCreated] [datetime] NULL,
	[ConsultantInitial] [nvarchar](20) NULL,
	[AgencyCode] [nvarchar](20) NULL,
	[OptionsBrochure] [int] NULL,
	[OptionsPricingGuide] [int] NULL,
	[TravelsureBrochure] [int] NULL,
	[TravelsurePricingGuide] [int] NULL,
	[EssentialsBrochure] [int] NULL,
	[EssentialsPricingGuide] [int] NULL,
	[SaveMoreBrochure] [int] NULL,
	[BusinessBrochure] [int] NULL,
	[STABrochure] [int] NULL,
	[STAPricingGuide] [int] NULL,
	[CorporateBrochure] [int] NULL,
	[CorporateQuotes] [int] NULL,
	[ComprehensiveBrochure] [int] NULL,
	[ComprehensivePricingGuide] [int] NULL,
	[BasicBrochure] [int] NULL,
	[BasicPricingGuide] [int] NULL,
	[ClaimForm] [int] NULL,
	[AssessmentForm] [int] NULL,
	[AssistanceCards] [int] NULL,
	[DeclarationPads] [int] NULL,
	[PolicyWallet] [int] NULL,
	[SalesReturn] [int] NULL,
	[QuickTips] [int] NULL,
	[Comments] [nvarchar](max) NULL,
	[Email] [nvarchar](200) NULL,
	[StationeryKey] [varchar](41) NULL,
	[OutletAlphaKey] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_StationeryOrder_StationeryID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_StationeryOrder_StationeryID] ON [dbo].[StationeryOrder]
(
	[StationeryID] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_StationeryOrder_AgencyCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_StationeryOrder_AgencyCode] ON [dbo].[StationeryOrder]
(
	[AgencyCode] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_StationeryOrder_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_StationeryOrder_CountryKey] ON [dbo].[StationeryOrder]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_StationeryOrder_DateCreated]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_StationeryOrder_DateCreated] ON [dbo].[StationeryOrder]
(
	[DateCreated] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_StationeryOrder_OutletAlphaKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_StationeryOrder_OutletAlphaKey] ON [dbo].[StationeryOrder]
(
	[OutletAlphaKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_StationeryOrder_StationeryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_StationeryOrder_StationeryKey] ON [dbo].[StationeryOrder]
(
	[StationeryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
