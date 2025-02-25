USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCRMCallComments_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCRMCallComments_autp](
	[CRMCallID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[ConsultantID] [int] NULL,
	[CategoryID] [int] NULL,
	[SubCategoryID] [int] NULL,
	[Duration] [int] NULL,
	[CallDate] [datetime] NOT NULL,
	[ActualCallDate] [datetime] NULL,
	[CallComments] [nvarchar](max) NULL,
	[CRMUserId] [int] NOT NULL,
	[IsXora] [bit] NULL,
	[AgencyCallID] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
