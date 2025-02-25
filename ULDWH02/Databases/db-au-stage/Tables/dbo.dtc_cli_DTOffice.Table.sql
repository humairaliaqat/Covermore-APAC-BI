USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_DTOffice]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_DTOffice](
	[DTOffice_ID] [varchar](32) NOT NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](20) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](20) NULL,
	[OfficeName] [varchar](60) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](20) NULL,
	[State] [varchar](20) NULL,
	[PostCode] [varchar](10) NULL,
	[Country] [varchar](12) NULL,
	[PriPhone] [varchar](20) NULL,
	[FaxPhone] [varchar](20) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[OfficeType] [varchar](20) NULL,
	[LocationMapFile] [varchar](40) NULL,
	[IsKey] [int] NULL,
	[Region] [varchar](50) NULL,
	[BusinessUnit] [varchar](50) NULL,
	[FIFOSite] [int] NULL,
	[CustomerSite] [int] NULL,
	[CancelledApptEmail] [varchar](100) NULL,
	[OfficeManager] [varchar](50) NULL,
	[Status] [int] NULL,
	[DefaultModeOfService] [varchar](50) NULL,
	[Lat] [numeric](10, 6) NULL,
	[Long] [numeric](10, 6) NULL
) ON [PRIMARY]
GO
