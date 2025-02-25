USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Group]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Group](
	[Group_ID] [varchar](32) NOT NULL,
	[Org_ID] [varchar](32) NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](20) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](20) NULL,
	[GroupName] [varchar](80) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](20) NULL,
	[State] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[Country] [varchar](12) NULL,
	[PriPhone] [varchar](20) NULL,
	[AltPhone] [varchar](20) NULL,
	[FaxPhone] [varchar](20) NULL,
	[Alert] [varchar](255) NULL,
	[InActive] [smallint] NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[Parent_Group_Id] [varchar](32) NULL,
	[Level] [int] NULL,
	[Cost_Centre_Code] [varchar](50) NULL,
	[StateBelongTo] [varchar](50) NULL,
	[Invoice_Person_ID] [varchar](32) NULL,
	[PurchaseOrderNumber] [varchar](20) NULL,
	[DisplayOrgName] [varchar](80) NULL
) ON [PRIMARY]
GO
