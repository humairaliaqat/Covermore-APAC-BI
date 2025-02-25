USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLUSERSECURITY_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLUSERSECURITY_uk2](
	[ID] [int] NOT NULL,
	[KLUSERID] [int] NOT NULL,
	[KLSECURITYLEVEL] [int] NULL,
	[KLSIGNLEVEL1] [nvarchar](50) NULL,
	[KLSIGNLEVEL2] [nvarchar](50) NULL,
	[KLSIGNLEVEL3] [nvarchar](50) NULL
) ON [PRIMARY]
GO
