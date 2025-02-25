USE [db-au-stage]
GO
/****** Object:  Table [dbo].[PolicyLineage]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PolicyLineage](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[AncestorPolicyKey] [varchar](41) NULL,
	[AncestorPolicyNo] [int] NULL,
	[AncestorCustomerKey] [varchar](41) NULL,
	[ParentPolicyKey] [varchar](41) NULL,
	[ParentPolicyNo] [int] NULL,
	[PolicyKey] [varchar](41) NULL,
	[PolicyNo] [int] NULL,
	[CustomerKey] [varchar](41) NULL,
	[Depth] [int] NULL
) ON [PRIMARY]
GO
