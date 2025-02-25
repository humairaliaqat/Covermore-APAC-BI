USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MB_PHI_MarketableSegment]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MB_PHI_MarketableSegment](
	[ID] [nvarchar](255) NULL,
	[First Name] [nvarchar](255) NULL,
	[Surname] [nvarchar](255) NULL,
	[Postcode] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[Mobile Phone] [nvarchar](255) NULL,
	[Home Phone] [nvarchar](255) NULL,
	[Work Phone] [nvarchar](255) NULL,
	[Marketable_Flag] [nvarchar](255) NULL,
	[CustomerID] [bigint] NULL,
	[State] [nvarchar](40) NULL,
	[Age] [int] NULL,
	[Gender] [nvarchar](7) NULL,
	[PrimaryScore] [int] NULL,
	[ClaimScore] [int] NULL,
	[Travel cover type] [nvarchar](125) NULL,
	[AllPolicyCount] [int] NULL,
	[DirectPolicyCount] [int] NULL,
	[AllSales] [money] NULL,
	[DirectSales] [money] NULL,
	[AllClaimCount] [int] NULL,
	[DirectClaimCount] [int] NULL,
	[AllClaimsPaid] [money] NULL,
	[DirectClaimsPaid] [money] NULL,
	[Marketing preference] [varchar](13) NOT NULL,
	[RiskCategory] [varchar](29) NOT NULL,
	[Family status] [varchar](16) NULL
) ON [PRIMARY]
GO
