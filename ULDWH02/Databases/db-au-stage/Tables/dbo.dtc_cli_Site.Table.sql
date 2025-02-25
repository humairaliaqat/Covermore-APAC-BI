USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_Site]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_Site](
	[uniquesiteid] [nvarchar](4000) NULL,
	[sitename] [nvarchar](4000) NULL,
	[parentuniquesiteid] [nvarchar](4000) NULL,
	[siteplaceofservice] [nvarchar](4000) NULL,
	[siteactive] [nvarchar](4000) NULL,
	[sitelocsameasagency] [nvarchar](4000) NULL,
	[siteaddr1] [nvarchar](4000) NULL,
	[siteaddr2] [nvarchar](4000) NULL,
	[sitecity] [nvarchar](4000) NULL,
	[siteprovstate] [nvarchar](4000) NULL,
	[sitecountry] [nvarchar](4000) NULL,
	[sitepczip] [nvarchar](4000) NULL,
	[sitephone] [nvarchar](4000) NULL,
	[sitefax] [nvarchar](4000) NULL,
	[userdefineddropdown1] [nvarchar](4000) NULL,
	[userdefineddropdown2] [nvarchar](4000) NULL,
	[userdefineddropdown3] [nvarchar](4000) NULL,
	[userdefineddropdown4] [nvarchar](4000) NULL,
	[userdefineddropdown5] [nvarchar](4000) NULL,
	[userdefineddropdown6] [nvarchar](4000) NULL,
	[userdefineddropdown7] [nvarchar](4000) NULL,
	[userdefineddropdown8] [nvarchar](4000) NULL,
	[userdefinedmemo1] [nvarchar](4000) NULL,
	[userdefinedmemo2] [nvarchar](4000) NULL,
	[userdefinedtext1] [nvarchar](4000) NULL,
	[userdefinedtext2] [nvarchar](4000) NULL,
	[preexisting] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
