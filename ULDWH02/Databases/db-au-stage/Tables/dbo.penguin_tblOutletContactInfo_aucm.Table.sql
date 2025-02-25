USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletContactInfo_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletContactInfo_aucm](
	[OutletID] [int] NOT NULL,
	[Title] [nvarchar](100) NULL,
	[Initial] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[ManagerEmail] [nvarchar](100) NULL,
	[Phone] [nvarchar](50) NULL,
	[Fax] [nvarchar](50) NULL,
	[Email] [nvarchar](100) NULL,
	[Street] [nvarchar](100) NULL,
	[Suburb] [nvarchar](52) NULL,
	[State] [nvarchar](100) NULL,
	[PostCode] [nvarchar](50) NULL,
	[POBox] [nvarchar](100) NULL,
	[MailSuburb] [nvarchar](52) NULL,
	[MailState] [nvarchar](100) NULL,
	[MailPostCode] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutletContactInfo_aucm_OutletID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblOutletContactInfo_aucm_OutletID] ON [dbo].[penguin_tblOutletContactInfo_aucm]
(
	[OutletID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
