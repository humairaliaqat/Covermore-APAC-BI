USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penOutlet_20230602]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penOutlet_20230602](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[OutletKey] [varchar](33) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[OutletSKey] [bigint] IDENTITY(1000,1) NOT NULL,
	[OutletStatus] [varchar](20) NOT NULL,
	[OutletStartDate] [datetime] NOT NULL,
	[OutletEndDate] [datetime] NULL,
	[OutletHashKey] [binary](30) NULL,
	[OutletID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[SubGroupID] [int] NOT NULL,
	[OutletTypeID] [int] NOT NULL,
	[OutletName] [nvarchar](50) NOT NULL,
	[OutletType] [nvarchar](50) NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[StatusValue] [int] NOT NULL,
	[CommencementDate] [datetime] NULL,
	[CloseDate] [datetime] NULL,
	[PreviousAlpha] [nvarchar](20) NULL,
	[StatusRegionID] [int] NULL,
	[StatusRegion] [nvarchar](50) NULL,
	[ContactTitle] [nvarchar](100) NULL,
	[ContactInitial] [nvarchar](50) NULL,
	[ContactFirstName] [nvarchar](50) NULL,
	[ContactLastName] [nvarchar](50) NULL,
	[ContactManagerEmail] [nvarchar](100) NULL,
	[ContactPhone] [nvarchar](50) NULL,
	[ContactFax] [nvarchar](50) NULL,
	[ContactEmail] [nvarchar](100) NULL,
	[ContactStreet] [nvarchar](100) NULL,
	[ContactSuburb] [nvarchar](52) NULL,
	[ContactState] [nvarchar](100) NULL,
	[ContactPostCode] [nvarchar](50) NULL,
	[ContactPOBox] [nvarchar](100) NULL,
	[ContactMailSuburb] [nvarchar](52) NULL,
	[ContactMailState] [nvarchar](100) NULL,
	[ContactMailPostCode] [nvarchar](50) NULL,
	[GroupDomainID] [int] NOT NULL,
	[SuperGroupName] [nvarchar](25) NULL,
	[GroupName] [nvarchar](50) NOT NULL,
	[GroupCode] [nvarchar](50) NOT NULL,
	[GroupStartDate] [datetime] NOT NULL,
	[GroupPhone] [nvarchar](50) NULL,
	[GroupFax] [nvarchar](50) NULL,
	[GroupEmail] [nvarchar](100) NULL,
	[GroupStreet] [nvarchar](100) NULL,
	[GroupSuburb] [nvarchar](50) NULL,
	[GroupPostCode] [nvarchar](10) NULL,
	[GroupMailSuburb] [nvarchar](50) NULL,
	[GroupMailState] [nvarchar](100) NULL,
	[GroupMailPostCode] [nvarchar](10) NULL,
	[GroupPOBox] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[SubGroupCode] [nvarchar](50) NULL,
	[SubGroupStartDate] [datetime] NULL,
	[SubGroupPhone] [nvarchar](50) NULL,
	[SubGroupFax] [nvarchar](50) NULL,
	[SubGroupEmail] [nvarchar](100) NULL,
	[SubGroupStreet] [nvarchar](100) NULL,
	[SubGroupSuburb] [nvarchar](50) NULL,
	[SubGroupPostCode] [nvarchar](10) NULL,
	[SubGroupMailSuburb] [nvarchar](50) NULL,
	[SubGroupMailState] [nvarchar](100) NULL,
	[SubGroupMailPostCode] [nvarchar](10) NULL,
	[SubGroupPOBox] [nvarchar](50) NULL,
	[AcctOfficerTitle] [nvarchar](50) NULL,
	[AcctOfficerFirstName] [nvarchar](50) NULL,
	[AcctOfficerLastName] [nvarchar](50) NULL,
	[AcctOfficerEmail] [nvarchar](100) NULL,
	[PaymentTypeID] [int] NULL,
	[PaymentType] [nvarchar](50) NULL,
	[AccountName] [nvarchar](100) NULL,
	[BSB] [nvarchar](50) NULL,
	[AccountNumber] [nvarchar](200) NULL,
	[AccountsEmail] [nvarchar](100) NULL,
	[CCSaleOnly] [int] NULL,
	[FSRTypeID] [int] NULL,
	[FSRType] [nvarchar](50) NULL,
	[FSGCategoryID] [int] NULL,
	[FSGCategory] [nvarchar](50) NULL,
	[LegalEntityName] [nvarchar](100) NULL,
	[ASICNumber] [nvarchar](50) NULL,
	[ABN] [nvarchar](50) NULL,
	[ASICCheckDate] [datetime] NULL,
	[AgreementDate] [datetime] NULL,
	[BDMID] [int] NULL,
	[BDMName] [nvarchar](101) NULL,
	[BDMCallFreqID] [int] NULL,
	[BDMCallFrequency] [nvarchar](50) NULL,
	[AcctManagerID] [int] NULL,
	[AcctManagerName] [nvarchar](101) NULL,
	[AcctMgrCallFreqID] [int] NULL,
	[AcctMgrCallFrequency] [nvarchar](50) NULL,
	[AdminExecID] [int] NULL,
	[AdminExecName] [nvarchar](101) NULL,
	[ExtID] [nvarchar](20) NULL,
	[ExtBDMID] [int] NULL,
	[ExternalBDMName] [nvarchar](50) NULL,
	[SalesSegment] [nvarchar](50) NULL,
	[PotentialSales] [money] NULL,
	[SalesTierID] [int] NULL,
	[SalesTier] [nvarchar](50) NULL,
	[Branch] [nvarchar](60) NULL,
	[Website] [varchar](100) NULL,
	[EGMNationID] [int] NULL,
	[EGMNation] [nvarchar](50) NULL,
	[FCNationID] [int] NULL,
	[FCNation] [nvarchar](50) NULL,
	[FCAreaID] [int] NULL,
	[FCArea] [nvarchar](50) NULL,
	[STARegionID] [int] NULL,
	[STARegion] [nvarchar](50) NULL,
	[StateSalesAreaID] [int] NULL,
	[StateSalesArea] [nvarchar](50) NULL,
	[TradingStatus] [nvarchar](50) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[EncryptedAccountNumber] [varbinary](max) NULL,
	[FCAreaCode] [nvarchar](50) NULL,
	[LatestOutletKey] [varchar](33) NULL,
	[AgencyGrading] [nvarchar](50) NULL,
	[DistributorKey] [varchar](33) NULL,
	[DistributorID] [int] NULL,
	[JVID] [int] NULL,
	[JV] [nvarchar](55) NULL,
	[JVCode] [nvarchar](10) NULL,
	[ChannelID] [int] NULL,
	[Channel] [nvarchar](100) NULL,
	[AMIArea] [nvarchar](50) NULL,
	[AMIAreaCode] [nvarchar](50) NULL,
	[AMINation] [nvarchar](50) NULL,
	[AMIEGMNation] [nvarchar](50) NULL,
	[SugarCRMID] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
