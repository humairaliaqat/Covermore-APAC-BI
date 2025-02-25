USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_ServiceType]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_ServiceType](
	[ServiceType_ID] [varchar](32) NOT NULL,
	[ServiceType] [varchar](30) NULL,
	[ServiceCategory] [varchar](5) NULL,
	[DefaultBillingType] [varchar](30) NULL,
	[DefaultFixedFeeAmt] [float] NULL,
	[DefaultPrePaidHours] [float] NULL,
	[DefaultPrePaidHourlyRate] [float] NULL,
	[DefaultFeeForServiceHrRate] [float] NULL,
	[InvoiceOnActivity] [varchar](30) NULL,
	[CloseJobOnActivity] [varchar](30) NULL,
	[ExternalPostingCode] [varchar](8) NULL,
	[InterCoPostingCode] [varchar](8) NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](20) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](20) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[GSTFlag] [int] NULL,
	[Survey_ID] [int] NULL,
	[Survey_Title] [varchar](50) NULL,
	[Survey_max_responses] [int] NULL,
	[Survey_link_valid_days] [int] NULL,
	[Survey1_ID] [int] NULL,
	[Survey1_Title] [varchar](50) NULL,
	[Survey1_max_responses] [int] NULL,
	[Survey1_link_valid_days] [int] NULL,
	[UseJobInvoiceText] [bit] NULL,
	[ParentServiceType_id] [varchar](32) NULL,
	[ExcludeFromJobRequestForm] [int] NULL,
	[JobRequestFormMessage] [varchar](200) NULL,
	[JobRequestFormAskIsTrainingRelated] [int] NULL,
	[NotVisibleInJobRequestForm] [int] NULL,
	[Interco_Seg1_code] [varchar](10) NULL,
	[Interco_Seg2_code] [varchar](10) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_ServiceType_ServiceType_ID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_ServiceType_ServiceType_ID] ON [dbo].[dtc_cli_ServiceType]
(
	[ServiceType_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
