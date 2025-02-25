USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Job]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Job](
	[Job_ID] [varchar](32) NOT NULL,
	[Contract_ID] [varchar](32) NULL,
	[ContractService_ID] [varchar](32) NULL,
	[Org_ID] [varchar](32) NULL,
	[Group_ID] [varchar](32) NULL,
	[Sublevel_ID] [varchar](32) NULL,
	[OpenDate] [datetime] NULL,
	[Status] [varchar](16) NULL,
	[ChangeDate] [datetime] NULL,
	[OpenBy] [varchar](20) NULL,
	[ChangeUser] [varchar](20) NULL,
	[Job_Num] [varchar](20) NULL,
	[Comments] [text] NULL,
	[Per_ID] [varchar](32) NULL,
	[IsFamilyMember] [int] NULL,
	[CostCentre] [varchar](50) NULL,
	[Invoice_Person_ID] [varchar](32) NULL,
	[AssignTo] [varchar](20) NULL,
	[AssignDate] [datetime] NULL,
	[OrgJobLocation_ID] [varchar](32) NULL,
	[BookingPhNo] [varchar](50) NULL,
	[SendEmail] [smallint] NULL,
	[InvoiceText] [text] NULL,
	[ManualRevenueAccrual] [int] NULL,
	[CustomerRefCode] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Job_ContractService_ID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Job_ContractService_ID] ON [dbo].[dtc_cli_Job]
(
	[ContractService_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Job_CostCentre]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Job_CostCentre] ON [dbo].[dtc_cli_Job]
(
	[CostCentre] ASC
)
INCLUDE([Job_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Job_Job_ID_CostCentre]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Job_Job_ID_CostCentre] ON [dbo].[dtc_cli_Job]
(
	[Job_ID] ASC,
	[CostCentre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Job_Job_Num]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Job_Job_Num] ON [dbo].[dtc_cli_Job]
(
	[Job_Num] ASC
)
INCLUDE([Job_ID],[Contract_ID],[ContractService_ID],[Per_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Job_Job_Num_ContractServiceID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Job_Job_Num_ContractServiceID] ON [dbo].[dtc_cli_Job]
(
	[Job_Num] ASC
)
INCLUDE([ContractService_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Job_Org_ID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Job_Org_ID] ON [dbo].[dtc_cli_Job]
(
	[Org_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_Job_Per_ID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_Job_Per_ID] ON [dbo].[dtc_cli_Job]
(
	[Per_ID] ASC
)
INCLUDE([OrgJobLocation_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_job_Per_ID_OpenDate_desc_BookingPhNo]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_job_Per_ID_OpenDate_desc_BookingPhNo] ON [dbo].[dtc_cli_Job]
(
	[Per_ID] ASC,
	[OpenDate] DESC
)
INCLUDE([BookingPhNo],[SendEmail]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
