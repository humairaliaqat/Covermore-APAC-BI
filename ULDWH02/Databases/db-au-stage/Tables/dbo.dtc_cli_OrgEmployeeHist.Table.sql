USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_OrgEmployeeHist]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_OrgEmployeeHist](
	[OrgEmployeeHist_ID] [varchar](32) NOT NULL,
	[Org_ID] [varchar](32) NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](50) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](50) NULL,
	[AsAtDate] [datetime] NULL,
	[employeeCnt] [int] NULL,
	[RSSiteID] [varchar](50) NULL,
	[RSArriveDate] [datetime] NULL,
	[RSChangeDate] [datetime] NULL,
	[Group_ID] [varchar](32) NULL,
	[SubLevel_ID] [varchar](32) NULL
) ON [PRIMARY]
GO
