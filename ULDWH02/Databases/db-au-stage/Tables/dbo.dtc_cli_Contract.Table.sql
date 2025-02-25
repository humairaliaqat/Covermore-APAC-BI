USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Contract]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Contract](
	[Contract_id] [varchar](32) NOT NULL,
	[ContractType] [varchar](3) NULL,
	[Per_ID] [varchar](32) NULL,
	[SubLevel_ID] [varchar](32) NULL,
	[Group_ID] [varchar](32) NULL,
	[Org_ID] [varchar](32) NULL,
	[ContractNumber] [varchar](10) NULL,
	[Description] [varchar](255) NULL,
	[StatusFlag] [varchar](30) NULL,
	[ProviderState] [varchar](10) NULL,
	[OwnerState] [varchar](10) NULL,
	[AccountMngr] [varchar](50) NULL,
	[Contact_Person_ID] [varchar](32) NULL,
	[Invoice_Person_ID] [varchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[NoMoreJobsDate] [datetime] NULL,
	[NoMoreWorkDate] [datetime] NULL,
	[RptStartDate] [datetime] NULL,
	[NotesItem] [int] NULL,
	[ReportingIntPeriod] [varchar](10) NULL,
	[ReportingIntPeriodNr] [int] NULL,
	[Notes] [varchar](255) NULL,
	[Alert] [varchar](255) NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](20) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](20) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[Formal] [smallint] NULL,
	[DebtorCode] [varchar](20) NULL,
	[IsExpUnNeg] [smallint] NULL,
	[IsResigned] [smallint] NULL,
	[IsLost] [smallint] NULL,
	[PACompanyCode] [varchar](10) NULL,
	[CurrencyCode] [varchar](3) NULL,
	[DefaultGSTCode] [varchar](10) NULL,
	[PurchaseOrderNum] [varchar](30) NULL,
	[DisplayOrgName] [varchar](80) NULL,
	[ProjectName] [varchar](32) NULL,
	[NegotationDate] [datetime] NULL
) ON [PRIMARY]
GO
