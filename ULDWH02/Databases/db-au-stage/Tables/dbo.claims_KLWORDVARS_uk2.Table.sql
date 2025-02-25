USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLWORDVARS_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLWORDVARS_uk2](
	[KV_ID] [int] NOT NULL,
	[KVPAYMENT_ID] [int] NULL,
	[KVWORDING_ID] [int] NULL,
	[KVWORD1] [nvarchar](25) NULL,
	[KVWORD2] [nvarchar](15) NULL,
	[KVWORD3] [nvarchar](15) NULL
) ON [PRIMARY]
GO
