USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblContacts_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblContacts_uk](
	[ContactID] [int] NOT NULL,
	[QtID] [int] NULL,
	[ContactType] [char](1) NULL,
	[Title] [varchar](5) NULL,
	[FirstName] [varchar](15) NULL,
	[Surname] [varchar](25) NULL,
	[DirectPh] [varchar](15) NULL
) ON [PRIMARY]
GO
