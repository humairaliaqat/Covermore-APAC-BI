USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_usrCDGQuoteBot]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_usrCDGQuoteBot](
	[analyticssessionid] [bigint] NULL,
	[transactiontime] [datetime2](7) NULL,
	[batchcreatetime] [datetime2](7) NULL
) ON [PRIMARY]
GO
