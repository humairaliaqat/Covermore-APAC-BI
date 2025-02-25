USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_SECHEQUE_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_SECHEQUE_uk2](
	[SECHEQUE_ID] [int] NOT NULL,
	[SECHEQUE] [bigint] NULL,
	[xxxSEDATE] [datetime] NULL,
	[SECLAIM] [int] NULL,
	[SESTATUS] [varchar](10) NULL,
	[SETRANS] [varchar](4) NULL,
	[SECURR] [varchar](4) NULL,
	[SETOTAL] [money] NULL,
	[SEMANUAL] [bit] NOT NULL,
	[SEPAYEE_ID] [int] NULL,
	[SEADDRESSEE_ID] [int] NULL,
	[SEACCT_ID] [int] NULL,
	[SEREASONCAT_ID] [int] NULL,
	[SEPAYDATE] [datetime] NULL,
	[SEBATCH] [int] NULL,
	[PAYMENTMODE_ID] [int] NULL,
	[SEBOUNCED] [bit] NULL,
	[KLDOMAINID] [int] NOT NULL
) ON [PRIMARY]
GO
