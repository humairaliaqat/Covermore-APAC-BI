USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[SurveyBrand_Info_Medallia_CHG0040020]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SurveyBrand_Info_Medallia_CHG0040020](
	[Rowid] [int] NULL,
	[Journey] [varchar](500) NULL,
	[Survey_Brand] [varchar](200) NULL,
	[Account_Manager_Name] [varchar](500) NULL,
	[Account_Manager_EMail] [varchar](500) NULL,
	[Account_Manager_EMPId] [varchar](500) NULL,
	[OutletKey] [varchar](500) NULL,
	[GroupName] [varchar](500) NULL,
	[SuperGroup] [varchar](500) NULL,
	[SubGroup] [varchar](500) NULL,
	[Active] [varchar](500) NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[SurveyBrand_Logo] [varchar](250) NULL,
	[CustomerEmail] [varchar](500) NULL,
	[Voc_Status] [int] NULL,
	[Country] [varchar](50) NULL,
	[Remarks] [varchar](2000) NULL
) ON [PRIMARY]
GO
