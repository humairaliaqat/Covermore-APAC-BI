USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[EMCApproval]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EMCApproval](
	[CountryKey] [varchar](2) NOT NULL,
	[EMCApprovalID] [int] NOT NULL,
	[PolicyEMCID] [int] NOT NULL,
	[Condition] [varchar](50) NULL,
	[StatusCode] [varchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_EMCApproval_PolicyEMCID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_EMCApproval_PolicyEMCID] ON [dbo].[EMCApproval]
(
	[PolicyEMCID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
