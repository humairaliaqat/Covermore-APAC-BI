USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[verOrganisation]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[verOrganisation](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[OrganisationKey] [int] NOT NULL,
	[OrganisationName] [nvarchar](255) NOT NULL,
	[OrganisationDescription] [nvarchar](255) NOT NULL,
	[Timezone] [nvarchar](50) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_verOrganisation_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_verOrganisation_BIRowID] ON [dbo].[verOrganisation]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_verOrganisation_OrganisationKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verOrganisation_OrganisationKey] ON [dbo].[verOrganisation]
(
	[OrganisationKey] ASC
)
INCLUDE([OrganisationName],[OrganisationDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
