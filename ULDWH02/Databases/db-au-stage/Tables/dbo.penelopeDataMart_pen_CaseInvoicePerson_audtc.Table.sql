USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelopeDataMart_pen_CaseInvoicePerson_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelopeDataMart_pen_CaseInvoicePerson_audtc](
	[caseid] [int] NOT NULL,
	[bluebookid] [int] NULL,
	[departmentid] [int] NULL,
	[ServiceFileID] [int] NULL,
	[ModifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
