USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLMAPCustomerClaim_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLMAPCustomerClaim_au](
	[ID] [int] NOT NULL,
	[KLCLAIM] [int] NOT NULL,
	[OnlineClaimId] [int] NOT NULL,
	[CustomerId] [nvarchar](100) NULL,
	[BinNumber] [nvarchar](50) NULL
) ON [PRIMARY]
GO
