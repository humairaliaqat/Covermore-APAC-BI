USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblSubGroup_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblSubGroup_ukcm](
	[ID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[FSRTypeID] [int] NULL,
	[FSGCategoryID] [int] NULL,
	[LegalEntityName] [nvarchar](100) NOT NULL,
	[ASICNumber] [varchar](50) NOT NULL,
	[ABN] [nvarchar](50) NOT NULL,
	[ASICCheckDate] [datetime] NULL,
	[AgreementDate] [datetime] NULL,
	[Phone] [nvarchar](50) NULL,
	[Fax] [nvarchar](50) NULL,
	[Email] [nvarchar](100) NULL,
	[Street] [nvarchar](100) NULL,
	[Suburb] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[PostCode] [nvarchar](10) NULL,
	[POBox] [nvarchar](50) NULL,
	[MailSuburb] [nvarchar](50) NULL,
	[MailState] [nvarchar](100) NULL,
	[MailPostCode] [nvarchar](10) NULL,
	[B2CWebFolder] [varchar](255) NULL,
	[PaymentProcessAgentId] [tinyint] NULL,
	[DistributorId] [int] NULL,
	[JointVentureId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblSubGroup_ukcm_ID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblSubGroup_ukcm_ID] ON [dbo].[penguin_tblSubGroup_ukcm]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
