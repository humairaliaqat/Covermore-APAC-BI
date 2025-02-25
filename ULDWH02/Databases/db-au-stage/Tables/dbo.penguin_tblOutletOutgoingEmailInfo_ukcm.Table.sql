USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletOutgoingEmailInfo_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletOutgoingEmailInfo_ukcm](
	[OutletID] [int] NOT NULL,
	[EmailTypeID] [int] NOT NULL,
	[EmailSubject] [nvarchar](250) NOT NULL,
	[EmailTemplate] [ntext] NULL,
	[EmailFromDisplayName] [nvarchar](50) NULL,
	[EmailFromAddress] [varchar](50) NOT NULL,
	[EmailCertOnPurchase] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
