USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[PenelopeWorkerRCTI]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PenelopeWorkerRCTI](
	[InvoiceID] [int] NOT NULL,
	[LineNum] [int] NULL,
	[InvoiceDate] [date] NULL,
	[TimesheetDate] [date] NULL,
	[EventDate] [date] NULL,
	[Unit] [varchar](10) NULL,
	[Qty] [money] NULL,
	[Rate] [money] NULL,
	[AmtIncGST] [money] NULL,
	[ServiceEventActivitySK] [int] NULL,
	[ServiceEventActivityID] [varchar](100) NULL,
	[ServiceEventSK] [int] NULL,
	[ServiceFileID] [varchar](50) NULL,
	[ServiceFileSK] [int] NULL,
	[DisplayName] [nvarchar](80) NULL,
	[UserID] [varchar](50) NULL,
	[Worker] [nvarchar](201) NULL,
	[DerivedRole] [nvarchar](50) NULL,
	[ReportsTo] [nvarchar](201) NULL,
	[Funder] [nvarchar](250) NULL,
	[Department] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
