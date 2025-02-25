USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblPolicyTypes_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblPolicyTypes_AU](
	[PolTypeID] [tinyint] NOT NULL,
	[PolCode] [varchar](3) NULL,
	[PolType] [varchar](100) NULL,
	[SortOrder] [int] NULL,
	[Tripspolcode] [varchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_emc_EMC_tblPolicyTypes_AU_PolTypeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_tblPolicyTypes_AU_PolTypeID] ON [dbo].[emc_EMC_tblPolicyTypes_AU]
(
	[PolTypeID] ASC
)
INCLUDE([PolCode],[PolType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
