USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_OrgJobLocation]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_OrgJobLocation](
	[OrgJobLocation_ID] [varchar](32) NOT NULL,
	[Org_ID] [varchar](32) NULL,
	[LocationName] [varchar](50) NULL,
	[Addr1] [varchar](50) NULL,
	[Addr2] [varchar](50) NULL,
	[Suburb] [varchar](30) NULL,
	[State] [varchar](20) NULL,
	[Postcode] [varchar](10) NULL,
	[Phone] [varchar](25) NULL,
	[Fax] [varchar](25) NULL,
	[Contact] [varchar](50) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL
) ON [PRIMARY]
GO
