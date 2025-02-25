USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Person]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Person](
	[Per_ID] [varchar](32) NOT NULL,
	[Group_ID] [varchar](32) NULL,
	[Org_ID] [varchar](32) NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](20) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](20) NULL,
	[LastName] [varchar](20) NULL,
	[FirstName] [varchar](15) NULL,
	[Salutation] [varchar](20) NULL,
	[Title] [varchar](80) NULL,
	[Role] [varchar](30) NULL,
	[ReportsTo] [varchar](40) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[City] [varchar](20) NULL,
	[State] [varchar](20) NULL,
	[Zip] [varchar](10) NULL,
	[Country] [varchar](12) NULL,
	[EmailAddress] [varchar](80) NULL,
	[PriPhone] [varchar](20) NULL,
	[AltPhone] [varchar](20) NULL,
	[FaxPhone] [varchar](20) NULL,
	[CellPhone] [varchar](20) NULL,
	[Pager] [varchar](20) NULL,
	[InActive] [smallint] NULL,
	[IsReferenceContact] [smallint] NULL,
	[SkillLevel] [varchar](16) NULL,
	[Comments] [varchar](255) NULL,
	[NoMailings] [smallint] NULL,
	[Alert] [varchar](255) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[BirthDate] [datetime] NULL,
	[BirthDateRadio] [int] NULL,
	[Gender] [int] NULL,
	[EmployeeIdNr] [varchar](50) NULL,
	[subLevelReportUnit] [varchar](50) NULL,
	[SubLevel_ID] [varchar](32) NULL,
	[AcctMgr] [varchar](20) NULL,
	[WDAClientCode] [varchar](20) NULL,
	[IsClient] [int] NULL,
	[IsCustomer] [int] NULL,
	[IsAssociate] [int] NULL,
	[IsEmployee] [int] NULL,
	[Job_category] [varchar](80) NULL,
	[Invitation] [smallint] NULL,
	[Newsletter] [smallint] NULL,
	[IsEmailInvoice] [int] NULL,
	[EmailInvoiceCC] [varchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Person_Per_ID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Person_Per_ID] ON [dbo].[dtc_cli_Person]
(
	[Per_ID] ASC
)
INCLUDE([LastName],[FirstName],[Address1],[Address2],[City],[State],[Zip],[Country]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
