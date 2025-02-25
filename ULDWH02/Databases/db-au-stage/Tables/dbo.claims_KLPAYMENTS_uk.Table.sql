USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLPAYMENTS_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLPAYMENTS_uk](
	[KPAY_ID] [int] NOT NULL,
	[KPCLAIM_ID] [int] NULL,
	[KPADDRSEE_ID] [int] NULL,
	[KPPROV_ID] [int] NULL,
	[KPCHQ_ID] [int] NULL,
	[KPEVENT_ID] [int] NULL,
	[KPIS_ID] [int] NULL,
	[KPINV_ID] [int] NULL,
	[KPAUTHOFF_ID] [int] NULL,
	[KPCHECKOFF_ID] [int] NULL,
	[KPWORDING_ID] [int] NULL,
	[KPMETHOD] [varchar](3) NULL,
	[KPCREATEDBY_ID] [int] NULL,
	[KPMODIFIEDBY_ID] [int] NULL,
	[KPNUM] [smallint] NULL,
	[KPBILLAMT] [money] NULL,
	[KPCURR] [varchar](3) NULL,
	[KPRATE] [float] NULL,
	[KPAUD] [money] NULL,
	[KPDEPR] [float] NULL,
	[KPDEPV] [money] NULL,
	[KPOTHER] [money] NULL,
	[KPOTHERDESC] [varchar](50) NULL,
	[KPSTATUS] [varchar](4) NULL,
	[KPGST] [money] NULL,
	[KPMAXPAY] [money] NULL,
	[KPPAYAMT] [money] NULL,
	[KPPAYEE] [varchar](50) NULL,
	[KPMODDT] [datetime] NULL,
	[KPPROPDT] [datetime] NULL,
	[KPPAYEE_ID] [int] NULL,
	[KPBATCH] [int] NULL,
	[KPDFTPAYEE_ID] [int] NULL,
	[KPGSTADJ] [money] NULL,
	[KPEXCESS] [money] NULL,
	[KPCREATEDDT] [datetime] NULL,
	[KPGOODSERV] [varchar](1) NULL,
	[KPTPLOC] [varchar](3) NULL,
	[KPGSTINC] [bit] NOT NULL,
	[KPPAYEETYPE] [varchar](1) NULL,
	[KPCHEQUENUM] [int] NULL,
	[KPCHECKSTATUS] [varchar](4) NULL,
	[KPBANKREF] [varchar](20) NULL
) ON [PRIMARY]
GO
