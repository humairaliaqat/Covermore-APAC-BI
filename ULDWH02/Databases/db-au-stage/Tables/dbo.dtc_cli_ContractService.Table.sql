USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_ContractService]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_ContractService](
	[ContractService_id] [varchar](32) NOT NULL,
	[Contract_id] [varchar](32) NULL,
	[ServiceType_Id] [varchar](32) NULL,
	[Description] [varchar](255) NULL,
	[BillingType] [varchar](30) NULL,
	[FixedFeeAmt] [float] NULL,
	[PrePaidHours] [float] NULL,
	[PrePaidHourlyRate] [float] NULL,
	[FeeForServiceHrRate] [float] NULL,
	[ServiceLimit] [float] NULL,
	[MaxServiceLimit] [float] NULL,
	[NoTimeLimit] [int] NULL,
	[AutoInvoiceOnActivity] [int] NULL,
	[ReferenceCode] [int] NULL,
	[FamilyMemberEligible] [int] NULL,
	[RequireWrittenRpt] [int] NULL,
	[JobType] [int] NULL,
	[CostCentre] [int] NULL,
	[EmployeeID] [int] NULL,
	[AllConsultants] [int] NULL,
	[Alert] [varchar](255) NULL,
	[AddDate] [datetime] NULL,
	[AddUser] [varchar](20) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](20) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[GSTFlag] [int] NULL,
	[Survey_override] [int] NULL,
	[Survey_ID] [int] NULL,
	[Survey_Title] [varchar](50) NULL,
	[Inactive] [smallint] NULL,
	[Survey1_override] [smallint] NULL,
	[Survey1_ID] [int] NULL,
	[Survey1_Title] [varchar](50) NULL,
	[IsNotified] [int] NULL,
	[InvoiceType] [int] NOT NULL,
	[Invoice_Person_ID] [varchar](50) NULL,
	[SendEmailNotifications] [int] NULL,
	[RequireSummaryRpt] [int] NULL,
	[PsychologistOnly] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_ContractService_ContractService_ID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_ContractService_ContractService_ID] ON [dbo].[dtc_cli_ContractService]
(
	[ContractService_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_ContractService_ServiceType_ID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_ContractService_ServiceType_ID] ON [dbo].[dtc_cli_ContractService]
(
	[ServiceType_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
