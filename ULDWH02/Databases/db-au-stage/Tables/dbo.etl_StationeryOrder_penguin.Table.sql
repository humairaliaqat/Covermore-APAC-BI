USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_StationeryOrder_penguin]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_StationeryOrder_penguin](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[StationeryKey] [varchar](71) NULL,
	[OutletAlphaKey] [nvarchar](61) NULL,
	[StationeryID] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[ConsultantInitial] [nvarchar](50) NOT NULL,
	[AgencyCode] [nvarchar](20) NOT NULL,
	[OptionsBrochure] [int] NULL,
	[OptionsPricingGuide] [int] NULL,
	[TravelsureBrochure] [int] NULL,
	[TravelsurePricingGuide] [int] NULL,
	[EssentialsBrochure] [int] NULL,
	[EssentialsPricingGuide] [int] NULL,
	[SaveMoreBrochure] [int] NULL,
	[BusinessBrochure] [int] NULL,
	[STABrochure] [int] NOT NULL,
	[STAPricingGuide] [int] NOT NULL,
	[CorporateBrochure] [int] NULL,
	[CorporateQuotes] [int] NOT NULL,
	[ComprehensiveBrochure] [int] NULL,
	[ComprehensivePricingGuide] [int] NULL,
	[BasicBrochure] [int] NULL,
	[BasicPricingGuide] [int] NULL,
	[ClaimForm] [int] NULL,
	[AssessmentForm] [int] NULL,
	[AssistanceCards] [int] NULL,
	[DeclarationPads] [int] NULL,
	[PolicyWallet] [int] NOT NULL,
	[SalesReturn] [int] NOT NULL,
	[QuickTips] [int] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[Email] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
