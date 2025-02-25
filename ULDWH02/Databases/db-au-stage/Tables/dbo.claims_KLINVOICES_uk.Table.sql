USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLINVOICES_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLINVOICES_uk](
	[KV_ID] [int] NOT NULL,
	[KVPROV_ID] [int] NULL,
	[KVCLAIM_ID] [int] NULL,
	[KVINVOICE] [varchar](50) NULL,
	[KVTOTAL] [money] NULL,
	[KVBATCH] [int] NULL,
	[KVINVDATE] [datetime] NULL,
	[KVCURR] [varchar](3) NULL,
	[KVDFTPAYEE_ID] [int] NULL,
	[KVGST] [money] NULL,
	[KVEVENT_ID] [int] NULL
) ON [PRIMARY]
GO
