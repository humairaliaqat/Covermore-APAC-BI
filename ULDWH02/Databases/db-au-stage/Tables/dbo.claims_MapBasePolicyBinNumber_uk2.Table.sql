USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_MapBasePolicyBinNumber_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_MapBasePolicyBinNumber_uk2](
	[ID] [int] NOT NULL,
	[BasePolicyNumber] [nvarchar](500) NULL,
	[BinNumber] [nvarchar](500) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[BrandCode] [varchar](50) NULL,
	[PlanCode] [nvarchar](20) NULL,
	[CardType] [nvarchar](1000) NULL,
	[ProductName] [nvarchar](1000) NULL,
	[IsCardValid] [bit] NOT NULL
) ON [PRIMARY]
GO
