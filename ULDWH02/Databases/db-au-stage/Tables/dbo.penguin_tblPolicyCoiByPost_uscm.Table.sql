USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyCoiByPost_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyCoiByPost_uscm](
	[ID] [int] NOT NULL,
	[POLICYNUMBER] [varchar](25) NOT NULL,
	[CREATEDATETIME] [datetime] NOT NULL,
	[UPDATEDATETIME] [datetime] NOT NULL,
	[POSTCODE] [varchar](50) NULL,
	[ADDRESSLINE1] [nvarchar](200) NULL,
	[ADDRESSLINE2] [nvarchar](200) NULL,
	[SUBURB] [nvarchar](100) NULL,
	[STATE] [nvarchar](200) NULL,
	[COUNTRYNAME] [nvarchar](200) NULL,
	[COUNTRYCODE] [char](3) NULL,
	[COMMENTS] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
