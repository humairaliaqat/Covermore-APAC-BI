USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_org]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_org](
	[Org_ID] [varchar](32) NOT NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](20) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](20) NULL,
	[OrgName] [varchar](80) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](20) NULL,
	[State] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[Country] [varchar](12) NULL,
	[TimeZone] [varchar](16) NULL,
	[URL] [varchar](255) NULL,
	[PriPhone] [varchar](20) NULL,
	[AltPhone] [varchar](20) NULL,
	[FaxPhone] [varchar](20) NULL,
	[Comments] [varchar](255) NULL,
	[AcctMgr] [varchar](20) NULL,
	[AccountNumber] [varchar](32) NULL,
	[Industry] [varchar](50) NULL,
	[EmployeeCnt] [int] NULL,
	[AnnualRevenue] [money] NULL,
	[GrowthTrend] [varchar](20) NULL,
	[YearEndMonth] [varchar](10) NULL,
	[SIC] [varchar](10) NULL,
	[DUNS] [varchar](9) NULL,
	[StockExchange] [varchar](20) NULL,
	[StockTickerSymbol] [varchar](5) NULL,
	[CustType] [varchar](20) NULL,
	[CustSince] [datetime] NULL,
	[IsCustomer] [smallint] NULL,
	[InActive] [smallint] NULL,
	[IsReferenceable] [smallint] NULL,
	[RefVerificationDate] [datetime] NULL,
	[ReferenceNotes] [text] NULL,
	[ResellerOrg_ID] [varchar](32) NULL,
	[ResellerGroup_ID] [varchar](32) NULL,
	[SalesArea_ID] [varchar](32) NULL,
	[TerritoryName] [varchar](50) NULL,
	[Alert] [varchar](255) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[Job_reporting_level] [int] NULL,
	[Region] [varchar](50) NULL,
	[PrioritySeq] [varchar](50) NULL,
	[ConDepCode] [varchar](50) NULL,
	[upsize_ts] [int] NULL,
	[WDAClientCode] [varchar](20) NULL,
	[WDADebtorCode] [varchar](20) NULL,
	[ABNNr] [varchar](11) NULL,
	[Invoice_reporting_level] [int] NULL,
	[Job_cat_required] [smallint] NULL,
	[KeyAccount] [smallint] NULL,
	[CreditsOnSummary] [bit] NOT NULL,
	[PurchaseOrderNum] [varchar](30) NULL,
	[DisplayOrgName] [varchar](80) NULL,
	[IndividualsSplitPDF] [bit] NULL,
	[ParentOrg] [varchar](32) NULL,
	[ParentRevenueOrg] [varchar](32) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Org_AcctMgr]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Org_AcctMgr] ON [dbo].[dtc_cli_org]
(
	[AcctMgr] ASC
)
INCLUDE([Org_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
