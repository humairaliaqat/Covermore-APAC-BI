USE [db-au-stage]
GO
/****** Object:  Table [dbo].[PolicySourceID]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PolicySourceID](
	[Country] [varchar](2) NOT NULL,
	[PolicyNo] [int] NOT NULL,
	[OldPolicyNo] [int] NULL,
	[AgencyCode] [varchar](7) NULL,
	[PolicyID] [int] NOT NULL
) ON [PRIMARY]
GO
